import 'package:flutter/material.dart';
import 'package:ikanku/core/theme/app_theme.dart';

/// Chip ikon (web .icon-chip): kotak membulat; tint gradien merek di permukaan terang,
/// putih transparan dengan ikon putih di atas latar biru.
class IconChip extends StatelessWidget {
  const IconChip({super.key, required this.icon, this.glass = false, this.size = 44, this.color});
  final IconData icon;
  final bool glass;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: glass ? null : AppGradients.chipTint,
          color: glass ? const Color(0x2EFFFFFF) : null,
          border: glass ? Border.all(color: const Color(0x47FFFFFF)) : null,
          borderRadius: BorderRadius.circular(AppRadius.icon),
        ),
        child: Icon(icon, size: size * 0.5, color: glass ? AppColors.onPrimary : (color ?? AppColors.primary)),
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
