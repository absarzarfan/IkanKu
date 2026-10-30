import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/common/presentation/common_screens.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Sesuaikan lokasi: placeholder statis mengembalikan label', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('fharaa@gmail.com', 'Admin123');
    await tester.pumpAndSettle();
    final result = c.read(routerProvider).push<String>('/pick-location');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('map-placeholder')), findsOneWidget);
    await tester.tap(find.text('Gunakan Lokasi Ini'));
    await tester.pumpAndSettle();
    expect(await result, PickLocationScreen.placeholderLabel);
  });

  testWidgets('Filter pesanan selesai: COD / NON COD', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('penjual@ikanku.id', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/seller/orders?tab=3');
    await tester.pumpAndSettle();
    expect(find.textContaining('| NON COD'), findsOneWidget);
    await tester.tap(find.byKey(const Key('filter-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('| NON COD'), findsNothing);
    expect(find.text('Belum ada pesanan selesai'), findsOneWidget);
    await tester.tap(find.byKey(const Key('filter-2')));
    await tester.pumpAndSettle();
    expect(find.textContaining('| NON COD'), findsOneWidget);
  });

  testWidgets('Ubah kategori: nama berubah di katalog', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('penjual@ikanku.id', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/seller/categories/Hias/edit');
    await tester.pumpAndSettle();
    expect(find.text('Ubah Kategori'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('cat-name')), 'Ikan Hias');
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();
    final cats = c.read(catalogProvider).categories;
    expect(cats, contains('Ikan Hias'));
    expect(cats, isNot(contains('Hias')));
  });

  testWidgets('Halaman toko menampilkan produk penjual', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('fharaa@gmail.com', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/shop/Tibelat%20Farm');
    await tester.pumpAndSettle();
    expect(find.text('Toko'), findsOneWidget);
    expect(find.text('Tibelat Farm'), findsOneWidget);
  });
}
