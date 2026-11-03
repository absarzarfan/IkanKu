import 'package:ikanku/core/responsive/breakpoints.dart';

/// Token tata letak tetap (Phase 16). Satu nilai per komponen dan kelas lebar, pada skala 4 dp,
/// diturunkan dari nilai yang sudah ada. Tabel lengkap: docs/layout-spec.md.
class Layout {
  const Layout._();

  /// Chip ikon: tepat dua ukuran.
  static const double iconChipMd = 40, iconChipLg = 48;

  /// Tinggi chip pilihan / filter, tombol minimum, kolom isian, tab segmen.
  static const double chip = 40, button = 48, field = 56, segmented = 48;

  /// Item bottom bar: area sentuh minimum (seluruh item, bukan hanya ikon).
  static const double navItemMinWidth = 48, navItemMinHeight = 64;

  /// Bagian item berikutnya yang terlihat pada daftar horizontal (24-32 dp).
  static const double peek = 28;

  /// Radius kartu dan foto kecil (sama dengan AppRadius.card / AppRadius.thumb).
  static const double cardRadius = 20, thumbRadius = 16;

  /// Thumbnail baris daftar produk (persegi).
  static const double rowThumb = 84;

  static int gridColumns(WidthClass w) => switch (w) { WidthClass.compact => 2, WidthClass.medium => 3, WidthClass.expanded => 4 };

  /// Jumlah item PENUH yang terlihat pada daftar horizontal (ditambah [peek]).
  static int carouselItems(WidthClass w) => switch (w) { WidthClass.compact => 2, WidthClass.medium => 3, WidthClass.expanded => 4 };

  /// Tinggi minimum tetap; kelompok mengambil tinggi anggota tertinggi (teks membungkus, tidak dipotong).
  static double heroContentMin(WidthClass w) => switch (w) { WidthClass.compact => 56, WidthClass.medium => 64, WidthClass.expanded => 72 };
  static double valuePropMin(WidthClass w) => switch (w) { WidthClass.compact => 128, WidthClass.medium => 136, WidthClass.expanded => 144 };
  static double statCardMin(WidthClass w) => switch (w) { WidthClass.compact => 120, WidthClass.medium => 128, WidthClass.expanded => 132 };
  static double orderCellMin(WidthClass w) => switch (w) { WidthClass.compact => 72, WidthClass.medium => 76, WidthClass.expanded => 80 };
  static double menuRowMin(WidthClass w) => 60;
  static double categoryCardMin(WidthClass w) => switch (w) { WidthClass.compact => 60, WidthClass.medium => 64, WidthClass.expanded => 68 };
  static double quickActionMin(WidthClass w) => switch (w) { WidthClass.compact => 104, WidthClass.medium => 112, WidthClass.expanded => 120 };

  /// Lebar item daftar horizontal: [items] item penuh + [peek] terlihat; item pertama sejajar gutter.
  static double carouselItemWidth(double frame, double gutter, int items, double gap) => (frame - gutter - peek - items * gap) / items;
}
