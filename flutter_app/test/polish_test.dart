import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';

double _lin(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
double luminance(Color c) => 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);
double contrast(Color a, Color b) {
  final l1 = luminance(a), l2 = luminance(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  test('kontras teks putih pada gradien merek >= 4.5:1 di titik terburuk', () {
    final stops = [for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) Color.lerp(AppGradients.colors.first, AppGradients.colors.last, t)!];
    final ratios = [for (final c in stops) contrast(Colors.white, c)];
    // ignore: avoid_print
    print('CONTRAST gradient white stops: ${ratios.map((r) => r.toStringAsFixed(2)).toList()} flat=${contrast(Colors.white, AppColors.primary).toStringAsFixed(2)}');
    for (final r in ratios) {
      expect(r, greaterThanOrEqualTo(4.5));
    }
    expect(contrast(Colors.white, AppColors.primary), greaterThanOrEqualTo(4.5));
  });

  test('gradien merek berselisih terang <= 6% dari warna datar', () {
    final flat = HSLColor.fromColor(AppColors.primary).lightness;
    for (final c in AppGradients.colors) {
      expect((HSLColor.fromColor(c).lightness - flat).abs(), lessThanOrEqualTo(0.061));
    }
  });

  test('kontras teks token pada permukaan', () {
    final pairs = <String, double>{
      'muted/background': contrast(AppColors.grey, AppColors.background),
      'body/background': contrast(AppColors.text, AppColors.background),
      'heading/white': contrast(AppColors.textStrong, Colors.white),
      'hint/field': contrast(AppColors.hint, AppColors.field),
      'danger/white': contrast(AppColors.danger, Colors.white),
      'primary/white': contrast(AppColors.primary, Colors.white),
    };
    for (final s in [AppColors.warning, AppColors.info, AppColors.success, AppColors.primary, AppColors.danger, AppColors.grey]) {
      pairs['status ${s.toARGB32().toRadixString(16)}/tint'] = contrast(StatusChip.textColor(s), Color.alphaBlend(s.withValues(alpha: 0.12), Colors.white));
    }
    // ignore: avoid_print
    print('CONTRAST ${pairs.map((k, v) => MapEntry(k, v.toStringAsFixed(2)))}');
    pairs.forEach((k, v) => expect(v, greaterThanOrEqualTo(4.5), reason: k));
  });

  testWidgets('Pressable: skala 0.98 saat ditekan, memanggil onTap, target >= 48 dp', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: Pressable(onTap: () => taps++, child: const SizedBox(width: 20, height: 10, child: Text('x')))))));
    final size = tester.getSize(find.byType(Pressable));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
    final g = await tester.startGesture(tester.getCenter(find.byType(Pressable)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 0.98);
    await g.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1.0);
    expect(taps, 1);
  });

  testWidgets('Pressable: tanpa skala dan durasi nol saat animasi dimatikan', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MediaQuery(data: const MediaQueryData(disableAnimations: true), child: Scaffold(body: Pressable(onTap: () {}, child: const Text('x'))))));
    final g = await tester.startGesture(tester.getCenter(find.byType(Pressable)));
    await tester.pump();
    final s = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(s.scale, 1.0);
    expect(s.duration, Duration.zero);
    await g.up();
  });

  testWidgets('PillButton busy: ukuran tetap dan tidak dapat ditekan dua kali', (tester) async {
    var taps = 0;
    Widget build(bool busy) => MaterialApp(home: Scaffold(body: Center(child: PillButton(label: 'Kirim', expanded: false, busy: busy, onPressed: () => taps++))));
    await tester.pumpWidget(build(false));
    final before = tester.getSize(find.byType(PillButton));
    await tester.tap(find.byType(PillButton));
    expect(taps, 1);
    await tester.pumpWidget(build(true));
    expect(tester.getSize(find.byType(PillButton)), before);
    await tester.tap(find.byType(PillButton), warnIfMissed: false);
    expect(taps, 1);
  });

  testWidgets('IconChip: dikeluarkan dari semantics, ukuran sesuai', (tester) async {
    final h = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(child: IconChip(icon: Icons.home, size: 44)))));
    expect(tester.getSize(find.byType(IconChip)), const Size(44, 44));
    expect(find.descendant(of: find.byType(IconChip), matching: find.byType(ExcludeSemantics)), findsWidgets);
    h.dispose();
  });

  testWidgets('StatusChip menampilkan label dan warna turunan token', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: StatusChip('Menunggu', color: AppColors.warning))));
    expect(find.text('Menunggu'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Menunggu')).style?.color, StatusChip.textColor(AppColors.warning));
  });

  testWidgets('Reveal: item ke-9 dan seterusnya tidak dianimasikan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Reveal(index: 9, child: Text('a')))));
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('Skeleton statis saat animasi dimatikan', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MediaQuery(data: const MediaQueryData(disableAnimations: true), child: const Scaffold(body: Skeleton()))));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  test('token gerak <= 350 ms', () {
    for (final d in [AppMotion.fast, AppMotion.base, AppMotion.slow, AppMotion.press]) {
      expect(d.inMilliseconds, lessThanOrEqualTo(350));
    }
    expect(AppMotion.stagger.inMilliseconds, lessThanOrEqualTo(60));
  });
}
