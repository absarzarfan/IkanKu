import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';
import 'package:ikanku/features/orders/presentation/orders_strings.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:ikanku/features/profile/presentation/profile_providers.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';
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

/// Opsi untuk sheet pilihan: nilai, judul, keterangan, kunci uji.
typedef _Option<T> = (T value, String title, String hint, Key key);

Future<T?> _pickOption<T>(BuildContext context, {required String title, required List<_Option<T>> options, required T current}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(Space.screenGutter(c), 0, Space.screenGutter(c), Gap.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.heading),
          const SizedBox(height: Gap.sm),
          for (final o in options)
            ListTile(
              key: o.$4,
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: Gap.sm,
              leading: Icon(o.$1 == current ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: o.$1 == current ? AppColors.primary : AppColors.grey),
              title: Text(o.$2, style: AppText.body),
              subtitle: Text(o.$3, style: AppText.small),
              onTap: () => Navigator.pop(c, o.$1),
            ),
        ]),
      ),
    ),
  );
}

/// Baris pilihan yang membuka sheet: judul, nilai terpilih, panah.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({super.key, required this.icon, required this.title, required this.value, required this.onTap});
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        child: Row(children: [
          IconChip(icon: icon, size: 40),
          const SizedBox(width: Gap.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppText.small.copyWith(color: AppColors.grey)), Text(value, style: AppText.semi)])),
          const Icon(Icons.chevron_right),
        ]),
      );
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
  bool _busy = false; // spinner pada tombol
  bool _guard = false; // cegah kirim ganda, termasuk saat dialog konfirmasi terbuka
  bool _addressError = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    if (_guard) return;
    final lines = ref.read(cartSelectedProvider);
    final address = _effectiveAddress(ref);
    final user = ref.read(authProvider);
    if (lines.isEmpty) return;
    if (address == null) {
      HapticFeedback.mediumImpact();
      setState(() => _addressError = true);
      return;
    }
    _guard = true;
    final ok = await confirmDialog(context, OrdersStrings.confirmAddressTitle, '${address.recipient}\n${address.full}', yes: OrdersStrings.yes, no: OrdersStrings.no);
    if (!ok || !mounted) {
      _guard = false;
      return;
    }
    if (mounted) setState(() => _busy = true);
    final settings = ref.read(sellerSettingsProvider);
    final sub = ref.read(cartSubtotalProvider);
    final Order order;
    try {
      order = await ref.read(ordersProvider.notifier).placeAsync(
          lines: [for (final l in lines) OrderLine(product: l.product, variation: l.variation, qty: l.qty, unitPrice: l.unitPrice)],
          payment: _payment,
          shipping: _shipping,
          address: address,
          shippingFee: _shipping == ShippingMethod.jemput ? 0 : settings.feeFor(sub),
          buyerName: user?.name ?? address.recipient,
          note: _note.text,
        );
    } catch (e) {
      _guard = false;
      if (mounted) {
        setState(() => _busy = false);
        showMsg(context, mapError(e).message);
      }
      return;
    }
    HapticFeedback.lightImpact();
    ref.read(cartProvider.notifier).removeSelected();
    if (!mounted) return;
    if (_payment == PaymentMethod.transfer) {
      context.pushReplacement('/payment/${order.id}');
    } else {
      context.pushReplacement('/order-success/${order.id}');
    }
  }

  Future<void> _pickShipping(SellerSettings s) async {
    final r = await _pickOption<ShippingMethod>(context, title: OrdersStrings.shippingTitle, current: _shipping, options: [
      if (s.deliveryEnabled) (ShippingMethod.kirim, OrdersStrings.shipSend, OrdersStrings.shipSendHint, const Key('ship-kirim')),
      if (s.pickupEnabled) (ShippingMethod.jemput, OrdersStrings.shipPickup, OrdersStrings.shipPickupHint, const Key('ship-jemput')),
    ]);
    if (r != null && mounted) setState(() => _shipping = r);
  }

  Future<void> _pickPayment(SellerSettings s) async {
    final r = await _pickOption<PaymentMethod>(context, title: OrdersStrings.paymentTitle, current: _payment, options: [
      if (s.transferEnabled) (PaymentMethod.transfer, OrdersStrings.payTransfer, OrdersStrings.payTransferHint, const Key('pay-transfer')),
      if (s.codEnabled) (PaymentMethod.cod, OrdersStrings.payCod, OrdersStrings.payCodHint, const Key('pay-cod')),
    ]);
    if (r != null && mounted) setState(() => _payment = r);
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartSelectedProvider);
    final settings = ref.watch(sellerSettingsProvider);
    final sub = ref.watch(cartSubtotalProvider);
    final fee = _shipping == ShippingMethod.jemput ? 0 : settings.feeFor(sub);
    final address = _effectiveAddress(ref);
    final steps = [OrdersStrings.stepOrder, if (_payment == PaymentMethod.transfer) OrdersStrings.stepPay, OrdersStrings.stepDone];
    return AppScaffold(
      title: OrdersStrings.checkoutTitle,
      bottom: lines.isEmpty
          ? null
          : StickyActionBar(
              child: Row(children: [
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(OrdersStrings.total, style: AppText.caption.copyWith(color: AppColors.grey)),
                  Text(rupiah(sub + fee), key: const Key('checkout-total'), style: AppText.semi),
                ]),
                const SizedBox(width: Gap.lg),
                Expanded(child: PillButton(label: OrdersStrings.placeOrder, busy: _busy, onPressed: _place)),
              ]),
            ),
      body: lines.isEmpty
          ? EmptyState(OrdersStrings.noItems, icon: Icons.shopping_bag_outlined, hint: OrdersStrings.noItemsHint, actionLabel: OrdersStrings.toCart, onAction: () => context.canPop() ? context.pop() : context.go('/cart'))
          : ListView(padding: Space.pad(context), children: [
              Padding(padding: const EdgeInsets.only(bottom: Gap.lg), child: StepIndicator(labels: steps, current: 0)),
              AppCard(
                key: const Key('checkout-address'),
                onTap: () => context.push('/addresses?pick=1'),
                child: Row(children: [
                  IconChip(icon: Icons.location_on_outlined, size: 40, color: _addressError ? AppColors.danger : null),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: address == null
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text(OrdersStrings.addAddress, style: AppText.semi),
                            if (_addressError) Text(OrdersStrings.addressMissing, key: const Key('address-error'), style: AppText.small.copyWith(color: AppColors.danger)),
                          ])
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${address.recipient} | ${address.phone}', style: AppText.label), Text(address.full, style: AppText.small)]),
                  ),
                  Text(address == null ? '' : OrdersStrings.change, style: AppText.body.copyWith(color: AppColors.primary)),
                  const Icon(Icons.chevron_right),
                ]),
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: const Key('checkout-items'),
                    initiallyExpanded: true,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(OrdersStrings.itemsTitle(lines.length), style: AppText.label),
                    childrenPadding: EdgeInsets.fromLTRB(Space.cardPadding(context), 0, Space.cardPadding(context), Space.cardPadding(context)),
                    children: [
                      for (final l in lines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Gap.sm),
                          child: Row(children: [
                            ProductImage(asset: l.product.image, size: 52),
                            const SizedBox(width: Gap.md),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.product.name, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis), Text(l.variation.label, style: AppText.small)])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rupiah(l.unitPrice), style: AppText.body), Text('x${l.qty}', style: AppText.small)]),
                          ]),
                        ),
                    ],
                  ),
                ),
              ),
              _ChoiceRow(
                key: const Key('checkout-shipping'),
                icon: Icons.local_shipping_outlined,
                title: OrdersStrings.shippingTitle,
                value: _shipping == ShippingMethod.kirim ? OrdersStrings.shipSend : OrdersStrings.shipPickup,
                onTap: () => _pickShipping(settings),
              ),
              _ChoiceRow(
                key: const Key('checkout-payment'),
                icon: Icons.account_balance_wallet_outlined,
                title: OrdersStrings.paymentTitle,
                value: _payment == PaymentMethod.transfer ? OrdersStrings.payTransfer : OrdersStrings.payCod,
                onTap: () => _pickPayment(settings),
              ),
              AppField(controller: _note, hint: OrdersStrings.noteHint, maxLines: 2, textInputAction: TextInputAction.done),
              AppCard(
                child: Column(children: [
                  KeyValueRow(OrdersStrings.subtotal, rupiah(sub)),
                  KeyValueRow(OrdersStrings.shippingFee, fee == 0 ? OrdersStrings.free : rupiah(fee)),
                  const Divider(),
                  KeyValueRow(OrdersStrings.total, rupiah(sub + fee), bold: true),
                ]),
              ),
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
    if (order == null) return const AppScaffold(title: OrdersStrings.paymentScreenTitle, body: EmptyState(OrdersStrings.notFound, icon: Icons.search_off));
    final bank = settings.banks.isEmpty ? null : settings.banks.first;
    return AppScaffold(
      title: OrdersStrings.paymentScreenTitle,
      bottom: StickyActionBar(
        child: PillButton(
          label: OrdersStrings.sendProof,
          onPressed: _picked
              ? () {
                  ref.read(ordersProvider.notifier).uploadProof(order.id);
                  context.pushReplacement('/order-success/${order.id}');
                }
              : null,
        ),
      ),
      body: ListView(padding: Space.pad(context), children: [
        const Padding(padding: EdgeInsets.only(bottom: Gap.lg), child: StepIndicator(labels: [OrdersStrings.stepOrder, OrdersStrings.stepPay, OrdersStrings.stepDone], current: 1)),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(OrdersStrings.transferTo, style: AppText.small),
            if (bank != null) ...[Text('${bank.bank} ${bank.number}', style: AppText.heading), Text('a.n. ${bank.holder}', style: AppText.small)] else const Text(OrdersStrings.noBank),
            const Divider(height: 24),
            KeyValueRow(OrdersStrings.subtotal, rupiah(order.subtotal)),
            KeyValueRow(OrdersStrings.shippingFee, rupiah(order.shippingFee)),
            KeyValueRow(OrdersStrings.total, rupiah(order.total), bold: true),
          ]),
        ),
        const SectionHeader(OrdersStrings.proofTitle),
        const SizedBox(height: Gap.sm),
        InkWell(
          onTap: () => setState(() => _picked = true),
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            width: double.infinity,
            padding: const EdgeInsets.all(Gap.lg),
            decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(_picked ? Icons.check_circle : Icons.upload_file, size: 36, color: _picked ? AppColors.success : AppColors.grey), Text(_picked ? OrdersStrings.proofPicked : OrdersStrings.proofPick, style: AppText.small)])),
          ),
        ),
        TextButton(onPressed: () => context.pushReplacement('/order-success/${order.id}'), child: const Text(OrdersStrings.payLater)),
      ]),
    );
  }
}

