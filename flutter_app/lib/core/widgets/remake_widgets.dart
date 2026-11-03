import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';

/// Hero gradien (web .band-blue + .curve-b): dasar melengkung, gelembung dekoratif, dan
/// kolom [floating] opsional yang menimpa lengkungan (setengah di dalam, setengah di luar).
class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key, required this.child, this.floating, this.floatingHeight = AppSize.searchBar, this.bottomPadding = Gap.xl, this.topPadding = Gap.md});
  final Widget child;
  final Widget? floating;
  final double floatingHeight;
  final double bottomPadding;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final half = floating == null ? 0.0 : floatingHeight / 2;
    final top = MediaQuery.paddingOf(context).top + topPadding;
    return Stack(children: [
      Padding(
        padding: EdgeInsets.only(bottom: half),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(gradient: AppGradients.surface, borderRadius: const BorderRadius.vertical(bottom: Radius.elliptical(400, AppRadius.headerCurve))),
          child: Stack(children: [
            const HeaderDecor(),
            Padding(padding: EdgeInsets.only(top: top, bottom: bottomPadding + half), child: ContentFrame(safe: true, child: SizedBox(width: double.infinity, child: child))),
          ]),
        ),
      ),
      if (floating != null) Positioned(left: 0, right: 0, bottom: 0, child: ContentFrame(safe: true, child: SizedBox(height: floatingHeight, child: floating))),
    ]);
  }
}

/// Kolom cari mengambang: bidang putih membulat dengan bayangan lembut, seluruhnya dapat ditekan.
class FloatingSearchField extends StatelessWidget {
  const FloatingSearchField({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Pressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.border), boxShadow: AppShadow.card),
          minSize: AppSize.searchBar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
            child: Row(children: [const Icon(Icons.search, size: 20, color: AppColors.primary), const SizedBox(width: Gap.sm), Expanded(child: Text(label, style: AppText.searchHint, maxLines: 1, overflow: TextOverflow.ellipsis))]),
          ),
        ),
      );
}

/// Kartu nilai jual (web "Keunggulan Produk"): icon chip + judul; deskripsi opsional.
class ValuePropCard extends StatelessWidget {
  const ValuePropCard({super.key, required this.icon, required this.title, this.body});
  final IconData icon;
  final String title;
  final String? body;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: AppCard.decorationFor(AppColors.surface),
        child: Padding(
          padding: EdgeInsets.all(Space.cardPadding(context)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconChip(icon: icon),
            const SizedBox(height: Gap.md),
            Text(title, style: AppText.label, maxLines: 4, overflow: TextOverflow.ellipsis),
            if (body != null) ...[const SizedBox(height: Gap.xs), Text(body!, style: AppText.small.copyWith(color: AppColors.grey))],
          ]),
        ),
      );
}

/// Kartu angka ringkas: nilai besar + label (membungkus), opsional dapat ditekan.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label, this.icon, this.onTap});
  final String value;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: EdgeInsets.all(Space.cardPadding(context)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) ...[IconChip(icon: icon!, size: 36), const SizedBox(height: Gap.sm)],
        Text(value, style: AppText.price.copyWith(color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: AppText.small.copyWith(color: AppColors.grey), maxLines: 3, overflow: TextOverflow.ellipsis),
      ]),
    );
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      button: onTap != null,
      child: onTap == null
          ? DecoratedBox(decoration: AppCard.decorationFor(AppColors.surface), child: SizedBox(width: double.infinity, child: body))
          : Pressable(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.card), decoration: AppCard.decorationFor(AppColors.surface), minSize: 0, child: SizedBox(width: double.infinity, child: body)),
    );
  }
}

/// Baris statistik: sel sama lebar, tinggi sama (IntrinsicHeight), label membungkus.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.cards});
  final List<StatCard> cards;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (i, c) in cards.indexed) ...[if (i > 0) const SizedBox(width: Space.itemGap), Expanded(child: c)],
        ]),
      );
}

/// Filter aktif yang dapat dihapus satu per satu; baris menggulir mendatar.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({super.key, required this.labels, required this.onRemove, this.onClearAll});
  final List<String> labels;
  final void Function(int index) onRemove;
  final VoidCallback? onClearAll;
  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: AppSize.chipHeight + Gap.sm,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Space.screenGutter(context)),
        children: [
          for (final (i, l) in labels.indexed)
            Padding(
              padding: const EdgeInsets.only(right: Gap.sm),
              child: Semantics(
                button: true,
                label: 'Hapus filter $l',
                excludeSemantics: true,
                child: Pressable(
                  onTap: () => onRemove(i),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: AppColors.border)),
                  minSize: AppSize.chipHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Gap.md, right: Gap.sm),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(l, style: AppText.small.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                      const SizedBox(width: Gap.xs),
                      Icon(Icons.close, size: 16, color: AppColors.primaryDark),
                    ]),
                  ),
                ),
              ),
            ),
          if (onClearAll != null && labels.length > 1) TextButton(onPressed: onClearAll, child: const Text('Hapus semua')),
        ],
      ),
    );
  }
}

