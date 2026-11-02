import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/data/backend.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';

class SellerSettingsNotifier extends Notifier<SellerSettings> {
  @override
  SellerSettings build() {
    final remote = ref.read(profileRemoteProvider);
    if (remote != null) {
      // Mode Supabase: muat pengaturan toko milik penjual yang login.
      ref.listen(authProvider, (_, user) {
        if (user?.role == UserRole.seller) _load();
      });
      if (ref.read(authProvider)?.role == UserRole.seller) Future.microtask(_load);
    }
    return const SellerSettings();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(profileRemoteProvider)?.myShop();
      if (s != null) state = s;
    } catch (e) {
      ref.read(backendErrorProvider.notifier).report(e);
    }
  }

  void update(SellerSettings s) {
    state = s;
    final remote = ref.read(profileRemoteProvider);
    if (remote == null) return;
    remote.saveShop(s).catchError((Object e) {
      ref.read(backendErrorProvider.notifier).report(e);
      _load();
    });
  }
}

final sellerSettingsProvider = NotifierProvider<SellerSettingsNotifier, SellerSettings>(SellerSettingsNotifier.new);
