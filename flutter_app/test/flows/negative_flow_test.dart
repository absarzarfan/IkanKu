import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

import 'flow_helpers.dart';

/// Kasus negatif: keranjang kosong, stok, transisi status tidak valid, penjaga peran, logout.
void main() {
  testWidgets('keranjang kosong tidak bisa checkout', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).push('/cart');
    await tester.pumpAndSettle();
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
    expect(find.textContaining('Beli ('), findsNothing);
    c.read(routerProvider).push('/checkout');
    await tester.pumpAndSettle();
    expect(find.text('Buat Pesanan'), findsNothing);
    expect(find.text('Belum ada item yang dipilih'), findsOneWidget);
  });

  testWidgets('jumlah di atas stok ditolak (keranjang dan sheet variasi)', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final p = c.read(catalogProvider).byId('nila')!;
    final v = p.variations.last;
    final cart = c.read(cartProvider.notifier);
    cart.add(p, v, qty: v.stock);
    cart.add(p, v, qty: 5);
    expect(c.read(cartProvider).first.qty, v.stock, reason: 'gabung item dibatasi stok');
    cart.setQty('${p.id}|${v.id}', v.stock + 100);
    expect(c.read(cartProvider).first.qty, v.stock);

    // Sheet variasi: tombol tambah nonaktif pada batas stok.
    c.read(routerProvider).push('/product/${p.id}');
    await tester.pumpAndSettle();
    await tapText(tester, 'Masukkan Keranjang');
    await tester.tap(find.byKey(Key('var-${v.id}')));
    await tester.pumpAndSettle();
    final plus = find.widgetWithIcon(IconButton, Icons.add_circle_outline);
    for (var i = 0; i < v.stock + 3; i++) {
      final b = tester.widget<IconButton>(plus);
      if (b.onPressed == null) break;
      b.onPressed!();
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(plus).onPressed, isNull);
    expect(find.text('Jumlah maksimal sesuai stok'), findsOneWidget);
  });

  testWidgets('transisi status tidak valid ditolak dan tombolnya tidak ditawarkan', (tester) async {
    final c = await startApp(tester);
    final n = c.read(ordersProvider.notifier);
    expect(n.accept('INV-1003'), isFalse, reason: 'dikirim tidak bisa diterima');
    expect(n.ship('INV-1001', photo: 'x'), isFalse, reason: 'menunggu tidak bisa dikirim');
    expect(n.complete('INV-1001'), isFalse, reason: 'menunggu tidak bisa selesai');
    expect(n.reject('INV-1002', 'x'), isFalse, reason: 'dikemas tidak bisa ditolak');
    expect(n.review('INV-1002', 5, 'x'), isFalse, reason: 'belum selesai tidak bisa diulas');
    expect(n.archive('INV-1001'), isFalse, reason: 'pesanan berjalan tidak bisa diarsipkan');
    expect(orderById(c, 'INV-1003').status, OrderStatus.dikirim);

    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/orders/INV-1003');
    await tester.pumpAndSettle();
    expect(find.text('Terima'), findsNothing);
    expect(find.text('Tolak'), findsNothing);
    expect(find.text('Tandai Selesai'), findsOneWidget);
  });

  testWidgets('penjaga peran: pembeli, penjual, tamu', (tester) async {
    final c = await startApp(tester);
    final r = c.read(routerProvider);
    await switchTo(tester, c, buyerEmail);
    r.go('/seller');
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/home');
    r.go('/admin');
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/home');
    r.go('/seller/orders');
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/home');

    await switchTo(tester, c, sellerEmail);
    r.go('/cart');
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/seller');
    r.go('/admin');
    await tester.pumpAndSettle();
    expect(r.state.uri.path, '/seller');

    c.read(authProvider.notifier).logout();
    await tester.pumpAndSettle();
    for (final path in ['/cart', '/orders', '/seller', '/admin', '/profile']) {
      r.go(path);
      await tester.pumpAndSettle();
      expect(r.state.uri.path, '/login', reason: '$path tanpa login');
    }
  });

  testWidgets('logout mengosongkan keranjang dan sesi', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final p = c.read(catalogProvider).byId('nila')!;
    c.read(cartProvider.notifier).add(p, p.variations.first);
    expect(c.read(cartProvider), isNotEmpty);
    c.read(authProvider.notifier).logout();
    await tester.pumpAndSettle();
    expect(c.read(authProvider), isNull);
    expect(c.read(cartProvider), isEmpty, reason: 'keranjang tidak boleh terbawa ke pengguna berikutnya');
    expect(c.read(routerProvider).state.uri.path, '/login');
  });
}
