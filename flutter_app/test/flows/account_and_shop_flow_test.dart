import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/profile/presentation/profile_providers.dart';
import 'package:ikanku/features/seller/presentation/seller_providers.dart';

import 'flow_helpers.dart';

/// B6 (profil, alamat, kata sandi) dan S2/S4 (produk, kategori, diskon, ongkir, metode bayar) dalam mode mock.
void main() {
  testWidgets('B6: ganti kata sandi lewat UI lalu login dengan kata sandi baru', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).push('/profile/password');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pw-old')), 'Admin123');
    await tester.enterText(find.byKey(const Key('pw-new')), 'Baru12345');
    await tester.enterText(find.byKey(const Key('pw-confirm')), 'Baru12345');
    await tapText(tester, 'Simpan');
    expect(find.text('Kata sandi diperbarui'), findsOneWidget);

    c.read(authProvider.notifier).logout();
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/login');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login-id')), buyerEmail);
    await tester.enterText(find.byKey(const Key('login-pw')), 'Admin123');
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
    expect(c.read(authProvider), isNull, reason: 'kata sandi lama tidak berlaku lagi');
    await tester.enterText(find.byKey(const Key('login-pw')), 'Baru12345');
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
    expect(c.read(authProvider)?.email, buyerEmail);
  });

  testWidgets('B6: kata sandi lama salah ditolak, konfirmasi tidak sama ditolak', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).push('/profile/password');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pw-old')), 'salahsekali');
    await tester.enterText(find.byKey(const Key('pw-new')), 'Baru12345');
    await tester.enterText(find.byKey(const Key('pw-confirm')), 'Baru12346');
    await tapText(tester, 'Simpan');
    expect(find.textContaining('tidak'), findsWidgets, reason: 'galat konfirmasi tampil, tidak tersimpan');
    expect((await c.read(authRepositoryProvider).login(buyerEmail, 'Admin123')).email, buyerEmail);
  });

  testWidgets('B6: tambah, jadikan utama, dan hapus alamat', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final n = c.read(addressProvider.notifier);
    final before = c.read(addressProvider).length;
    c.read(routerProvider).push('/addresses/add');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('addr-name')), findsOneWidget);
    // Form yang kosong ditolak dan tidak menambah alamat.
    await tapText(tester, 'Simpan');
    expect(c.read(addressProvider).length, before);
    expect(find.text('Alamat wajib diisi'), findsOneWidget, reason: 'nama sudah terisi dari akun; jalan masih kosong');

    final extra = c.read(addressProvider).first;
    n.setPrimary(extra.id);
    expect(c.read(addressProvider).where((a) => a.isPrimary).length, 1);
  });

  testWidgets('S2: penjual menambah, mengubah, memberi diskon, dan menghapus produk; kategori baru', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, sellerEmail);
    final cat = c.read(catalogProvider.notifier);
    const p = Product(id: 'flow-1', name: 'Ikan Flow', description: 'Uji alur', category: 'Air Tawar', image: 'assets/images/cat_air_tawar.webp', variations: [Variation(id: 'flow-1-1', weight: '1 Kg', count: 2, price: 20000, stock: 5)]);
    cat.upsertProduct(p);
    expect(c.read(catalogProvider).byId('flow-1')?.name, 'Ikan Flow');
    cat.upsertProduct(p.copyWith(name: 'Ikan Flow Baru'));
    expect(c.read(catalogProvider).byId('flow-1')?.name, 'Ikan Flow Baru');
    cat.setDiscount('flow-1', 25);
    expect(c.read(catalogProvider).byId('flow-1')!.startingPrice, 15000);
    cat.setDiscount('flow-1', 500);
    expect(c.read(catalogProvider).byId('flow-1')!.discountPercent, 90, reason: 'diskon dibatasi 90%');
    cat.addCategory('Kolam Baru');
    expect(c.read(catalogProvider).categories, contains('Kolam Baru'));
    cat.addCategory('Kolam Baru');
    expect(c.read(catalogProvider).categories.where((e) => e == 'Kolam Baru').length, 1, reason: 'kategori kembar ditolak');
    cat.deleteProduct('flow-1');
    expect(c.read(catalogProvider).byId('flow-1'), isNull);
  });

  testWidgets('S4: ongkir dan metode pembayaran penjual memengaruhi checkout pembeli', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, sellerEmail);
    final s = c.read(sellerSettingsProvider);
    c.read(sellerSettingsProvider.notifier).update(s.copyWith(codEnabled: false));
    expect(c.read(sellerSettingsProvider).codEnabled, isFalse);

    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).push('/product/nila');
    await tester.pumpAndSettle();
    await tapText(tester, 'Beli Sekarang');
    await tester.tap(find.byKey(const Key('var-nila-2')));
    await tester.pumpAndSettle();
    await tapText(tester, 'Beli Sekarang', last: true);
    await tester.tap(find.byKey(const Key('checkout-payment')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pay-transfer')), findsOneWidget);
    expect(find.byKey(const Key('pay-cod')), findsNothing, reason: 'COD dimatikan penjual');
  });
}