/// Tab berbentuk pil yang menggulir, dengan hitungan opsional. Tinggi sama untuk semua pil.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.labels, required this.index, required this.onChanged, this.counts});
  final List<String> labels;
  final List<int>? counts;
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: AppSize.buttonSmall,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Space.screenGutter(context)),
          children: [
            for (final (i, l) in labels.indexed)
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: Semantics(
                  button: true,
                  selected: i == index,
                  excludeSemantics: true,
                  label: counts != null && counts![i] > 0 ? '$l, ${counts![i]}' : l,
                  child: Pressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChanged(i);
                    },
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    decoration: BoxDecoration(
                      gradient: i == index ? AppGradients.primary : null,
                      color: i == index ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: i == index ? Colors.transparent : AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(l, style: AppText.label.copyWith(color: i == index ? Colors.white : AppColors.text)),
                        if (counts != null && counts![i] > 0) ...[
                          const SizedBox(width: Gap.sm),
                          Container(
                            key: Key('tab-count-$i'),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                            decoration: BoxDecoration(color: i == index ? Colors.white : AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.pill)),
                            child: Text('${counts![i]}', style: AppText.caption.copyWith(color: i == index ? AppColors.primary : Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Linimasa status pesanan: titik + garis vertikal; langkah selesai terisi, langkah sekarang diberi cincin.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.steps, required this.current, this.failed = false});
  final List<String> steps;

  /// Indeks langkah yang sedang berlangsung (langkah sebelumnya selesai).
  final int current;

  /// true: langkah sekarang memakai warna bahaya (mis. ditolak).
  final bool failed;
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Status pesanan: ${steps[current.clamp(0, steps.length - 1)]}',
        container: true,
        excludeSemantics: true,
        child: Column(children: [
          for (final (i, s) in steps.indexed)
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(
                  width: 28,
                  child: Column(children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= current ? (failed && i == current ? AppColors.danger : AppColors.primary) : AppColors.surface,
                        border: Border.all(color: i <= current ? (failed && i == current ? AppColors.danger : AppColors.primary) : AppColors.greyLight, width: 2),
                      ),
                      child: i < current ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                    ),
                    if (i < steps.length - 1) Expanded(child: Container(width: 2, color: i < current ? AppColors.primary : AppColors.greyLight)),
                  ]),
                ),
                const SizedBox(width: Gap.md),
                Expanded(child: Padding(padding: const EdgeInsets.only(bottom: Gap.lg), child: Text(s, style: AppText.body.copyWith(fontWeight: i == current ? FontWeight.w600 : FontWeight.w400, color: i <= current ? AppColors.textStrong : AppColors.grey)))),
              ]),
            ),
        ]),
      );
}

/// Momen sukses: centang beranimasi dalam lingkaran gradien, judul, dan keterangan.
class SuccessMoment extends StatelessWidget {
  const SuccessMoment({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        const AnimatedCheck(size: 96),
        const SizedBox(height: Gap.lg),
        Text(title, style: AppText.heading, textAlign: TextAlign.center),
        if (subtitle != null) ...[const SizedBox(height: Gap.xs), Text(subtitle!, style: AppText.small.copyWith(color: AppColors.grey), textAlign: TextAlign.center)],
      ]);
}

/// Satu baris menu dengan icon chip, judul, keterangan opsional, dan chevron.
class MenuItem {
  const MenuItem({required this.icon, required this.label, required this.onTap, this.hint, this.destructive = false});
  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback onTap;
  final bool destructive;
}

/// Kelompok menu: kartu dengan baris icon chip dan pemisah tipis.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.title, required this.items});
  final String title;
  final List<MenuItem> items;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(bottom: Gap.sm), child: Text(title, style: AppText.label.copyWith(color: AppColors.grey))),
        DecoratedBox(
          decoration: AppCard.decorationFor(AppColors.surface),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Column(children: [
              for (final (i, it) in items.indexed) ...[
                if (i > 0) const Divider(height: 1, indent: 72, color: AppColors.border),
                Semantics(
                  button: true,
                  label: it.label,
                  excludeSemantics: true,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: it.onTap,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 60),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
                          child: Row(children: [
                            IconChip(icon: it.icon, size: 40, color: it.destructive ? AppColors.danger : null),
                            const SizedBox(width: Gap.md),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(it.label, style: AppText.body.copyWith(color: it.destructive ? AppColors.danger : AppColors.textStrong)),
                                if (it.hint != null) Text(it.hint!, style: AppText.small.copyWith(color: AppColors.grey)),
                              ]),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.grey),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ]);
}

/// Sheet bawah: handle, header lengket, badan menggulir, footer lengket. Selalu dibuka di root navigator.
class BottomSheetScaffold extends StatelessWidget {
  const BottomSheetScaffold({super.key, required this.title, required this.body, this.footer, this.trailing});
  final String title;
  final Widget body;
  final Widget? footer;
  final Widget? trailing;

