import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';

/// Profil pengguna dan toko di backend.
abstract class ProfileRemote {
  Future<AppUser> myProfile();
  Future<AppUser> updateProfile({String? name, String? phone});

  /// RPC become_seller: satu-satunya jalur pembeli menjadi penjual.
  Future<void> becomeSeller(String shopName);
  Future<SellerSettings?> myShop();
  Future<void> saveShop(SellerSettings s);
}
