import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/router/tab_reselect.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_screens.dart';
import 'package:ikanku/features/catalog/presentation/catalog_strings.dart';
import 'package:ikanku/features/catalog/presentation/search_filter.dart';

/// Telusuri + hasil pencarian (Figma "Contoh Pencarian" dan "Contoh Hasil Pencarian").
/// Input di-debounce 300 ms; filter dan urutan lewat sheet; jumlah hasil selalu tampil.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const debounce = Duration(milliseconds: 300);
  final _c = TextEditingController();
  final _scroll = ScrollController();
  Timer? _timer;
  String _q = '';
  SearchFilter _filter = const SearchFilter();

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() {}); // tombol hapus langsung tampil; hasil menunggu debounce
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
    final f = await showFilterSheet(context, current: _filter, products: cat.products, categories: cat.categories);
    if (f != null && mounted) setState(() => _filter = f);
  }

  @override
  Widget build(BuildContext context) {
    listenTabReselect(ref, context, 1, _scroll);
    final cat = ref.watch(catalogProvider);
    final searching = _q.trim().isNotEmpty;
    final browsing = searching || !_filter.isDefault;
    final results = _filter.apply(cat.search(_q));
    return AppScaffold(
      title: 'Telusuri',
      showBack: false,
      headerExtra: Padding(
        padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, 0),
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
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _c.text.isEmpty ? null : IconButton(tooltip: CatalogStrings.clear, icon: const Icon(Icons.close), onPressed: _clear),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: Gap.sm),
          IconButton(
            key: const Key('search-filter'),
            tooltip: CatalogStrings.filter,
            onPressed: () => _openFilter(cat),
            icon: NavBadge(count: _filter.activeCount, label: 'filter aktif', child: const Icon(Icons.tune, color: Colors.white)),
          ),
        ]),
      ),
      body: !browsing
          ? ListView(controller: _scroll, padding: Space.padTab(context), children: [
              SectionHeader(CatalogStrings.recommendations),
              for (final (i, p) in cat.products.take(5).indexed) ProductRow(product: p, index: i, heroScope: 'search'),
            ])
          : results.isEmpty
              ? EmptyState(
                  searching ? CatalogStrings.noResults(_q) : CatalogStrings.noResultsFiltered,
                  icon: Icons.search_off,
                  hint: CatalogStrings.noResultsHint,
                  actionLabel: _filter.isDefault ? CatalogStrings.clear : CatalogStrings.resetFilters,
                  onAction: () => _filter.isDefault ? _clear() : setState(() => _filter = const SearchFilter()),
                )
              : ListView(controller: _scroll, padding: Space.padTab(context), children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.sm),
                    child: Text(searching ? CatalogStrings.resultsFor(results.length, _q.trim()) : CatalogStrings.results(results.length), key: const Key('search-count'), style: AppText.small),
                  ),
                  for (final (i, p) in results.indexed) ProductRow(product: p, index: i, heroScope: 'search'),
                ]),
    );
  }
}
