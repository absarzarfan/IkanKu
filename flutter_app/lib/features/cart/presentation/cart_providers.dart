import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/orders/domain/orders.dart';

class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => const [];

  /// Menambah item; variasi yang sama digabung (qty dijumlah, dibatasi stok).
  void add(Product product, Variation variation, {int qty = 1}) {
    final line = CartLine(product: product, variation: variation, qty: qty);
    final i = state.indexWhere((l) => l.key == line.key);
    if (i < 0) {
      state = [...state, line];
    } else {
      final merged = (state[i].qty + qty).clamp(1, variation.stock < 1 ? 1 : variation.stock);
      state = [for (var j = 0; j < state.length; j++) j == i ? state[j].copyWith(qty: merged) : state[j]];
    }
  }

  void setQty(String key, int qty) {
    if (qty < 1) return;
    state = [for (final l in state) l.key == key ? l.copyWith(qty: qty.clamp(1, l.variation.stock < 1 ? 1 : l.variation.stock)) : l];
  }

  void toggle(String key) => state = [for (final l in state) l.key == key ? l.copyWith(selected: !l.selected) : l];

  void toggleAll(bool value) => state = [for (final l in state) l.copyWith(selected: value)];

  void remove(String key) => state = state.where((l) => l.key != key).toList();

  void removeSelected() => state = state.where((l) => !l.selected).toList();

  /// Pembelian langsung tanpa melalui keranjang (tombol "Beli Sekarang").
  List<CartLine> get selected => state.where((l) => l.selected).toList();
}

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(CartNotifier.new);

final cartSelectedProvider = Provider<List<CartLine>>((ref) => ref.watch(cartProvider).where((l) => l.selected).toList());

final cartSubtotalProvider = Provider<int>((ref) => ref.watch(cartSelectedProvider).fold(0, (s, l) => s + l.total));

final cartCountProvider = Provider<int>((ref) => ref.watch(cartProvider).fold(0, (s, l) => s + l.qty));
