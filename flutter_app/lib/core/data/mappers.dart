import 'package:ikanku/features/admin/domain/admin.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';

/// Pemeta baris database (Map JSON dari PostgREST) ke model domain. Murni, tanpa jaringan.
typedef Row = Map<String, dynamic>;

const _paymentStatusDb = {
  PaymentStatus.belumBayar: 'belum_bayar',
  PaymentStatus.menungguVerifikasi: 'menunggu_verifikasi',
  PaymentStatus.terverifikasi: 'terverifikasi',
};

String paymentStatusToDb(PaymentStatus s) => _paymentStatusDb[s]!;

PaymentStatus paymentStatusFromDb(String? v) {
  for (final e in _paymentStatusDb.entries) {
    if (e.value == v) return e.key;
  }
  return PaymentStatus.belumBayar;
}

UserRole roleFromDb(String? v) => UserRole.values.firstWhere((r) => r.name == v, orElse: () => UserRole.buyer);

AppUser userFromRow(Row r) => AppUser(
      id: r['id'] as String,
      name: (r['full_name'] ?? '') as String,
      email: (r['email'] ?? '') as String,
      phone: (r['phone'] ?? '') as String,
      role: roleFromDb(r['role'] as String?),
      isActive: (r['is_active'] ?? true) as bool,
    );

Variation variationFromRow(Row r) => Variation(
      id: r['id'] as String,
      weight: (r['weight'] ?? '') as String,
      count: (r['count'] ?? 1) as int,
      price: (r['price'] ?? 0) as int,
      stock: (r['stock'] ?? 0) as int,
    );

Row variationToRow(Variation v, String productId) => {'product_id': productId, 'weight': v.weight, 'count': v.count, 'price': v.price, 'stock': v.stock};

Review reviewFromRow(Row r) {
  final name = (r['reviewer_name'] ?? '') as String;
  return Review(author: name.isEmpty ? 'Pembeli' : name, rating: (r['rating'] ?? 5) as int, text: (r['comment'] ?? '') as String);
}

/// Baris `products` dengan embed `categories(name)`, `shops(name)`, `product_variants(*)`, `reviews(...)`.
Product productFromRow(Row r) {
  final reviews = [for (final x in (r['reviews'] as List? ?? const [])) reviewFromRow(Map<String, dynamic>.from(x as Map))];
  final rating = reviews.isEmpty ? 0.0 : reviews.fold<int>(0, (s, e) => s + e.rating) / reviews.length;
  return Product(
    id: r['id'] as String,
    name: (r['name'] ?? '') as String,
    description: (r['description'] ?? '') as String,
    category: ((r['categories'] as Map?)?['name'] ?? '') as String,
    image: (r['image_url'] ?? '') as String,
    variations: [for (final v in (r['product_variants'] as List? ?? const [])) variationFromRow(Map<String, dynamic>.from(v as Map))],
    rating: double.parse(rating.toStringAsFixed(1)),
    reviews: reviews,
    discountPercent: (r['discount_percent'] ?? 0) as int,
    sellerName: ((r['shops'] as Map?)?['name'] ?? '') as String,
  );
}

Row productToRow(Product p, {required String shopId, String? categoryId}) => {
      'shop_id': shopId,
      'category_id': categoryId,
      'name': p.name,
      'description': p.description,
      'image_url': p.image.startsWith('http') ? p.image : null,
      'discount_percent': p.discountPercent,
    };

final _labelRe = RegExp(r'^Berat (.+), Isi (\d+) ekor$');

/// Baris `order_items` dengan embed opsional `products(image_url)` dan `product_variants(weight,count)`.
OrderLine orderLineFromRow(Row r) {
  final label = (r['variant_label'] ?? '') as String;
  final m = _labelRe.firstMatch(label);
  final embedded = r['product_variants'] as Map?;
  final weight = (embedded?['weight'] ?? m?.group(1) ?? label) as String;
  final count = (embedded?['count'] ?? int.tryParse(m?.group(2) ?? '') ?? 1) as int;
  final price = r['unit_price'] as int;
  final variation = Variation(id: (r['variant_id'] ?? '') as String, weight: weight, count: count, price: price, stock: 0);
  final product = Product(
    id: (r['product_id'] ?? '') as String,
    name: (r['product_name'] ?? '') as String,
    description: '',
    category: '',
    image: ((r['products'] as Map?)?['image_url'] ?? '') as String,
    variations: [variation],
  );
  return OrderLine(product: product, variation: variation, qty: r['quantity'] as int, unitPrice: price);
}