  /// Menampilkan sheet pada root navigator sehingga scrim menutupi bottom bar.
  static Future<T?> show<T>(BuildContext context, {required WidgetBuilder builder}) => showModalBottomSheet<T>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: builder,
      );

  @override
  Widget build(BuildContext context) {
    final g = Space.screenGutter(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: Gap.sm),
      ExcludeSemantics(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(4)))),
      Padding(
        padding: EdgeInsets.fromLTRB(g, Gap.md, g - Gap.sm, Gap.xs),
        child: Row(children: [
          Expanded(child: Semantics(header: true, child: Text(title, style: AppText.heading))),
          ?trailing,
        ]),
      ),
      const Divider(height: 1),
      Flexible(child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(g, Gap.lg, g, Gap.lg), child: body)),
      if (footer != null)
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
          child: SafeArea(top: false, child: Padding(padding: EdgeInsets.fromLTRB(g, Gap.md, g, Gap.md), child: footer)),
        ),
    ]);
  }
}

/// Kerangka grid produk: ubin foto atas + dua baris teks.
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({super.key, this.count = 4});
  final int count;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(Space.screenGutter(context)),
        child: ResponsiveGrid(maxCrossAxisExtent: 200, children: [for (var i = 0; i < count; i++) const SkeletonCard()]),
      );
}

/// Chip bulat kecil berisi ikon + teks (rating, stok, diskon). [onPhoto] = latar gelap transparan agar terbaca di atas foto.
class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.label, this.icon, this.iconColor, this.onPhoto = false, this.tint, this.solid = false});
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool onPhoto;
  final Color? tint;

  /// true: latar [tint] penuh dengan teks putih (di atas foto).
  final bool solid;
  @override
  Widget build(BuildContext context) {
    final bg = onPhoto ? AppColors.buttonOnPhoto : (tint ?? AppColors.surfaceTint);
    final fg = onPhoto || solid ? Colors.white : (tint == null ? AppColors.textStrong : StatusChip.textColor(tint!));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 3),
      decoration: BoxDecoration(color: solid ? tint : (tint != null && !onPhoto ? tint!.withValues(alpha: 0.14) : bg), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: iconColor ?? fg), const SizedBox(width: 3)],
        Flexible(child: Text(label, style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

/// Chip pilihan seragam (tinggi tetap 40): terpilih = gradien merek + teks putih. Dipakai sheet filter dan variasi.
class SelectChip extends StatelessWidget {
  const SelectChip({super.key, required this.label, required this.selected, required this.onTap, this.keyId});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? keyId;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: Pressable(
          key: keyId == null ? null : Key(keyId!),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppRadius.pill),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.primary : null,
            color: selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: selected ? Colors.transparent : AppColors.border),
          ),
          minSize: AppSize.chipHeight,
          child: Container(
            height: AppSize.chipHeight,
            padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
            child: Center(widthFactor: 1, child: Text(label, style: AppText.small.copyWith(fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ),
        ),
      );
}


/// Satu tujuan bottom bar.
class BarItem {
  const BarItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom bar putih: pil terpilih bertint merek, badge di kanan atas ikon (di luar kotak ikon),
/// mengikuti safe area, label membungkus (tidak terpotong pada skala teks 2.0).
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key, required this.items, required this.index, required this.onTap, this.badgeIndex, this.badgeCount = 0, this.badgeLabel});
  final List<BarItem> items;
  final int index;
  final void Function(int i) onTap;
  final int? badgeIndex;
  final int badgeCount;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        key: const Key('app-bottom-bar'),
        decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border)), boxShadow: AppShadow.card),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.navBar),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (final (i, it) in items.indexed)
                  Expanded(
                    child: Semantics(
                      selected: i == index,
                      button: true,
                      label: it.label,
                      excludeSemantics: true,
                      child: InkWell(
                        onTap: () => onTap(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Gap.xs, vertical: Gap.sm),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            AnimatedContainer(
                              duration: AppMotion.of(context, AppMotion.fast),
                              curve: AppMotion.curve,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                              decoration: BoxDecoration(color: i == index ? AppColors.surfaceTint : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.pill)),
                              child: NavBadge(
                                count: i == badgeIndex ? badgeCount : 0,
                                label: badgeLabel,
                                badgeKey: Key('nav-badge-$i'),
                                child: Icon(i == index ? it.selectedIcon : it.icon, key: Key('nav-icon-$i'), size: 24, color: i == index ? AppColors.primaryDark : AppColors.grey),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(it.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.caption.copyWith(fontWeight: i == index ? FontWeight.w600 : FontWeight.w400, color: i == index ? AppColors.primaryDark : AppColors.grey)),
                          ]),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}

/// Grid sel sama tinggi (IntrinsicHeight per baris), [columns] kolom; sel kosong mengisi sisa baris.
class EqualGrid extends StatelessWidget {
  const EqualGrid({super.key, required this.columns, required this.children, this.spacing = Space.itemGap});
  final int columns;
  final List<Widget> children;
  final double spacing;
  @override
  Widget build(BuildContext context) {
    final rows = (children.length / columns).ceil();
    return Column(children: [
      for (var r = 0; r < rows; r++) ...[
        if (r > 0) SizedBox(height: spacing),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) SizedBox(width: spacing),
              Expanded(child: r * columns + c < children.length ? children[r * columns + c] : const SizedBox.shrink()),
            ],
          ]),
        ),
      ],
    ]);
  }
}
