import 'dart:typed_data';

import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/admin/domain/admin.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/catalog/data/mock_catalog_repository.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/domain/catalog_remote.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/domain/orders_remote.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

/// Implementasi in-memory dari kontrak async; aturannya meniru fungsi SQL
/// (harga dari katalog, cek stok, transisi status valid).
class InMemoryCatalogRemote implements CatalogRemote {
  InMemoryCatalogRemote()
      : _products = MockCatalogRepository().products().toList(),
        _categories = MockCatalogRepository().categories().toList();
  final List<Product> _products;
  final List<String> _categories;
  final inactive = <String>{};

  @override
  Future<List<Product>> listProducts({String? query, String? category, bool mine = false}) async {
    final q = (query ?? '').trim().toLowerCase();
    return _products
        .where((p) => !inactive.contains(p.id) && (category == null || category == 'Semua' || p.category == category) && (q.isEmpty || p.name.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Future<Product?> getProduct(String id) async => _products.where((p) => p.id == id).firstOrNull;

  @override
  Future<List<String>> categories() async => List.of(_categories);

  @override
  Future<Product> saveProduct(Product p) async {
    final i = _products.indexWhere((e) => e.id == p.id);
    if (i >= 0) {
      _products[i] = p;
    } else {
      _products.add(p);
    }
    return p;
  }

  @override
  Future<void> deleteProduct(String id) async => _products.removeWhere((p) => p.id == id);

  @override
  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) throw const AppError.validation('Nama kategori wajib diisi.');
    if (!_categories.contains(name.trim())) _categories.add(name.trim());
  }

  @override
  Future<String> uploadProductImage(Uint8List bytes, {required String extension}) async {
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension.toLowerCase())) throw const AppError.validation('Format gambar harus JPG, PNG, atau WebP.');
    if (bytes.length > 2 * 1024 * 1024) throw const AppError.validation('Ukuran gambar maksimal 2 MB.');
    return 'https://example.test/product-images/u1/${bytes.length}.$extension';
  }
}

class InMemoryOrderRemote implements OrderRemote {
  InMemoryOrderRemote(this.catalog);
  final InMemoryCatalogRemote catalog;
  final _orders = <Order>[];
  final _reviews = <String, List<Review>>{};
  var _seq = 1100;

  @override
  Future<List<Order>> placeOrder({required List<CartLine> lines, required PaymentMethod payment, required ShippingMethod shipping, required Address address, String note = ''}) async {
    if (lines.isEmpty) throw const AppError.validation('Keranjang kosong');
    final built = <OrderLine>[];
    for (final l in lines) {
      final p = await catalog.getProduct(l.product.id);
      final v = p?.variations.where((x) => x.id == l.variation.id).firstOrNull;
      if (p == null || v == null) throw const AppError.validation('Produk tidak tersedia');
      if (v.stock < l.qty) throw AppError.validation('Stok ${p.name} tidak cukup');
      // Harga dari katalog, bukan dari klien.
      built.add(OrderLine(product: p, variation: v, qty: l.qty, unitPrice: p.priceOf(v)));
    }
    for (final l in built) {
      final p = (await catalog.getProduct(l.product.id))!;
      await catalog.saveProduct(p.copyWith(variations: [for (final v in p.variations) v.id == l.variation.id ? v.copyWith(stock: v.stock - l.qty) : v]));
    }
    final o = Order(
      id: 'INV-${++_seq}',
      remoteId: 'r$_seq',
      lines: built,
      status: OrderStatus.menunggu,
      payment: payment,
      shipping: shipping,
      address: address,
      shippingFee: shipping == ShippingMethod.jemput ? 0 : 10000,
      createdAt: DateTime(2026),
      buyerName: 'Tes',
      note: note,
    );
    _orders.insert(0, o);
    return [o];
  }

  @override
  Future<List<Order>> listOrders() async => List.of(_orders);

  @override
  Future<Order?> getOrder(String code) async => _orders.where((o) => o.id == code).firstOrNull;

