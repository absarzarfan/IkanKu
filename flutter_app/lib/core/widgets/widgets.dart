import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/responsive/breakpoints.dart';
import 'package:ikanku/core/responsive/content_frame.dart';
import 'package:ikanku/core/responsive/spacing.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/decor_widgets.dart';
import 'package:ikanku/core/widgets/motion_widgets.dart';

export 'package:ikanku/core/responsive/breakpoints.dart';
export 'package:ikanku/core/responsive/content_frame.dart';
export 'package:ikanku/core/widgets/decor_widgets.dart';
export 'package:ikanku/core/widgets/motion_widgets.dart';
export 'package:ikanku/core/responsive/spacing.dart';

/// Layout standar: kotak biru melengkung di atas (Figma "kotak"), judul, tombol kembali.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.showBack = true,
    this.bottom,
    this.bottomNavigationBar,
    this.actions = const [],
    this.headerExtra,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final bool showBack;
  final Widget? bottom;
  final Widget? bottomNavigationBar;
  final List<Widget> actions;
  final Widget? headerExtra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          GradientHeader(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 14),
            child: ContentFrame(
              padded: false,
              safe: true,
              child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSize.buttonSmall),
                  child: Row(
                    children: [
                      showBack
                          ? IconButton(
                              tooltip: 'Kembali',
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: onBack ?? () => context.canPop() ? context.pop() : context.go('/'),
                            )
                          : const SizedBox(width: 48),
                      Expanded(
                        child: Text(title, textAlign: TextAlign.center, style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      ...actions,
                      if (actions.isEmpty) const SizedBox(width: 48),
                    ],
                  ),
                ),
                ?headerExtra,
              ],
            ),
            ),
          ),
          Expanded(child: ContentFrame(padded: false, safe: true, child: bottom == null && bottomNavigationBar == null ? SafeArea(top: false, child: body) : body)),
          if (bottom != null) ContentFrame(padded: false, safe: true, child: bottom!),
        ],
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({super.key, required this.label, required this.onPressed, this.color = AppColors.primary, this.outlined = false, this.height = AppSize.button, this.expanded = true, this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool outlined;
  final double height;
  final bool expanded;

  /// true: tombol dinonaktifkan dan menampilkan indikator tanpa mengubah ukuran (cegah kirim ganda).
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final fg = outlined ? color : AppColors.onPrimary;
    final gradient = !outlined && enabled && color == AppColors.primary;
    final h = height < AppSize.buttonSmall ? AppSize.buttonSmall : height;
    final radius = BorderRadius.circular(AppRadius.pill);
    final decoration = BoxDecoration(
      gradient: gradient ? AppGradients.primary : null,
      color: gradient ? null : (outlined ? AppColors.surface : (enabled ? color : AppColors.greyLight)),
      borderRadius: radius,
      border: outlined ? Border.all(color: color) : null,
    );
    final text = Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.buttonLabel.copyWith(color: fg));
    final child = Container(
      constraints: BoxConstraints(minHeight: h, minWidth: expanded ? double.infinity : 64),
      padding: const EdgeInsets.symmetric(horizontal: Gap.xl, vertical: Gap.sm),
      alignment: Alignment.center,
      child: Stack(alignment: Alignment.center, children: [
        Opacity(opacity: busy ? 0 : 1, child: text),
        if (busy) SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg)),
      ]),
    );
    final button = Pressable(onTap: enabled ? onPressed : null, borderRadius: radius, decoration: decoration, minSize: h, child: child);
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Field abu-abu radius 10 (Figma Login).
class AppField extends StatelessWidget {
  const AppField({super.key, required this.controller, required this.hint, this.validator, this.obscure = false, this.keyboard, this.maxLines = 1, this.readOnly = false, this.onTap, this.suffix, this.label, this.fieldKey});
  final TextEditingController controller;
  final String hint;
  final String? label;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType? keyboard;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) Padding(padding: const EdgeInsets.only(bottom: Gap.sm), child: Text(label!, style: AppText.label)),
          TextFormField(
            key: fieldKey,
            controller: controller,
            validator: validator,
            obscureText: obscure,
            keyboardType: keyboard,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: AppText.input,
            scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.hint,
              suffixIcon: suffix,
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color = AppColors.surface, this.margin = const EdgeInsets.only(bottom: Space.itemGap), this.revealIndex});
  final int? revealIndex;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsets margin;

  /// Sistem kartu tunggal: radius 20, border 1 px merek 12%, bayangan lembut web (.card).
  static BoxDecoration decorationFor(Color color) => BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.border), boxShadow: AppShadow.card);

  @override
  Widget build(BuildContext context) {
    final inner = Padding(padding: padding ?? EdgeInsets.all(Space.cardPadding(context)), child: child);
    final card = onTap == null
        ? DecoratedBox(decoration: decorationFor(color), child: inner)
        : Pressable(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.card), decoration: decorationFor(color), child: inner);
    return Padding(padding: margin, child: revealIndex == null ? card : Reveal(index: revealIndex!, child: card));
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 14});
  final double rating;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Penilaian $rating dari 5',
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++)
          Icon(rating >= i ? Icons.star : (rating >= i - 0.5 ? Icons.star_half : Icons.star_border), size: size, color: AppColors.star),
      ]),
    );
  }
}

