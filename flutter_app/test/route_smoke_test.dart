import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';

import 'helpers.dart';
import 'route_lists.dart';


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

  testWidgets('semua rute pembeli dapat dirender tanpa error', (tester) => visitAll(tester, 'fharaa@gmail.com', buyerRoutes));
  testWidgets('semua rute penjual dapat dirender tanpa error', (tester) => visitAll(tester, 'penjual@ikanku.id', sellerRoutes));
}
