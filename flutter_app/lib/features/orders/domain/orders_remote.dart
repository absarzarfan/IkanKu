import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

/// Kontrak pesanan, keranjang, dan ulasan di backend.
abstract class OrderRemote {
  /// Membuat pesanan lewat RPC place_order. Harga dibaca server, klien tidak mengirim harga.
  /// Mengembalikan pesanan yang dibuat (satu per toko).
  Future<List<Order>> placeOrder({
    required List<CartLine> lines,
    required PaymentMethod payment,
    required ShippingMethod shipping,
    required Address address,
    String note = '',
  });

  /// Pesanan milik pembeli / pesanan toko penjual (sesuai peran pemanggil dan RLS).
  Future<List<Order>> listOrders();
  Future<Order?> getOrder(String code);

  /// Ubah status lewat RPC; server menolak transisi yang tidak valid.
  Future<Order> updateStatus(Order order, OrderStatus next, {String? reason, String? photoRef, String? note});
  Future<void> setPaymentProof(Order order, String ref);

  /// Satu ulasan per item pesanan selesai; semua item pesanan diberi ulasan yang sama.
  Future<void> submitReview(Order order, int rating, String text);
  Future<List<Review>> reviewsFor(String productId);
}

/// Keranjang server (tabel cart_items).
abstract class CartRemote {
  Future<List<CartLine>> list();
  Future<void> setQty(Variation variation, int qty);
  Future<void> remove(Variation variation);
  Future<void> clear();
}
