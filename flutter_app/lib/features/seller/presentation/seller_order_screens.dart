import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/buyer_order_screens.dart' show statusColor;
import 'package:ikanku/features/orders/presentation/order_providers.dart';

/// Tab pesanan penjual: Baru (menunggu), Dikemas, Dikirim, Selesai, Ditolak, Pembatalan (dibatalkan), Diarsipkan.
const sellerTabs = [OrderStatus.menunggu, OrderStatus.dikemas, OrderStatus.dikirim, OrderStatus.selesai, OrderStatus.ditolak, OrderStatus.dibatalkan, OrderStatus.diarsipkan];
const sellerTabLabels = ['Baru', 'Dikemas', 'Dikirim', 'Selesai', 'Ditolak', 'Pembatalan', 'Diarsipkan'];

/// Aksi cepat: chip ikon solid + label; tinggi minimum dari token, grup setinggi anggota tertinggi.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Pressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          decoration: AppCard.decorationFor(AppColors.surface),
          minSize: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity, minHeight: Layout.quickActionMin(context.widthClass)),
            child: Padding(
              padding: EdgeInsets.all(Space.cardPadding(context)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [IconChip(icon: icon, variant: IconChipVariant.solid, size: Layout.iconChipLg), const SizedBox(height: Gap.sm), Text(label, textAlign: TextAlign.center, style: AppText.small.copyWith(fontWeight: FontWeight.w600))]),
            ),
          ),
        ),
      );
}

/// Dashboard penjual: sapaan, StatCard pesanan per status, aksi cepat (grid icon chip), pesanan terbaru.
class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final orders = ref.watch(ordersProvider);
    int count(OrderStatus s) => orders.where((o) => o.status == s).length;
    final cards = [
      ('Pesanan Baru', OrderStatus.menunggu, Icons.fiber_new_outlined),
      ('Dikemas', OrderStatus.dikemas, Icons.inventory_2_outlined),
      ('Sedang Dikirim', OrderStatus.dikirim, Icons.local_shipping_outlined),
      ('Pembatalan', OrderStatus.dibatalkan, Icons.cancel_outlined),
    ];
    final actions = [
      ('Semua Pesanan', Icons.receipt_long_outlined, '/seller/orders'),
      ('Ulasan Pembeli', Icons.rate_review_outlined, '/seller/reviews'),
      ('Atur Diskon', Icons.sell_outlined, '/seller/discount'),
      ('Tambah Produk', Icons.add_box_outlined, '/seller/products/new'),
    ];
    final latest = ([...orders]..sort((a, b) => b.createdAt.compareTo(a.createdAt))).take(3).toList();
    final first = (user?.name ?? '').trim().split(' ').first;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(padding: EdgeInsets.only(bottom: Space.minBottomClearance(context)), children: [
        HeroHeader(
          bottomPadding: Gap.xxl,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Toko Saya', style: AppText.small.copyWith(color: Colors.white)),
            Text(first.isEmpty ? 'Selamat datang!' : 'Selamat datang, $first!', style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        ContentFrame(
          safe: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: Gap.lg),
            const SectionHeader('Ringkasan pesanan', eyebrow: 'Dashboard'),
            const VGap.title(),
            EqualGrid(columns: context.isCompact ? 2 : 4, children: [
              for (final c in cards)
                Stack(children: [
                  StatCard(value: '${count(c.$2)}', label: c.$1, icon: c.$3, onTap: () => context.push('/seller/orders?tab=${sellerTabs.indexOf(c.$2)}')),
                  Positioned(left: 0, top: 0, child: SizedBox(key: Key('count-${c.$2.name}'), width: 1, height: 1)),
                ]),
            ]),
            const VGap.section(),
            const SectionHeader('Aksi cepat'),
            const VGap.title(),
            EqualGrid(columns: 2, children: [
              for (final a in actions)
                QuickActionTile(icon: a.$2, label: a.$1, onTap: () => context.push(a.$3)),
            ]),
            const VGap.section(),
            SectionHeader('Pesanan terbaru', action: 'Lihat semua', onAction: () => context.push('/seller/orders')),
            const VGap.title(),
            if (latest.isEmpty)
              const EmptyState('Belum ada pesanan', icon: Icons.receipt_long_outlined, hint: 'Pesanan baru dari pembeli akan muncul di sini.')
            else
              for (final o in latest)
                AppCard(
                  onTap: () => context.push('/seller/orders/${o.id}'),
                  child: Row(children: [
                    ProductImage(asset: o.lines.first.product.image, size: 52),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o.lines.first.product.name + (o.lines.length > 1 ? ' +${o.lines.length - 1}' : ''), style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(rupiah(o.total), style: AppText.small.copyWith(color: AppColors.grey)),
                      ]),
                    ),
                    const SizedBox(width: Gap.sm),
                    Flexible(child: StatusChip(o.status.label, color: statusColor(o.status))),
                  ]),
                ),
          ]),
        ),
      ]),
    );
  }
}

