import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/data/backend.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/catalog/data/mock_catalog_repository.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/domain/catalog_remote.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => MockCatalogRepository());

class CatalogState {
  const CatalogState({required this.products, required this.categories});
  final List<Product> products;
  final List<String> categories;

  Product? byId(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Product> search(String q, {String? category}) {
    final query = q.trim().toLowerCase();
    return products.where((p) {
      final okCat = category == null || category == 'Semua' || p.category == category;
      final okQ = query.isEmpty || p.name.toLowerCase().contains(query) || p.category.toLowerCase().contains(query);
      return okCat && okQ;
    }).toList();
  }
}

/// Id produk yang dinonaktifkan admin (hanya mode mock); produk ini tidak tampil di katalog.
class InactiveProductsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};
  void setActive(String id, bool active) => state = active ? ({...state}..remove(id)) : {...state, id};
}

final inactiveProductsProvider = NotifierProvider<InactiveProductsNotifier, Set<String>>(InactiveProductsNotifier.new);

class CatalogNotifier extends Notifier<CatalogState> {
  CatalogRepository get _repo => ref.read(catalogRepositoryProvider);

  CatalogRemote? get _remote => ref.read(catalogRemoteProvider);

  @override
  CatalogState build() {
    if (ref.read(catalogRemoteProvider) == null) {
      final hidden = ref.watch(inactiveProductsProvider);
      return CatalogState(products: [for (final p in _repo.products()) if (!hidden.contains(p.id)) p], categories: _repo.categories());
    }
    // Mode Supabase: mulai kosong, muat dari server saat login dan setiap pengguna berganti.
    ref.listen(authProvider, (_, user) {
      if (user == null) {
        state = const CatalogState(products: [], categories: []);
      } else {
        refresh();
      }
    });
    if (ref.read(authProvider) != null) Future.microtask(refresh);
    return const CatalogState(products: [], categories: []);
  }

  /// Memuat ulang dari backend (penjual: produk tokonya; lainnya: produk aktif).
  Future<void> refresh() async {
    final r = _remote;
    if (r == null) return;
    try {
      final mine = ref.read(authProvider)?.role == UserRole.seller;
      final results = await Future.wait([r.listProducts(mine: mine), r.categories()]);
      state = CatalogState(products: results[0] as List<Product>, categories: results[1] as List<String>);
    } catch (e) {
      ref.read(backendErrorProvider.notifier).report(e);
    }
  }

  /// Jalankan tulis ke backend; hasil akhir selalu disamakan dengan server (rollback bila gagal).
  Future<void> _run(Future<void> Function(CatalogRemote r) f) async {
    final r = _remote;
    if (r == null) return;
    try {
      await f(r);
    } catch (e) {
      ref.read(backendErrorProvider.notifier).report(e);
    }
    await refresh();
  }

  void _commit(List<Product> p, List<String> c) {
    if (_remote != null) {
      state = CatalogState(products: p, categories: c);
      return;
    }
    _repo.saveProducts(p);
    _repo.saveCategories(c);
    final hidden = ref.read(inactiveProductsProvider);
    state = CatalogState(products: [for (final p in _repo.products()) if (!hidden.contains(p.id)) p], categories: _repo.categories());
  }

  void upsertProduct(Product product) {
    final list = List.of(state.products);
    final i = list.indexWhere((e) => e.id == product.id);
    if (i >= 0) {
      list[i] = product;
    } else {
      list.add(product);
    }
    _commit(list, state.categories);
    _run((r) => r.saveProduct(product));
  }

  void deleteProduct(String id) {
    _commit(state.products.where((p) => p.id != id).toList(), state.categories);
    _run((r) => r.deleteProduct(id));
  }

  void addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty || state.categories.contains(n)) return;
    _commit(state.products, [...state.categories, n]);
    _run((r) => r.addCategory(n));
  }

  /// Ubah/hapus kategori hanya admin di backend (RLS); mode Supabase menolak di sisi klien.
  bool _categoryEditBlocked() {
    if (_remote == null) return false;
    ref.read(backendErrorProvider.notifier).report(const AppError.permission('Hanya admin yang dapat mengubah atau menghapus kategori.'));
    return true;
  }

  void renameCategory(String old, String name) {
    final n = name.trim();
    if (n.isEmpty || _categoryEditBlocked()) return;
    _commit(
      state.products.map((p) => p.category == old ? p.copyWith(category: n) : p).toList(),
      state.categories.map((c) => c == old ? n : c).toList(),
    );
  }

  void deleteCategory(String name) {
    if (_categoryEditBlocked()) return;
    _commit(state.products, state.categories.where((c) => c != name).toList());
  }

  void setDiscount(String productId, int percent) {
    final p = state.byId(productId);
    if (p != null) upsertProduct(p.copyWith(discountPercent: percent.clamp(0, 90)));
  }
}

final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(CatalogNotifier.new);
