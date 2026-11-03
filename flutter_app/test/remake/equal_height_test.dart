import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/catalog/presentation/catalog_screens.dart';
import 'package:ikanku/features/profile/presentation/profile_screens.dart';
import 'package:ikanku/features/seller/presentation/seller_order_screens.dart';

import '../flows/flow_helpers.dart';

/// Kelompok yang harus SATU tinggi. Menambah kelompok = satu baris di [groups].
final groups = <(String role, String route, String name, Finder finder)>[
  ('buyer', '/home', 'nilai jual', find.byType(ValuePropCard)),
  ('buyer', '/home', 'kategori', find.byType(CategoryCard)),
  ('buyer', '/home', 'carousel unggulan', find.byType(ProductFeaturedCard)),
  ('buyer', '/home', 'grid Semua ikan', find.byType(ProductTile)),
  ('buyer', '/search', 'carousel Telusuri', find.byType(ProductFeaturedCard)),
  ('buyer', '/search', 'grid Telusuri', find.byType(ProductTile)),
  ('buyer', '/recommendations', 'grid Rekomendasi', find.byType(ProductTile)),
  ('buyer', '/profile', 'StatCard profil', find.byType(StatCard)),
  ('buyer', '/profile', 'Pesanan Saya', find.byType(OrderStatusCell)),
  ('seller', '/seller', 'StatCard penjual', find.byType(StatCard)),
  ('seller', '/seller', 'aksi cepat', find.byType(QuickActionTile)),
  ('admin', '/admin', 'StatCard admin', find.byType(StatCard)),
];

const sizes = [Size(320, 568), Size(360, 800), Size(412, 915), Size(768, 1024)];
const scales = [1.0, 1.3, 2.0];
const emails = {'buyer': buyerEmail, 'seller': sellerEmail, 'admin': adminEmail};

void main() {
  for (final role in ['buyer', 'seller', 'admin']) {
    for (final size in sizes) {
      for (final scale in scales) {
        testWidgets('tinggi sama per kelompok: $role ${size.width.toInt()}x${size.height.toInt()} teks $scale', timeout: const Timeout(Duration(minutes: 3)), (tester) async {
          final c = await startApp(tester);
          await switchTo(tester, c, emails[role]!);
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(() {
            tester.view.reset();
            tester.platformDispatcher.clearTextScaleFactorTestValue();
          });
          for (final g in groups.where((g) => g.$1 == role)) {
            c.read(routerProvider).go(g.$2);
            await tester.pumpAndSettle();
            final scroll = find.byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical).first;
            for (var i = 0; i < 8; i++) {
              await tester.drag(scroll, const Offset(0, 3000));
              await tester.pumpAndSettle();
            }
            for (var i = 0; i < 40 && g.$4.evaluate().isEmpty; i++) {
              await tester.drag(scroll, const Offset(0, -300));
              await tester.pumpAndSettle();
            }
            expect(g.$4, findsWidgets, reason: '${g.$3} harus ada');
            final heights = <double>[];
            for (final e in g.$4.evaluate()) {
              final ro = e.renderObject;
              if (ro is RenderBox && ro.hasSize) heights.add(ro.size.height);
            }
            expect(tester.takeException(), isNull, reason: '${g.$3}: tanpa overflow');
            for (final h in heights) {
              expect(h, closeTo(heights.first, 0.5), reason: '${g.$3} ($role ${size.width.toInt()} x$scale): semua anggota satu tinggi, dapat $heights');
            }
          }
        });
      }
    }
  }
}
