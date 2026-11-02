import 'package:flutter/material.dart';
import 'package:ikanku/core/responsive/breakpoints.dart';

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
  const ResponsiveGrid({super.key, required this.children, this.maxCrossAxisExtent = 200, this.spacing = 16, this.runSpacing = 8});
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

/// Daftar horizontal: tinggi dari isi, item ber-lebar dari ruang tersedia dengan "intip" item berikut,
/// item pertama sejajar dengan padding halaman.
class PeekRow extends StatelessWidget {
  const PeekRow({super.key, required this.children, this.gap = 16, this.preferred = 160, this.min = 120, this.max = 220});
  final List<Widget> children;
  final double gap, preferred, min, max;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = peekItemWidth(c.maxWidth, inset: 0, gap: gap, preferred: preferred, min: min, max: max);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (i, ch) in children.indexed) ...[if (i > 0) SizedBox(width: gap), SizedBox(width: w, child: ch)],
        ]),
      );
    });
  }
}
