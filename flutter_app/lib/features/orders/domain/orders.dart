import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

enum OrderStatus {
  menunggu('Menunggu'),
  dikemas('Dikemas'),
  dikirim('Dikirim'),
  selesai('Selesai'),
  ditolak('Ditolak'),
  dibatalkan('Dibatalkan'),
  diarsipkan('Diarsipkan');

  const OrderStatus(this.label);
  final String label;
}

enum PaymentMethod { transfer, cod }

enum ShippingMethod { kirim, jemput }

class OrderLine {
  const OrderLine({required this.product, required this.variation, required this.qty, required this.unitPrice});
  final Product product;
  final Variation variation;
  final int qty;
  final int unitPrice;

  int get total => unitPrice * qty;
}

class Order {
  const Order({
    required this.id,
    required this.lines,
    required this.status,
    required this.payment,
    required this.shipping,
    required this.address,
    required this.shippingFee,
    required this.createdAt,
    required this.buyerName,
    this.note = '',
    this.rejectReason,
    this.proofUploaded = false,
    this.shipmentPhoto,
    this.shipmentNote = '',
    this.review,
    this.archivedFrom,
  });

  final String id;
  final List<OrderLine> lines;
  final OrderStatus status;
  final PaymentMethod payment;
  final ShippingMethod shipping;
  final Address address;
  final int shippingFee;
  final DateTime createdAt;
  final String buyerName;
  final String note;
  final String? rejectReason;
  final bool proofUploaded;
  final String? shipmentPhoto;
  final String shipmentNote;
  final Review? review;
  final OrderStatus? archivedFrom;

  int get subtotal => lines.fold(0, (s, l) => s + l.total);
  int get total => subtotal + shippingFee;

  /// Transfer harus diberi bukti bayar sebelum penjual bisa memverifikasi.
  bool get needsProof => payment == PaymentMethod.transfer && !proofUploaded;

  Order copyWith({
    OrderStatus? status,
    String? rejectReason,
    bool? proofUploaded,
    String? shipmentPhoto,
    String? shipmentNote,
    Review? review,
    OrderStatus? archivedFrom,
    PaymentMethod? payment,
  }) =>
      Order(
        id: id,
        lines: lines,
        status: status ?? this.status,
        payment: payment ?? this.payment,
        shipping: shipping,
        address: address,
        shippingFee: shippingFee,
        createdAt: createdAt,
        buyerName: buyerName,
        note: note,
        rejectReason: rejectReason ?? this.rejectReason,
        proofUploaded: proofUploaded ?? this.proofUploaded,
        shipmentPhoto: shipmentPhoto ?? this.shipmentPhoto,
        shipmentNote: shipmentNote ?? this.shipmentNote,
        review: review ?? this.review,
        archivedFrom: archivedFrom ?? this.archivedFrom,
      );
}

abstract class OrderRepository {
  List<Order> orders();
  void save(List<Order> orders);
}

class CartLine {
  const CartLine({required this.product, required this.variation, this.qty = 1, this.selected = true});
  final Product product;
  final Variation variation;
  final int qty;
  final bool selected;

  String get key => '${product.id}|${variation.id}';
  int get unitPrice => product.priceOf(variation);
  int get total => unitPrice * qty;

  CartLine copyWith({int? qty, bool? selected}) => CartLine(product: product, variation: variation, qty: qty ?? this.qty, selected: selected ?? this.selected);
}
