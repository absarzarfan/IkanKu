import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

import 'flow_helpers.dart';

/// S3/B4: penolakan dengan alasan dan pembatalan.
void main() {
  testWidgets('penjual menolak dengan alasan; pembeli melihat alasan dan bisa Bayar Ulang', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: true);

    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/orders/${o.id}');
    await tester.pumpAndSettle();
    await tapText(tester, 'Tolak');
    await tester.enterText(find.byKey(const Key('reject-input')), 'Stok sedang kosong');
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Tolak')));
    await tester.pumpAndSettle();
    expect(orderById(c, o.id).status, OrderStatus.ditolak);
    expect(orderById(c, o.id).rejectReason, 'Stok sedang kosong');

    await switchTo(tester, c, buyerEmail);
    c.read(routerProvider).push('/orders/${o.id}/rejected');
    await tester.pumpAndSettle();
    expect(find.text('Stok sedang kosong'), findsOneWidget);
    await tapText(tester, 'Bayar Ulang');
    expect(orderById(c, o.id).status, OrderStatus.menunggu);
  });

  testWidgets('penolakan tanpa alasan memakai teks bawaan', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: true);
    await switchTo(tester, c, sellerEmail);
    c.read(routerProvider).push('/seller/orders/${o.id}');
    await tester.pumpAndSettle();
    await tapText(tester, 'Tolak');
    await tester.enterText(find.byKey(const Key('reject-input')), '   ');
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Tolak')));
    await tester.pumpAndSettle();
    expect(orderById(c, o.id).rejectReason, 'Pesanan ditolak penjual');
  });

  testWidgets('pembeli membatalkan pesanan Menunggu lewat dialog konfirmasi', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    final o = await buyerPlacesOrder(tester, c, cod: true);
    c.read(routerProvider).push('/orders/${o.id}');
    await tester.pumpAndSettle();
    await tapText(tester, 'Batalkan pesanan');
    expect(find.text('Batalkan pesanan ini?'), findsOneWidget);
    await tapText(tester, 'Tidak');
    expect(orderById(c, o.id).status, OrderStatus.menunggu, reason: 'Tidak = tetap');
    await tapText(tester, 'Batalkan pesanan');
    await tapText(tester, 'Ya, batalkan');
    expect(orderById(c, o.id).status, OrderStatus.dibatalkan);
  });

  testWidgets('pembatalan tidak ditawarkan setelah pesanan dikemas atau dikirim', (tester) async {
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    for (final id in ['INV-1002', 'INV-1003']) {
      c.read(routerProvider).push('/orders/$id');
      await tester.pumpAndSettle();
      expect(find.text('Batalkan pesanan'), findsNothing, reason: '$id tidak boleh dibatalkan');
      c.read(routerProvider).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('arsip: pesanan dibatalkan/ditolak/selesai bisa diarsipkan, pesanan berjalan tidak', (tester) async {
    final c = await startApp(tester);
    final n = c.read(ordersProvider.notifier);
    expect(n.archive('INV-1006'), isTrue);
    expect(orderById(c, 'INV-1006').status, OrderStatus.diarsipkan);
    expect(orderById(c, 'INV-1006').archivedFrom, OrderStatus.dibatalkan);
    expect(n.archive('INV-1002'), isFalse);
    expect(orderById(c, 'INV-1002').status, OrderStatus.dikemas);
  });
}
