import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/main.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('IkanKuApp (root widget) dapat dirender', (tester) async {
    tester.view.physicalSize = const Size(412 * 2, 917 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: IkanKuApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
