import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';
import 'package:ikanku/features/seller/presentation/seller_providers.dart';

/// Pengaturan penjual (Figma 2583:10986).
class SellerSettingsScreen extends ConsumerWidget {
  const SellerSettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sellerSettingsProvider);
    final n = ref.read(sellerSettingsProvider.notifier);
    Widget tile(IconData i, String t, String route) => AppCard(margin: const EdgeInsets.only(bottom: 10), onTap: () => context.push(route), child: Row(children: [Icon(i, color: AppColors.primary), const SizedBox(width: 14), Expanded(child: Text(t, style: AppText.body)), const Icon(Icons.chevron_right)]));
    return AppScaffold(
      title: 'Pengaturan',
      showBack: false,
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(s.shopName, style: AppText.semi.copyWith(fontSize: 18)),
        const SizedBox(height: 12),
        tile(Icons.local_shipping_outlined, 'Biaya Ongkir', '/seller/ongkir'),
        tile(Icons.payments_outlined, 'Metode Pembayaran', '/seller/payment-methods'),
        tile(Icons.rate_review_outlined, 'Ulasan', '/seller/reviews'),
        tile(Icons.discount_outlined, 'Diskon', '/seller/discount'),
        tile(Icons.help_outline, 'Pusat Bantuan', '/help'),
        const SizedBox(height: 6),
        Text('Metode Pengiriman', style: AppText.semi),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Kirim'), value: s.deliveryEnabled, onChanged: (v) => n.update(s.copyWith(deliveryEnabled: v || s.pickupEnabled ? v : true))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Jemput'), value: s.pickupEnabled, onChanged: (v) => n.update(s.copyWith(pickupEnabled: v || s.deliveryEnabled ? v : true))),
        const SizedBox(height: 10),
        PillButton(label: 'Keluar', color: AppColors.danger, onPressed: () => ref.read(authProvider.notifier).logout()),
      ]),
    );
  }
}

/// Biaya ongkir (Figma 2588:11577).
class OngkirScreen extends ConsumerStatefulWidget {
  const OngkirScreen({super.key});
  @override
  ConsumerState<OngkirScreen> createState() => _OngkirScreenState();
}

class _OngkirScreenState extends ConsumerState<OngkirScreen> {
  final _form = GlobalKey<FormState>();
  late final _fee = TextEditingController(text: '${ref.read(sellerSettingsProvider).shippingFee}');
  late final _free = TextEditingController(text: '${ref.read(sellerSettingsProvider).freeShippingMin}');
  @override
  void dispose() {
    _fee.dispose();
    _free.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Biaya Ongkir',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          AppField(fieldKey: const Key('ongkir-fee'), label: 'Biaya ongkir (Rp)', controller: _fee, hint: '10000', keyboard: TextInputType.number, validator: (v) => Validators.number(v, 'Biaya')),
          AppField(fieldKey: const Key('ongkir-free'), label: 'Gratis ongkir untuk subtotal minimal (0 = nonaktif)', controller: _free, hint: '0', keyboard: TextInputType.number, validator: (v) => Validators.number(v, 'Nilai')),
          PillButton(
            label: 'Simpan',
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              final s = ref.read(sellerSettingsProvider);
              ref.read(sellerSettingsProvider.notifier).update(s.copyWith(shippingFee: int.parse(_fee.text.trim()), freeShippingMin: int.parse(_free.text.trim())));
              context.pop();
            },
          ),
        ]),
      ),
    );
  }
}

/// Metode pembayaran: Transfer/COD + rekening (Figma 1804:14071, 1804:14023).
class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final _bank = TextEditingController();
  final _no = TextEditingController();
  @override
  void dispose() {
    _bank.dispose();
    _no.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sellerSettingsProvider);
    final n = ref.read(sellerSettingsProvider.notifier);
    return AppScaffold(
      title: 'Metode Pembayaran',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Transfer'), value: s.transferEnabled, onChanged: (v) => n.update(s.copyWith(transferEnabled: v || s.codEnabled ? v : true))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('COD'), value: s.codEnabled, onChanged: (v) => n.update(s.copyWith(codEnabled: v || s.transferEnabled ? v : true))),
        const Divider(),
        Text('Rekening', style: AppText.semi),
        for (final (i, b) in s.banks.indexed)
          AppCard(child: Row(children: [Expanded(child: Text('${b.bank} ${b.number}\na.n. ${b.holder}', style: AppText.body)), IconButton(tooltip: 'Hapus rekening', icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: () => n.update(s.copyWith(banks: [...s.banks]..removeAt(i))))])),
        AppField(fieldKey: const Key('bank-name'), controller: _bank, hint: 'Nama bank'),
        AppField(fieldKey: const Key('bank-no'), controller: _no, hint: 'Nomor rekening', keyboard: TextInputType.number),
        PillButton(
          label: 'Simpan Rekening',
          onPressed: () {
            if (_bank.text.trim().isEmpty || int.tryParse(_no.text.trim()) == null) {
              showMsg(context, 'Isi nama bank dan nomor rekening (angka)');
              return;
            }
            n.update(s.copyWith(banks: [...s.banks, BankAccount(bank: _bank.text.trim(), number: _no.text.trim(), holder: s.shopName)]));
            _bank.clear();
            _no.clear();
          },
        ),
      ]),
    );
  }
}
