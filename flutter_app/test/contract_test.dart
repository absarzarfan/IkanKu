import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/admin/domain/admin.dart';
import 'package:ikanku/features/auth/data/mock_auth_repository.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/catalog/domain/catalog_remote.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/domain/orders_remote.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

import 'support/memory_remotes.dart';

/// Kontrak: pernyataan yang sama dijalankan pada setiap implementasi (mock/in-memory di sini).
/// Implementasi Supabase memenuhi kontrak yang sama tetapi tidak dites tanpa database hidup.
void authContract(String name, AuthRepository Function() make) {
  group('AuthRepository ($name)', () {
    test('login valid mengembalikan pengguna dengan peran', () async {
      final u = await make().login('penjual@ikanku.id', 'Admin123');
      expect(u.role, UserRole.seller);
    });

    test('login salah melempar AuthException berpesan Indonesia', () async {
      expect(() => make().login('penjual@ikanku.id', 'salah'), throwsA(isA<AuthException>().having((e) => e.message, 'message', isNotEmpty)));
    });

    test('registrasi membuat pembeli, tidak pernah admin atau penjual', () async {
      final r = make();
      final u = await r.register(name: 'Uji', phone: '6281200000001', password: 'Rahasia123', email: 'uji@example.test');
      expect(u.role, UserRole.buyer);
      expect(u.isActive, isTrue);
    });

    test('reset password untuk email tak dikenal ditolak', () async {
      expect(() => make().requestPasswordReset('tidak-ada@example.test'), throwsA(isA<AuthException>()));
    });

    test('ganti sandi dengan sandi lama salah ditolak', () async {
      final r = make();
      final u = await r.login('penjual@ikanku.id', 'Admin123');
      expect(() => r.changePassword(u.id, 'salah', 'Baru12345'), throwsA(isA<AuthException>()));
    });
  });
}

void catalogContract(String name, CatalogRemote Function() make) {
  group('CatalogRemote ($name)', () {
    test('daftar, pencarian, dan filter kategori', () async {
      final c = make();
      final all = await c.listProducts();
      expect(all, isNotEmpty);
      final nila = await c.listProducts(query: 'nila');
      expect(nila.every((p) => p.name.toLowerCase().contains('nila')), isTrue);
      final hias = await c.listProducts(category: 'Hias');
      expect(hias, isNotEmpty);
      expect(hias.every((p) => p.category == 'Hias'), isTrue);
      expect((await c.listProducts(category: 'Semua')).length, all.length);
    });

    test('detail memuat variasi dan id tak dikenal null', () async {
      final c = make();
      final p = (await c.listProducts()).first;
      final d = await c.getProduct(p.id);
      expect(d!.variations, isNotEmpty);
      expect(await c.getProduct('tidak-ada'), isNull);
    });

    test('unggah gambar menolak format dan ukuran tak valid', () async {
      final c = make();
      expect(await c.uploadProductImage(Uint8List(10), extension: 'png'), startsWith('http'));
      expect(() => c.uploadProductImage(Uint8List(10), extension: 'exe'), throwsA(isA<AppError>()));
      expect(() => c.uploadProductImage(Uint8List(3 * 1024 * 1024), extension: 'jpg'), throwsA(isA<AppError>()));
    });

    test('kategori kosong ditolak', () async {
      expect(() => make().addCategory('  '), throwsA(isA<AppError>()));
    });
  });
}

const _addr = Address(id: 'a', recipient: 'Uji', phone: '1', street: 'Jl. A', area: Kecamatan('Sekupang', 'Batam', '29425'));

