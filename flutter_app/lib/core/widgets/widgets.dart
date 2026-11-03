import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';

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
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 14),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
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
          Expanded(child: bottom == null && bottomNavigationBar == null ? SafeArea(top: false, child: body) : body),
          ?bottom,
        ],
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({super.key, required this.label, required this.onPressed, this.color = AppColors.primary, this.outlined = false, this.height = 50, this.expanded = true});
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool outlined;
  final double height;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: outlined ? Colors.white : color,
        foregroundColor: outlined ? color : AppColors.onPrimarySoft,
        disabledBackgroundColor: AppColors.greyLight,
        elevation: 0,
        minimumSize: Size(expanded ? double.infinity : 0, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: outlined ? BorderSide(color: color) : BorderSide.none),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15, color: outlined ? color : AppColors.onPrimarySoft)),
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label!, style: AppText.semi.copyWith(fontSize: 14))),
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
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.hint,
              filled: true,
              fillColor: AppColors.field,
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.danger)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.onTap, this.color = Colors.white, this.margin = const EdgeInsets.only(bottom: 14)});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: color,
        elevation: 2,
        shadowColor: Colors.black45,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 14});
  final double rating;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 1; i <= 5; i++)
        Icon(rating >= i ? Icons.star : (rating >= i - 0.5 ? Icons.star_half : Icons.star_border), size: size, color: AppColors.star),
    ]);
  }
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
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover, cacheWidth: (size * 3).round(), errorBuilder: (_, _, _) => Container(width: size, height: size, color: AppColors.field, child: const Icon(Icons.image_not_supported, color: AppColors.grey))),
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
      IconButton(tooltip: 'Kurangi', visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove_circle_outline), onPressed: value > min ? () => onChanged(value - 1) : null),
      Text('$value', style: AppText.semi),
      IconButton(tooltip: 'Tambah', visualDensity: VisualDensity.compact, icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(value + 1)),
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
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (_, i) => InkWell(
          onTap: () => onChanged(i),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: i == index ? active : Colors.transparent, width: 3))),
            child: Text(labels[i], style: AppText.body.copyWith(fontWeight: i == index ? FontWeight.w600 : FontWeight.w400, color: i == index ? active : base)),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key, this.icon = Icons.inbox_outlined});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: AppColors.greyLight),
          const SizedBox(height: 8),
          Text(message, style: AppText.body.copyWith(color: AppColors.grey), textAlign: TextAlign.center),
        ]),
      );
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.color = AppColors.primary});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: color)),
        child: Text(label, style: AppText.small.copyWith(color: color, fontWeight: FontWeight.w500)),
      );
}

class SectionRow extends StatelessWidget {
  const SectionRow({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(title, style: AppText.body, overflow: TextOverflow.ellipsis)),
          if (action != null) InkWell(onTap: onAction, child: Text(action!, style: AppText.body.copyWith(color: AppColors.primary))),
        ]),
      );
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.k, this.v, {super.key, this.bold = false});
  final String k;
  final String v;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: bold ? AppText.semi : AppText.body),
          const SizedBox(width: 12),
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