/// Pesanan sukses (Figma 478:1178, 1804:14120): centang beranimasi, langkah berikutnya, dua tombol.
class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersProvider).where((o) => o.id == orderId).firstOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ContentFrame(padded: false, child: ListView(padding: Space.pad(context), children: [
          const SizedBox(height: Gap.xxl),
          const Center(child: SuccessMoment(title: OrdersStrings.successTitle)),
          const SizedBox(height: Gap.xl),
          if (order != null) ...[
            AppCard(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const IconChip(icon: Icons.info_outline, size: 40),
                const SizedBox(width: Gap.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(OrdersStrings.nextTitle, style: AppText.label),
                  const SizedBox(height: Gap.xs),
                  Text(order.needsProof ? OrdersStrings.nextPayProof : OrdersStrings.nextProcessing, style: AppText.small),
                ])),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(OrdersStrings.summaryTitle),
                const SizedBox(height: Gap.sm),
                for (final l in order.lines) KeyValueRow('${l.product.name} x${l.qty}', rupiah(l.total)),
                const Divider(),
                KeyValueRow(OrdersStrings.subtotal, rupiah(order.subtotal)),
                KeyValueRow(OrdersStrings.shippingFee, rupiah(order.shippingFee)),
                KeyValueRow(OrdersStrings.total, rupiah(order.total), bold: true),
                KeyValueRow(OrdersStrings.paymentLabel, order.payment == PaymentMethod.transfer ? OrdersStrings.payTransfer : OrdersStrings.payCod),
              ]),
            ),
          ],
          PillButton(label: OrdersStrings.viewOrders, onPressed: () => context.go('/orders')),
          const SizedBox(height: Gap.md),
          PillButton(label: OrdersStrings.shopAgain, outlined: true, onPressed: () => context.go('/home')),
        ])),
      ),
    );
  }
}
