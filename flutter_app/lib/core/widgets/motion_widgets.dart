import 'package:flutter/material.dart';
import 'package:ikanku/core/theme/app_theme.dart';

/// Elemen yang bisa ditekan: skala 0.98 saat ditekan (130 ms, easeOutCubic), ripple tetap ada,
/// area sentuh minimal 48 dp. Hanya transform; tanpa animasi bila disableAnimations.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.borderRadius, this.semanticLabel, this.minSize = 48, this.enableFeedback = true, this.decoration});
  final BoxDecoration? decoration;
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final double minSize;
  final bool enableFeedback;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _down && !AppMotion.reduced(context) ? 0.98 : 1.0;
    final inner = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: widget.borderRadius,
        onTap: widget.onTap,
        onHighlightChanged: _set,
        enableFeedback: widget.enableFeedback,
        child: ConstrainedBox(constraints: BoxConstraints(minHeight: widget.minSize, minWidth: widget.minSize), child: widget.child),
      ),
    );
    Widget c = AnimatedScale(
      scale: scale,
      duration: AppMotion.of(context, AppMotion.press),
      curve: AppMotion.curve,
      child: widget.decoration == null ? inner : DecoratedBox(decoration: widget.decoration!, child: inner),
    );
    if (widget.semanticLabel != null) c = Semantics(button: true, label: widget.semanticLabel, excludeSemantics: true, child: c);
    return c;
  }
}

/// Muncul bertahap: fade + naik 14 dp, jeda antar item <= 60 ms, hanya 8 item pertama,
/// sekali per kunjungan layar (state dibuat sekali). Opacity dan transform saja.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  late final bool _skip = widget.index >= AppMotion.revealMaxItems;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || _skip) return;
    if (AppMotion.reduced(context)) {
      _skip2 = true;
      return;
    }
    final c = AnimationController(vsync: this, duration: AppMotion.slow);
    _c = c;
    Future<void>.delayed(AppMotion.stagger * widget.index, () {
      if (mounted) c.forward();
    });
  }

  bool _skip2 = false;

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (_skip || _skip2 || c == null) return widget.child;
    final a = CurvedAnimation(parent: c, curve: AppMotion.curve);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: a,
        child: widget.child,
        builder: (context, child) => Opacity(opacity: a.value, child: Transform.translate(offset: Offset(0, (1 - a.value) * AppMotion.revealOffset), child: child)),
      ),
    );
  }
}

/// Placeholder pemuatan tanpa paket: pulsa opacity ~1.2 s; statis bila animasi dimatikan.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.height = 16, this.width, this.radius = 8});
  final double height;
  final double? width;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(widget.radius)),
      child: SizedBox(height: widget.height, width: widget.width),
    );
    return ExcludeSemantics(
      child: AnimatedBuilder(animation: _c, child: box, builder: (context, child) => Opacity(opacity: 1 - 0.5 * Curves.easeInOut.transform(_c.value), child: child)),
    );
  }
}

/// Daftar kartu kerangka untuk keadaan memuat.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 4});
  final int count;
  @override
  Widget build(BuildContext context) => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const SkeletonRow(),
      );
}

/// Kerangka berbentuk baris produk/pesanan: thumbnail persegi + dua baris teks, dalam kartu.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: AppCard0.decoration,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Row(children: [
            Skeleton(height: 60, width: 60, radius: AppRadius.thumb),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Skeleton(height: 14), SizedBox(height: 8), Skeleton(height: 14, width: 96)])),
          ]),
        ),
      );
}

/// Kerangka berbentuk kartu vertikal produk (foto di atas, dua baris teks).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: AppCard0.decoration,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Skeleton(height: 96, radius: AppRadius.card),
            SizedBox(height: 10),
            Skeleton(height: 14),
            SizedBox(height: 8),
            Skeleton(height: 14, width: 72),
          ]),
        ),
      );
}

/// Dekorasi kartu yang sama dengan AppCard (widgets.dart mengimpor berkas ini, jadi diulang di sini tanpa impor melingkar).
class AppCard0 {
  static final decoration = BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.border), boxShadow: AppShadow.card);
}
