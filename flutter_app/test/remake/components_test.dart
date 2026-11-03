import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/product_cards.dart';

double _lum(Color c) {
  double f(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
}

double ratio(Color a, Color b) {
  final l1 = _lum(a), l2 = _lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

const _p = Product(id: 'x', name: 'Ikan Uji dengan nama yang sangat panjang sekali', description: 'd', category: 'Hias', image: 'assets/images/fish_3.webp', variations: [Variation(id: 'v', weight: '1 Kg', count: 2, price: 100000, stock: 3)], discountPercent: 10);

Widget _gallery() => Column(children: [
      HeroHeader(floating: FloatingSearchField(label: 'Cari ikan air tawar', onTap: () {}), child: const Text('Halo, Uji!')),
      ValuePropCard(icon: Icons.verified_outlined, title: 'Ikan Segar Langsung ke Rumah Anda'),
      StatRow(cards: [StatCard(value: '12', label: 'Total pesanan', icon: Icons.receipt_long_outlined), StatCard(value: '3', label: 'Pesanan aktif'), StatCard(value: '0', label: 'Ulasan diberikan')]),
      FilterChipBar(labels: const ['Hias', 'Rating 4.5+'], onRemove: (_) {}, onClearAll: () {}),
      SegmentedTabs(labels: const ['Menunggu', 'Dikemas', 'Dikirim'], counts: const [1, 2, 0], index: 0, onChanged: (_) {}),
      const StatusTimeline(steps: ['Pesanan dibuat', 'Dikemas', 'Dikirim', 'Selesai'], current: 1),
      const SuccessMoment(title: 'Pesanan berhasil dibuat', subtitle: 'Pantau di Pesanan Saya'),
      MenuGroup(title: 'Akun', items: [MenuItem(icon: Icons.person_outline, label: 'Data Profil', onTap: () {}), MenuItem(icon: Icons.logout, label: 'Keluar', destructive: true, onTap: () {})]),
      EmptyState('Tidak ada hasil', icon: Icons.search_off, hint: 'Coba kata kunci lain.', actionLabel: 'Atur ulang filter', onAction: () {}),
      const EqualGrid(columns: 2, children: [InfoPill(label: 'Stok habis'), InfoPill(label: '4.5', icon: Icons.star)]),
      SelectChip(label: 'Terpilih', selected: true, onTap: () {}),
      Row(children: [Expanded(child: ProductTile(product: _p)), const SizedBox(width: 12), Expanded(child: ProductFeaturedCard(product: _p))]),
      ProductRow(product: _p),
      AppBottomBar(items: const [BarItem(Icons.home_outlined, Icons.home, 'Beranda'), BarItem(Icons.person_outline, Icons.person, 'Pengaturan')], index: 0, badgeIndex: 1, badgeCount: 12, onTap: (_) {}),
    ]);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  for (final scale in [1.0, 2.0]) {
    for (final reduced in [false, true]) {
      testWidgets('komponen remake render tanpa overflow di 320 dp, skala teks $scale, gerak dikurangi=$reduced', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 2400);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: buildTheme(),
          builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: reduced), child: child!),
          home: Scaffold(body: SingleChildScrollView(child: _gallery())),
        ));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        if (reduced) {
          // Tanpa gerak: tidak ada animasi tersisa setelah satu frame.
          expect(tester.binding.hasScheduledFrame, isFalse);
        }
      });
    }
  }

  testWidgets('semantics: aksi berlabel, chip terpilih, ikon dekoratif dikecualikan', (tester) async {
    final h = tester.ensureSemantics();
    tester.view.physicalSize = const Size(320, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: Scaffold(body: SingleChildScrollView(child: _gallery()))));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.bySemanticsLabel('Hapus filter Hias'), findsOneWidget);
    expect(find.bySemanticsLabel('Cari ikan air tawar'), findsOneWidget);
    expect(find.bySemanticsLabel('Total pesanan: 12'), findsOneWidget);
    expect(tester.getSemantics(find.text('Terpilih')).flagsCollection.isSelected, isNotNull);
    expect(find.bySemanticsLabel(RegExp('^12 ')), findsNothing, reason: 'badge tanpa label tidak dibaca sebagai teks lepas');
    h.dispose();
  });

  testWidgets('hover: tema memakai tint merek (bukan abu-abu), ~6%', (tester) async {
    final t = buildTheme();
    expect(t.hoverColor, AppColors.hover);
    final c = t.hoverColor;
    expect(c.a, closeTo(0.06, 0.01));
    expect((c.b - c.r) > 0.5, isTrue, reason: 'dominan biru, bukan abu-abu');
  });

  test('kontras: teks di atas gradien, chip, dan foto >= 4.5:1 (titik terburuk)', () {
    final w = Colors.white;
    final worst = <String, double>{
      'putih di gradien (titik terang)': ratio(w, AppGradients.colors.first),
      'putih di gradien (titik gelap)': ratio(w, AppGradients.colors.last),
      'putih di lencana bahaya (solid)': ratio(w, AppColors.danger),
      'putih di bawah-foto (80% gelap di atas foto putih)': ratio(w, Color.alphaBlend(AppColors.photoShade, Colors.white)),
      'putih di pil-foto (70% gelap di atas foto putih)': ratio(w, Color.alphaBlend(AppColors.buttonOnPhoto, Colors.white)),
      'primaryDark di pil terpilih (surfaceTint)': ratio(AppColors.primaryDark, AppColors.surfaceTint),
      'primaryDark di chip filter (surfaceTint)': ratio(AppColors.primaryDark, AppColors.surfaceTint),
      'teks status Menunggu di tint 12%': ratio(StatusChip.textColor(AppColors.warning), Color.alphaBlend(AppColors.warning.withValues(alpha: 0.12), Colors.white)),
      'teks lencana diskon di tint 14%': ratio(StatusChip.textColor(AppColors.danger), Color.alphaBlend(AppColors.danger.withValues(alpha: 0.14), Colors.white)),
      'teks lencana stok di tint 14%': ratio(StatusChip.textColor(AppColors.success), Color.alphaBlend(AppColors.success.withValues(alpha: 0.14), Colors.white)),
      'abu-abu keterangan di latar tint': ratio(AppColors.grey, AppColors.background),
      'primary di latar tint': ratio(AppColors.primary, AppColors.background),
    };
    worst.forEach((k, v) => debugPrint('KONTRAS ${v.toStringAsFixed(2)}  $k'));
    for (final e in worst.entries) {
      expect(e.value, greaterThanOrEqualTo(4.5), reason: e.key);
    }
  });
}
