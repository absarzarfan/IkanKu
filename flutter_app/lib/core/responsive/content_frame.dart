import 'package:flutter/material.dart';
import 'package:ikanku/core/layout/layout.dart';
import 'package:ikanku/core/responsive/breakpoints.dart';
import 'package:ikanku/core/responsive/spacing.dart';

/// Memusatkan konten dengan lebar maksimum [maxWidth] pada layar lebar.
/// Padding horizontal mengikuti kelas lebar (16/20/24) kecuali [padded] false.
class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child, this.maxWidth = kContentMaxWidth, this.padded = true, this.safe = false});
  final Widget child;
  final double maxWidth;
  final bool padded;

  /// true: hormati inset aman kiri/kanan (mode landscape dengan notch).
  final bool safe;

  @override
  Widget build(BuildContext context) {
    final pad = padded ? context.pagePadding : 0.0;
    Widget c = Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: pad), child: child),
      ),
    );
    if (safe) c = SafeArea(top: false, bottom: false, child: c);
    return c;
  }
}

/// Grid responsif: tinggi baris mengikuti isi kartu (tanpa tinggi tetap), kolom dari maxCrossAxisExtent.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.maxCrossAxisExtent = 200, this.spacing = Space.itemGap, this.runSpacing = Space.itemGap});
  final List<Widget> children;
  final double maxCrossAxisExtent;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = columnsFor(c.maxWidth, maxCrossAxisExtent, spacing);
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    });
  }
}

/// Daftar kartu horizontal (Phase 16): item pertama sejajar `screenGutter`, lebar item dari token
/// ([Layout.carouselItems] item penuh + [Layout.peek] terlihat), SEMUA item setinggi item tertinggi
/// (IntrinsicHeight + stretch; teks membungkus). Tempatkan di luar padding halaman.
class HorizontalCardList extends StatelessWidget {
  const HorizontalCardList({super.key, required this.children, this.gap = Space.itemGap, this.items});
  final List<Widget> children;
  final double gap;

  /// Menimpa jumlah item penuh yang terlihat (bawaan: menurut kelas lebar).
  final int? items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final g = Space.screenGutter(context);
      final frame = c.maxWidth < kContentMaxWidth ? c.maxWidth : kContentMaxWidth;
      final inset = (c.maxWidth - frame) / 2 + g;
      final n = items ?? Layout.carouselItems(context.widthClass);
      final w = Layout.carouselItemWidth(frame, g, n, gap);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (i, ch) in children.indexed) ...[if (i > 0) SizedBox(width: gap), SizedBox(width: w, child: ch)],
          ]),
        ),
      );
    });
  }
}
