import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final selectedCount = ref.watch(cartSelectedProvider).length;
    final cart = ref.read(cartProvider.notifier);
    return AppScaffold(
      title: 'Keranjang',
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      bottom: lines.isEmpty
          ? null
          : Material(
              elevation: 8,
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Row(children: [
                    Checkbox(value: selectedCount == lines.length, onChanged: (v) => cart.toggleAll(v ?? false)),
                    const Text('Semua'),
                    const Spacer(),
                    Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Total', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                      Text(rupiah(subtotal), key: const Key('cart-total'), style: AppText.semi),
                    ]),
                    const SizedBox(width: 12),
                    PillButton(label: 'Beli Sekarang', expanded: false, onPressed: selectedCount == 0 ? null : () => context.push('/checkout')),
                  ]),
                ),
              ),
            ),
      body: lines.isEmpty
          ? const EmptyState('Keranjang masih kosong', icon: Icons.shopping_cart_outlined)
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final l in lines)
                Dismissible(
                  key: ValueKey(l.key),
                  direction: DismissDirection.endToStart,
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) => cart.remove(l.key),
                  child: AppCard(
                    child: Row(children: [
                      Checkbox(value: l.selected, onChanged: (_) => cart.toggle(l.key)),
                      ProductImage(asset: l.product.image, size: 64),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l.product.name, style: AppText.body),
                          Text(l.variation.label, style: AppText.small),
                          Text(rupiah(l.unitPrice), style: AppText.semi),
                          Row(children: [
                            QtyStepper(value: l.qty, onChanged: (q) => cart.setQty(l.key, q)),
                            const Spacer(),
                            IconButton(tooltip: 'Hapus', icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: () => cart.remove(l.key)),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                ),
            ]),
    );
  }
}