  @override
  Future<Order> updateStatus(Order order, OrderStatus next, {String? reason, String? photoRef, String? note}) async {
    final i = _orders.indexWhere((o) => o.id == order.id);
    final o = _orders[i];
    const allowed = {
      OrderStatus.menunggu: {OrderStatus.dikemas, OrderStatus.ditolak, OrderStatus.dibatalkan},
      OrderStatus.dikemas: {OrderStatus.dikirim},
      OrderStatus.dikirim: {OrderStatus.selesai},
      OrderStatus.ditolak: {OrderStatus.menunggu, OrderStatus.diarsipkan},
      OrderStatus.selesai: {OrderStatus.diarsipkan},
      OrderStatus.dibatalkan: {OrderStatus.diarsipkan},
    };
    if (!(allowed[o.status]?.contains(next) ?? false)) throw AppError.validation('Transisi status ${o.status.name} -> ${next.name} tidak diizinkan');
    if (next == OrderStatus.dikemas && o.needsProof) throw const AppError.validation('Bukti pembayaran belum diunggah');
    if (next == OrderStatus.dikirim && (photoRef ?? '').isEmpty) throw const AppError.validation('Bukti pengiriman wajib');
    return _orders[i] = o.copyWith(status: next, rejectReason: reason, shipmentPhoto: photoRef, archivedFrom: next == OrderStatus.diarsipkan ? o.status : null);
  }

  @override
  Future<void> setPaymentProof(Order order, String ref) async {
    final i = _orders.indexWhere((o) => o.id == order.id);
    _orders[i] = _orders[i].copyWith(proofUploaded: true, paymentStatus: PaymentStatus.menungguVerifikasi);
  }

  @override
  Future<void> submitReview(Order order, int rating, String text) async {
    final o = _orders.firstWhere((x) => x.id == order.id);
    final done = o.status == OrderStatus.selesai || (o.status == OrderStatus.diarsipkan && o.archivedFrom == OrderStatus.selesai);
    if (!done) throw const AppError.permission();
    if (rating < 1 || rating > 5) throw const AppError.validation('Rating harus 1 sampai 5.');
    for (final l in o.lines) {
      _reviews.putIfAbsent(l.product.id, () => []).add(Review(author: o.buyerName, rating: rating, text: text));
    }
  }

  @override
  Future<List<Review>> reviewsFor(String productId) async => _reviews[productId] ?? const [];
}

class InMemoryAdminRemote implements AdminRemote {
  final _users = [
    const AppUser(id: 'u1', name: 'Budi', email: 'budi@example.test', phone: '', role: UserRole.buyer),
    const AppUser(id: 'u2', name: 'Sari', email: 'sari@example.test', phone: '', role: UserRole.seller),
  ];
  final _products = [const AdminProduct(id: 'p1', name: 'Ikan Nila', shopName: 'Toko A', isActive: true)];

  @override
  Future<List<AppUser>> users({String? query}) async {
    final q = (query ?? '').toLowerCase();
    return _users.where((u) => q.isEmpty || u.name.toLowerCase().contains(q) || u.email.contains(q)).toList();
  }

  @override
  Future<void> setUserActive(String userId, bool active) async {
    final i = _users.indexWhere((u) => u.id == userId);
    final u = _users[i];
    _users[i] = AppUser(id: u.id, name: u.name, email: u.email, phone: u.phone, role: u.role, isActive: active);
  }

  @override
  Future<List<AdminOrder>> orders() async => const [];

  @override
  Future<List<AdminProduct>> products({String? query}) async {
    final q = (query ?? '').toLowerCase();
    return _products.where((p) => q.isEmpty || p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Future<void> setProductActive(String productId, bool active) async {
    final i = _products.indexWhere((p) => p.id == productId);
    final p = _products[i];
    _products[i] = AdminProduct(id: p.id, name: p.name, shopName: p.shopName, isActive: active);
  }
}
