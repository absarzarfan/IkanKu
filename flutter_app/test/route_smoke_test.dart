import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';

import 'helpers.dart';

const _buyerRoutes = [
  '/home', '/search', '/profile', '/category/Hias', '/category/Semua', '/recommendations', '/product/nila', '/cart', '/checkout',
  '/payment/INV-1001', '/order-success/INV-1001', '/orders', '/orders?tab=3', '/orders/INV-1002', '/orders/INV-1003', '/orders/INV-1005/rejected',
  '/orders/INV-1004/review', '/orders/INV-1004/review/view', '/profile/data', '/profile/password', '/profile/email', '/profile/phone',
  '/addresses', '/addresses?pick=1', '/addresses/add', '/pick-kecamatan', '/help', '/offline',
];

const _sellerRoutes = [
  '/seller', '/seller/products', '/seller/settings', '/seller/orders', '/seller/orders?tab=1', '/seller/orders?tab=2', '/seller/orders?tab=3', '/seller/orders?tab=4',
  '/seller/orders?tab=5', '/seller/orders?tab=6', '/seller/orders/INV-1001', '/seller/orders/INV-1002/ship', '/seller/reviews', '/seller/products/new',
  '/seller/products/nila', '/seller/products/nila/edit', '/seller/products/nila/variants', '/seller/categories/new', '/seller/discount',
  '/seller/ongkir', '/seller/payment-methods', '/help',
];

void main() {
  setUpAll(loadAppFonts);

  Future<void> visitAll(WidgetTester tester, String user, List<String> routes) async {
    final c = await pumpApp(tester);
    await c.read(authProvider.notifier).login(user, 'Admin123');
    await tester.pumpAndSettle();
    for (final r in routes) {
      c.read(routerProvider).go(r);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'rute $r melempar exception');
    }
  }

  testWidgets('semua rute pembeli dapat dirender tanpa error', (tester) => visitAll(tester, 'fharaa@gmail.com', _buyerRoutes));
  testWidgets('semua rute penjual dapat dirender tanpa error', (tester) => visitAll(tester, 'penjual@ikanku.id', _sellerRoutes));
}
