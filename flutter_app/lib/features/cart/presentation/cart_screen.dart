import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/cart/presentation/cart_strings.dart';
import 'package:ikanku/features/orders/domain/orders.dart';

/// Keranjang: item dikelompokkan per toko, geser untuk hapus dengan Urungkan, stepper dibatasi stok,
/// total berubah dengan fade, bilah checkout lengket di bawah.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _remove(BuildContext context, CartNotifier cart, List<CartLine> lines, CartLine l) {
    final index = lines.indexWhere((e) => e.key == l.key);
    cart.remove(l.key);
    HapticFeedback.lightImpact();
    showActionMsg(context, CartStrings.removed, actionLabel: CartStrings.undo, onAction: () => cart.restore(l, index));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final selectedCount = ref.watch(cartSelectedProvider).length;
    final cart = ref.read(cartProvider.notifier);
    final shops = <String, List<CartLine>>{};
    for (final l in lines) {
      shops.putIfAbsent(l.product.sellerName, () => []).add(l);
    }
    return AppScaffold(
      title: CartStrings.title,
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      bottom: lines.isEmpty
          ? null
          : StickyActionBar(
              child: Row(children: [
                Checkbox(value: selectedCount == lines.length, onChanged: (v) => cart.toggleAll(v ?? false)),
                const Text(CartStrings.selectAll),
                const Spacer(),
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(CartStrings.total, style: AppText.caption.copyWith(color: AppColors.grey)),
                  AnimatedSwitcher(
                    key: const Key('cart-total'),
                    duration: AppMotion.of(context, AppMotion.fast),
                    switchInCurve: AppMotion.curve,
                    child: Text(rupiah(subtotal), key: ValueKey(subtotal), style: AppText.semi),
                  ),
                ]),
                const SizedBox(width: Gap.md),
                PillButton(label: CartStrings.buy(selectedCount), expanded: false, onPressed: selectedCount == 0 ? null : () => context.push('/checkout')),
              ]),
            ),
      body: lines.isEmpty
          ? EmptyState(CartStrings.empty, icon: Icons.shopping_cart_outlined, hint: CartStrings.emptyHint, actionLabel: CartStrings.shopNow, onAction: () => context.go('/home'))
          : ListView(padding: Space.pad(context), children: [
              for (final shop in shops.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: Gap.sm),
                  child: Row(children: [
                    const IconChip(icon: Icons.storefront, size: 40),
                    const SizedBox(width: Gap.sm),
                    Expanded(child: Text(shop.key, style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
                for (final l in shop.value)
                  Dismissible(
                    key: ValueKey(l.key),
                    direction: DismissDirection.endToStart,
                    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: Gap.xl), margin: const EdgeInsets.only(bottom: Gap.md), decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppRadius.card)), child: const Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (_) => _remove(context, cart, lines, l),
                    child: AppCard(
                      child: Row(children: [
                        Checkbox(value: l.selected, onChanged: (_) => cart.toggle(l.key)),
                        ProductImage(asset: l.product.image, size: 64),
                        const SizedBox(width: Gap.md),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.product.name, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text(l.variation.label, style: AppText.small),
                            Text(rupiah(l.unitPrice), style: AppText.semi),
                            Row(children: [
                              QtyStepper(value: l.qty, max: l.variation.stock < 1 ? 1 : l.variation.stock, onChanged: (q) => cart.setQty(l.key, q)),
                              const Spacer(),
                              IconButton(tooltip: CartStrings.remove, icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: () => _remove(context, cart, lines, l)),
                            ]),
                            if (l.qty >= l.variation.stock) Text(CartStrings.maxStock, style: AppText.caption.copyWith(color: AppColors.grey)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
              ],
              AppCard(
                key: const Key('cart-summary'),
                margin: const EdgeInsets.only(top: Gap.sm),
                child: Column(children: [
                  KeyValueRow('Item dipilih', '$selectedCount'),
                  KeyValueRow('Subtotal', rupiah(subtotal)),
                  Align(alignment: Alignment.centerLeft, child: Text('Ongkir dihitung di checkout.', style: AppText.caption.copyWith(color: AppColors.grey))),
                ]),
              ),
            ]),
    );
  }
}
