import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';

import '../flows/flow_helpers.dart';

Rect _r(WidgetTester t, String k) => t.getRect(find.byKey(Key(k)));

void main() {
  testWidgets('bottom bar tampil di semua rute level-jelajah dan hilang di layar tugas fokus', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    for (final p in ['/home', '/search', '/profile', '/recommendations', '/category/Semua', '/category/Hias', '/orders', '/addresses', '/help', '/shop/Tibelat%20Farm']) {
      c.read(routerProvider).go(p);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('app-bottom-bar')), findsOneWidget, reason: 'bar harus tampil di $p');
    }
    for (final p in ['/product/nila', '/cart', '/checkout', '/profile/data', '/addresses/add']) {
      c.read(routerProvider).go(p);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('app-bottom-bar')), findsNothing, reason: 'bar harus hilang di $p');
    }
  });

  testWidgets('bottom bar penjual tampil di daftar pesanan dan ulasan', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, sellerEmail);
    for (final p in ['/seller', '/seller/orders', '/seller/reviews', '/seller/products', '/seller/settings', '/seller/help']) {
      c.read(routerProvider).go(p);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('app-bottom-bar')), findsOneWidget, reason: 'bar harus tampil di $p');
    }
  });

  testWidgets('sheet filter memakai root navigator: scrim menutupi bottom bar', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).go('/search');
    await tester.pumpAndSettle();
    final bar = tester.getRect(find.byKey(const Key('app-bottom-bar')));
    await tester.tap(find.byKey(const Key('search-filter')));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.text('Filter & urutkan').first);
    expect(Navigator.of(ctx), same(Navigator.of(ctx, rootNavigator: true)));
    final scrim = tester.getRect(find.byType(ModalBarrier).last);
    expect(scrim.contains(bar.topLeft) && scrim.contains(bar.bottomRight - const Offset(1, 1)), isTrue, reason: 'scrim menutupi bar');
  });

  testWidgets('badge tab Profil tidak menimpa kotak ikon', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).go('/home');
    await tester.pumpAndSettle();
    final badge = _r(tester, 'nav-badge-2');
    final icon = _r(tester, 'nav-icon-2');
    expect(badge.overlaps(icon), isFalse);
    expect(badge.width, greaterThanOrEqualTo(18));
    expect(badge.top, lessThan(icon.top + 1));
  });

  testWidgets('hitungan langsung di sheet filter = hasil yang diterapkan', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).go('/search');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('search-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4.5+'));
    await tester.pumpAndSettle();
    final label = tester.widget<Text>(find.descendant(of: find.byKey(const Key('filter-apply')), matching: find.byType(Text)).first).data!;
    final n = int.parse(RegExp(r'(\d+) produk').firstMatch(label)!.group(1)!);
    await tester.tap(find.byKey(const Key('filter-apply')));
    await tester.pumpAndSettle();
    expect(find.text('$n produk ditemukan'), findsOneWidget);
  });

  testWidgets('galeri /dev/gallery ada di debug+mock dan render komponen', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).go('/dev/gallery');
    await tester.pumpAndSettle();
    expect(find.text('Galeri komponen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
