import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/config/app_config.dart';
import 'package:ikanku/core/data/mappers.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/orders/domain/orders.dart';

AppUser _user(UserRole r) => AppUser(id: 'x', name: 'n', email: 'e', phone: 'p', role: r);

void main() {
  group('AppConfig', () {
    test('tanpa dart-define aplikasi memakai mock', () {
      expect(AppConfig.useSupabase, isFalse);
    });
  });

  group('mapper', () {
    test('profil: role tak dikenal menjadi buyer, admin dipetakan', () {
      expect(userFromRow({'id': 'a', 'role': 'admin', 'full_name': 'A', 'email': 'a@x', 'phone': '1', 'is_active': false}).role, UserRole.admin);
      expect(userFromRow({'id': 'a', 'role': 'aneh'}).role, UserRole.buyer);
      expect(userFromRow({'id': 'a', 'role': 'seller', 'is_active': false}).isActive, isFalse);
      expect(userFromRow({'id': 'a'}).isActive, isTrue);
    });

    test('produk: kategori, penjual, variasi, rating dari ulasan', () {
      final p = productFromRow({
        'id': 'p1',
        'name': 'Nila',
        'description': 'd',
        'image_url': 'https://x/y.png',
        'discount_percent': 10,
        'categories': {'name': 'Air Tawar'},
        'shops': {'name': 'Toko A'},
        'product_variants': [
          {'id': 'v1', 'weight': '1 Kg', 'count': 2, 'price': 30000, 'stock': 5}
        ],
        'reviews': [
          {'rating': 5, 'comment': 'ok', 'reviewer_name': 'Ani'},
          {'rating': 4, 'comment': '', 'reviewer_name': ''},
        ],
      });
      expect(p.category, 'Air Tawar');
      expect(p.sellerName, 'Toko A');
      expect(p.variations.single.label, 'Berat 1 Kg, Isi 2 ekor');
      expect(p.startingPrice, 27000);
      expect(p.rating, 4.5);
      expect(p.reviews.last.author, 'Pembeli');
    });

    test('produk tanpa embed tidak crash', () {
      final p = productFromRow({'id': 'p', 'name': 'x'});
      expect(p.variations, isEmpty);
      expect(p.rating, 0);
    });

    test('produk ke baris: asset lokal tidak dikirim sebagai image_url', () {
      final p = productFromRow({'id': 'p', 'name': 'x', 'image_url': 'https://a/b.png'});
      expect(productToRow(p, shopId: 's')['image_url'], 'https://a/b.png');
      expect(productToRow(p.copyWith(image: 'assets/images/a.png'), shopId: 's')['image_url'], isNull);
    });

    Row orderRow({String status = 'menunggu', String? archived, String? proof}) => {
          'id': 'uuid-1',
          'code': 'INV-1100',
          'status': status,
          'payment_method': 'transfer',
          'payment_status': 'menunggu_verifikasi',
          'shipping_method': 'kirim',
          'shipping_fee': 10000,
          'ship_recipient': 'Uji',
          'ship_phone': '1',
          'ship_street': 'Jl. A',
          'ship_kecamatan': 'Sekupang',
          'ship_city': 'Batam',
          'ship_postal_code': '29425',
          'buyer_name': 'Uji',
          'created_at': '2026-10-20T10:00:00Z',
          'payment_proof_ref': proof,
          'archived_from': archived,
          'order_items': <dynamic>[
            <String, dynamic>{
              'product_id': 'p1',
              'variant_id': 'v1',
              'product_name': 'Nila',
              'variant_label': 'Berat 1 Kg, Isi 2 ekor',
              'unit_price': 30000,
              'quantity': 2,
              'products': {'image_url': 'https://x/y.png'},
              'reviews': {'rating': 5, 'comment': 'mantap', 'reviewer_name': 'Uji'},
            }
          ],
        };

    test('pesanan: kode jadi id, uuid jadi remoteId, total dan ulasan', () {
      final o = orderFromRow(orderRow(proof: 'ref'));
      expect(o.id, 'INV-1100');
      expect(o.remoteId, 'uuid-1');
      expect(o.status, OrderStatus.menunggu);
      expect(o.paymentStatus, PaymentStatus.menungguVerifikasi);
      expect(o.proofUploaded, isTrue);
      expect(o.subtotal, 60000);
      expect(o.total, 70000);
      expect(o.lines.single.variation.weight, '1 Kg');
      expect(o.lines.single.variation.count, 2);
      expect(o.lines.single.product.image, 'https://x/y.png');
      expect(o.review!.text, 'mantap');
      expect(o.address.area.city, 'Batam');
    });

    test('pesanan: tanpa bukti needsProof, arsip menyimpan status asal', () {
      final o = orderFromRow(orderRow(status: 'diarsipkan', archived: 'selesai'));
      expect(o.needsProof, isTrue);
      expect(o.archivedFrom, OrderStatus.selesai);
    });

    test('pesanan: variasi terhapus (id null) memakai label snapshot', () {
      final r = orderRow();
      final item = (r['order_items'] as List).first as Map<String, dynamic>;
      item['variant_id'] = null;
      final o = orderFromRow(r);
      expect(o.lines.single.variation.weight, '1 Kg');
    });

    test('status pembayaran bolak-balik', () {
      for (final s in PaymentStatus.values) {
        expect(paymentStatusFromDb(paymentStatusToDb(s)), s);
      }
      expect(paymentStatusFromDb('aneh'), PaymentStatus.belumBayar);
    });

    test('toko dan bank', () {
      final s = shopFromRow({
        'name': 'Toko A',
        'shipping_fee': 8000,
        'free_shipping_min': 100000,
        'cod_enabled': false,
        'shop_banks': [
          {'bank': 'BCA', 'number': '123', 'holder': 'A'}
        ],
      });
      expect(s.shopName, 'Toko A');
      expect(s.codEnabled, isFalse);
      expect(s.transferEnabled, isTrue);
      expect(s.feeFor(100000), 0);
      expect(s.banks.single.bank, 'BCA');
    });

    test('ringkasan pesanan admin menghitung total', () {
      final a = adminOrderFromRow({
        'code': 'INV-1',
        'status': 'menunggu',
        'buyer_name': 'B',
        'payment_method': 'cod',
        'shipping_fee': 5000,
        'shops': {'name': 'T'},
        'order_items': [
          {'unit_price': 1000, 'quantity': 3}
        ],
      });
      expect(a.total, 8000);
      expect(a.shopName, 'T');
    });
  });

  group('redirect berdasarkan peran', () {
    test('belum login: hanya rute publik', () {
      expect(computeRedirect(null, '/home'), '/login');
      expect(computeRedirect(null, '/admin'), '/login');
      expect(computeRedirect(null, '/seller/products'), '/login');
      expect(computeRedirect(null, '/login'), isNull);
    });

    test('pembeli: tidak boleh /seller dan /admin, rute tamu menuju beranda', () {
      final u = _user(UserRole.buyer);
      expect(computeRedirect(u, '/seller'), '/home');
      expect(computeRedirect(u, '/admin'), '/home');
      expect(computeRedirect(u, '/login'), '/home');
      expect(computeRedirect(u, '/cart'), isNull);
    });

    test('penjual: tidak boleh rute pembeli dan /admin', () {
      final u = _user(UserRole.seller);
      expect(computeRedirect(u, '/home'), '/seller');
      expect(computeRedirect(u, '/cart'), '/seller');
      expect(computeRedirect(u, '/admin'), '/seller');
      expect(computeRedirect(u, '/seller/orders'), isNull);
      expect(computeRedirect(u, '/'), '/seller');
    });

    test('admin: hanya /admin (dan offline); sisanya dialihkan', () {
      final u = _user(UserRole.admin);
      expect(computeRedirect(u, '/admin'), isNull);
      expect(computeRedirect(u, '/home'), '/admin');
      expect(computeRedirect(u, '/seller/orders'), '/admin');
      expect(computeRedirect(u, '/login'), '/admin');
      expect(computeRedirect(u, '/offline'), isNull);
    });

    test('homeFor tiap peran', () {
      expect(homeFor(UserRole.buyer), '/home');
      expect(homeFor(UserRole.seller), '/seller');
      expect(homeFor(UserRole.admin), '/admin');
    });
  });

  group('AppError', () {
    test('galat tak dikenal tidak membocorkan teks mentah', () {
      final e = mapError(StateError('rahasia: select * from profiles'));
      expect(e.message.contains('rahasia'), isFalse);
      expect(e.kind, AppErrorKind.unknown);
    });

    test('AppError dilewatkan apa adanya', () {
      const e = AppError.permission();
      expect(identical(mapError(e), e), isTrue);
    });
  });
}
