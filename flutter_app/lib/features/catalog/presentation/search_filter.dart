import 'package:flutter/material.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/catalog_strings.dart';

enum SearchSort {
  relevance('Paling sesuai'),
  priceAsc('Harga terendah'),
  priceDesc('Harga tertinggi'),
  rating('Rating tertinggi');

  const SearchSort(this.label);
  final String label;
}

/// Filter dan urutan pencarian. Hanya memakai data yang ada di produk: kategori, harga mulai dari, rating.
class SearchFilter {
  const SearchFilter({this.category, this.minPrice, this.maxPrice, this.minRating = 0, this.sort = SearchSort.relevance});
  final String? category;
  final int? minPrice;
  final int? maxPrice;
  final double minRating;
  final SearchSort sort;

  bool get isDefault => category == null && minPrice == null && maxPrice == null && minRating == 0 && sort == SearchSort.relevance;

  /// Jumlah pengaturan yang aktif (untuk badge tombol filter).
  int get activeCount => (category != null ? 1 : 0) + (minPrice != null || maxPrice != null ? 1 : 0) + (minRating > 0 ? 1 : 0) + (sort != SearchSort.relevance ? 1 : 0);

  List<Product> apply(List<Product> items) {
    final out = items.where((p) {
      if (category != null && p.category != category) return false;
      if (minPrice != null && p.startingPrice < minPrice!) return false;
      if (maxPrice != null && p.startingPrice > maxPrice!) return false;
      return p.rating >= minRating;
    }).toList();
    switch (sort) {
      case SearchSort.relevance:
        break;
      case SearchSort.priceAsc:
        out.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
      case SearchSort.priceDesc:
        out.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
      case SearchSort.rating:
        out.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return out;
  }
}

/// Sheet filter dan urutan. Mengembalikan filter baru, atau null bila ditutup tanpa menerapkan.
Future<SearchFilter?> showFilterSheet(BuildContext context, {required SearchFilter current, required List<Product> products, required List<String> categories}) {
  return showModalBottomSheet<SearchFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FilterSheet(current: current, products: products, categories: categories),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.products, required this.categories});
  final SearchFilter current;
  final List<Product> products;
  final List<String> categories;
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _category = widget.current.category;
  late SearchSort _sort = widget.current.sort;
  late double _rating = widget.current.minRating;
  late RangeValues _range;
  late final double _lo;
  late final double _hi;

  @override
  void initState() {
    super.initState();
    final prices = widget.products.map((p) => p.startingPrice).toList()..sort();
    _lo = prices.isEmpty ? 0 : prices.first.toDouble();
    _hi = prices.isEmpty || prices.last == prices.first ? _lo + 1 : prices.last.toDouble();
    _range = RangeValues((widget.current.minPrice ?? _lo.round()).toDouble().clamp(_lo, _hi), (widget.current.maxPrice ?? _hi.round()).toDouble().clamp(_lo, _hi));
  }

  SearchFilter _build() => SearchFilter(
        category: _category,
        minPrice: _range.start <= _lo ? null : _range.start.round(),
        maxPrice: _range.end >= _hi ? null : _range.end.round(),
        minRating: _rating,
        sort: _sort,
      );

  @override
  Widget build(BuildContext context) {
    final g = Space.screenGutter(context);
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(g, 0, g, Gap.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(CatalogStrings.filterTitle, style: AppText.heading),
              const SizedBox(height: Gap.lg),
              Text(CatalogStrings.sortLabel, style: AppText.label),
              const SizedBox(height: Gap.sm),
              Wrap(spacing: Gap.sm, children: [
                for (final s in SearchSort.values) ChoiceChip(label: Text(s.label), selected: _sort == s, onSelected: (_) => setState(() => _sort = s)),
              ]),
              const SizedBox(height: Gap.lg),
              Text(CatalogStrings.categoryLabel, style: AppText.label),
              const SizedBox(height: Gap.sm),
              Wrap(spacing: Gap.sm, children: [
                ChoiceChip(label: const Text(CatalogStrings.allCategories), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
                for (final c in widget.categories) ChoiceChip(label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = c)),
              ]),
              const SizedBox(height: Gap.lg),
              Text(CatalogStrings.priceLabel, style: AppText.label),
              Text('${rupiah(_range.start.round())} - ${rupiah(_range.end.round())}', style: AppText.small),
              RangeSlider(values: _range, min: _lo, max: _hi, onChanged: (v) => setState(() => _range = v)),
              const SizedBox(height: Gap.sm),
              Text(CatalogStrings.ratingLabel, style: AppText.label),
              const SizedBox(height: Gap.sm),
              Wrap(spacing: Gap.sm, children: [
                for (final r in const [0.0, 3.0, 4.0, 4.5]) ChoiceChip(label: Text(r == 0 ? 'Semua' : '$r+'), selected: _rating == r, onSelected: (_) => setState(() => _rating = r)),
              ]),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(g, Gap.sm, g, Gap.md),
          child: Row(children: [
            Expanded(child: PillButton(label: CatalogStrings.reset, outlined: true, onPressed: () => Navigator.pop(context, const SearchFilter()))),
            const SizedBox(width: Gap.md),
            Expanded(child: PillButton(label: CatalogStrings.apply, onPressed: () => Navigator.pop(context, _build()))),
          ]),
        ),
      ]),
    );
  }
}
