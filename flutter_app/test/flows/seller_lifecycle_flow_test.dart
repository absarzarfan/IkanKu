import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

import 'flow_helpers.dart';

/// S3: siklus pesanan penjual (NON COD) dan ulasan. Setelah tiap langkah pembeli melihat status barunya.
void main() {
  testWidgets('penjual: terima -> periksa bukti -> kirim dengan bukti kirim -> selesai; pembeli ulas, penjual melihat ulasan', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: false, proof: true);
    final id = o.id;

    // Penjual melihat pesanan baru di daftar dan membukanya.
    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).go('/seller/orders');
    await tester.pumpAndSettle();
    expect(find.text('Proses Pesanan'), findsWidgets, reason: 'pesanan baru muncul di tab Menunggu penjual');
    c.read(routerProvider).push('/seller/orders/$id');
    await tester.pumpAndSettle();
    expect(find.text('Sudah diunggah'), findsOneWidget, reason: 'bukti bayar terlihat penjual');
    await tapText(tester, 'Terima');
    expect(orderById(c, id).status, OrderStatus.dikemas);
    await expectBuyerSees(tester, c, id, 'Dikemas');

    // Kirim dengan bukti pengiriman.
    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/orders/$id/ship');
    await tester.pumpAndSettle();
    expect(find.byType(Scrollable), findsWidgets);
    await tester.tap(find.byKey(const Key('ship-photo')));
    await tester.pumpAndSettle();
    await tapText(tester, 'Kirim');
    expect(orderById(c, id).status, OrderStatus.dikirim);
    expect(orderById(c, id).shipmentPhoto, isNotEmpty);
    await expectBuyerSees(tester, c, id, 'Dikirim');

    // Selesai.
    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/orders/$id');
    await tester.pumpAndSettle();
    await tapText(tester, 'Tandai Selesai');
    expect(orderById(c, id).status, OrderStatus.selesai);
    await expectBuyerSees(tester, c, id, 'Selesai');

    // Pembeli memberi ulasan.
    c.read(routerProvider).push('/orders/$id/review');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('star-4')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ikan segar dan sampai dengan selamat');
    await tapText(tester, 'Kirim');
    expect(orderById(c, id).review?.rating, 4);

    // Penjual melihat ulasan.
    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/reviews');
    await tester.pumpAndSettle();
    expect(find.textContaining('Ikan segar dan sampai'), findsOneWidget);
  });

  testWidgets('penjual: NON COD tanpa bukti tidak bisa diterima sampai pembeli mengunggah bukti', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: false, proof: false);

    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/orders/${o.id}');
    await tester.pumpAndSettle();
    expect(find.text('Belum ada'), findsOneWidget);
    await tapText(tester, 'Terima');
    expect(find.text('Bukti pembayaran belum diunggah pembeli'), findsOneWidget);
    expect(orderById(c, o.id).status, OrderStatus.menunggu);

    c.read(ordersProvider.notifier).uploadProof(o.id);
    await tester.pumpAndSettle();
    await tapText(tester, 'Terima');
    expect(orderById(c, o.id).status, OrderStatus.dikemas);
  });

  testWidgets('penjual: pesanan COD bisa langsung diterima tanpa bukti bayar', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: true);
    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/orders/${o.id}');
    await tester.pumpAndSettle();
    await tapText(tester, 'Terima');
    expect(orderById(c, o.id).status, OrderStatus.dikemas);
  });
}
