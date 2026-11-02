import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/data/backend.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/orders/data/mock_order_repository.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/domain/orders_remote.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) => MockOrderRepository());

/// Alur status: menunggu -> (terima) dikemas -> (kirim + bukti) dikirim -> selesai.
/// menunggu -> ditolak (penjual) -> (bayar ulang) menunggu; menunggu -> dibatalkan (pembeli).
class OrdersNotifier extends Notifier<List<Order>> {
  OrderRepository get _repo => ref.read(orderRepositoryProvider);

  OrderRemote? get _remote => ref.read(orderRemoteProvider);

  @override
  List<Order> build() {
    if (ref.read(orderRemoteProvider) == null) return _repo.orders();
    // Mode Supabase: kosong sampai dimuat dari server; dikosongkan saat keluar.
    ref.listen(authProvider, (_, user) {
      if (user == null) {
        state = const [];
      } else {
        refresh();
      }
    });
    if (ref.read(authProvider) != null) Future.microtask(refresh);
    return const [];
  }

  /// Memuat ulang pesanan dari server (pembeli: pesanannya; penjual: pesanan tokonya).
  Future<void> refresh() async {
    final r = _remote;
    if (r == null) return;
    try {
      state = await r.listOrders();
    } catch (e) {
      ref.read(backendErrorProvider.notifier).report(e);
    }
  }

  /// Kirim perubahan ke server lalu samakan dengan server (rollback otomatis bila ditolak).
  void _sync(Order before, Future<void> Function(OrderRemote r, Order o) f) {
    final r = _remote;
    if (r == null) return;
    () async {
      try {
        await f(r, before);
      } catch (e) {
        ref.read(backendErrorProvider.notifier).report(e);
      }
      await refresh();
    }();
  }

  void _set(List<Order> v) {
    if (_remote != null) {
      state = List.unmodifiable(v);
      return;
    }
    _repo.save(v);
    state = _repo.orders();
  }

  Order? byId(String id) {
    for (final o in state) {
      if (o.id == id) return o;
    }
    return null;
  }

  void _update(String id, Order Function(Order) f) => _set([for (final o in state) o.id == id ? f(o) : o]);

  int _seq = 1100;

  Order place({
    required List<OrderLine> lines,
    required PaymentMethod payment,
    required ShippingMethod shipping,
    required Address address,
    required int shippingFee,
    required String buyerName,
    String note = '',
  }) {
    if (lines.isEmpty) throw StateError('Tidak ada item');
    final o = Order(
      id: 'INV-${++_seq}',
      lines: lines,
      status: OrderStatus.menunggu,
      payment: payment,
      shipping: shipping,
      address: address,
      shippingFee: shipping == ShippingMethod.jemput ? 0 : shippingFee,
      createdAt: DateTime.now(),
      buyerName: buyerName,
      note: note,
    );
    _set([o, ...state]);
    return o;
  }

  /// Checkout: mode mock membuat pesanan lokal; mode Supabase memanggil RPC place_order (harga dari server).
  Future<Order> placeAsync({
    required List<OrderLine> lines,
    required PaymentMethod payment,
    required ShippingMethod shipping,
    required Address address,
    required int shippingFee,
    required String buyerName,
    String note = '',
  }) async {
    final r = _remote;
    if (r == null) return place(lines: lines, payment: payment, shipping: shipping, address: address, shippingFee: shippingFee, buyerName: buyerName, note: note);
    final cart = [for (final l in lines) CartLine(product: l.product, variation: l.variation, qty: l.qty)];
    final created = await r.placeOrder(lines: cart, payment: payment, shipping: shipping, address: address, note: note);
    state = [...created, ...state.where((o) => !created.any((c) => c.id == o.id))];
    refresh();
    return created.first;
  }

  bool cancel(String id) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.menunggu) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.dibatalkan));
    _sync(o, (r, x) => r.updateStatus(x, OrderStatus.dibatalkan));
    return true;
  }

  /// Unggah berkas bukti belum dibuat: hanya referensi teks yang dikirim (lihat docs/decisions.md).
  void uploadProof(String id) {
    final o = byId(id);
    _update(id, (o) => o.copyWith(proofUploaded: true));
    if (o != null) _sync(o, (r, x) => r.setPaymentProof(x, 'simulated-proof'));
  }

  /// Penjual menerima pesanan. Transfer wajib punya bukti bayar.
  bool accept(String id) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.menunggu || o.needsProof) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.dikemas));
    _sync(o, (r, x) => r.updateStatus(x, OrderStatus.dikemas));
    return true;
  }

  bool reject(String id, String reason) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.menunggu) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.ditolak, rejectReason: reason.trim().isEmpty ? 'Pesanan ditolak penjual' : reason.trim()));
    _sync(o, (r, x) => r.updateStatus(x, OrderStatus.ditolak, reason: reason.trim()));
    return true;
  }

  bool ship(String id, {required String photo, String note = ''}) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.dikemas || photo.isEmpty) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.dikirim, shipmentPhoto: photo, shipmentNote: note));
    _sync(o, (r, x) => r.updateStatus(x, OrderStatus.dikirim, photoRef: photo, note: note));
    return true;
  }

  bool complete(String id) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.dikirim) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.selesai));
    _sync(o, (r, x) => r.updateStatus(x, OrderStatus.selesai));
    return true;
  }

  bool archive(String id) {
    final o = byId(id);
    if (o == null || o.status == OrderStatus.diarsipkan || o.status == OrderStatus.menunggu || o.status == OrderStatus.dikemas || o.status == OrderStatus.dikirim) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.diarsipkan, archivedFrom: o.status));
    _sync(o, (r, x) => r.updateStatus(x, OrderStatus.diarsipkan));
    return true;
  }

  /// Pembeli membayar ulang pesanan yang ditolak.
  bool repay(String id) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.ditolak) return false;
    _update(id, (o) => Order(
          id: o.id,
          lines: o.lines,
          status: OrderStatus.menunggu,
          payment: o.payment,
          shipping: o.shipping,
          address: o.address,
          shippingFee: o.shippingFee,
          createdAt: o.createdAt,
          buyerName: o.buyerName,
          note: o.note,
          proofUploaded: true,
          remoteId: o.remoteId,
        ));
    _sync(o, (r, x) => r.updateStatus(x, OrderStatus.menunggu));
    return true;
  }

  bool review(String id, int rating, String text) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.selesai || o.review != null || rating < 1 || rating > 5) return false;
    _update(id, (o) => o.copyWith(review: Review(author: o.buyerName, rating: rating, text: text.trim(), orderId: id)));
    _sync(o, (r, x) => r.submitReview(x, rating, text));
    return true;
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

/// Pesanan per tab pembeli.
List<Order> buyerOrders(List<Order> all, OrderStatus s) => all.where((o) => o.status == s).toList();
