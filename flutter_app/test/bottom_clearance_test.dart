import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';

/// Tab bawah berada di luar body Scaffold; item terakhir harus terlihat penuh dan berjarak 16..32 dp dari tab.
void main() {
  const buyerTabs = ['/home', '/search', '/profile'];
  const sellerTabs = ['/seller', '/seller/products', '/seller/settings'];

  for (final size in const [Size(360, 800), Size(412, 915)]) {
    for (final (role, tabs) in [('buyer', buyerTabs), ('seller', sellerTabs)]) {
      for (final route in tabs) {
        testWidgets('jarak bawah $role $route ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
          tester.view.physicalSize = size * 2;
          tester.view.devicePixelRatio = 2;
          addTearDown(tester.view.reset);
          final c = ProviderContainer();
          addTearDown(c.dispose);
          await tester.pumpWidget(UncontrolledProviderScope(
            container: c,
            child: Consumer(builder: (context, ref, _) => MaterialApp.router(theme: buildTheme(), routerConfig: ref.watch(routerProvider))),
          ));
          await tester.pumpAndSettle();
          if (role == 'seller') {
            await c.read(authProvider.notifier).login('penjual@ikanku.id', 'Admin123');
            await tester.pumpAndSettle();
          }
          c.read(routerProvider).go(route);
          await tester.pumpAndSettle();

          // Daftar vertikal utama = Scrollable vertikal tertinggi.
          final vertical = find.byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical);
          Finder scrollable = vertical.first;
          for (final e in vertical.evaluate()) {
            if (tester.getSize(find.byElementPredicate((x) => x == e)).height > tester.getSize(scrollable).height) scrollable = find.byElementPredicate((x) => x == e);
          }
          for (var i = 0; i < 6; i++) {
            await tester.drag(scrollable, const Offset(0, -3000));
            await tester.pumpAndSettle();
          }
          final sliver = tester.renderObject<RenderSliverMultiBoxAdaptor>(find.descendant(of: scrollable, matching: find.byType(SliverList)).first);
          final last = sliver.lastChild!;
          final bottom = last.localToGlobal(Offset(0, last.size.height)).dy;
          final navTop = tester.getRect(find.text(role == 'buyer' ? 'Beranda' : 'Beranda')).top;
          final viewportBottom = tester.getRect(scrollable).bottom;
          // Tab adalah bottomNavigationBar: bawah viewport = atas tab (label berada di dalam tab).
          expect(viewportBottom, lessThanOrEqualTo(navTop));
          final gap = viewportBottom - bottom;
          expect(bottom, lessThanOrEqualTo(viewportBottom), reason: 'item terakhir terlihat penuh');
          final fits = tester.state<ScrollableState>(scrollable).position.maxScrollExtent == 0;
          // Isi yang muat tanpa scroll: cukup jarak minimal 16 (ruang sisa di bawah wajar).
          if (fits) {
            expect(gap, greaterThanOrEqualTo(15.99), reason: 'jarak (isi muat) = $gap');
          } else {
            expect(gap, inInclusiveRange(15.99, 32.01), reason: 'jarak item terakhir ke tab = $gap');
          }
        });
      }
    }
  }
}
