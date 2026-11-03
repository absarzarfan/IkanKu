import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';
import 'package:ikanku/features/orders/presentation/orders_strings.dart';

const buyerTabs = [OrderStatus.menunggu, OrderStatus.dikemas, OrderStatus.dikirim, OrderStatus.selesai, OrderStatus.ditolak];
const _buyerTabLabels = OrdersStrings.tabs;

Color statusColor(OrderStatus s) => switch (s) {
      OrderStatus.menunggu => AppColors.warning,
      OrderStatus.dikemas => AppColors.primary,
      OrderStatus.dikirim => AppColors.info,
      OrderStatus.selesai => AppColors.success,
      OrderStatus.ditolak => AppColors.danger,
      OrderStatus.dibatalkan => AppColors.grey,
      OrderStatus.diarsipkan => AppColors.grey,
    };

/// Pesanan Saya: tab Menunggu/Dikemas/Dikirim/Selesai/Ditolak (Figma 1044:5000 dst), dengan hitungan per tab.
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
      title: OrdersStrings.ordersTitle,
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      body: Column(children: [
        const SizedBox(height: Gap.md),
        SegmentedTabs(labels: _buyerTabLabels, counts: [for (final s in buyerTabs) buyerOrders(all, s).length], index: _tab, onChanged: (i) => setState(() => _tab = i)),
        const SizedBox(height: Gap.sm),
        Expanded(
          child: items.isEmpty
              ? EmptyState(OrdersStrings.emptyTab(_buyerTabLabels[_tab]), icon: Icons.receipt_long_outlined, hint: OrdersStrings.emptyHint)
              : RefreshableList(onRefresh: () async => ref.invalidate(ordersProvider), padding: Space.pad(context), children: [for (final (i, o) in items.indexed) _OrderCard(order: o, index: i)]),
        ),
      ]),
    );
  }
}

Future<void> _confirmCancel(BuildContext context, OrdersNotifier n, Order order) async {
  final ok = await confirmDialog(context, OrdersStrings.cancelTitle, OrdersStrings.cancelBody(order.id), yes: OrdersStrings.cancelYes, no: OrdersStrings.cancelNo);
  if (ok) {
    HapticFeedback.lightImpact();
    n.cancel(order.id);
  }
}

/// Strip thumbnail persegi bertumpuk (maks 3), cincin putih di antara tumpukan.
class _ThumbStrip extends StatelessWidget {
  const _ThumbStrip({required this.images});
  final List<String> images;
  @override
  Widget build(BuildContext context) {
    const side = 56.0, step = 22.0;
    final shown = images.take(3).toList();
    return ExcludeSemantics(
      child: SizedBox(
        width: side + step * (shown.length - 1),
        height: side,
        child: Stack(children: [
          for (var i = shown.length - 1; i >= 0; i--)
            Positioned(
              left: i * step,
              child: DecoratedBox(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.thumb + 2), border: Border.all(color: Colors.white, width: 2)),
                child: ProductImage(asset: shown[i], size: side - 4),
              ),
            ),
        ]),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.index});
  final Order order;
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = order.lines.first;
    final n = ref.read(ordersProvider.notifier);
    return AppCard(
      revealIndex: index,
      onTap: () => context.push(order.status == OrderStatus.ditolak ? '/orders/${order.id}/rejected' : '/orders/${order.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _ThumbStrip(images: [for (final x in order.lines) x.product.image]),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.product.name + (order.lines.length > 1 ? ' +${order.lines.length - 1}' : ''), style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(OrdersStrings.variation(l.variation.label), style: AppText.small),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(rupiah(order.total), style: AppText.semi)), const SizedBox(width: Gap.sm), Text('x${l.qty}', style: AppText.small)]),
            ]),
          ),
        ]),
        const SizedBox(height: Gap.md),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: Gap.md), child: StatusChip(order.status.label, color: statusColor(order.status))),
          const SizedBox(width: Gap.sm),
          Expanded(child: Wrap(alignment: WrapAlignment.end, crossAxisAlignment: WrapCrossAlignment.center, children: [
            if (order.status == OrderStatus.menunggu) ...[
              if (order.needsProof) TextButton(onPressed: () => context.push('/payment/${order.id}'), child: const Text(OrdersStrings.payNow)),
              TextButton(onPressed: () => _confirmCancel(context, n, order), child: Text(OrdersStrings.cancel, style: AppText.body.copyWith(color: AppColors.danger))),
            ],
            if (order.status == OrderStatus.selesai)
              TextButton(onPressed: () => context.push(order.review == null ? '/orders/${order.id}/review' : '/orders/${order.id}/review/view'), child: Text(order.review == null ? OrdersStrings.review : OrdersStrings.viewReview)),
            if (order.status == OrderStatus.ditolak) TextButton(onPressed: () => context.push('/orders/${order.id}/rejected'), child: const Text(OrdersStrings.viewReason)),
          ])),
        ]),
      ]),
    );
  }
}

