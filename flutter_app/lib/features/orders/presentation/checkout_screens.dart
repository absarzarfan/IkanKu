import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:ikanku/features/profile/presentation/profile_providers.dart';
import 'package:ikanku/features/seller/presentation/seller_providers.dart';

Address? _effectiveAddress(WidgetRef ref) {
  final list = ref.watch(addressProvider);
  final sel = ref.watch(selectedAddressIdProvider);
  for (final a in list) {
    if (a.id == sel) return a;
  }
  for (final a in list) {
    if (a.isPrimary) return a;
  }
  return list.isEmpty ? null : list.first;
}

/// Ringkasan Pemesanan / Bayar (Figma 1804:11463, 3434:7411).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  ShippingMethod _shipping = ShippingMethod.kirim;
  PaymentMethod _payment = PaymentMethod.transfer;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    final lines = ref.read(cartSelectedProvider);
    final address = _effectiveAddress(ref);
    final user = ref.read(authProvider);
    if (lines.isEmpty) return;
    if (address == null) {
      showMsg(context, 'Tambahkan alamat terlebih dahulu');
      return;
    }
    final ok = await confirmDialog(context, 'Apakah alamat sudah benar?', '${address.recipient}\n${address.full}', yes: 'Ya', no: 'Tidak');
    if (!ok || !mounted) return;
    final settings = ref.read(sellerSettingsProvider);
    final sub = ref.read(cartSubtotalProvider);
    final order = ref.read(ordersProvider.notifier).place(
          lines: [for (final l in lines) OrderLine(product: l.product, variation: l.variation, qty: l.qty, unitPrice: l.unitPrice)],
          payment: _payment,
          shipping: _shipping,
          address: address,
          shippingFee: settings.feeFor(sub),
          buyerName: user?.name ?? address.recipient,
          note: _note.text,
        );
    ref.read(cartProvider.notifier).removeSelected();
    if (!mounted) return;
    if (_payment == PaymentMethod.transfer) {
      context.pushReplacement('/payment/${order.id}');
    } else {
      context.pushReplacement('/order-success/${order.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartSelectedProvider);
    final settings = ref.watch(sellerSettingsProvider);
    final sub = ref.watch(cartSubtotalProvider);
    final fee = _shipping == ShippingMethod.jemput ? 0 : settings.feeFor(sub);
    final address = _effectiveAddress(ref);
    return AppScaffold(
      title: 'Ringkasan Pemesanan',
      body: lines.isEmpty
          ? const EmptyState('Tidak ada item dipilih')
          : ListView(padding: const EdgeInsets.all(20), children: [
              AppCard(
                onTap: () => context.push('/addresses?pick=1'),
                child: Row(children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: address == null
                        ? const Text('Pilih alamat pengiriman')
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${address.recipient} | ${address.phone}', style: AppText.semi.copyWith(fontSize: 14)), Text(address.full, style: AppText.small)]),
                  ),
                  const Icon(Icons.chevron_right),
                ]),
              ),
              for (final l in lines)
                AppCard(
                  child: Row(children: [
                    ProductImage(asset: l.product.image, size: 60),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.product.name, style: AppText.body), Text(l.variation.label, style: AppText.small)])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rupiah(l.unitPrice), style: AppText.body), Text('x${l.qty}', style: AppText.small)]),
                  ]),
                ),
              Text('Metode Pengiriman', style: AppText.semi),
              Wrap(spacing: 8, children: [
                if (settings.deliveryEnabled) ChoiceChip(key: const Key('ship-kirim'), label: const Text('Kirim'), selected: _shipping == ShippingMethod.kirim, onSelected: (_) => setState(() => _shipping = ShippingMethod.kirim)),
                if (settings.pickupEnabled) ChoiceChip(key: const Key('ship-jemput'), label: const Text('Jemput'), selected: _shipping == ShippingMethod.jemput, onSelected: (_) => setState(() => _shipping = ShippingMethod.jemput)),
              ]),
              const SizedBox(height: 10),
              Text('Metode Pembayaran', style: AppText.semi),
              Wrap(spacing: 8, children: [
                if (settings.transferEnabled) ChoiceChip(key: const Key('pay-transfer'), label: const Text('Transfer'), selected: _payment == PaymentMethod.transfer, onSelected: (_) => setState(() => _payment = PaymentMethod.transfer)),
                if (settings.codEnabled) ChoiceChip(key: const Key('pay-cod'), label: const Text('COD'), selected: _payment == PaymentMethod.cod, onSelected: (_) => setState(() => _payment = PaymentMethod.cod)),
              ]),
              const SizedBox(height: 14),
              AppField(controller: _note, hint: 'Opsional: Catatan untuk penjual', maxLines: 2),
              AppCard(
                child: Column(children: [
                  KeyValueRow('Subtotal', rupiah(sub)),
                  KeyValueRow('Ongkir', fee == 0 ? 'Gratis' : rupiah(fee)),
                  const Divider(),
                  KeyValueRow('Total', rupiah(sub + fee), bold: true),
                ]),
              ),
              Row(children: [
                Expanded(child: PillButton(label: 'Batal', outlined: true, color: AppColors.danger, onPressed: () => context.canPop() ? context.pop() : context.go('/home'))),
                const SizedBox(width: 12),
                Expanded(child: PillButton(label: 'Buat Pesanan', onPressed: _place)),
              ]),
            ]),
    );
  }
}

