import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Kelas lebar layar: compact < 600, medium 600-839, expanded >= 840 (dp).
enum WidthClass { compact, medium, expanded }

WidthClass widthClassOf(double width) {
  if (width < 600) return WidthClass.compact;
  if (width < 840) return WidthClass.medium;
  return WidthClass.expanded;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  WidthClass get widthClass => widthClassOf(screenWidth);
  bool get isCompact => widthClass == WidthClass.compact;

  /// Padding horizontal halaman: 16 / 20 / 24 menurut kelas lebar.
  double get pagePadding => pagePaddingFor(widthClass);
}

double pagePaddingFor(WidthClass c) => switch (c) {
      WidthClass.compact => 16,
      WidthClass.medium => 20,
      WidthClass.expanded => 24,
    };

/// Lebar maksimum konten pada layar lebar.
const double kContentMaxWidth = 560;

/// Skala fluida = clamp(lebar / 360, 0.85, 1.25). HANYA untuk dimensi media dan kartu, bukan ukuran huruf.
double fluidScale(double width) => (width / 360).clamp(0.85, 1.25);

/// Dimensi media/kartu yang ikut skala fluida.
double fluid(BuildContext context, double base) => base * fluidScale(MediaQuery.sizeOf(context).width);

/// Skala spasi.
class Gap {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24, xxxl = 32;
}

/// Jumlah kolom dari lebar tersedia dan lebar sel maksimum (setara maxCrossAxisExtent).
int columnsFor(double available, double maxExtent, double spacing, {int min = 2}) {
  if (available <= 0) return min;
  final n = ((available + spacing) / (maxExtent + spacing)).ceil();
  return math.max(min, n);
}

/// Lebar item daftar horizontal: n item penuh + sebagian item berikutnya terlihat (peek).
/// [available] = lebar area daftar, [inset] = padding kiri+kanan, hasil dibatasi min..max.
double peekItemWidth(double available, {required double inset, required double gap, double preferred = 160, double min = 120, double max = 220, double peek = 0.35}) {
  final usable = math.max(0.0, available - inset);
  final n = math.max(1, (usable / (preferred + gap)).floor());
  final w = (usable - gap * n) / (n + peek);
  return w.clamp(min, max);
}
