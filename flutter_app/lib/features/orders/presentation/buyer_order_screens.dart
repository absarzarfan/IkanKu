import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

const buyerTabs = [OrderStatus.menunggu, OrderStatus.dikemas, OrderStatus.dikirim, OrderStatus.selesai, OrderStatus.ditolak];
const _buyerTabLabels = ['Belum Bayar', 'Dikemas', 'Dikirim', 'Selesai', 'Ditolak'];

Color statusColor(OrderStatus s) => switch (s) {
      OrderStatus.menunggu => AppColors.star,
      OrderStatus.dikemas => AppColors.primary,
      OrderStatus.dikirim => AppColors.primary,
      OrderStatus.selesai => AppColors.success,
      OrderStatus.ditolak => AppColors.danger,
      OrderStatus.dibatalkan => AppColors.grey,
      OrderStatus.diarsipkan => AppColors.grey,
    };

/// Pesanan Saya: tab Belum Bayar/Dikemas/Dikirim/Selesai/Ditolak (Figma 1044:5000 dst).
class BuyerOrdersScreen extends ConsumerStatefulWidget {
  const BuyerOrdersScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  ConsumerState<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends ConsumerState<BuyerOrdersScreen> {
  late int _tab = widget.initialTab.clamp(0, buyerTabs.length - 1);

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(ordersProvider);
    final items = buyerOrders(all, buyerTabs[_tab]);
    return AppScaffold(
      title: 'Pesanan Saya',
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      headerExtra: TextTabs(labels: _buyerTabLabels, index: _tab, onChanged: (i) => setState(() => _tab = i), onDark: true),
      body: items.isEmpty
          ? EmptyState('Belum ada pesanan ${_buyerTabLabels[_tab].toLowerCase()}')
          : ListView(padding: const EdgeInsets.all(20), children: [for (final o in items) _OrderCard(order: o)]),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});
  final Order order;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = order.lines.first;
    final n = ref.read(ordersProvider.notifier);
    return AppCard(
      onTap: () => context.push(order.status == OrderStatus.ditolak ? '/orders/${order.id}/rejected' : '/orders/${order.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ProductImage(asset: l.product.image, size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.product.name + (order.lines.length > 1 ? ' +${order.lines.length - 1}' : ''), style: AppText.body),
              Text('Pilih Variasi ${l.variation.label}', style: AppText.small),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(rupiah(order.total), style: AppText.semi), Text('x${l.qty}', style: AppText.small)]),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          StatusChip(order.status.label, color: statusColor(order.status)),
          const Spacer(),
          if (order.status == OrderStatus.menunggu) ...[
            if (order.needsProof) TextButton(onPressed: () => context.push('/payment/${order.id}'), child: const Text('Bayar Sekarang')),
            TextButton(
              onPressed: () async {
                if (await confirmDialog(context, 'Batalkan pesanan?', order.id)) n.cancel(order.id);
              },
              child: const Text('Batal', style: TextStyle(color: AppColors.danger)),
            ),
          ],
          if (order.status == OrderStatus.selesai)
            TextButton(onPressed: () => context.push(order.review == null ? '/orders/${order.id}/review' : '/orders/${order.id}/review/view'), child: Text(order.review == null ? 'Beri Ulasan' : 'Lihat Ulasan')),
          if (order.status == OrderStatus.ditolak) TextButton(onPressed: () => context.push('/orders/${order.id}/rejected'), child: const Text('Lihat Alasan')),
        ]),
      ]),
    );
  }
}

/// Detail Pesanan / Detail Pengiriman (Figma 2128:5299, 1044:5666, 1804:14742).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(ordersProvider).where((e) => e.id == orderId).firstOrNull;
    if (o == null) return const AppScaffold(title: 'Detail Pesanan', body: EmptyState('Pesanan tidak ditemukan'));
    return AppScaffold(
      title: o.status == OrderStatus.dikirim ? 'Detail Pengiriman' : 'Detail Pesanan',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o.id, style: AppText.semi), StatusChip(o.status.label, color: statusColor(o.status))]),
        const SizedBox(height: 12),
        for (final l in o.lines)
          AppCard(child: Row(children: [
            ProductImage(asset: l.product.image, size: 60),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.product.name, style: AppText.body), Text('Pilih Variasi ${l.variation.label}', style: AppText.small)])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rupiah(l.unitPrice), style: AppText.body), Text('x${l.qty}', style: AppText.small)]),
          ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alamat Pengiriman', style: AppText.semi),
          Text('${o.address.recipient} | ${o.address.phone}', style: AppText.small),
          Text(o.address.full, style: AppText.small),
          const Divider(height: 20),
          KeyValueRow('Pengiriman', o.shipping == ShippingMethod.kirim ? 'Kirim' : 'Jemput'),
          KeyValueRow('Pembayaran', o.payment == PaymentMethod.transfer ? 'Transfer' : 'COD'),
          if (o.note.isNotEmpty) KeyValueRow('Catatan', o.note),
          if (o.shipmentNote.isNotEmpty) KeyValueRow('Catatan pengiriman', o.shipmentNote),
        ])),
        AppCard(child: Column(children: [
          KeyValueRow('Subtotal', rupiah(o.subtotal)),
          KeyValueRow('Ongkir', rupiah(o.shippingFee)),
          const Divider(),
          KeyValueRow('Total', rupiah(o.total), bold: true),
        ])),
        if (o.status == OrderStatus.selesai)
          PillButton(label: o.review == null ? 'Beri Ulasan' : 'Lihat Ulasan', onPressed: () => context.push(o.review == null ? '/orders/${o.id}/review' : '/orders/${o.id}/review/view')),
        if (o.status == OrderStatus.menunggu && o.needsProof) PillButton(label: 'Bayar Sekarang', onPressed: () => context.push('/payment/${o.id}')),
      ]),
    );
  }
}

