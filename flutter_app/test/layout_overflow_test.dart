import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';

import 'helpers.dart';
import 'route_lists.dart';

/// Menjalankan semua rute pada layar kecil dengan teks diperbesar dan mengumpulkan overflow layout.
void main() {
  setUpAll(loadAppFonts);

  Future<List<String>> overflows(WidgetTester tester, String user, List<String> routes, Size dp, double textScale) async {
    tester.view.physicalSize = Size(dp.width * 2, dp.height * 2);
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
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await c.read(authProvider.notifier).login(user, 'Admin123');
    await tester.pumpAndSettle();

    final found = <String>[];
    final old = FlutterError.onError;
    String? current;
    FlutterError.onError = (d) {
      final msg = d.exceptionAsString();
      if (msg.contains('overflowed')) {
        found.add('$current: ${msg.split('\n').first}');
      } else {
        old?.call(d);
      }
    };
    try {
      for (final r in routes) {
        current = r;
        c.read(routerProvider).go(r);
        await tester.pumpAndSettle();
      }
    } finally {
      FlutterError.onError = old;
    }
    return found;
  }

  const small = Size(360, 640);
  const large = Size(412, 917);

  testWidgets('pembeli tanpa overflow $small', (tester) async {
    expect(await overflows(tester, 'fharaa@gmail.com', buyerRoutes, small, 1.0), isEmpty);
  });
  testWidgets('penjual tanpa overflow $small', (tester) async {
    expect(await overflows(tester, 'penjual@ikanku.id', sellerRoutes, small, 1.0), isEmpty);
  });

  // Teks diperbesar 1.4x: satu tes per rute agar rute bermasalah mudah dikenali.
  for (final r in buyerRoutes) {
    testWidgets('pembeli $r teks 1.4x', timeout: const Timeout(Duration(seconds: 40)), (tester) async {
      expect(await overflows(tester, 'fharaa@gmail.com', [r], large, 1.4), isEmpty);
    });
  }
  for (final r in sellerRoutes) {
    testWidgets('penjual $r teks 1.4x', timeout: const Timeout(Duration(seconds: 40)), (tester) async {
      expect(await overflows(tester, 'penjual@ikanku.id', [r], large, 1.4), isEmpty);
    });
  }
}
