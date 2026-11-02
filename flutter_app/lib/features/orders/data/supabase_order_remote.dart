import 'package:ikanku/core/data/mappers.dart';
import 'package:ikanku/core/data/supabase_support.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/domain/orders_remote.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

const _orderSelect = '*, order_items(*, products(image_url), product_variants(weight, count), reviews(rating, comment, reviewer_name))';

class SupabaseOrderRemote implements OrderRemote {
  SupabaseOrderRemote(this._db);
  final sb.SupabaseClient _db;

  Future<String> _addressId(String uid, Address a) async {
    if (isUuid(a.id)) return a.id;
    final row = await _db.from('addresses').insert({
      'user_id': uid,
      'recipient': a.recipient,
      'phone': a.phone,
      'street': a.street,
      'kecamatan': a.area.name,
      'city': a.area.city,
      'postal_code': a.area.postalCode,
    }).select('id').single();
    return row['id'] as String;
  }

  @override
  Future<List<Order>> placeOrder({
    required List<CartLine> lines,
    required PaymentMethod payment,
    required ShippingMethod shipping,
    required Address address,
    String note = '',
  }) =>
      guarded(() async {
        if (lines.isEmpty) throw const AppError.validation('Tidak ada item untuk dipesan.');
        final uid = requireUid(_db);
        final addressId = await _addressId(uid, address);
        // Hanya id varian dan jumlah yang dikirim; harga dibaca server di place_order.
        final cart = await _db
            .from('cart_items')
            .upsert([for (final l in lines) {'user_id': uid, 'variant_id': l.variation.id, 'qty': l.qty}], onConflict: 'user_id,variant_id')
            .select('id');
        final cartIds = [for (final r in cart) r['id'] as String];
        try {
          final res = await _db.rpc('place_order', params: {
            'p_payment_method': payment.name,
            'p_shipping_method': shipping.name,
            'p_address_id': addressId,
            'p_note': note,
            'p_cart_item_ids': cartIds,
          });
          final ids = [for (final x in (res as List)) x.toString()];
          final rows = await _db.from('orders').select(_orderSelect).inFilter('id', ids).order('created_at', ascending: false);
          return rows.map(orderFromRow).toList();
        } catch (_) {
          await _db.from('cart_items').delete().inFilter('id', cartIds);
          rethrow;
        }
      });

  @override
  Future<List<Order>> listOrders() => guarded(() async {
        final rows = await _db.from('orders').select(_orderSelect).order('created_at', ascending: false).limit(200);
        return rows.map(orderFromRow).toList();
      });

  @override
  Future<Order?> getOrder(String code) => guarded(() async {
        final row = await _db.from('orders').select(_orderSelect).eq('code', code).maybeSingle();
        return row == null ? null : orderFromRow(row);
      });

  String _remote(Order o) => o.remoteId ?? (throw const AppError.validation('Pesanan belum tersimpan di server.'));

  @override
  Future<Order> updateStatus(Order order, OrderStatus next, {String? reason, String? photoRef, String? note}) => guarded(() async {
        final id = _remote(order);
        await _db.rpc('update_order_status', params: {'p_order_id': id, 'p_new': next.name, 'p_reason': reason, 'p_photo_ref': photoRef, 'p_note': note});
        final row = await _db.from('orders').select(_orderSelect).eq('id', id).single();
        return orderFromRow(row);
      });

  @override
  Future<void> setPaymentProof(Order order, String ref) => guarded(() async {
        await _db.rpc('set_payment_proof', params: {'p_order_id': _remote(order), 'p_ref': ref});
      });

  @override
  Future<void> submitReview(Order order, int rating, String text) => guarded(() async {
        if (rating < 1 || rating > 5) throw const AppError.validation('Rating harus 1 sampai 5.');
        final uid = requireUid(_db);
        final items = await _db.from('order_items').select('id').eq('order_id', _remote(order));
        await _db.from('reviews').upsert(
          [for (final i in items) {'order_item_id': i['id'], 'reviewer_id': uid, 'rating': rating, 'comment': text.trim()}],
          onConflict: 'order_item_id',
          ignoreDuplicates: true,
        );
      });

  @override
  Future<List<Review>> reviewsFor(String productId) => guarded(() async {
        if (!isUuid(productId)) return <Review>[];
        final rows = await _db.from('reviews').select('rating, comment, reviewer_name').eq('product_id', productId).order('created_at', ascending: false);
        return rows.map(reviewFromRow).toList();
      });
}

class SupabaseCartRemote implements CartRemote {
  SupabaseCartRemote(this._db);
  final sb.SupabaseClient _db;

  @override
  Future<List<CartLine>> list() => guarded(() async {
        final rows = await _db
            .from('cart_items')
            .select('qty, product_variants(*, products(*, categories(name), shops(name), product_variants(*)))')
            .eq('user_id', requireUid(_db));
        return [
          for (final r in rows)
            if (r['product_variants'] is Map)
              CartLine(
                product: productFromRow(Map<String, dynamic>.from((r['product_variants'] as Map)['products'] as Map)),
                variation: variationFromRow(Map<String, dynamic>.from(r['product_variants'] as Map)),
                qty: r['qty'] as int,
              ),
        ];
      });

  @override
  Future<void> setQty(Variation variation, int qty) => guarded(() async {
        if (qty < 1) throw const AppError.validation('Jumlah minimal 1.');
        await _db.from('cart_items').upsert({'user_id': requireUid(_db), 'variant_id': variation.id, 'qty': qty}, onConflict: 'user_id,variant_id');
      });

  @override
  Future<void> remove(Variation variation) => guarded(() async {
        await _db.from('cart_items').delete().eq('user_id', requireUid(_db)).eq('variant_id', variation.id);
      });

  @override
  Future<void> clear() => guarded(() async {
        await _db.from('cart_items').delete().eq('user_id', requireUid(_db));
      });
}