/// Jika pesanan ditolak (Figma 2719:8984, 6438:9986).
class OrderRejectedScreen extends ConsumerWidget {
  const OrderRejectedScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(ordersProvider).where((e) => e.id == orderId).firstOrNull;
    if (o == null) return const AppScaffold(title: 'Pesanan Ditolak', body: EmptyState('Pesanan tidak ditemukan'));
    return AppScaffold(
      title: 'Pesanan Ditolak',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AppCard(color: const Color(0xFFFFF2F1), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alasan ditolak', style: AppText.semi.copyWith(color: AppColors.danger)),
          const SizedBox(height: 6),
          Text(o.rejectReason ?? 'Pesanan ditolak penjual', key: const Key('reject-reason'), style: AppText.body),
        ])),
        for (final l in o.lines) AppCard(child: Row(children: [ProductImage(asset: l.product.image, size: 56), const SizedBox(width: 12), Expanded(child: Text('${l.product.name}\n${l.variation.label}', style: AppText.body)), Text(rupiah(l.total), style: AppText.semi)])),
        Row(children: [
          Expanded(child: PillButton(label: 'Kembali', outlined: true, onPressed: () => context.canPop() ? context.pop() : context.go('/orders'))),
          const SizedBox(width: 12),
          Expanded(
            child: PillButton(
              label: 'Bayar Ulang',
              onPressed: o.status != OrderStatus.ditolak
                  ? null
                  : () {
                      ref.read(ordersProvider.notifier).repay(o.id);
                      context.pushReplacement('/payment/${o.id}');
                    },
            ),
          ),
        ]),
      ]),
    );
  }
}

/// Memberi ulasan (Figma 1804:14908) + notifikasi "Ulasan Terkirim, Terima Kasih!".
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = ref.watch(ordersProvider).where((e) => e.id == widget.orderId).firstOrNull;
    if (o == null) return const AppScaffold(title: 'Beri Ulasan', body: EmptyState('Pesanan tidak ditemukan'));
    return AppScaffold(
      title: 'Beri Ulasan',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AppCard(child: Row(children: [ProductImage(asset: o.lines.first.product.image, size: 56), const SizedBox(width: 12), Expanded(child: Text('${o.lines.first.product.name}\n${o.lines.first.variation.label}', style: AppText.body))])),
        Center(child: Text('Bagaimana pengalaman Anda?', style: AppText.semi)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 1; i <= 5; i++)
            IconButton(key: Key('star-$i'), tooltip: '$i bintang', iconSize: 36, icon: Icon(i <= _rating ? Icons.star : Icons.star_border, color: AppColors.star), onPressed: () => setState(() => _rating = i)),
        ]),
        AppField(controller: _text, hint: 'Tulis ulasan Anda', maxLines: 4),
        PillButton(
          label: 'Kirim',
          onPressed: _rating == 0
              ? null
              : () {
                  ref.read(ordersProvider.notifier).review(o.id, _rating, _text.text);
                  showMsg(context, 'Ulasan Terkirim, Terima Kasih!');
                  context.canPop() ? context.pop() : context.go('/orders');
                },
        ),
      ]),
    );
  }
}

/// Lihat ulasan (Figma 3120:6894) - dipakai pembeli dan penjual.
class ViewReviewScreen extends ConsumerWidget {
  const ViewReviewScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(ordersProvider).where((e) => e.id == orderId).firstOrNull;
    final r = o?.review;
    return AppScaffold(
      title: 'Ulasan',
      body: r == null
          ? const EmptyState('Belum ada ulasan')
          : ListView(padding: const EdgeInsets.all(20), children: [
              AppCard(color: AppColors.field, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(r.author, style: AppText.semi), RatingStars(rating: r.rating.toDouble())]),
                const SizedBox(height: 6),
                Text(r.text.isEmpty ? '(tanpa komentar)' : r.text, style: AppText.body),
              ])),
            ]),
    );
  }
}
