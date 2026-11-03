import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';

import 'flow_helpers.dart';

/// A1: admin mode mock. Nonaktifkan produk/pengguna lalu aktifkan lagi.
void main() {
  testWidgets('admin: panel tampil tanpa pesan Supabase, daftar pengguna, pesanan dengan filter, produk', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, adminEmail);
    await tapText(tester, 'Pengguna'); // Phase 15R: tab awal admin = Ringkasan
    expect(c.read(routerProvider).state.uri.path, '/admin');
    expect(find.textContaining('memerlukan koneksi Supabase'), findsNothing);
    expect(find.text('Rina Putri'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('admin-search')), 'dedi');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Dedi Kurniawan'), findsOneWidget);
    expect(find.text('Rina Putri'), findsNothing);

    await tapText(tester, 'Pesanan');
    expect(find.textContaining('INV-1001'), findsOneWidget);
    expect(find.textContaining('INV-1006'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('admin-status-Selesai')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin-status-Selesai')));
    await tester.pumpAndSettle();
    expect(find.textContaining('INV-1004'), findsOneWidget);
    expect(find.textContaining('INV-1001'), findsNothing);
  });

  testWidgets('admin menonaktifkan produk: hilang dari katalog pembeli; diaktifkan lagi: muncul kembali', (tester) async {
    final c = await startApp(tester);
    expect(c.read(catalogProvider).byId('nila'), isNotNull);
    await switchTo(tester, c, adminEmail);
    await tapText(tester, 'Pengguna'); // Phase 15R: tab awal admin = Ringkasan
    await tapText(tester, 'Produk');
    await tester.tap(find.byKey(const Key('product-nila')));
    await tester.pumpAndSettle();
    expect(c.read(catalogProvider).byId('nila'), isNull, reason: 'produk nonaktif tidak ada di katalog');

    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).go('/search');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-field')), 'nila');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Ikan Nila'), findsNothing);

    await switchTo(tester, c, adminEmail);
    await tapText(tester, 'Pengguna'); // Phase 15R: tab awal admin = Ringkasan
    await tapText(tester, 'Produk');
    await tester.tap(find.byKey(const Key('product-nila')));
    await tester.pumpAndSettle();
    expect(c.read(catalogProvider).byId('nila'), isNotNull);
  });

  testWidgets('admin menonaktifkan pengguna: tidak bisa login (pesan ramah); diaktifkan lagi: bisa login', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, adminEmail);
    await tapText(tester, 'Pengguna'); // Phase 15R: tab awal admin = Ringkasan
    await tester.tap(find.byKey(const Key('user-b2')));
    await tester.pumpAndSettle();

    c.read(authProvider.notifier).logout();
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/login');
    await tester.pumpAndSettle();
    await loginAs(tester, 'rina@ikanku.id');
    expect(c.read(authProvider), isNull);
    expect(find.textContaining('dinonaktifkan'), findsOneWidget);

    await switchTo(tester, c, adminEmail);
    await tapText(tester, 'Pengguna'); // Phase 15R: tab awal admin = Ringkasan
    await tester.tap(find.byKey(const Key('user-b2')));
    await tester.pumpAndSettle();
    await switchTo(tester, c, 'rina@ikanku.id');
    expect(c.read(authProvider)?.email, 'rina@ikanku.id');
  });
}
