import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
export 'package:ikanku/core/widgets/remake_widgets.dart';

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
    this.maxWidth = kContentMaxWidth,
  });


  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final bool showBack;
  final Widget? bottom;
  final Widget? bottomNavigationBar;
  final List<Widget> actions;
  final Widget? headerExtra;
  final double maxWidth;

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
          Expanded(child: ContentFrame(maxWidth: maxWidth, padded: false, safe: true, child: bottom == null && bottomNavigationBar == null ? SafeArea(top: false, child: body) : body)),
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
      // Tombol tidak melebar penuh (alignment membuat Container mengisi lebar) kecuali expanded.
      child: Center(
        heightFactor: 1,
        widthFactor: expanded ? null : 1,
        child: Stack(alignment: Alignment.center, children: [
          Opacity(opacity: busy ? 0 : 1, child: text),
          if (busy) SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg)),
        ]),
      ),
    );
    final button = Pressable(onTap: enabled ? onPressed : null, borderRadius: radius, decoration: decoration, minSize: h, child: child);
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Field abu-abu radius 10 (Figma Login). Validasi baru tampil setelah field pertama kali kehilangan fokus
/// atau saat formulir dikirim (lihat [validateAndFocus]); bukan saat mengetik karakter pertama.
class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.obscure = false,
    this.keyboard,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.label,
    this.fieldKey,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.helper,
  });
  final TextEditingController controller;
  final String hint;
  final String? label;
  final String? helper;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType? keyboard;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final Key? fieldKey;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  /// true hanya selama [validateAndFocus] berjalan: galat pertama memindahkan fokus ke field itu.
  static bool _focusFirstInvalid = false;
  static bool _focusTaken = false;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  FocusNode? _own;
  FocusNode get _node => widget.focusNode ?? (_own ??= FocusNode());
  bool _touched = false;
  bool _hidden = true;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocus);
  }

  void _onFocus() {
    if (!_node.hasFocus && !_touched && mounted) setState(() => _touched = true);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocus);
    _own?.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final e = widget.validator?.call(v);
    if (e != null && AppField._focusFirstInvalid && !AppField._focusTaken) {
      AppField._focusTaken = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _node.requestFocus();
      });
    }
    return e;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final toggle = w.obscure
        ? IconButton(
            tooltip: _hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
            icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _hidden = !_hidden),
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.itemGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (w.label != null) Padding(padding: const EdgeInsets.only(bottom: Gap.sm), child: Text(w.label!, style: AppText.label)),
          TextFormField(
            key: w.fieldKey,
            controller: w.controller,
            focusNode: _node,
            validator: w.validator == null ? null : _validate,
            autovalidateMode: _touched ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            obscureText: w.obscure && _hidden,
            keyboardType: w.keyboard,
            textInputAction: w.textInputAction,
            autofillHints: w.autofillHints,
            inputFormatters: w.inputFormatters,
            maxLength: w.maxLength,
            onChanged: w.onChanged,
            onFieldSubmitted: w.onSubmitted,
            maxLines: w.obscure ? 1 : w.maxLines,
            readOnly: w.readOnly,
            onTap: w.onTap,
            style: AppText.input,
            scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            decoration: InputDecoration(
              hintText: w.hint,
              hintStyle: AppText.hint,
              helperText: w.helper,
              suffixIcon: w.suffix ?? toggle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Validasi formulir; galat pertama (urutan tampilan) menerima fokus. Pakai ini sebagai pengganti `validate()` saat kirim.
bool validateAndFocus(GlobalKey<FormState> key) {
  AppField._focusFirstInvalid = true;
  AppField._focusTaken = false;
  try {
    return key.currentState?.validate() ?? false;
  } finally {
    AppField._focusFirstInvalid = false;
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
      borderRadius: BorderRadius.circular(radius ?? AppRadius.thumb),
      child: productPicture(asset, width: size, height: size, cacheWidth: (size * 3).round()),
    );
  }
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.max});
  final int value;
  final int min;

  /// Batas atas (stok); null = tanpa batas.
  final int? max;
  final ValueChanged<int> onChanged;

  void _set(int v) {
    HapticFeedback.selectionClick();
    onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(tooltip: 'Kurangi', icon: const Icon(Icons.remove_circle_outline), onPressed: value > min ? () => _set(value - 1) : null),
      Semantics(label: 'Jumlah $value', excludeSemantics: true, child: SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.center, style: AppText.semi))),
      IconButton(tooltip: 'Tambah', icon: const Icon(Icons.add_circle_outline), onPressed: max == null || value < max! ? () => _set(value + 1) : null),
    ]);
  }
}

/// Tab teks horizontal (Pesanan | Dikemas | ...), garis bawah aktif.
class TextTabs extends StatelessWidget {
  const TextTabs({super.key, required this.labels, required this.index, required this.onChanged, this.onDark = false, this.counts});
  final List<String> labels;
  final List<int>? counts;
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
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(l, style: AppText.body.copyWith(fontWeight: i == index ? FontWeight.w600 : FontWeight.w400, color: i == index ? active : base)),
                  if (counts != null && counts![i] > 0) ...[
                    const SizedBox(width: Gap.xs),
                    Container(
                      key: Key('tab-count-$i'),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: onDark ? Colors.white : AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.chip)),
                      child: Text('${counts![i]}', style: AppText.caption.copyWith(color: onDark ? AppColors.primary : Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key, this.icon = Icons.inbox_outlined, this.hint, this.actionLabel, this.onAction});
  final String message;
  final String? hint;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: Space.pad(context),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Ilustrasi dari bentuk dan ikon: lingkaran besar lembut, lingkaran kecil, ikon di tengah.
            ExcludeSemantics(
              child: SizedBox(
                width: 112,
                height: 96,
                child: Stack(alignment: Alignment.center, children: [
                  Container(width: 88, height: 88, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceTint)),
                  Positioned(right: 10, top: 6, child: Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.16)))),
                  Positioned(left: 6, bottom: 8, child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.28)))),
                  Icon(icon, size: 44, color: AppColors.primary),
                ]),
              ),
            ),
            const SizedBox(height: Gap.md),
            Text(message, style: AppText.semi.copyWith(color: AppColors.textStrong), textAlign: TextAlign.center),
            if (hint != null) ...[const SizedBox(height: Gap.xs), Text(hint!, style: AppText.small.copyWith(color: AppColors.grey), textAlign: TextAlign.center)],
            if (actionLabel != null) ...[const SizedBox(height: Gap.lg), PillButton(label: actionLabel!, expanded: false, onPressed: onAction)],
          ]),
        ),
      );
}