class SellerOrdersScreen extends ConsumerStatefulWidget {
  const SellerOrdersScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  ConsumerState<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends ConsumerState<SellerOrdersScreen> {
  late int _tab = widget.initialTab.clamp(0, sellerTabs.length - 1);
  int _pay = 0; // 0 semua, 1 COD, 2 NON COD (filter tab Selesai)
  @override
  Widget build(BuildContext context) {
    final done = sellerTabs[_tab] == OrderStatus.selesai;
    final items = [
      for (final o in buyerOrders(ref.watch(ordersProvider), sellerTabs[_tab]))
        if (!done || _pay == 0 || (_pay == 1) == (o.payment == PaymentMethod.cod)) o,
    ];
    final n = ref.read(ordersProvider.notifier);
    return AppScaffold(
      title: 'Pesanan',
      onBack: () => context.canPop() ? context.pop() : context.go('/seller'),
      body: Column(children: [
        const SizedBox(height: Gap.md),
        SegmentedTabs(labels: sellerTabLabels, counts: [for (final t in sellerTabs) buyerOrders(ref.watch(ordersProvider), t).length], index: _tab, onChanged: (i) => setState(() => _tab = i)),
        if (done)
          Padding(
            padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.md, context.pagePadding, 0),
            child: Wrap(spacing: 8, children: [
              for (final (i, l) in ['Semua', 'COD', 'NON COD'].indexed) ChoiceChip(key: Key('filter-$i'), label: Text(l), selected: _pay == i, onSelected: (_) => setState(() => _pay = i)),
            ]),
          ),
        Expanded(
          child: items.isEmpty
          ? EmptyState('Belum ada pesanan ${sellerTabLabels[_tab].toLowerCase()}')
          : RefreshableList(onRefresh: () async => ref.invalidate(ordersProvider), padding: Space.pad(context), children: [
              for (final o in items)
                AppCard(
                  onTap: () => context.push('/seller/orders/${o.id}'),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      ProductImage(asset: o.lines.first.product.image, size: 60),
                      const SizedBox(width: Gap.md),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o.lines.first.product.name, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(o.lines.first.variation.label, style: AppText.small),
                        Text('${o.buyerName} | ${o.payment == PaymentMethod.cod ? 'COD' : 'NON COD'}', style: AppText.small),
                        Text(rupiah(o.total), style: AppText.semi),
                        const SizedBox(height: Gap.xs),
                        StatusChip(o.status.label, color: statusColor(o.status)),
                      ])),
                    ]),
                    const SizedBox(height: Gap.sm),
                    Wrap(alignment: WrapAlignment.end, children: [
                      if (o.status == OrderStatus.menunggu) TextButton(onPressed: () => context.push('/seller/orders/${o.id}'), child: const Text('Proses Pesanan')),
                      if (o.status == OrderStatus.dikemas) TextButton(onPressed: () => context.push('/seller/orders/${o.id}/ship'), child: const Text('Kirim')),
                      if (o.status == OrderStatus.dikirim) TextButton(onPressed: () => n.complete(o.id), child: const Text('Selesai')),
                      if (o.status == OrderStatus.selesai) TextButton(onPressed: () => context.push('/orders/${o.id}/review/view'), child: const Text('Lihat Ulasan')),
                      if (o.status == OrderStatus.dibatalkan || o.status == OrderStatus.ditolak || o.status == OrderStatus.selesai) TextButton(onPressed: () => n.archive(o.id), child: Text('Hapus', style: AppText.body.copyWith(color: AppColors.danger))),
                    ]),
                  ]),
                ),
            ]),
        ),
      ]),
    );
  }
}

