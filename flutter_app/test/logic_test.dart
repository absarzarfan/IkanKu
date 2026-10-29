import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:ikanku/features/seller/domain/seller_settings.dart';

const _buyer = AppUser(id: 'b', name: 'B', email: 'b@x.id', phone: '6281', role: UserRole.buyer);
const _seller = AppUser(id: 's', name: 'S', email: 's@x.id', phone: '6282', role: UserRole.seller);
const _addr = Address(id: 'a', recipient: 'R', phone: '6281', street: 'Jl', area: Kecamatan('Sekupang', 'Batam', '29425'));

void main() {
  group('format & validators', () {
    test('rupiah memakai pemisah ribuan', () {
      expect(rupiah(0), 'Rp 0');
      expect(rupiah(40000), 'Rp 40.000');
      expect(rupiah(1250000), 'Rp 1.250.000');
    });
    test('validator', () {
      expect(Validators.email('a@b.co'), isNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.phone('6282387436427'), isNull);
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.number('-1'), isNotNull);
    });
  });

  group('redirect router', () {
    test('tamu hanya boleh rute publik', () {
      expect(computeRedirect(null, '/home'), '/login');
      expect(computeRedirect(null, '/seller'), '/login');
      expect(computeRedirect(null, '/login'), isNull);
      expect(computeRedirect(null, '/register/otp'), isNull);
    });
    test('pembeli diarahkan dari halaman tamu dan dilarang area penjual', () {
      expect(computeRedirect(_buyer, '/login'), '/home');
      expect(computeRedirect(_buyer, '/seller/orders'), '/home');
      expect(computeRedirect(_buyer, '/cart'), isNull);
    });
    test('penjual dilarang area pembeli', () {
      expect(computeRedirect(_seller, '/'), '/seller');
      expect(computeRedirect(_seller, '/cart'), '/seller');
      expect(computeRedirect(_seller, '/seller/products'), isNull);
    });
  });

  group('keranjang', () {
    late ProviderContainer c;
    setUp(() => c = ProviderContainer());
    tearDown(() => c.dispose());

    test('menambah item sama menggabungkan qty dan menghitung subtotal terpilih', () {
      final p = c.read(catalogProvider).byId('nila')!;
      final v = p.variations[1];
      final cart = c.read(cartProvider.notifier);
      cart.add(p, v);
      cart.add(p, v, qty: 2);
      expect(c.read(cartProvider), hasLength(1));
      expect(c.read(cartProvider).first.qty, 3);
      expect(c.read(cartSubtotalProvider), 3 * p.priceOf(v));
      cart.toggleAll(false);
      expect(c.read(cartSubtotalProvider), 0);
    });

    test('qty dibatasi stok dan minimal 1', () {
      final p = c.read(catalogProvider).byId('nila')!;
      final v = p.variations[0];
      final cart = c.read(cartProvider.notifier);
      cart.add(p, v);
      cart.setQty('${p.id}|${v.id}', 9999);
      expect(c.read(cartProvider).first.qty, v.stock);
      cart.setQty('${p.id}|${v.id}', 0);
      expect(c.read(cartProvider).first.qty, v.stock);
    });

    test('diskon penjual memengaruhi harga', () {
      final cat = c.read(catalogProvider.notifier);
      final base = c.read(catalogProvider).byId('nila')!;
      cat.setDiscount('nila', 50);
      final p = c.read(catalogProvider).byId('nila')!;
      expect(p.priceOf(p.variations[1]), (base.variations[1].price / 2).round());
    });
  });

  group('alur pesanan', () {
    late ProviderContainer c;
    late OrdersNotifier n;
    Order place({PaymentMethod pay = PaymentMethod.transfer, ShippingMethod ship = ShippingMethod.kirim}) {
      final p = c.read(catalogProvider).byId('discus')!;
      final v = p.variations.first;
      return n.place(lines: [OrderLine(product: p, variation: v, qty: 2, unitPrice: p.priceOf(v))], payment: pay, shipping: ship, address: _addr, shippingFee: 10000, buyerName: 'B');
    }

    setUp(() {
      c = ProviderContainer();
      n = c.read(ordersProvider.notifier);
    });
    tearDown(() => c.dispose());

    test('total = subtotal + ongkir; jemput gratis ongkir', () {
      final o = place();
      expect(o.total, o.subtotal + 10000);
      expect(place(ship: ShippingMethod.jemput).shippingFee, 0);
    });

    test('transfer tanpa bukti tidak bisa diterima, setelah bukti bisa', () {
      final o = place();
      expect(n.accept(o.id), isFalse);
      n.uploadProof(o.id);
      expect(n.accept(o.id), isTrue);
      expect(n.byId(o.id)!.status, OrderStatus.dikemas);
    });

    test('COD langsung bisa diterima, kirim butuh foto, lalu selesai dan ulasan sekali', () {
      final o = place(pay: PaymentMethod.cod);
      expect(n.accept(o.id), isTrue);
      expect(n.ship(o.id, photo: ''), isFalse);
      expect(n.ship(o.id, photo: 'p', note: 'resi'), isTrue);
      expect(n.complete(o.id), isTrue);
      expect(n.review(o.id, 0, 'x'), isFalse);
      expect(n.review(o.id, 5, 'mantap'), isTrue);
      expect(n.review(o.id, 4, 'lagi'), isFalse);
      expect(n.byId(o.id)!.review!.rating, 5);
    });

    test('tolak lalu bayar ulang kembali ke menunggu; batal hanya saat menunggu', () {
      final o = place();
      expect(n.reject(o.id, 'bukti palsu'), isTrue);
      expect(n.byId(o.id)!.rejectReason, 'bukti palsu');
      expect(n.cancel(o.id), isFalse);
      expect(n.repay(o.id), isTrue);
      expect(n.byId(o.id)!.status, OrderStatus.menunggu);
      expect(n.cancel(o.id), isTrue);
      expect(n.archive(o.id), isTrue);
      expect(n.byId(o.id)!.status, OrderStatus.diarsipkan);
    });

    test('pesanan aktif tidak bisa diarsipkan', () {
      final o = place();
      expect(n.archive(o.id), isFalse);
    });
  });

  test('ongkir gratis di atas batas', () {
    const s = SellerSettings(shippingFee: 10000, freeShippingMin: 100000);
    expect(s.feeFor(99999), 10000);
    expect(s.feeFor(100000), 0);
    expect(const SellerSettings().feeFor(1), 10000);
  });
}
