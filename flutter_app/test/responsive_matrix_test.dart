import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';

import 'helpers.dart';
import 'route_lists.dart';

/// Matriks responsif: peran x ukuran x skala teks. Menambah layar = menambah satu baris di route_lists.dart.
const adminRoutes = ['/admin'];
const keyRoutes = ['/home', '/search', '/product/nila', '/cart', '/checkout', '/orders', '/profile'];
const keySellerRoutes = ['/seller', '/seller/products', '/seller/orders'];

const portraitSizes = [Size(280, 653), Size(320, 568), Size(360, 800), Size(375, 667), Size(412, 915), Size(430, 932), Size(600, 960), Size(768, 1024)];
const landscape = Size(800, 360);
const scales = [1.0, 1.3, 2.0];

class Role {
  const Role(this.name, this.user, this.routes, this.keyRoutes);
  final String name;
  final String user;
  final List<String> routes;
  final List<String> keyRoutes;
}

const roles = [
  Role('pembeli', 'fharaa@gmail.com', buyerRoutes, keyRoutes),
  Role('penjual', 'penjual@ikanku.id', sellerRoutes, keySellerRoutes),
  Role('admin', 'admin@ikanku.id', adminRoutes, adminRoutes),
];

/// Menjalankan [routes] pada satu aplikasi dan mengembalikan semua galat layout/pengecualian.
Future<List<String>> runRoutes(WidgetTester tester, Role role, List<String> routes, Size dp, double textScale) async {
  tester.view.physicalSize = dp * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final c = ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: Consumer(
      builder: (context, ref, _) => MaterialApp.router(
        theme: buildTheme(),
        routerConfig: ref.watch(routerProvider),
        builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
      ),
    ),
  ));
  await tester.pump();
  await c.read(authProvider.notifier).login(role.user, 'Admin123');
  await tester.pump();

  final found = <String>[];
  final old = FlutterError.onError;
  String? current;
  FlutterError.onError = (d) => found.add('$current: ${d.exceptionAsString().split('\n').first}');
  try {
    for (final r in routes) {
      current = r;
      c.read(routerProvider).go(r);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final e = tester.takeException();
      if (e != null) found.add('$r: $e');
    }
  } finally {
    FlutterError.onError = old;
  }
  return found;
}

void main() {
  setUpAll(loadAppFonts);

  for (final role in roles) {
    for (final size in [...portraitSizes, landscape]) {
      for (final scale in scales) {
        final isLandscape = size == landscape;
        final routes = isLandscape ? role.keyRoutes : role.routes;
        testWidgets('${role.name} ${size.width.toInt()}x${size.height.toInt()} teks ${scale}x', timeout: const Timeout(Duration(minutes: 3)), (tester) async {
          expect(await runRoutes(tester, role, routes, size, scale), isEmpty);
        });
      }
    }
  }

  // Tombol utama: target sentuh Android (48dp) dan label untuk pembaca layar.
  for (final r in ['/home', '/login', '/cart', '/checkout']) {
    testWidgets('pedoman target sentuh $r', (tester) async {
      final handle = tester.ensureSemantics();
      final user = r == '/login' ? null : 'fharaa@gmail.com';
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: Consumer(builder: (context, ref, _) => MaterialApp.router(theme: buildTheme(), routerConfig: ref.watch(routerProvider))),
      ));
      await tester.pump();
      if (user == null) {
        c.read(authProvider.notifier).logout();
      }
      c.read(routerProvider).go(r);
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  }
}
