import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/responsive/breakpoints.dart';
import 'package:ikanku/core/responsive/spacing.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  test('token spasi menurut kelas lebar', () {
    expect(pagePaddingFor(WidthClass.compact), 16);
    expect(pagePaddingFor(WidthClass.medium), 20);
    expect(pagePaddingFor(WidthClass.expanded), 24);
    expect(Space.sectionGapFor(WidthClass.compact), 24);
    expect(Space.sectionGapFor(WidthClass.medium), 28);
    expect(Space.sectionGapFor(WidthClass.expanded), 28);
    expect(Space.cardPaddingFor(WidthClass.compact), 12);
    expect(Space.cardPaddingFor(WidthClass.medium), 16);
    expect(Space.sectionTitleGap, 12);
    expect(Space.itemGap, 12);
    expect(Space.dotsGap, 8);
  });

  testWidgets('VGap dan minBottomClearance mengikuti token', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(360, 800), padding: EdgeInsets.only(bottom: 20)),
        child: Builder(builder: (c) {
          ctx = c;
          return const Column(children: [VGap.section(key: Key('s')), VGap.title(key: Key('t')), VGap.item(key: Key('i'))]);
        }),
      ),
    ));
    expect(tester.getSize(find.byKey(const Key('s'))).height, 24);
    expect(tester.getSize(find.byKey(const Key('t'))).height, 12);
    expect(tester.getSize(find.byKey(const Key('i'))).height, 12);
    expect(Space.minBottomClearance(ctx), 20 + 16);
  });

  for (final size in const [Size(360, 800), Size(412, 915), Size(768, 1024)]) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('Home jarak vertikal/horizontal = token ${size.width.toInt()}x${size.height.toInt()} teks ${scale}x', (tester) async {
        tester.view.physicalSize = size * 2;
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
              builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        Rect r(String k) => tester.getRect(find.byKey(Key(k)));
        // Gulir daftar utama tanpa ensureVisible (yang ikut menggeser daftar horizontal).
        Future<void> scrollTo(String k) async {
          for (var i = 0; i < 30; i++) {
            final f = find.byKey(Key(k));
            if (f.evaluate().isNotEmpty && tester.getRect(f).bottom < size.height - 100) return;
            await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
            await tester.pumpAndSettle();
          }
        }

        final section = Space.sectionGapFor(widthClassOf(size.width));
        const tol = 0.5;

        // Atas: kategori -> banner -> titik -> judul rekomendasi.
        expect(r('home-banner').top - r('home-categories').bottom, closeTo(section, tol), reason: 'kategori -> banner');
        expect(r('home-banner-dots').top - r('home-banner').bottom, closeTo(Space.dotsGap, tol), reason: 'banner -> titik');
        expect(r('home-reco-title').top - r('home-banner-dots').bottom, closeTo(section, tol), reason: 'titik -> judul');

        // Judul -> bagian atas foto, dan jarak horizontal antar kartu.
        await scrollTo('home-reco-photo-0');
        await tester.pumpAndSettle();
        expect(r('home-reco-photo-0').top - r('home-reco-title').bottom, closeTo(Space.sectionTitleGap, tol), reason: 'judul -> foto');
        expect(r('home-reco-card-1').left - r('home-reco-card-0').right, closeTo(Space.itemGap, tol), reason: 'kartu -> kartu');
        expect(r('home-reco-card-0').left, closeTo((size.width - (size.width < kContentMaxWidth ? size.width : kContentMaxWidth)) / 2 + pagePaddingFor(widthClassOf(size.width)), tol), reason: 'kartu pertama sejajar margin layar');

        // Kartu -> daftar vertikal.
        await scrollTo('home-list-first');
        await tester.pumpAndSettle();
        final unitBottom = r('home-reco-card-0').bottom;
        expect(r('home-list-first').top - unitBottom, closeTo(section, tol), reason: 'kartu -> daftar');

        // Ujung daftar: tombol terakhir tidak tertutup tab bawah.
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
        await tester.pumpAndSettle();
        final last = tester.getRect(find.text('Lihat Lebih'));
        final navTop = tester.getRect(find.text('Beranda')).top;
        expect(last.bottom, lessThanOrEqualTo(navTop));
      });
    }
  }
}