/// Lini masa status. Hanya memakai data yang sudah ada: status, createdAt, proofUploaded, payment.
/// Hanya langkah pertama punya waktu (createdAt); status lain tidak menyimpan cap waktu.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});
  final Order order;

  static List<(String label, bool done, String? time)> stepsFor(Order o) {
    final s = o.status;
    final progress = switch (s) {
      OrderStatus.dikemas => 1,
      OrderStatus.dikirim => 2,
      OrderStatus.selesai => 3,
      _ => 0,
    };
    final terminal = s == OrderStatus.ditolak || s == OrderStatus.dibatalkan;
    return [
      (OrdersStrings.stepCreated, true, formatDateTime(o.createdAt)),
      if (o.payment == PaymentMethod.transfer) (o.proofUploaded || progress > 0 ? OrdersStrings.stepProof : OrdersStrings.stepProofWait, o.proofUploaded || progress > 0, null),
      if (terminal) (s == OrderStatus.ditolak ? OrdersStrings.stepRejected : OrdersStrings.stepCancelled, true, null) else ...[
        (OrdersStrings.stepPacked, progress >= 1, null),
        (OrdersStrings.stepShipped, progress >= 2, null),
        (OrdersStrings.stepDelivered, progress >= 3, null),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = stepsFor(order);
    final terminal = order.status == OrderStatus.ditolak || order.status == OrderStatus.dibatalkan;
    return Column(children: [
      for (final (i, s) in steps.indexed)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 24,
              child: Column(children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: s.$2 ? (terminal && i == steps.length - 1 ? AppColors.danger : AppColors.primary) : AppColors.surface, border: Border.all(color: s.$2 ? (terminal && i == steps.length - 1 ? AppColors.danger : AppColors.primary) : AppColors.greyLight, width: 2)),
                  child: s.$2 ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                ),
                if (i < steps.length - 1) Expanded(child: Container(width: 2, color: steps[i + 1].$2 ? AppColors.primary : AppColors.greyLight)),
              ]),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: Gap.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.$1, style: AppText.body.copyWith(fontWeight: s.$2 ? FontWeight.w600 : FontWeight.w400, color: s.$2 ? AppColors.textStrong : AppColors.grey)),
                  if (s.$3 != null) Text(s.$3!, style: AppText.small.copyWith(color: AppColors.grey)),
                ]),
              ),
            ),
          ]),
        ),
    ]);
  }
}

