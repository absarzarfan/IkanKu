import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/router/tab_reselect.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_strings.dart';
import 'package:ikanku/features/catalog/presentation/product_cards.dart';
import 'package:ikanku/features/catalog/presentation/search_filter.dart';

/// Jumlah kolom grid per kelas lebar: 2 compact, 3 medium, 4 expanded.
int gridColumnsFor(WidthClass w) => switch (w) { WidthClass.compact => 2, WidthClass.medium => 3, WidthClass.expanded => 4 };

/// Satu baris grid: sel sama tinggi (IntrinsicHeight), sel kosong mengisi sisa kolom.
Widget productGridRow(List<Product> products, int r, int cols, String? heroScope, {Key? firstKey}) => IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var c = 0; c < cols; c++) ...[
          if (c > 0) const SizedBox(width: Space.itemGap),
          Expanded(
            child: r * cols + c < products.length
                ? KeyedSubtree(key: r == 0 && c == 0 ? firstKey : null, child: ProductTile(product: products[r * cols + c], heroScope: heroScope))
                : const SizedBox.shrink(),
          ),
        ],
      ]),
    );

/// Grid sliver, dibangun malas per baris.
class ProductGridRows extends StatelessWidget {
  const ProductGridRows({super.key, required this.products, this.heroScope});
  final List<Product> products;
  final String? heroScope;
  @override
  Widget build(BuildContext context) {
    final cols = gridColumnsFor(context.widthClass);
    final rows = (products.length / cols).ceil();
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: Space.screenGutter(context)),
      sliver: SliverList.separated(
        itemCount: rows,
        separatorBuilder: (_, _) => const SizedBox(height: Space.itemGap),
        itemBuilder: (_, r) => Reveal(index: r, child: productGridRow(products, r, cols, heroScope)),
      ),
    );
  }
}

/// Grid non-sliver (untuk ListView, mis. Beranda).
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products, this.heroScope, this.firstKey});
  final List<Product> products;
  final String? heroScope;
  final Key? firstKey;
  @override
  Widget build(BuildContext context) {
    final cols = gridColumnsFor(context.widthClass);
    final rows = (products.length / cols).ceil();
    return Column(children: [
      for (var r = 0; r < rows; r++) ...[if (r > 0) const SizedBox(height: Space.itemGap), productGridRow(products, r, cols, heroScope, firstKey: firstKey)],
    ]);
  }
}

/// Komponen daftar bersama Telusuri dan layar "Lihat semua": pencarian tersemat, filter, urutan, grid/daftar.
/// [discovery] = tampilkan kategori + rekomendasi di atas grid saat belum mencari atau memfilter (tab Telusuri).
class ProductBrowser extends ConsumerStatefulWidget {
  const ProductBrowser({super.key, required this.title, this.showBack = false, this.initialFilter = const SearchFilter(), this.discovery = false, this.tabIndex, this.heroScope = 'search'});
  final String title;
  final bool showBack;
  final SearchFilter initialFilter;
  final bool discovery;
  final int? tabIndex;
  final String heroScope;

  @override
  ConsumerState<ProductBrowser> createState() => _ProductBrowserState();
}

