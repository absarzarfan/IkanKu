import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';

class SellerSettingsNotifier extends Notifier<SellerSettings> {
  @override
  SellerSettings build() => const SellerSettings();

  void update(SellerSettings s) => state = s;
}

final sellerSettingsProvider = NotifierProvider<SellerSettingsNotifier, SellerSettings>(SellerSettingsNotifier.new);