/// Baris `orders` dengan embed `order_items(*, products(image_url), product_variants(weight,count), reviews(...))`.
Order orderFromRow(Row r) {
  final items = [for (final x in (r['order_items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];
  Review? review;
  for (final i in items) {
    final rs = i['reviews'];
    final first = rs is List && rs.isNotEmpty ? rs.first : (rs is Map ? rs : null);
    if (first != null) {
      review = reviewFromRow(Map<String, dynamic>.from(first as Map));
      break;
    }
  }
  final archived = r['archived_from'] as String?;
  return Order(
    id: r['code'] as String,
    remoteId: r['id'] as String,
    lines: items.map(orderLineFromRow).toList(),
    status: OrderStatus.values.byName(r['status'] as String),
    payment: PaymentMethod.values.byName(r['payment_method'] as String),
    paymentStatus: paymentStatusFromDb(r['payment_status'] as String?),
    shipping: ShippingMethod.values.byName(r['shipping_method'] as String),
    address: Address(
      id: '',
      recipient: (r['ship_recipient'] ?? '') as String,
      phone: (r['ship_phone'] ?? '') as String,
      street: (r['ship_street'] ?? '') as String,
      area: Kecamatan((r['ship_kecamatan'] ?? '') as String, (r['ship_city'] ?? '') as String, (r['ship_postal_code'] ?? '') as String),
    ),
    shippingFee: (r['shipping_fee'] ?? 0) as int,
    createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
    buyerName: (r['buyer_name'] ?? '') as String,
    note: (r['note'] ?? '') as String,
    rejectReason: r['reject_reason'] as String?,
    proofUploaded: r['payment_proof_ref'] != null,
    shipmentPhoto: r['shipment_photo_ref'] as String?,
    shipmentNote: (r['shipment_note'] ?? '') as String,
    review: review,
    archivedFrom: archived == null ? null : OrderStatus.values.byName(archived),
  );
}

/// Baris `shops` dengan embed `shop_banks(*)`.
SellerSettings shopFromRow(Row r) => SellerSettings(
      shopName: (r['name'] ?? '') as String,
      shippingFee: (r['shipping_fee'] ?? 0) as int,
      freeShippingMin: (r['free_shipping_min'] ?? 0) as int,
      transferEnabled: (r['transfer_enabled'] ?? true) as bool,
      codEnabled: (r['cod_enabled'] ?? true) as bool,
      deliveryEnabled: (r['delivery_enabled'] ?? true) as bool,
      pickupEnabled: (r['pickup_enabled'] ?? true) as bool,
      banks: [
        for (final b in (r['shop_banks'] as List? ?? const []))
          BankAccount(bank: (b as Map)['bank'] as String, number: b['number'] as String, holder: b['holder'] as String),
      ],
    );

Row shopToRow(SellerSettings s) => {
      'name': s.shopName,
      'shipping_fee': s.shippingFee,
      'free_shipping_min': s.freeShippingMin,
      'transfer_enabled': s.transferEnabled,
      'cod_enabled': s.codEnabled,
      'delivery_enabled': s.deliveryEnabled,
      'pickup_enabled': s.pickupEnabled,
    };

AdminProduct adminProductFromRow(Row r) => AdminProduct(
      id: r['id'] as String,
      name: (r['name'] ?? '') as String,
      shopName: ((r['shops'] as Map?)?['name'] ?? '') as String,
      isActive: (r['is_active'] ?? true) as bool,
    );

/// Baris `orders` dengan embed `shops(name)` dan `order_items(unit_price,quantity)`.
AdminOrder adminOrderFromRow(Row r) {
  final items = (r['order_items'] as List? ?? const []);
  final subtotal = items.fold<int>(0, (s, i) => s + ((i as Map)['unit_price'] as int) * (i['quantity'] as int));
  return AdminOrder(
    code: r['code'] as String,
    status: r['status'] as String,
    buyerName: (r['buyer_name'] ?? '') as String,
    shopName: ((r['shops'] as Map?)?['name'] ?? '') as String,
    total: subtotal + ((r['shipping_fee'] ?? 0) as int),
    payment: (r['payment_method'] ?? '') as String,
  );
}