class _ProductBrowserState extends ConsumerState<ProductBrowser> {
  static const debounce = Duration(milliseconds: 300);
  final _c = TextEditingController();
  final _scroll = ScrollController();
  Timer? _timer;
  String _q = '';
  late SearchFilter _filter = widget.initialFilter;
  bool _grid = true;

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() {});
    _timer?.cancel();
    if (v.trim().isEmpty) {
      setState(() => _q = '');
      return;
    }
    _timer = Timer(debounce, () {
      if (mounted) setState(() => _q = v);
    });
  }

  void _clear() {
    _timer?.cancel();
    _c.clear();
    setState(() => _q = '');
  }

  Future<void> _openFilter(CatalogState cat) async {
    final f = await showFilterSheet(context, current: _filter, products: cat.products, categories: cat.categories, items: cat.search(_q));
    if (f != null && mounted) setState(() => _filter = f);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabIndex != null) listenTabReselect(ref, context, widget.tabIndex!, _scroll);
    final cat = ref.watch(catalogProvider);
    final searching = _q.trim().isNotEmpty;
    final browsing = searching || !_filter.isDefault;
    final results = _filter.apply(cat.search(_q));
    final showDiscovery = widget.discovery && !browsing;
    final g = Space.screenGutter(context);
    final wide = context.widthClass == WidthClass.expanded && _grid;
    return AppScaffold(
      title: widget.title,
      showBack: widget.showBack,
      maxWidth: wide ? 960 : kContentMaxWidth,
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      headerExtra: Padding(
        padding: EdgeInsets.fromLTRB(g, Gap.sm, g, 0),
        child: Row(children: [
          Expanded(
            child: TextField(
              key: const Key('search-field'),
              controller: _c,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _timer?.cancel();
                setState(() => _q = v);
              },
              decoration: InputDecoration(
                hintText: CatalogStrings.searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _c.text.isEmpty ? null : IconButton(tooltip: CatalogStrings.clear, icon: const Icon(Icons.close), onPressed: _clear),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: Gap.xs),
          IconButton(
            key: const Key('search-filter'),
            tooltip: CatalogStrings.filter,
            onPressed: () => _openFilter(cat),
            icon: NavBadge(count: _filter.activeCount, label: 'filter aktif', child: const Icon(Icons.tune, color: Colors.white)),
          ),
        ]),
      ),
      body: CustomScrollView(controller: _scroll, slivers: [
        if (showDiscovery) ...[
          SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(g, Gap.lg, g, Gap.md), child: const SectionHeader(CatalogStrings.categories, eyebrow: CatalogStrings.categoriesEyebrow))),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSize.chipHeight + Gap.sm,
              child: ListView(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: g), children: [
                for (final n in cat.categories)
                  Padding(
                    padding: const EdgeInsets.only(right: Gap.sm),
                    child: Pressable(
                      onTap: () => setState(() => _filter = SearchFilter(category: n)),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: AppColors.border)),
                      minSize: AppSize.chipHeight,
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: Gap.lg), child: Center(child: Text(n, style: AppText.label))),
                    ),
                  ),
              ]),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(g, Gap.xl, g, Gap.md), child: const SectionHeader(CatalogStrings.recommendations, eyebrow: CatalogStrings.recoEyebrow))),
          SliverToBoxAdapter(
            child: HorizontalCardList(
              preferred: 170,
              min: 150,
              max: 220,
              children: [for (final p in cat.products.take(6)) ProductFeaturedCard(product: p, heroScope: '${widget.heroScope}-rail')],
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(g, Gap.xl, g, 0), child: const SectionHeader(CatalogStrings.allFish))),
        ],
        if (!showDiscovery) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: Gap.md), child: FilterChipBar(labels: [for (final c in _filter.chips) c.$1], onRemove: (i) => setState(() => _filter = _filter.chips[i].$2(_filter)), onClearAll: () => setState(() => _filter = const SearchFilter())))),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(g, Gap.md, g - Gap.sm, Gap.sm),
            child: Row(children: [
              Expanded(child: Text(searching ? CatalogStrings.resultsFor(results.length, _q.trim()) : CatalogStrings.results(results.length), key: const Key('search-count'), style: AppText.small.copyWith(color: AppColors.grey))),
              PopupMenuButton<SearchSort>(
                tooltip: CatalogStrings.sortTooltip,
                initialValue: _filter.sort,
                onSelected: (s) => setState(() => _filter = _filter.copyWith(sort: s)),
                itemBuilder: (_) => [for (final s in SearchSort.values) PopupMenuItem(value: s, child: Text(s.label))],
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSize.buttonSmall),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.swap_vert, size: 18, color: AppColors.primary), const SizedBox(width: Gap.xs), Text(_filter.sort.label, style: AppText.small.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600))]),
                ),
              ),
              IconButton(
                tooltip: _grid ? CatalogStrings.listView : CatalogStrings.gridView,
                onPressed: () => setState(() => _grid = !_grid),
                icon: Icon(_grid ? Icons.view_list_outlined : Icons.grid_view_outlined, color: AppColors.primary),
              ),
            ]),
          ),
        ),
        if (results.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              searching ? CatalogStrings.noResults(_q) : (_filter.isDefault ? CatalogStrings.noProducts : CatalogStrings.noResultsFiltered),
              icon: Icons.search_off,
              hint: CatalogStrings.noResultsHint,
              actionLabel: _filter.isDefault ? (searching ? CatalogStrings.clear : null) : CatalogStrings.resetFilters,
              onAction: () => _filter.isDefault ? _clear() : setState(() => _filter = const SearchFilter()),
            ),
          )
        else if (_grid)
          ProductGridRows(products: results, heroScope: widget.heroScope)
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: g),
            sliver: SliverList.builder(itemCount: results.length, itemBuilder: (_, i) => ProductRow(product: results[i], index: i, heroScope: widget.heroScope)),
          ),
        SliverToBoxAdapter(child: SizedBox(height: Space.minBottomClearance(context))),
      ]),
    );
  }
}
