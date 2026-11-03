import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/features/catalog/data/mock_catalog_repository.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';

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

class CatalogNotifier extends Notifier<CatalogState> {
  CatalogRepository get _repo => ref.read(catalogRepositoryProvider);

  @override
  CatalogState build() => CatalogState(products: _repo.products(), categories: _repo.categories());

  void _commit(List<Product> p, List<String> c) {
    _repo.saveProducts(p);
    _repo.saveCategories(c);
    state = CatalogState(products: _repo.products(), categories: _repo.categories());
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
  }

  void deleteProduct(String id) => _commit(state.products.where((p) => p.id != id).toList(), state.categories);

  void addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty || state.categories.contains(n)) return;
    _commit(state.products, [...state.categories, n]);
  }

  void renameCategory(String old, String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    _commit(
      state.products.map((p) => p.category == old ? p.copyWith(category: n) : p).toList(),
      state.categories.map((c) => c == old ? n : c).toList(),
    );
  }

  void deleteCategory(String name) => _commit(state.products, state.categories.where((c) => c != name).toList());

  void setDiscount(String productId, int percent) {
    final p = state.byId(productId);
    if (p != null) upsertProduct(p.copyWith(discountPercent: percent.clamp(0, 90)));
  }
}

final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(CatalogNotifier.new);
