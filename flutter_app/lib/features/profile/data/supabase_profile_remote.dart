import 'package:ikanku/core/data/mappers.dart';
import 'package:ikanku/core/data/supabase_support.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/profile/domain/profile_remote.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseProfileRemote implements ProfileRemote {
  SupabaseProfileRemote(this._db);
  final sb.SupabaseClient _db;

  @override
  Future<AppUser> myProfile() => guarded(() async => userFromRow(await _db.from('profiles').select().eq('id', requireUid(_db)).single()));

  /// Hanya nama dan telepon; role/is_active/email dijaga trigger database.
  @override
  Future<AppUser> updateProfile({String? name, String? phone}) => guarded(() async {
        final patch = {'full_name': ?name, 'phone': ?phone};
        if (patch.isNotEmpty) await _db.from('profiles').update(patch).eq('id', requireUid(_db));
        return userFromRow(await _db.from('profiles').select().eq('id', requireUid(_db)).single());
      });

  @override
  Future<void> becomeSeller(String shopName) => guarded(() async {
        if (shopName.trim().isEmpty) throw const AppError.validation('Nama toko wajib diisi.');
        await _db.rpc('become_seller', params: {'p_shop_name': shopName.trim()});
      });

  @override
  Future<SellerSettings?> myShop() => guarded(() async {
        final row = await _db.from('shops').select('*, shop_banks(*)').eq('owner_id', requireUid(_db)).maybeSingle();
        return row == null ? null : shopFromRow(row);
      });

  @override
  Future<void> saveShop(SellerSettings s) => guarded(() async {
        final uid = requireUid(_db);
        final shop = await _db.from('shops').update(shopToRow(s)).eq('owner_id', uid).select('id').single();
        final shopId = shop['id'] as String;
        await _db.from('shop_banks').delete().eq('shop_id', shopId);
        if (s.banks.isNotEmpty) {
          await _db.from('shop_banks').insert([for (final b in s.banks) {'shop_id': shopId, 'bank': b.bank, 'number': b.number, 'holder': b.holder}]);
        }
      });
}
