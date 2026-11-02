import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

import '../helpers.dart';

export '../helpers.dart';

const buyerEmail = 'fharaa@gmail.com';
const sellerEmail = 'penjual@ikanku.id';
const adminEmail = 'admin@ikanku.id';

/// Setiap tes memakai ProviderContainer baru sehingga seluruh state mock (pesanan, keranjang, admin) mulai dari seed.
Future<ProviderContainer> startApp(WidgetTester tester) async {
  await loadAppFonts();
  return pumpApp(tester);
}

/// Pindah peran lewat layar login sungguhan: keluar, buka /login, isi akun, tekan Login.
Future<void> switchTo(WidgetTester tester, ProviderContainer c, String email) async {
  c.read(authProvider.notifier).logout();
  await tester.pumpAndSettle();
  c.read(routerProvider).go('/login');
  await tester.pumpAndSettle();
  await loginAs(tester, email);
}

Future<void> tapText(WidgetTester tester, String text, {bool last = false}) async {
  final f = last ? find.text(text).last : find.text(text).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Pembeli membuat pesanan lewat UI (Beli Sekarang -> variasi -> checkout). Mengembalikan pesanan terbaru.
/// [cod] true = COD; false = transfer, dengan [proof] true mengunggah bukti di layar pembayaran.
Future<Order> buyerPlacesOrder(WidgetTester tester, ProviderContainer c, {required bool cod, bool proof = true}) async {
  c.read(routerProvider).push('/product/nila');
  await tester.pumpAndSettle();
  await tapText(tester, 'Beli Sekarang');
  await tester.tap(find.byKey(const Key('var-nila-2')));
  await tester.pumpAndSettle();
  await tapText(tester, 'Beli Sekarang', last: true);
  if (cod) {
    await tester.tap(find.byKey(const Key('checkout-payment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pay-cod')));
    await tester.pumpAndSettle();
  }
  await tapText(tester, 'Buat Pesanan');
  await tapText(tester, 'Ya');
  if (!cod) {
    if (proof) {
      await tapText(tester, 'Unggah bukti transfer (simulasi)');
      await tapText(tester, 'Kirim bukti');
    } else {
      await tapText(tester, 'Bayar nanti');
    }
  }
  expect(find.text('Pesanan berhasil dibuat'), findsOneWidget);
  return c.read(ordersProvider).first;
}

Order orderById(ProviderContainer c, String id) => c.read(ordersProvider).firstWhere((o) => o.id == id);

/// Pembeli (login ulang) membuka detail pesanan dan memeriksa chip status.
Future<void> expectBuyerSees(WidgetTester tester, ProviderContainer c, String id, String statusLabel) async {
  await switchTo(tester, c, buyerEmail);
  c.read(routerProvider).push('/orders/$id');
  await tester.pumpAndSettle();
  expect(find.widgetWithText(StatusChip, statusLabel), findsWidgets, reason: 'pembeli melihat status $statusLabel');
}
