import 'package:ikanku/core/data/mappers.dart';
import 'package:ikanku/core/data/supabase_support.dart';
import 'package:ikanku/features/admin/domain/admin.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Kueri admin. Hak akses ditegakkan RLS (is_admin()) dan RPC admin_set_*; klien hanya meminta.
class SupabaseAdminRemote implements AdminRemote {
  SupabaseAdminRemote(this._db);
  final sb.SupabaseClient _db;

  @override
  Future<List<AppUser>> users({String? query}) => guarded(() async {
        var q = _db.from('profiles').select();
        final t = safeQuery(query ?? '');
        if (t.isNotEmpty) q = q.or('full_name.ilike.%$t%,email.ilike.%$t%');
        final rows = await q.order('created_at', ascending: false).limit(200);
        return rows.map(userFromRow).toList();
      });

  @override
  Future<void> setUserActive(String userId, bool active) => guarded(() async {
        await _db.rpc('admin_set_user_active', params: {'p_user_id': userId, 'p_active': active});
      });

  @override
  Future<List<AdminOrder>> orders() => guarded(() async {
        final rows = await _db
            .from('orders')
            .select('code, status, buyer_name, payment_method, shipping_fee, shops(name), order_items(unit_price, quantity)')
            .order('created_at', ascending: false)
            .limit(100);
        return rows.map(adminOrderFromRow).toList();
      });

  @override
  Future<List<AdminProduct>> products({String? query}) => guarded(() async {
        var q = _db.from('products').select('id, name, is_active, shops(name)');
        final t = safeQuery(query ?? '');
        if (t.isNotEmpty) q = q.ilike('name', '%$t%');
        final rows = await q.order('created_at', ascending: false).limit(200);
        return rows.map(adminProductFromRow).toList();
      });

  @override
  Future<void> setProductActive(String productId, bool active) => guarded(() async {
        await _db.rpc('admin_set_product_active', params: {'p_product_id': productId, 'p_active': active});
      });
}