/// Detail Pesanan / Detail Pengiriman (Figma 2128:5299, 1044:5666, 1804:14742).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(ordersProvider).where((e) => e.id == orderId).firstOrNull;
    if (o == null) return const AppScaffold(title: OrdersStrings.detailTitle, body: EmptyState(OrdersStrings.notFound, icon: Icons.search_off));
    final n = ref.read(ordersProvider.notifier);
    return AppScaffold(
      title: o.status == OrderStatus.dikirim ? OrdersStrings.shippingDetailTitle : OrdersStrings.detailTitle,
      body: RefreshableList(onRefresh: () async => ref.invalidate(ordersProvider), padding: Space.pad(context), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(o.id, style: AppText.semi)), const SizedBox(width: Gap.sm), StatusChip(o.status.label, color: statusColor(o.status))]),
        const SizedBox(height: Gap.md),
        AppCard(
          key: const Key('order-timeline'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(OrdersStrings.timelineTitle),
            const SizedBox(height: Gap.sm),
            OrderTimeline(order: o),
          ]),
        ),
        for (final l in o.lines)
          AppCard(child: Row(children: [
            ProductImage(asset: l.product.image, size: 60),
            const SizedBox(width: Gap.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.product.name, style: AppText.body), Text(OrdersStrings.variation(l.variation.label), style: AppText.small)])),
            const SizedBox(width: Gap.sm),
            Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rupiah(l.unitPrice), style: AppText.body), Text('x${l.qty}', style: AppText.small)])),
          ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(OrdersStrings.addressTitle),
          Text('${o.address.recipient} | ${o.address.phone}', style: AppText.small),
          Text(o.address.full, style: AppText.small),
          const Divider(height: 20),
          KeyValueRow('Pengiriman', o.shipping == ShippingMethod.kirim ? OrdersStrings.shipSend : OrdersStrings.shipPickup),
          KeyValueRow(OrdersStrings.paymentLabel, o.payment == PaymentMethod.transfer ? OrdersStrings.payTransfer : OrdersStrings.payCod),
          if (o.note.isNotEmpty) KeyValueRow('Catatan', o.note),
          if (o.shipmentNote.isNotEmpty) KeyValueRow('Catatan pengiriman', o.shipmentNote),
        ])),
        AppCard(child: Column(children: [
          KeyValueRow(OrdersStrings.subtotal, rupiah(o.subtotal)),
          KeyValueRow(OrdersStrings.shippingFee, rupiah(o.shippingFee)),
          const Divider(),
          KeyValueRow(OrdersStrings.total, rupiah(o.total), bold: true),
        ])),
        if (o.status == OrderStatus.selesai)
          PillButton(label: o.review == null ? OrdersStrings.review : OrdersStrings.viewReview, onPressed: () => context.push(o.review == null ? '/orders/${o.id}/review' : '/orders/${o.id}/review/view')),
        if (o.status == OrderStatus.menunggu && o.needsProof) PillButton(label: OrdersStrings.payNow, onPressed: () => context.push('/payment/${o.id}')),
        if (o.status == OrderStatus.menunggu) ...[
          const SizedBox(height: Gap.md),
          PillButton(label: OrdersStrings.cancelOrder, outlined: true, color: AppColors.danger, onPressed: () => _confirmCancel(context, n, o)),
        ],
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
    if (o == null) return const AppScaffold(title: 'Pesanan Ditolak', body: EmptyState(OrdersStrings.notFound, icon: Icons.search_off));
    return AppScaffold(
      title: 'Pesanan Ditolak',
      body: ListView(padding: Space.pad(context), children: [
        AppCard(color: AppColors.dangerSoft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alasan ditolak', style: AppText.semi.copyWith(color: AppColors.danger)),
          const SizedBox(height: Gap.sm),
          Text(o.rejectReason ?? 'Pesanan ditolak penjual', key: const Key('reject-reason'), style: AppText.body),
        ])),
        for (final l in o.lines) AppCard(child: Row(children: [ProductImage(asset: l.product.image, size: 56), const SizedBox(width: Gap.md), Expanded(child: Text('${l.product.name}\n${l.variation.label}', style: AppText.body)), const SizedBox(width: Gap.sm), Flexible(child: Text(rupiah(l.total), style: AppText.semi))])),
        Row(children: [
          Expanded(child: PillButton(label: 'Kembali', outlined: true, onPressed: () => context.canPop() ? context.pop() : context.go('/orders'))),
          const SizedBox(width: Gap.md),
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

/// Memberi ulasan (Figma 1804:14908): bintang ketuk dengan animasi kecil, penghitung karakter, validasi.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  bool _submitted = false;
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send(Order o) {
    if (_rating == 0) {
      HapticFeedback.mediumImpact();
      setState(() => _submitted = true);
      return;
    }
    ref.read(ordersProvider.notifier).review(o.id, _rating, _text.text);
    HapticFeedback.lightImpact();
    showMsg(context, OrdersStrings.reviewSent);
    context.canPop() ? context.pop() : context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final o = ref.watch(ordersProvider).where((e) => e.id == widget.orderId).firstOrNull;
    if (o == null) return const AppScaffold(title: OrdersStrings.reviewTitle, body: EmptyState(OrdersStrings.notFound, icon: Icons.search_off));
    return AppScaffold(
      title: OrdersStrings.reviewTitle,
      bottom: StickyActionBar(child: PillButton(label: OrdersStrings.reviewSend, onPressed: () => _send(o))),
      body: ListView(padding: Space.pad(context), children: [
        AppCard(child: Row(children: [ProductImage(asset: o.lines.first.product.image, size: 56), const SizedBox(width: Gap.md), Expanded(child: Text('${o.lines.first.product.name}\n${o.lines.first.variation.label}', style: AppText.body))])),
        Center(child: Text(OrdersStrings.reviewAsk, style: AppText.semi)),
        Wrap(alignment: WrapAlignment.center, children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              key: Key('star-$i'),
              tooltip: '$i bintang',
              iconSize: 36,
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _rating = i);
              },
              icon: AnimatedScale(
                scale: i == _rating ? 1.2 : 1,
                duration: AppMotion.of(context, AppMotion.fast),
                curve: AppMotion.curve,
                child: Icon(i <= _rating ? Icons.star : Icons.star_border, color: AppColors.star),
              ),
            ),
        ]),
        if (_submitted && _rating == 0) Center(child: Padding(padding: const EdgeInsets.only(bottom: Gap.md), child: Text(OrdersStrings.reviewNeedStars, key: const Key('review-error'), style: AppText.small.copyWith(color: AppColors.danger)))),
        AppField(controller: _text, hint: OrdersStrings.reviewHint, maxLines: 4, maxLength: OrdersStrings.reviewMax, textInputAction: TextInputAction.newline, keyboard: TextInputType.multiline),
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
          ? const EmptyState('Belum ada ulasan', icon: Icons.rate_review_outlined)
          : ListView(padding: Space.pad(context), children: [
              AppCard(color: AppColors.field, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(r.author, style: AppText.semi), RatingStars(rating: r.rating.toDouble())]),
                const SizedBox(height: Gap.sm),
                Text(r.text.isEmpty ? '(tanpa komentar)' : r.text, style: AppText.body),
              ])),
            ]),
    );
  }
}
