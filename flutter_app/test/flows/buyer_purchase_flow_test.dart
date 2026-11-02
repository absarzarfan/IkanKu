import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

import 'flow_helpers.dart';

/// B2 + B3 (+ B4 awal): pembeli mencari, memilih variasi, mengubah jumlah, checkout COD dan NON COD.
void main() {
  testWidgets('pembeli COD: login -> cari -> produk -> variasi -> keranjang -> ubah jumlah -> checkout -> sukses -> daftar pesanan', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);

    // Cari. Hasil memakai debounce 300 ms.
    c.read(routerProvider).go('/search');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-field')), 'nila');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-count')), findsOneWidget);
    await tapText(tester, 'Ikan Nila');
    expect(find.text('Deskripsi'), findsOneWidget);

    // Variasi dalam sheet (jumlah 2), lalu keranjang dikelompokkan per toko; jumlah diubah menjadi 1.
    await tapText(tester, 'Masukkan Keranjang');
    await tester.tap(find.byKey(const Key('var-nila-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tambah'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Masukkan Keranjang', last: true);
    await tapText(tester, 'Lihat keranjang');
    expect(find.text('Tibelat Farm'), findsOneWidget, reason: 'item dikelompokkan per toko');
    expect(c.read(cartProvider).first.qty, 2);
    await tester.tap(find.byTooltip('Kurangi'));
    await tester.pumpAndSettle();
    expect(c.read(cartProvider).first.qty, 1);

    // Checkout: indikator langkah mengikuti metode. Transfer (bawaan) punya langkah Pembayaran, COD tidak.
    await tapText(tester, 'Beli (1)');
    expect(find.text('Ringkasan Pemesanan'), findsOneWidget);
    expect(find.text('Pembayaran'), findsOneWidget);
    await tester.tap(find.byKey(const Key('checkout-payment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pay-cod')));
    await tester.pumpAndSettle();
    expect(find.text('Pembayaran'), findsNothing);
    final before = c.read(ordersProvider).length;
    await tapText(tester, 'Buat Pesanan');
    await tapText(tester, 'Ya');
    expect(find.text('Pesanan berhasil dibuat'), findsOneWidget);
    expect(c.read(ordersProvider).length, before + 1);
  });

  testWidgets('pembeli COD: pesanan masuk daftar dengan status awal Menunggu dan lini masa', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final before = c.read(ordersProvider).length;
    final o = await buyerPlacesOrder(tester, c, cod: true);
    expect(c.read(ordersProvider).length, before + 1);
    expect(o.payment, PaymentMethod.cod);
    expect(o.status, OrderStatus.menunggu);
    expect(c.read(cartProvider), isEmpty);

    await tapText(tester, 'Lihat pesanan');
    expect(find.text('Menunggu'), findsWidgets);
    expect(find.text('Ikan Nila'), findsWidgets);
    c.read(routerProvider).push('/orders/${o.id}');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('order-timeline')), findsOneWidget);
    expect(find.text('Pesanan dibuat'), findsOneWidget);
    expect(find.text('Dikemas penjual'), findsOneWidget);
  });

  testWidgets('pembeli NON COD: transfer dengan bukti pembayaran, langkah Pembayaran muncul', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: false, proof: true);
    expect(o.payment, PaymentMethod.transfer);
    expect(o.proofUploaded, isTrue);
    expect(o.status, OrderStatus.menunggu);
    c.read(routerProvider).push('/orders/${o.id}');
    await tester.pumpAndSettle();
    expect(find.text('Bukti pembayaran dikirim'), findsOneWidget);
  });

  testWidgets('pembeli NON COD tanpa bukti: bisa membayar nanti lalu mengunggah bukti dari daftar pesanan', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: false, proof: false);
    expect(o.proofUploaded, isFalse);
    expect(o.needsProof, isTrue);
    c.read(routerProvider).push('/orders/${o.id}');
    await tester.pumpAndSettle();
    expect(find.text('Menunggu bukti pembayaran'), findsOneWidget);
    await tapText(tester, 'Bayar Sekarang');
    await tapText(tester, 'Unggah bukti transfer (simulasi)');
    await tapText(tester, 'Kirim bukti');
    expect(orderById(c, o.id).proofUploaded, isTrue);
  });
}
