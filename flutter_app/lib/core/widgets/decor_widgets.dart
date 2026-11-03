import 'package:flutter/material.dart';
import 'package:ikanku/core/layout/layout.dart';
import 'package:ikanku/core/theme/app_theme.dart';

/// Varian chip ikon: tint (gradien merek rendah, ikon biru), solid (gradien merek penuh, ikon putih),
/// onBlue (putih translusen di atas latar biru).
enum IconChipVariant { tint, solid, onBlue }

/// Chip ikon (web .icon-chip): kotak membulat, TEPAT dua ukuran (40 dan 48; nilai lain dibulatkan).
class IconChip extends StatelessWidget {
  const IconChip({super.key, required this.icon, this.variant = IconChipVariant.tint, this.glass = false, this.size = Layout.iconChipMd, this.color, this.ring = false});
  final IconData icon;
  final IconChipVariant variant;

  /// Kompatibilitas lama: sama dengan [IconChipVariant.onBlue].
  final bool glass;
  final double size;
  final Color? color;

  /// Cincin tipis 1 px (merek 12%).
  final bool ring;

  static double snap(double s) => s >= 46 ? Layout.iconChipLg : Layout.iconChipMd;

  @override
  Widget build(BuildContext context) {
    final v = glass ? IconChipVariant.onBlue : variant;
    final s = snap(size);
    final solid = v == IconChipVariant.solid;
    final onBlue = v == IconChipVariant.onBlue;
    final fg = onBlue || solid ? AppColors.onPrimary : (color ?? AppColors.primary);
    return ExcludeSemantics(
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          gradient: onBlue ? null : (solid && color == null ? AppGradients.primary : (solid ? LinearGradient(colors: [color!, color!]) : AppGradients.chipTint)),
          color: onBlue ? AppColors.glass : null,
          border: onBlue ? Border.all(color: AppColors.glassBorder) : (ring ? Border.all(color: AppColors.border) : null),
          borderRadius: BorderRadius.circular(AppRadius.icon),
        ),
        // Sorot sangat halus di kiri atas (tanpa pendar).
        foregroundDecoration: solid ? BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.icon), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.center, colors: [Color(0x26FFFFFF), Color(0x00FFFFFF)])) : null,
        child: Icon(icon, size: s * 0.5, color: fg),
      ),
    );
  }
}

/// Lingkaran dekoratif (opasitas <= 0.12), di luar semantics dan tidak menangkap sentuhan.
/// Ditaruh di sudut kanan atas header, jauh dari teks isi.
class HeaderDecor extends StatelessWidget {
  const HeaderDecor({super.key});
  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: Stack(clipBehavior: Clip.hardEdge, children: [
            Positioned(right: -36, top: -48, child: _Dot(size: 150, alpha: 0.10)),
            Positioned(right: 56, top: -24, child: _Dot(size: 56, alpha: 0.07)),
          ]),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.alpha});
  final double size;
  final double alpha;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
        child: SizedBox(width: size, height: size),
      );
}

/// Kotak biru bergradien dengan dasar melengkung dan dekorasi; dipakai header layar.
class GradientHeader extends StatelessWidget {
  const GradientHeader({super.key, required this.child, this.padding = EdgeInsets.zero, this.radius = AppRadius.header, this.shadow = true});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
        boxShadow: shadow ? AppShadow.header : null,
      ),
      child: Stack(children: [
        const HeaderDecor(),
        Padding(padding: padding, child: child),
      ]),
    );
  }
}

/// Judul bagian dengan batang aksen gradien 40x4 (web .section-title::after).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.eyebrow});
  final String title;
  final String? eyebrow;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (eyebrow != null) Text(eyebrow!, style: AppText.eyebrow),
        Text(title, style: AppText.subheading, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(4)),
          child: const SizedBox(width: 40, height: 4),
        ),
      ]);
}
