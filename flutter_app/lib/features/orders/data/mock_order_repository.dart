import 'package:ikanku/features/catalog/data/mock_catalog_repository.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

const _demoAddress = Address(id: 'a-demo', recipient: 'Miftahul Fazra', phone: '6285274088734', street: 'Jl. Nusantara No. 12', area: Kecamatan('Sekupang', 'Batam', '29425'), isPrimary: true);

OrderLine _line(Product p, int vi, int qty) {
  final v = p.variations[vi];
  return OrderLine(product: p, variation: v, qty: qty, unitPrice: p.priceOf(v));
}

Order _order(String id, Product p, OrderStatus s, {PaymentMethod pay = PaymentMethod.transfer, bool proof = true, String? reason}) => Order(
      id: id,
      lines: [_line(p, 1, 1)],
      status: s,
      payment: pay,
      shipping: ShippingMethod.kirim,
      address: _demoAddress,
      shippingFee: 10000,
      createdAt: DateTime(2026, 10, 20),
      buyerName: 'Miftahul Fazra',
      proofUploaded: proof,
      rejectReason: reason,
    );

class MockOrderRepository implements OrderRepository {
  MockOrderRepository() {
    final p = MockCatalogRepository().products();
    _orders = [
      _order('INV-1001', p[0], OrderStatus.menunggu),
      _order('INV-1002', p[1], OrderStatus.dikemas),
      _order('INV-1003', p[2], OrderStatus.dikirim),
      _order('INV-1004', p[6], OrderStatus.selesai),
      _order('INV-1005', p[3], OrderStatus.ditolak, reason: 'Bukti pembayaran anda tidak valid'),
      _order('INV-1006', p[7], OrderStatus.dibatalkan, pay: PaymentMethod.cod, proof: false),
    ];
  }

  late List<Order> _orders;

  @override
  List<Order> orders() => List.unmodifiable(_orders);

  @override
  void save(List<Order> orders) => _orders = List.of(orders);
}

