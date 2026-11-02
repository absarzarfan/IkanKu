import 'package:flutter/material.dart';
import 'package:ikanku/core/responsive/breakpoints.dart';

/// Token spasi semantik di atas skala 4, 8, 12, 16, 20, 24, 32 (`Gap`).
/// Nilai fungsi mengikuti kelas lebar; nilai konstanta tetap.
class Space {
  /// Tinggi minimum tab bawah (lihat `_ShellScaffold`).
  static const double navMinHeight = 64;

  /// Jarak antara judul bagian dan isinya.
  static const double sectionTitleGap = 12;

  /// Jarak antar kartu (daftar horizontal, tile, sel grid).
  static const double itemGap = 12;

  /// Jarak titik indikator di bawah banner.
  static const double dotsGap = 8;

  /// Margin kiri/kanan layar: 16 / 20 / 24.
  static double screenGutter(BuildContext c) => pagePaddingFor(c.widthClass);

  /// Jarak antar bagian: 24 (compact), 28 (medium dan expanded).
  static double sectionGap(BuildContext c) => c.widthClass == WidthClass.compact ? 24 : 28;
  static double sectionGapFor(WidthClass w) => w == WidthClass.compact ? 24 : 28;

  /// Padding kartu: 12 pada layar compact (kartu padat), 16 selainnya.
  static double cardPadding(BuildContext c) => cardPaddingFor(c.widthClass);
  static double cardPaddingFor(WidthClass w) => w == WidthClass.compact ? 12 : 16;

  /// Ruang bawah layar tab: tab bawah berada DI LUAR body Scaffold (bottomNavigationBar), jadi
  /// body tidak tertimpa tab. Isi = inset aman + 16 (Scaffold sudah menghapus inset bawah dari body saat ada tab).
  /// Jika suatu saat tab menimpa body: tambahkan `navMinHeight`.
  static double minBottomClearance(BuildContext c) => MediaQuery.paddingOf(c).bottom + 16;

  /// Ruang bawah untuk layar non-tab (tanpa tab bawah): inset aman + 16.
  static double bottomClearance(BuildContext c) => MediaQuery.paddingOf(c).bottom + 16;

  /// Padding daftar layar biasa: margin layar di sisi dan atas, ruang bawah minimum.
  static EdgeInsets pad(BuildContext c) {
    final g = screenGutter(c);
    return EdgeInsets.fromLTRB(g, g, g, bottomClearance(c));
  }

  /// Padding daftar layar tab (ada tab bawah).
  static EdgeInsets padTab(BuildContext c) {
    final g = screenGutter(c);
    return EdgeInsets.fromLTRB(g, g, g, minBottomClearance(c));
  }
}

/// Jarak vertikal semantik: `VGap.section()`, `VGap.title()`, `VGap.item()`.
class VGap extends StatelessWidget {
  const VGap.section({super.key}) : _kind = 0;
  const VGap.title({super.key}) : _kind = 1;
  const VGap.item({super.key}) : _kind = 2;
  final int _kind;

  @override
  Widget build(BuildContext context) => SizedBox(height: switch (_kind) { 0 => Space.sectionGap(context), 1 => Space.sectionTitleGap, _ => Space.itemGap });
}

/// Jarak horizontal antar item.
class HGap extends StatelessWidget {
  const HGap({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(width: Space.itemGap);
}
