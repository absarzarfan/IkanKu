import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/responsive/breakpoints.dart';
import 'package:ikanku/core/responsive/content_frame.dart';

void main() {
  test('kelas lebar: compact < 600, medium 600-839, expanded >= 840', () {
    expect(widthClassOf(280), WidthClass.compact);
    expect(widthClassOf(599.9), WidthClass.compact);
    expect(widthClassOf(600), WidthClass.medium);
    expect(widthClassOf(839), WidthClass.medium);
    expect(widthClassOf(840), WidthClass.expanded);
  });

  test('padding halaman 16 / 20 / 24', () {
    expect(pagePaddingFor(WidthClass.compact), 16);
    expect(pagePaddingFor(WidthClass.medium), 20);
    expect(pagePaddingFor(WidthClass.expanded), 24);
  });

  test('skala fluida dijepit 0.85..1.25', () {
    expect(fluidScale(280), 0.85);
    expect(fluidScale(360), 1.0);
    expect(fluidScale(412), closeTo(412 / 360, 1e-9));
    expect(fluidScale(1000), 1.25);
  });

  test('kolom grid dari lebar maksimum sel; minimal 2', () {
    expect(columnsFor(280, 200, 16), 2);
    expect(columnsFor(520, 200, 16), 3);
    expect(columnsFor(0, 200, 16), 2);
  });

  test('lebar item horizontal: dibatasi min/max dan menyisakan intipan item berikut', () {
    for (final w in [280.0, 360.0, 430.0, 560.0]) {
      final item = peekItemWidth(w, inset: 32, gap: 16, preferred: 160, min: 120, max: 220);
      expect(item, inInclusiveRange(120, 220));
    }
    // 360 dp: 1 item penuh + intipan, jadi item + gap < lebar yang dapat dipakai.
    final w = peekItemWidth(360, inset: 32, gap: 16);
    expect(w + 16, lessThan(360 - 32));
  });

  testWidgets('ContentFrame membatasi lebar 560 dan memusatkan', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ContentFrame(child: SizedBox.expand(key: Key('x'))))));
    final r = tester.getRect(find.byKey(const Key('x')));
    expect(r.width, 560 - 2 * 24);
    expect(r.center.dx, 600);
  });

  testWidgets('ContentFrame pada layar compact memakai padding 16', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ContentFrame(child: SizedBox.expand(key: Key('x'))))));
    expect(tester.getRect(find.byKey(const Key('x'))).width, 360 - 32);
  });

  testWidgets('ResponsiveGrid: tinggi mengikuti isi dan 2 kolom pada layar kecil', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ResponsiveGrid(children: [for (var i = 0; i < 4; i++) SizedBox(key: Key('c$i'), height: 50 + i * 10.0)])),
    ));
    expect(tester.getTopLeft(find.byKey(const Key('c1'))).dx, greaterThan(tester.getTopLeft(find.byKey(const Key('c0'))).dx));
    expect(tester.getTopLeft(find.byKey(const Key('c2'))).dx, tester.getTopLeft(find.byKey(const Key('c0'))).dx);
  });
}
