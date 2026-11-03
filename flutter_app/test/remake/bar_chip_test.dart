import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';

import '../flows/flow_helpers.dart';

double _lum(Color c) {
  double f(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
}

double _ratio(Color a, Color b) => (math.max(_lum(a), _lum(b)) + 0.05) / (math.min(_lum(a), _lum(b)) + 0.05);

Rect _r(WidgetTester t, String k) => t.getRect(find.byKey(Key(k)));

void main() {
  for (final w in [320.0, 360.0, 412.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('bottom bar ${w.toInt()} dp skala $scale: badge tidak menyentuh pil, label, atau ikon; target >= 48 x 64', (tester) async {
        final c = await startApp(tester);
        await switchTo(tester, c, buyerEmail);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(w, 800);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });
        c.read(routerProvider).go('/profile'); // tab Profil terpilih + badge pesanan aktif
        await tester.pumpAndSettle();
        final badge = _r(tester, 'nav-badge-2');
        final icon = _r(tester, 'nav-icon-2');
        final label = _r(tester, 'nav-label-2');
        final pill = _r(tester, 'nav-item-2');
        expect(badge.overlaps(icon), isFalse, reason: 'badge tidak menimpa glyph');
        expect(badge.left - icon.right, greaterThanOrEqualTo(1.5), reason: 'ada jarak dari ikon');
        expect(badge.overlaps(label), isFalse, reason: 'badge tidak menimpa label');
        // Badge sepenuhnya di dalam pil: tidak menyentuh tepi pil.
        expect(badge.right, lessThan(pill.right - 2), reason: 'badge tidak menyentuh tepi kanan pil');
        expect(badge.top, greaterThan(pill.top + 1), reason: 'badge tidak menyentuh tepi atas pil');
        expect(badge.width, greaterThanOrEqualTo(18));
        for (var i = 0; i < 3; i++) {
          final item = _r(tester, 'nav-item-$i');
          expect(item.width, greaterThanOrEqualTo(48));
          expect(item.height, greaterThanOrEqualTo(56), reason: 'tinggi item (bar 64 termasuk padding)');
        }
        expect(tester.getSize(find.byKey(const Key('app-bottom-bar'))).height, greaterThanOrEqualTo(64));
        // Label tak terpotong pada skala 2.0: tiap label di dalam itemnya.
        for (var i = 0; i < 3; i++) {
          final item = _r(tester, 'nav-item-$i');
          final l = _r(tester, 'nav-label-$i');
          expect(l.left, greaterThanOrEqualTo(item.left - 0.5));
          expect(l.right, lessThanOrEqualTo(item.right + 0.5));
        }
      });
    }
  }

  testWidgets('badge hitungan dibatasi "9+"', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(child: NavBadge(count: 12, child: Icon(Icons.home))))));
    expect(find.text('9+'), findsOneWidget);
    expect(find.text('12'), findsNothing);
  });

  testWidgets('IconChip: hanya ukuran 40 atau 48, di semua varian dan layar', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: [
          IconChip(icon: Icons.home, size: 32),
          IconChip(icon: Icons.home, size: 44),
          IconChip(icon: Icons.home, size: 52, variant: IconChipVariant.solid),
          IconChip(icon: Icons.home, size: 48, variant: IconChipVariant.onBlue),
          IconChip(icon: Icons.home, glass: true),
        ]),
      ),
    ));
    for (final e in find.byType(IconChip).evaluate()) {
      final h = tester.getSize(find.byWidget(e.widget)).height;
      expect([40.0, 48.0], contains(h));
    }
    final c = await startApp(tester);
    await switchTo(tester, c, buyerEmail);
    for (final role in [(buyerEmail, '/profile'), (buyerEmail, '/home'), (buyerEmail, '/orders')]) {
      c.read(routerProvider).go(role.$2);
      await tester.pumpAndSettle();
      for (final e in find.byType(IconChip).evaluate()) {
        final h = tester.getSize(find.byWidget(e.widget)).height;
        expect([40.0, 48.0], contains(h), reason: 'IconChip di ${role.$2}');
      }
    }
  });

  test('kontras: pil terpilih (gradien) dan chip terpilih, teks putih >= 4.5:1 di titik terburuk', () {
    final worst = AppGradients.colors.map((c) => _ratio(Colors.white, c)).reduce(math.min);
    final danger = _ratio(Colors.white, AppColors.danger);
    debugPrint('KONTRAS pil/chip gradien terburuk: ${worst.toStringAsFixed(2)}; badge: ${danger.toStringAsFixed(2)}');
    expect(worst, greaterThanOrEqualTo(4.5));
    expect(danger, greaterThanOrEqualTo(4.5));
  });
}