void orderContract(String name, (CatalogRemote, OrderRemote) Function() make) {
  group('OrderRemote ($name)', () {
    Future<CartLine> firstLine(CatalogRemote c, {int qty = 1}) async {
      final p = (await c.listProducts()).first;
      return CartLine(product: p, variation: p.variations[1], qty: qty);
    }

    test('harga pesanan dari katalog, bukan dari klien', () async {
      final (c, o) = make();
      final line = await firstLine(c);
      // Klien mengaku harga murah: CartLine hanya membawa id/qty, harga tetap dari katalog.
      final cheap = CartLine(product: line.product.copyWith(variations: [line.variation.copyWith(price: 1)]), variation: line.variation.copyWith(price: 1), qty: 1);
      final created = await o.placeOrder(lines: [cheap], payment: PaymentMethod.cod, shipping: ShippingMethod.kirim, address: _addr);
      expect(created.single.lines.single.unitPrice, line.product.priceOf(line.variation));
    });

    test('stok tidak cukup ditolak dan tidak ada pesanan', () async {
      final (c, o) = make();
      final line = await firstLine(c, qty: 100000);
      await expectLater(o.placeOrder(lines: [line], payment: PaymentMethod.cod, shipping: ShippingMethod.kirim, address: _addr), throwsA(isA<AppError>()));
      expect(await o.listOrders(), isEmpty);
    });

    test('stok berkurang setelah pesanan', () async {
      final (c, o) = make();
      final line = await firstLine(c, qty: 2);
      await o.placeOrder(lines: [line], payment: PaymentMethod.cod, shipping: ShippingMethod.jemput, address: _addr);
      final after = await c.getProduct(line.product.id);
      expect(after!.variations[1].stock, line.variation.stock - 2);
    });

    test('alur status valid dan transisi tidak valid ditolak', () async {
      final (c, o) = make();
      final line = await firstLine(c);
      var order = (await o.placeOrder(lines: [line], payment: PaymentMethod.transfer, shipping: ShippingMethod.kirim, address: _addr)).single;
      await expectLater(o.updateStatus(order, OrderStatus.selesai), throwsA(isA<AppError>()));
      await expectLater(o.updateStatus(order, OrderStatus.dikemas), throwsA(isA<AppError>()), reason: 'transfer wajib bukti');
      await o.setPaymentProof(order, 'ref');
      order = await o.updateStatus(order, OrderStatus.dikemas);
      await expectLater(o.updateStatus(order, OrderStatus.dikirim), throwsA(isA<AppError>()), reason: 'bukti kirim wajib');
      order = await o.updateStatus(order, OrderStatus.dikirim, photoRef: 'foto');
      order = await o.updateStatus(order, OrderStatus.selesai);
      expect(order.status, OrderStatus.selesai);
    });

    test('ulasan hanya setelah pesanan selesai', () async {
      final (c, o) = make();
      final line = await firstLine(c);
      final order = (await o.placeOrder(lines: [line], payment: PaymentMethod.cod, shipping: ShippingMethod.kirim, address: _addr)).single;
      await expectLater(o.submitReview(order, 5, 'bagus'), throwsA(isA<AppError>()));
      var x = await o.updateStatus(order, OrderStatus.dikemas);
      x = await o.updateStatus(x, OrderStatus.dikirim, photoRef: 'f');
      x = await o.updateStatus(x, OrderStatus.selesai);
      await o.submitReview(x, 5, 'bagus');
      expect((await o.reviewsFor(line.product.id)).single.rating, 5);
      await expectLater(o.submitReview(x, 9, 'x'), throwsA(isA<AppError>()));
    });
  });
}

void adminContract(String name, AdminRemote Function() make) {
  group('AdminRemote ($name)', () {
    test('cari pengguna dan nonaktifkan/aktifkan', () async {
      final a = make();
      expect((await a.users(query: 'sari')).single.email, 'sari@example.test');
      await a.setUserActive('u1', false);
      expect((await a.users()).firstWhere((u) => u.id == 'u1').isActive, isFalse);
      await a.setUserActive('u1', true);
      expect((await a.users()).firstWhere((u) => u.id == 'u1').isActive, isTrue);
    });

    test('nonaktifkan/aktifkan produk', () async {
      final a = make();
      await a.setProductActive('p1', false);
      expect((await a.products()).single.isActive, isFalse);
      await a.setProductActive('p1', true);
      expect((await a.products(query: 'nila')).single.isActive, isTrue);
    });
  });
}

void main() {
  authContract('mock', MockAuthRepository.new);
  catalogContract('in-memory', InMemoryCatalogRemote.new);
  orderContract('in-memory', () {
    final c = InMemoryCatalogRemote();
    return (c, InMemoryOrderRemote(c));
  });
  adminContract('in-memory', InMemoryAdminRemote.new);
}
