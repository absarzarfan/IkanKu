import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/orders/data/mock_order_repository.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) => MockOrderRepository());

/// Alur status: menunggu -> (terima) dikemas -> (kirim + bukti) dikirim -> selesai.
/// menunggu -> ditolak (penjual) -> (bayar ulang) menunggu; menunggu -> dibatalkan (pembeli).
class OrdersNotifier extends Notifier<List<Order>> {
  OrderRepository get _repo => ref.read(orderRepositoryProvider);

  @override
  List<Order> build() => _repo.orders();

  void _set(List<Order> v) {
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

  bool cancel(String id) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.menunggu) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.dibatalkan));
    return true;
  }

  void uploadProof(String id) => _update(id, (o) => o.copyWith(proofUploaded: true));

  /// Penjual menerima pesanan. Transfer wajib punya bukti bayar.
  bool accept(String id) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.menunggu || o.needsProof) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.dikemas));
    return true;
  }

  bool reject(String id, String reason) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.menunggu) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.ditolak, rejectReason: reason.trim().isEmpty ? 'Pesanan ditolak penjual' : reason.trim()));
    return true;
  }

  bool ship(String id, {required String photo, String note = ''}) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.dikemas || photo.isEmpty) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.dikirim, shipmentPhoto: photo, shipmentNote: note));
    return true;
  }

  bool complete(String id) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.dikirim) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.selesai));
    return true;
  }

  bool archive(String id) {
    final o = byId(id);
    if (o == null || o.status == OrderStatus.diarsipkan || o.status == OrderStatus.menunggu || o.status == OrderStatus.dikemas || o.status == OrderStatus.dikirim) return false;
    _update(id, (o) => o.copyWith(status: OrderStatus.diarsipkan, archivedFrom: o.status));
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
        ));
    return true;
  }

  bool review(String id, int rating, String text) {
    final o = byId(id);
    if (o == null || o.status != OrderStatus.selesai || o.review != null || rating < 1 || rating > 5) return false;
    _update(id, (o) => o.copyWith(review: Review(author: o.buyerName, rating: rating, text: text.trim(), orderId: id)));
    return true;
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

/// Pesanan per tab pembeli.
List<Order> buyerOrders(List<Order> all, OrderStatus s) => all.where((o) => o.status == s).toList();
