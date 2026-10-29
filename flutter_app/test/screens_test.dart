import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';
import 'package:ikanku/features/seller/presentation/seller_providers.dart';
import 'package:ikanku/core/router/app_router.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('smoke: start di startup page, Masuk ke Login', (tester) async {
    await pumpApp(tester);
    expect(find.text('Jelajahi Website kami'), findsOneWidget);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Lupa kata sandi'), findsOneWidget);
  });

  testWidgets('login: validasi kosong dan kredensial salah', (tester) async {
    final c = await pumpApp(tester);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
    expect(find.text('Nomor ponsel/email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('login-id')), 'x@y.id');
    await tester.enterText(find.byKey(const Key('login-pw')), 'salahsalah');
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
    expect(find.text('Nomor/email atau kata sandi salah'), findsOneWidget);
    expect(c.read(authProvider), isNull);
  });

  testWidgets('login pembeli masuk beranda; login penjual masuk beranda toko', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    await loginAs(tester, 'fharaa@gmail.com');
    expect(find.text('Hallo, Miftahul Fazra!'), findsOneWidget);
    expect(find.text('Rekomendasi untuk anda'), findsOneWidget);
  });

  testWidgets('login penjual', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    await loginAs(tester, 'penjual@ikanku.id');
    expect(find.textContaining('SELAMAT DATANG'), findsOneWidget);
    expect(find.byKey(const Key('count-menunggu')), findsOneWidget);
  });

  testWidgets('lupa kata sandi: email valid terdaftar menampilkan konfirmasi', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lupa kata sandi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('forgot-email')), 'fharaa@gmail.com');
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('forgot-sent')), findsOneWidget);
  });

  testWidgets('registrasi: nomor -> OTP salah ditolak -> OTP benar', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('reg-phone')), '6281234567890');
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('otp-field')), '0000');
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kode salah'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('otp-field')), '1234');
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Lengkapi Data'), findsWidgets);
  });

  testWidgets('pencarian menyaring produk', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('fharaa@gmail.com', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/search');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-field')), 'cupang');
    await tester.pumpAndSettle();
    expect(find.text('Ikan Cupang'), findsOneWidget);
    expect(find.text('Ikan Nila'), findsNothing);
    await tester.enterText(find.byKey(const Key('search-field')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('Tidak ada hasil'), findsOneWidget);
  });

  testWidgets('end-to-end pembeli: detail -> variasi -> keranjang -> checkout COD -> sukses', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('fharaa@gmail.com', 'Admin123');
    await tester.pumpAndSettle();
    final before = c.read(ordersProvider).length;
    c.read(routerProvider).push('/product/nila');
    await tester.pumpAndSettle();
    expect(find.text('Deskripsi'), findsOneWidget);
    await tester.tap(find.text('Beli Sekarang'));
    await tester.pumpAndSettle();
    // Tombol aksi di sheet nonaktif sebelum variasi dipilih.
    await tester.tap(find.byKey(const Key('var-nila-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beli Sekarang').last);
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan Pemesanan'), findsOneWidget);
    await tester.tap(find.byKey(const Key('pay-cod')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Pesanan'));
    await tester.pumpAndSettle();
    expect(find.text('Apakah alamat sudah benar?'), findsOneWidget);
    await tester.tap(find.text('Ya'));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan berhasil dilakukan !'), findsOneWidget);
    expect(c.read(ordersProvider).length, before + 1);
    expect(c.read(ordersProvider).first.payment, PaymentMethod.cod);
    expect(c.read(cartProvider), isEmpty);
  });

  testWidgets('keranjang kosong menampilkan state kosong', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('fharaa@gmail.com', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).push('/cart');
    await tester.pumpAndSettle();
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
  });

  testWidgets('pesanan ditolak: alasan tampil dan Bayar Ulang memindahkan ke menunggu', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('fharaa@gmail.com', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).push('/orders/INV-1005/rejected');
    await tester.pumpAndSettle();
    expect(find.text('Bukti pembayaran anda tidak valid'), findsOneWidget);
    await tester.tap(find.text('Bayar Ulang'));
    await tester.pumpAndSettle();
    expect(c.read(ordersProvider.notifier).byId('INV-1005')!.status, OrderStatus.menunggu);
    expect(find.text('Pembayaran'), findsWidgets);
  });

  testWidgets('penjual menolak pesanan dengan alasan', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('penjual@ikanku.id', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).push('/seller/orders/INV-1001');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tolak'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('reject-input')), 'Stok habis');
    await tester.tap(find.text('Tolak').last);
    await tester.pumpAndSettle();
    final o = c.read(ordersProvider.notifier).byId('INV-1001')!;
    expect(o.status, OrderStatus.ditolak);
    expect(o.rejectReason, 'Stok habis');
  });

  testWidgets('penjual menambah produk dengan validasi lalu produk muncul di katalog', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('penjual@ikanku.id', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).push('/seller/products/new');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Nama wajib diisi'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('prod-name')), 'Ikan Mas');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Air Tawar'));
    await tester.enterText(find.byKey(const Key('var-price-0')), '25000');
    await tester.enterText(find.byKey(const Key('var-stock-0')), '10');
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(c.read(catalogProvider).products.any((p) => p.name == 'Ikan Mas' && p.variations.first.price == 25000), isTrue);
  });

  testWidgets('ongkir penjual tersimpan dan dipakai pengaturan', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('penjual@ikanku.id', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).push('/seller/ongkir');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ongkir-fee')), '15000');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(c.read(sellerSettingsProvider).shippingFee, 15000);
  });

  testWidgets('buyer tidak bisa membuka area penjual lewat URL', (tester) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login('fharaa@gmail.com', 'Admin123');
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/seller/orders');
    await tester.pumpAndSettle();
    expect(c.read(routerProvider).state.uri.path, '/home');
  });

  testWidgets('layar offline tersedia', (tester) async {
    final c = await pumpApp(tester);
    c.read(routerProvider).go('/offline');
    await tester.pumpAndSettle();
    expect(find.text('Koneksi Internet Terputus!'), findsOneWidget);
  });
}