/// Galat dengan tombol "Coba lagi".
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.message = 'Belum bisa dimuat. Periksa koneksi internet Anda, lalu coba lagi.', required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => EmptyState(message, icon: Icons.cloud_off_outlined, actionLabel: 'Coba lagi', onAction: onRetry);
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
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.eyebrow});
  final String title;
  final String? eyebrow;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: SectionTitle(title, eyebrow: eyebrow)),
          if (action != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.42),
              child: InkWell(
              onTap: onAction,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSize.buttonSmall, minWidth: AppSize.buttonSmall),
                child: Align(alignment: Alignment.centerRight, widthFactor: 1, child: Padding(padding: const EdgeInsets.only(left: Gap.md), child: Text(action!, textAlign: TextAlign.end, maxLines: 2, style: AppText.body.copyWith(color: AppColors.primary)))),
              ),
            )),
        ],
      );
}



/// Bilah aksi lengket di bawah layar formulir. Dipasang lewat `AppScaffold.bottom`, sehingga tingginya
/// otomatis mengurangi area scroll dan isi tidak pernah tertutup.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppShadow.card),
        child: SafeArea(
          top: false,
          child: Padding(padding: EdgeInsets.fromLTRB(Space.screenGutter(context), Space.itemGap, Space.screenGutter(context), Space.itemGap), child: child),
        ),
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

/// Snackbar dengan aksi (mis. Urungkan, Lihat keranjang).
void showActionMsg(BuildContext context, String msg, {required String actionLabel, required VoidCallback onAction}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), action: SnackBarAction(label: actionLabel, onPressed: onAction)));
}

/// Indikator langkah: lingkaran bernomor dengan garis penghubung; langkah selesai berisi centang.
/// Tiap langkah mendapat lebar sama dan labelnya membungkus, sehingga aman pada teks besar.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.labels, required this.current});
  final List<String> labels;
  final int current;
  @override
  Widget build(BuildContext context) {
    Widget line(bool on, bool visible) => Expanded(child: Container(height: 2, color: !visible ? Colors.transparent : (on ? AppColors.primary : AppColors.greyLight)));
    return Semantics(
      label: 'Langkah ${current + 1} dari ${labels.length}: ${labels[current]}',
      excludeSemantics: true,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final (i, l) in labels.indexed)
          Expanded(
            child: Column(children: [
              Row(children: [
                line(i <= current, i > 0),
                AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.base),
                  curve: AppMotion.curve,
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: i <= current ? AppColors.primary : AppColors.surface, border: Border.all(color: i <= current ? AppColors.primary : AppColors.greyLight, width: 2)),
                  child: i < current ? const Icon(Icons.check, size: 16, color: Colors.white) : Text('${i + 1}', style: AppText.caption.copyWith(color: i == current ? Colors.white : AppColors.grey, fontWeight: FontWeight.w600)),
                ),
                line(i < current, i < labels.length - 1),
              ]),
              const SizedBox(height: Gap.xs),
              Text(l, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.caption.copyWith(fontWeight: i == current ? FontWeight.w600 : FontWeight.w400)),
            ]),
          ),
      ]),
    );
  }
}

/// Centang sukses: muncul dengan skala 0.7 -> 1 dan opacity (transform + opacity saja); statis bila animasi dimatikan.
class AnimatedCheck extends StatelessWidget {
  const AnimatedCheck({super.key, this.size = 96});
  final double size;
  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.check_circle, size: size, color: AppColors.success);
    if (AppMotion.reduced(context)) return icon;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
      curve: AppMotion.curve,
      child: icon,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.scale(scale: 0.7 + 0.3 * t, child: child)),
    );
  }
}

/// Badge hitungan di kanan atas ikon, di LUAR kotak ikon (tidak pernah menimpa glyph): isi 18 dp, cincin putih 2 dp.
class NavBadge extends StatelessWidget {
  const NavBadge({super.key, required this.count, required this.child, this.label, this.badgeKey});
  final int count;
  final Widget child;
  final String? label;
  final Key? badgeKey;
  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    final text = count > 99 ? '99+' : '$count';
    return Stack(clipBehavior: Clip.none, children: [
      child,
      Positioned.fill(
        child: Align(
          alignment: Alignment.topRight,
          child: FractionalTranslation(
            translation: const Offset(1, -0.5),
            child: Semantics(
              label: label == null ? text : '$count $label',
              excludeSemantics: true,
              child: Container(
                key: badgeKey,
                constraints: const BoxConstraints(minWidth: AppSize.badge + 4, minHeight: AppSize.badge + 4),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.danger, shape: text.length > 1 ? BoxShape.rectangle : BoxShape.circle, borderRadius: text.length > 1 ? BorderRadius.circular(AppSize.badge) : null, border: Border.all(color: Colors.white, width: 2)),
                child: Text(text, style: AppText.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, height: 1.1)),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
