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

/// Beranda penjual / daftar harian aktivitas (Figma 1799:12083, 1769:7716).
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
    return AppScaffold(
      title: 'Toko Saya',
      showBack: false,
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('SELAMAT DATANG, ${(user?.name ?? '').toUpperCase()}!', style: AppText.semi.copyWith(fontSize: 18)),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            for (final c in cards)
              AppCard(
                margin: EdgeInsets.zero,
                onTap: () => context.push('/seller/orders?tab=${sellerTabs.indexOf(c.$2)}'),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Icon(c.$3, color: AppColors.primary),
                  Text('${count(c.$2)}', key: Key('count-${c.$2.name}'), style: AppText.price),
                  Text(c.$1.toUpperCase(), style: AppText.small),
                ]),
              ),
          ],
        ),
        const SizedBox(height: 16),
        PillButton(label: 'Semua Pesanan', onPressed: () => context.push('/seller/orders')),
        const SizedBox(height: 10),
        PillButton(label: 'Ulasan Pembeli', outlined: true, onPressed: () => context.push('/seller/reviews')),
        const SizedBox(height: 10),
        PillButton(label: 'Atur Diskon', outlined: true, onPressed: () => context.push('/seller/discount')),
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
      headerExtra: TextTabs(labels: sellerTabLabels, index: _tab, onChanged: (i) => setState(() => _tab = i), onDark: true),
      body: Column(children: [
        if (done)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Wrap(spacing: 8, children: [
              for (final (i, l) in ['Semua', 'COD', 'NON COD'].indexed) ChoiceChip(key: Key('filter-$i'), label: Text(l), selected: _pay == i, onSelected: (_) => setState(() => _pay = i)),
            ]),
          ),
        Expanded(
          child: items.isEmpty
          ? EmptyState('Belum ada pesanan ${sellerTabLabels[_tab].toLowerCase()}')
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final o in items)
                AppCard(
                  onTap: () => context.push('/seller/orders/${o.id}'),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      ProductImage(asset: o.lines.first.product.image, size: 60),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o.lines.first.product.name, style: AppText.body),
                        Text(o.lines.first.variation.label, style: AppText.small),
                        Text('${o.buyerName} | ${o.payment == PaymentMethod.cod ? 'COD' : 'NON COD'}', style: AppText.small),
                        Text(rupiah(o.total), style: AppText.semi),
                      ])),
                      StatusChip(o.status.label, color: statusColor(o.status)),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      if (o.status == OrderStatus.menunggu) TextButton(onPressed: () => context.push('/seller/orders/${o.id}'), child: const Text('Proses Pesanan')),
                      if (o.status == OrderStatus.dikemas) TextButton(onPressed: () => context.push('/seller/orders/${o.id}/ship'), child: const Text('Kirim')),
                      if (o.status == OrderStatus.dikirim) TextButton(onPressed: () => n.complete(o.id), child: const Text('Selesai')),
                      if (o.status == OrderStatus.selesai) TextButton(onPressed: () => context.push('/orders/${o.id}/review/view'), child: const Text('Lihat Ulasan')),
                      if (o.status == OrderStatus.dibatalkan || o.status == OrderStatus.ditolak || o.status == OrderStatus.selesai) TextButton(onPressed: () => n.archive(o.id), child: const Text('Hapus', style: TextStyle(color: AppColors.danger))),
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
    final reason = await showDialog<String>(context: context, builder: (_) => const _RejectDialog());
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
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o.id, style: AppText.semi), StatusChip(o.status.label, color: statusColor(o.status))]),
        const SizedBox(height: 12),
        for (final l in o.lines) AppCard(child: Row(children: [ProductImage(asset: l.product.image, size: 56), const SizedBox(width: 12), Expanded(child: Text('${l.product.name}\n${l.variation.label}', style: AppText.body)), Text('x${l.qty}', style: AppText.small)])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pembeli', style: AppText.semi),
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
            const SizedBox(width: 12),
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
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Silahkan Upload Foto Pengiriman', style: AppText.semi),
        const SizedBox(height: 8),
        InkWell(
          key: const Key('ship-photo'),
          onTap: () => setState(() => _photo = true),
          child: Container(
            height: 140,
            decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(_photo ? Icons.check_circle : Icons.add_a_photo_outlined, size: 36, color: _photo ? AppColors.success : AppColors.grey), Text(_photo ? 'Foto terpilih (simulasi)' : 'Upload Disini (simulasi)', style: AppText.small)])),
          ),
        ),
        const SizedBox(height: 14),
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
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final o in reviewed)
                AppCard(
                  onTap: () => context.push('/orders/${o.id}/review/view'),
                  child: Row(children: [
                    ProductImage(asset: o.lines.first.product.image, size: 50),
                    const SizedBox(width: 12),
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
