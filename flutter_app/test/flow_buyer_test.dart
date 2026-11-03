import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

import 'helpers.dart';

/// Alur pembeli end-to-end dalam mode mock (Phase 14a): login -> Home -> detail -> variasi -> keranjang -> checkout -> pesanan -> lini masa.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('alur penuh: login -> produk dari Home -> variasi -> keranjang -> checkout -> pesanan -> lini masa', (tester) async {
    final c = await pumpAppSignedOut(tester);
    c.read(routerProvider).go('/login');
    await tester.pumpAndSettle();
    await loginAs(tester, 'fharaa@gmail.com');
    expect(c.read(routerProvider).state.uri.path, '/home');

    // Buka produk dari Home.
    await tester.scrollUntilVisible(find.text('Ikan Nila'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ikan Nila').first);
    await tester.pumpAndSettle();
    expect(find.text('Deskripsi'), findsOneWidget);

    // Pilih variasi, tambah jumlah, masukkan keranjang.
    await tester.tap(find.text('Masukkan Keranjang'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('var-nila-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tambah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masukkan Keranjang').last);
    await tester.pumpAndSettle();
    expect(find.text('Ditambahkan ke keranjang'), findsOneWidget);
    await tester.tap(find.text('Lihat keranjang'));
    await tester.pumpAndSettle();

    // Keranjang menampilkan item dan total.
    final lines = c.read(cartProvider);
    expect(lines.length, 1);
    expect(lines.first.qty, 2);
    expect(find.text('Ikan Nila'), findsOneWidget);
    final total = c.read(cartSubtotalProvider);
    expect(find.descendant(of: find.byKey(const Key('cart-total')), matching: find.text(rupiah(total))), findsOneWidget);

    // Checkout -> buat pesanan (transfer, bayar nanti) -> sukses.
    final before = c.read(ordersProvider).length;
    await tester.tap(find.text('Beli (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan Pemesanan'), findsOneWidget);
    await tester.tap(find.text('Buat Pesanan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bayar nanti'));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan berhasil dibuat'), findsOneWidget);
    expect(c.read(ordersProvider).length, before + 1);
    expect(c.read(cartProvider), isEmpty);

    // Pesanan muncul di daftar dan detailnya punya lini masa.
    await tester.tap(find.text('Lihat pesanan'));
    await tester.pumpAndSettle();
    expect(find.text('Ikan Nila'), findsWidgets);
    await tester.tap(find.text('Ikan Nila').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('order-timeline')), findsOneWidget);
    expect(find.text('Pesanan dibuat'), findsOneWidget);
  });

  testWidgets('keranjang: hapus lalu Urungkan mengembalikan item', (tester) async {
    final c = await pumpApp(tester);
    final p = c.read(catalogProvider).byId('nila')!;
    c.read(cartProvider.notifier).add(p, p.variations[1]);
    c.read(routerProvider).push('/cart');
    await tester.pumpAndSettle();
    expect(c.read(cartProvider).length, 1);
    await tester.tap(find.byTooltip('Hapus'));
    await tester.pumpAndSettle();
    expect(c.read(cartProvider), isEmpty);
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
    await tester.tap(find.text('Urungkan'));
    await tester.pumpAndSettle();
    expect(c.read(cartProvider).length, 1);
  });

  testWidgets('batas jumlah: tidak melebihi stok dan tombol tambah nonaktif', (tester) async {
    final c = await pumpApp(tester);
    final p = c.read(catalogProvider).byId('nila')!;
    final v = p.variations.last;
    final cart = c.read(cartProvider.notifier);
    cart.add(p, v);
    cart.setQty('${p.id}|${v.id}', 99999);
    expect(c.read(cartProvider).first.qty, v.stock);
    cart.setQty('${p.id}|${v.id}', 0);
    expect(c.read(cartProvider).first.qty, v.stock, reason: 'jumlah di bawah 1 ditolak');
    c.read(routerProvider).push('/cart');
    await tester.pumpAndSettle();
    final plus = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add_circle_outline));
    expect(plus.onPressed, isNull);
    expect(find.text('Sudah mencapai stok tersedia'), findsOneWidget);
  });

  testWidgets('formulir: galat baru tampil setelah blur atau kirim, fokus ke field salah pertama', (tester) async {
    await pumpAppSignedOut(tester).then((c) async {
      c.read(routerProvider).go('/login');
      await tester.pumpAndSettle();
    });
    const idError = 'Nomor ponsel/email wajib diisi';
    await tester.tap(find.byKey(const Key('login-id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login-id')), 'a');
    await tester.enterText(find.byKey(const Key('login-id')), '');
    await tester.pumpAndSettle();
    expect(find.text(idError), findsNothing, reason: 'belum blur, belum ada galat');
    await tester.tap(find.byKey(const Key('login-pw')));
    await tester.pumpAndSettle();
    expect(find.text(idError), findsOneWidget, reason: 'galat setelah blur pertama');

    // Kirim dengan kedua field kosong: galat sandi muncul dan fokus kembali ke field pertama yang salah.
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    final idEditable = tester.widget<EditableText>(find.descendant(of: find.byKey(const Key('login-id')), matching: find.byType(EditableText)));
    expect(idEditable.focusNode.hasFocus, isTrue);
  });
}