/// Proses pesanan / Konfirmasi pesanan / Konfirmasi bukti bayar (Figma 1121:17070, 1121:17121, 2330:5707).
class SellerOrderDetailScreen extends ConsumerWidget {
  const SellerOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  Future<void> _reject(BuildContext context, WidgetRef ref, Order o) async {
    final reason = await showDialog<String>(context: context, useRootNavigator: true, builder: (_) => const _RejectDialog());
    if (reason != null) {
      ref.read(ordersProvider.notifier).reject(o.id, reason);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(ordersProvider).where((e) => e.id == orderId).firstOrNull;
    if (o == null) return const AppScaffold(title: 'Pesanan', body: EmptyState('Pesanan tidak ditemukan'));
    final n = ref.read(ordersProvider.notifier);
    return AppScaffold(
      title: o.status == OrderStatus.menunggu ? 'Proses Pesanan' : 'Detail Pesanan',
      body: ListView(padding: Space.pad(context), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(o.id, style: AppText.semi)), const SizedBox(width: Gap.sm), StatusChip(o.status.label, color: statusColor(o.status))]),
        const SizedBox(height: Gap.md),
        for (final l in o.lines) AppCard(child: Row(children: [ProductImage(asset: l.product.image, size: 56), const SizedBox(width: Gap.md), Expanded(child: Text('${l.product.name}\n${l.variation.label}', style: AppText.body)), Text('x${l.qty}', style: AppText.small)])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('Pembeli'),
          Text('${o.address.recipient} | ${o.address.phone}', style: AppText.small),
          Text(o.address.full, style: AppText.small),
          const Divider(height: 20),
          KeyValueRow('Pembayaran', o.payment == PaymentMethod.transfer ? 'Transfer' : 'COD'),
          if (o.payment == PaymentMethod.transfer) KeyValueRow('Bukti bayar', o.proofUploaded ? 'Sudah diunggah' : 'Belum ada'),
          KeyValueRow('Pengiriman', o.shipping == ShippingMethod.kirim ? 'Kirim' : 'Jemput'),
          if (o.note.isNotEmpty) KeyValueRow('Catatan', o.note),
          const Divider(height: 20),
          KeyValueRow('Total bayar', rupiah(o.total), bold: true),
        ])),
        if (o.status == OrderStatus.menunggu)
          Row(children: [
            Expanded(child: PillButton(label: 'Tolak', color: AppColors.danger, outlined: true, onPressed: () => _reject(context, ref, o))),
            const SizedBox(width: Gap.md),
            Expanded(
              child: PillButton(
                label: 'Terima',
                onPressed: () {
                  if (!n.accept(o.id)) {
                    showMsg(context, 'Bukti pembayaran belum diunggah pembeli');
                  } else {
                    context.pop();
                  }
                },
              ),
            ),
          ]),
        if (o.status == OrderStatus.dikemas) PillButton(label: 'Atur Pengiriman', onPressed: () => context.push('/seller/orders/${o.id}/ship')),
        if (o.status == OrderStatus.dikirim) PillButton(label: 'Tandai Selesai', onPressed: () => n.complete(o.id)),
        if (o.rejectReason != null) Text('Alasan: ${o.rejectReason}', style: AppText.small.copyWith(color: AppColors.danger)),
      ]),
    );
  }
}

/// Bukti pengiriman (Figma 1121:17156, 1769:8745). Unggah foto disimulasikan.
class ShipProofScreen extends ConsumerStatefulWidget {
  const ShipProofScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<ShipProofScreen> createState() => _ShipProofScreenState();
}

class _ShipProofScreenState extends ConsumerState<ShipProofScreen> {
  bool _photo = false;
  final _note = TextEditingController();
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bukti Pengiriman',
      body: ListView(padding: Space.pad(context), children: [
        const SectionHeader('Silahkan Upload Foto Pengiriman'),
        const SizedBox(height: Gap.sm),
        InkWell(
          key: const Key('ship-photo'),
          onTap: () => setState(() => _photo = true),
          child: Container(
            height: 140,
            decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(_photo ? Icons.check_circle : Icons.add_a_photo_outlined, size: 36, color: _photo ? AppColors.success : AppColors.grey), Text(_photo ? 'Foto terpilih (simulasi)' : 'Upload Disini (simulasi)', style: AppText.small)])),
          ),
        ),
        const SizedBox(height: Gap.md),
        AppField(controller: _note, hint: 'Catatan', maxLines: 3),
        PillButton(
          label: 'Kirim',
          onPressed: !_photo
              ? null
              : () {
                  ref.read(ordersProvider.notifier).ship(widget.orderId, photo: 'simulated-photo', note: _note.text.trim());
                  context.pop();
                },
        ),
      ]),
    );
  }
}

/// Ulasan per pesanan (Figma 2582:9601, 1121:17419).
class SellerReviewsScreen extends ConsumerWidget {
  const SellerReviewsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewed = ref.watch(ordersProvider).where((o) => o.review != null).toList();
    return AppScaffold(
      title: 'Ulasan',
      body: reviewed.isEmpty
          ? const EmptyState('Belum ada ulasan')
          : ListView(padding: Space.pad(context), children: [
              for (final o in reviewed)
                AppCard(
                  onTap: () => context.push('/orders/${o.id}/review/view'),
                  child: Row(children: [
                    ProductImage(asset: o.lines.first.product.image, size: 50),
                    const SizedBox(width: Gap.md),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.lines.first.product.name, style: AppText.body), Text(o.review!.text, style: AppText.small, maxLines: 2, overflow: TextOverflow.ellipsis)])),
                    RatingStars(rating: o.review!.rating.toDouble()),
                  ]),
                ),
            ]),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();
  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _c = TextEditingController(text: 'Bukti pembayaran anda tidak valid');
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Tolak pesanan'),
        content: TextField(key: const Key('reject-input'), controller: _c, decoration: const InputDecoration(labelText: 'Alasan')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(context, _c.text), child: const Text('Tolak'))],
      );
}