/// Pembayaran transfer: tampilkan rekening penjual + unggah bukti (simulasi) (Figma 938:4885).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _picked = false;
  @override
  Widget build(BuildContext context) {
    final order = ref.watch(ordersProvider).where((o) => o.id == widget.orderId).firstOrNull;
    final settings = ref.watch(sellerSettingsProvider);
    if (order == null) return const AppScaffold(title: 'Pembayaran', body: EmptyState('Pesanan tidak ditemukan'));
    final bank = settings.banks.isEmpty ? null : settings.banks.first;
    return AppScaffold(
      title: 'Pembayaran',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Transfer ke', style: AppText.small),
            if (bank != null) ...[Text('${bank.bank} ${bank.number}', style: AppText.semi.copyWith(fontSize: 18)), Text('a.n. ${bank.holder}', style: AppText.small)] else const Text('Rekening belum diatur penjual'),
            const Divider(height: 24),
            KeyValueRow('Subtotal', rupiah(order.subtotal)),
            KeyValueRow('Ongkir', rupiah(order.shippingFee)),
            KeyValueRow('Total', rupiah(order.total), bold: true),
          ]),
        ),
        Text('Bukti Pembayaran', style: AppText.semi),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _picked = true),
          child: Container(
            height: 120,
            decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(_picked ? Icons.check_circle : Icons.upload_file, size: 36, color: _picked ? AppColors.success : AppColors.grey), Text(_picked ? 'Bukti terpilih (simulasi)' : 'Unggah bukti transfer (simulasi)', style: AppText.small)])),
          ),
        ),
        const SizedBox(height: 20),
        PillButton(
          label: 'Kirim',
          onPressed: _picked
              ? () {
                  ref.read(ordersProvider.notifier).uploadProof(order.id);
                  context.pushReplacement('/order-success/${order.id}');
                }
              : null,
        ),
        TextButton(onPressed: () => context.pushReplacement('/order-success/${order.id}'), child: const Text('Bayar nanti')),
      ]),
    );
  }
}

/// Pesanan sukses (Figma 478:1178, 1804:14120).
class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersProvider).where((o) => o.id == orderId).firstOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, size: 96, color: AppColors.success),
          const SizedBox(height: 12),
          Center(child: Text('Pesanan berhasil dilakukan !', style: AppText.semi.copyWith(fontSize: 18))),
          const SizedBox(height: 24),
          if (order != null)
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ringkasan Pesanan', style: AppText.semi),
                const SizedBox(height: 8),
                for (final l in order.lines) KeyValueRow('${l.product.name} x${l.qty}', rupiah(l.total)),
                const Divider(),
                KeyValueRow('Subtotal', rupiah(order.subtotal)),
                KeyValueRow('Ongkir', rupiah(order.shippingFee)),
                KeyValueRow('Total', rupiah(order.total), bold: true),
                KeyValueRow('Pembayaran', order.payment == PaymentMethod.transfer ? 'Transfer' : 'COD'),
              ]),
            ),
          PillButton(label: 'Lihat Pesanan', outlined: true, onPressed: () => context.go('/orders')),
          const SizedBox(height: 12),
          PillButton(label: 'Kembali ke Beranda', onPressed: () => context.go('/home')),
        ]),
      ),
    );
  }
}
