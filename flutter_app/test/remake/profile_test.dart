import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/features/profile/presentation/profile_screens.dart';

import '../flows/flow_helpers.dart';

void main() {
  for (final w in [320.0, 360.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('baris Pesanan Saya tidak terpotong di ${w.toInt()} dp, skala teks $scale', (tester) async {
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });
        final c = await startApp(tester);
        await switchTo(tester, c, buyerEmail);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(w, 800);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        c.read(routerProvider).go('/profile');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final row = tester.getRect(find.byKey(const Key('orders-row')));
        expect(row.left, greaterThanOrEqualTo(0));
        expect(row.right, lessThanOrEqualTo(w));
        final cells = find.byType(OrderStatusCell);
        expect(cells, findsNWidgets(5));
        final widths = [for (final e in cells.evaluate()) tester.getRect(find.byWidget(e.widget)).width];
        for (final x in widths) {
          expect(x, closeTo(widths.first, 0.5), reason: 'sel sama lebar');
        }
        for (final e in cells.evaluate()) {
          final cell = tester.getRect(find.byWidget(e.widget));
          final label = tester.getRect(find.descendant(of: find.byWidget(e.widget), matching: find.byType(Text)).last);
          expect(label.left, greaterThanOrEqualTo(cell.left - 0.5));
          expect(label.right, lessThanOrEqualTo(cell.right + 0.5), reason: 'label tidak terpotong');
          final para = tester.renderObject<RenderParagraph>(find.descendant(of: find.byWidget(e.widget), matching: find.byType(RichText)).last);
          final tp = TextPainter(text: para.text, textDirection: TextDirection.ltr, textScaler: para.textScaler, maxLines: 2)..layout(maxWidth: para.size.width);
          expect(tp.didExceedMaxLines, isFalse, reason: 'label muat dalam 2 baris');
          final longest = tp.computeLineMetrics().map((m) => m.width).reduce((a, b) => a > b ? a : b);
          expect(longest, lessThanOrEqualTo(para.size.width + 0.5), reason: 'kata tidak melampaui sel');
        }
      });
    }
  }
}