/// Gambar produk: URL (Supabase Storage) atau aset bawaan (mode mock).
Widget productPicture(String src, {double? width, double? height, int? cacheWidth, BoxFit fit = BoxFit.cover}) {
  Widget fallback(BuildContext c, Object e, StackTrace? st) => Container(width: width, height: height, color: AppColors.field, child: const Icon(Icons.image_not_supported, color: AppColors.grey));
  Widget placeholder(BuildContext c, Widget child, int? frame, bool sync) => sync || frame != null ? child : Container(width: width, height: height, color: AppColors.field);
  if (src.startsWith('http')) {
    return Image.network(src, width: width, height: height, fit: fit, cacheWidth: cacheWidth, errorBuilder: fallback, frameBuilder: placeholder);
  }
  return Image.asset(src, width: width, height: height, fit: fit, cacheWidth: cacheWidth, errorBuilder: fallback);
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.asset, this.size = 60, this.radius});
  final String asset;
  final double size;
  final double? radius;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size / 2),
      child: productPicture(asset, width: size, height: size, cacheWidth: (size * 3).round()),
    );
  }
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.onChanged, this.min = 1});
  final int value;
  final int min;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(tooltip: 'Kurangi', icon: const Icon(Icons.remove_circle_outline), onPressed: value > min ? () => onChanged(value - 1) : null),
      Text('$value', style: AppText.semi),
      IconButton(tooltip: 'Tambah', icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(value + 1)),
    ]);
  }
}

/// Tab teks horizontal (Pesanan | Dikemas | ...), garis bawah aktif.
class TextTabs extends StatelessWidget {
  const TextTabs({super.key, required this.labels, required this.index, required this.onChanged, this.onDark = false});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final bool onDark;
  @override
  Widget build(BuildContext context) {
    final base = onDark ? Colors.white : Colors.black;
    final active = onDark ? Colors.white : AppColors.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Row(children: [
        for (final (i, l) in labels.indexed)
          Padding(
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : Gap.lg),
            child: InkWell(
              onTap: () => onChanged(i),
              child: Container(
                constraints: const BoxConstraints(minHeight: AppSize.buttonSmall, minWidth: 48),
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: i == index ? active : Colors.transparent, width: 3))),
                child: Text(l, style: AppText.body.copyWith(fontWeight: i == index ? FontWeight.w600 : FontWeight.w400, color: i == index ? active : base)),
              ),
            ),
          ),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key, this.icon = Icons.inbox_outlined, this.actionLabel, this.onAction});
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: Space.pad(context),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: AppColors.greyLight),
            const SizedBox(height: Gap.sm),
            Text(message, style: AppText.body.copyWith(color: AppColors.grey), textAlign: TextAlign.center),
            if (actionLabel != null) ...[const SizedBox(height: Gap.lg), PillButton(label: actionLabel!, expanded: false, onPressed: onAction)],
          ]),
        ),
      );
}

/// Galat dengan tombol "Coba lagi".
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.message = 'Terjadi kesalahan. Silakan coba lagi.', required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => EmptyState(message, icon: Icons.error_outline, actionLabel: 'Coba lagi', onAction: onRetry);
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonList();
}

/// Daftar yang bisa ditarik untuk memuat ulang; selalu dapat di-scroll agar gesture tarik berfungsi, juga saat kosong.
class RefreshableList extends StatelessWidget {
  const RefreshableList({super.key, required this.onRefresh, required this.children, this.padding});
  final Future<void> Function() onRefresh;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) => RefreshIndicator(onRefresh: onRefresh, child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: padding, children: children));
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.color = AppColors.primary});
  final String label;
  final Color color;

  /// Warna teks turunan token: diperdalam 25% agar kontras >= 4.5:1 di atas tint 12%.
  static Color textColor(Color c) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness * 0.75).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.xs),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: color)),
        child: Text(label, style: AppText.small.copyWith(color: textColor(color), fontWeight: FontWeight.w500)),
      );
}

/// Header bagian: judul (membungkus, tidak overflow) dan aksi opsional (target sentuh 48 dp), sejajar garis dasar.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: SectionTitle(title)),
          if (action != null)
            InkWell(
              onTap: onAction,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSize.buttonSmall, minWidth: AppSize.buttonSmall),
                child: Align(alignment: Alignment.centerRight, widthFactor: 1, child: Padding(padding: const EdgeInsets.only(left: Gap.md), child: Text(action!, style: AppText.body.copyWith(color: AppColors.primary)))),
              ),
            ),
        ],
      );
}



class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.k, this.v, {super.key, this.bold = false});
  final String k;
  final String v;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.xs),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: bold ? AppText.semi : AppText.body),
          const SizedBox(width: Gap.md),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: bold ? AppText.semi : AppText.body)),
        ]),
      );
}

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

Future<bool> confirmDialog(BuildContext context, String title, String message, {String yes = 'Ya', String no = 'Batal'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title, style: AppText.semi),
      content: Text(message, style: AppText.body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(no)),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(yes)),
      ],
    ),
  );
  return r ?? false;
}
