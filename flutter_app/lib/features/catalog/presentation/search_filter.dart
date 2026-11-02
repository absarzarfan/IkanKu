import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Label filter aktif (urutan tetap: kategori, harga, rating, urutan) untuk FilterChipBar.
  List<(String, SearchFilter Function(SearchFilter))> get chips => [
        if (category != null) ('$category', (f) => f.copyWith(clearCategory: true)),
        if (minPrice != null || maxPrice != null) (priceLabel, (f) => f.copyWith(clearPrice: true)),
        if (minRating > 0) ('Rating $minRating+', (f) => f.copyWith(minRating: 0)),
        if (sort != SearchSort.relevance) (sort.label, (f) => f.copyWith(sort: SearchSort.relevance)),
      ];

  String get priceLabel => minPrice != null && maxPrice != null ? '${rupiah(minPrice!)} - ${rupiah(maxPrice!)}' : (minPrice != null ? 'Min ${rupiah(minPrice!)}' : 'Maks ${rupiah(maxPrice!)}');

  SearchFilter copyWith({bool clearCategory = false, bool clearPrice = false, double? minRating, SearchSort? sort}) => SearchFilter(
        category: clearCategory ? null : category,
        minPrice: clearPrice ? null : minPrice,
        maxPrice: clearPrice ? null : maxPrice,
        minRating: minRating ?? this.minRating,
        sort: sort ?? this.sort,
      );

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

/// Kuantil (0..1) dari daftar harga terurut, dibulatkan ke harga yang ada.
int priceQuantile(List<int> sorted, double q) => sorted.isEmpty ? 0 : sorted[((sorted.length - 1) * q).round()];

/// Sheet filter dan urutan pada root navigator (scrim menutupi bottom bar).
/// [items] = produk yang cocok dengan kata kunci; hitungan "Terapkan" dihitung langsung dari [SearchFilter.apply].
Future<SearchFilter?> showFilterSheet(BuildContext context, {required SearchFilter current, required List<Product> products, required List<String> categories, List<Product>? items}) {
  return BottomSheetScaffold.show<SearchFilter>(
    context,
    builder: (_) => FilterSheet(current: current, products: products, categories: categories, items: items ?? products),
  );
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Semantics(
        label: '$label $value',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
          decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(AppRadius.field)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppText.caption.copyWith(color: AppColors.grey)),
            Text(value, style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.current, required this.products, required this.categories, required this.items});
  final SearchFilter current;
  final List<Product> products;
  final List<String> categories;
  final List<Product> items;
  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _category = widget.current.category;
  late SearchSort _sort = widget.current.sort;
  late double _rating = widget.current.minRating;
  late RangeValues _range;
  late final double _lo;
  late final double _hi;
  late final List<int> _prices;

  @override
  void initState() {
    super.initState();
    _prices = widget.products.map((p) => p.startingPrice).toList()..sort();
    _lo = _prices.isEmpty ? 0 : _prices.first.toDouble();
    _hi = _prices.isEmpty || _prices.last == _prices.first ? _lo + 1 : _prices.last.toDouble();
    _range = RangeValues((widget.current.minPrice ?? _lo.round()).toDouble().clamp(_lo, _hi), (widget.current.maxPrice ?? _hi.round()).toDouble().clamp(_lo, _hi));
  }

  SearchFilter get _filter => SearchFilter(
        category: _category,
        minPrice: _range.start <= _lo ? null : _range.start.round(),
        maxPrice: _range.end >= _hi ? null : _range.end.round(),
        minRating: _rating,
        sort: _sort,
      );

  int get _count => _filter.apply(widget.items).length;

  void _reset() => setState(() {
        _category = null;
        _sort = SearchSort.relevance;
        _rating = 0;
        _range = RangeValues(_lo, _hi);
      });

  void _preset(int a, int b) => setState(() => _range = RangeValues(a.toDouble().clamp(_lo, _hi), b.toDouble().clamp(_lo, _hi)));

  Widget _section(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: Gap.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppText.label), const SizedBox(height: Gap.md), child]),
      );

  @override
  Widget build(BuildContext context) {
    final q25 = priceQuantile(_prices, 0.25), q75 = priceQuantile(_prices, 0.75);
    final presets = <(String, int, int)>[
      if (_prices.isNotEmpty) ('Hingga ${rupiah(q25)}', _lo.round(), q25),
      if (_prices.isNotEmpty && q75 > q25) ('${rupiah(q25)} - ${rupiah(q75)}', q25, q75),
      if (_prices.isNotEmpty) ('Mulai ${rupiah(q75)}', q75, _hi.round()),
    ];
    return BottomSheetScaffold(
      title: CatalogStrings.filterTitle,
      trailing: TextButton(onPressed: _reset, child: const Text(CatalogStrings.reset)),
      footer: PillButton(
        key: const Key('filter-apply'),
        label: CatalogStrings.applyCount(_count),
        onPressed: _count == 0 ? null : () {
          HapticFeedback.selectionClick();
          Navigator.of(context).pop(_filter);
        },
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section(
          CatalogStrings.sortLabel,
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - Gap.sm) / 2;
            return Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: [
              for (final s in SearchSort.values) SizedBox(width: w, child: SelectChip(label: s.label, selected: _sort == s, onTap: () => setState(() => _sort = s))),
            ]);
          }),
        ),
        _section(
          CatalogStrings.categoryLabel,
          Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: [
            SelectChip(label: CatalogStrings.allCategories, selected: _category == null, onTap: () => setState(() => _category = null)),
            for (final c in widget.categories) SelectChip(label: c, selected: _category == c, onTap: () => setState(() => _category = c)),
          ]),
        ),
        _section(
          CatalogStrings.priceLabel,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _ReadOnlyField(label: 'Min', value: rupiah(_range.start.round()))),
              const SizedBox(width: Gap.md),
              Expanded(child: _ReadOnlyField(label: 'Maks', value: rupiah(_range.end.round()))),
            ]),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceTint,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.splash,
                rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 11, elevation: 2),
              ),
              child: RangeSlider(
                key: const Key('filter-price'),
                values: _range,
                min: _lo,
                max: _hi,
                semanticFormatterCallback: (v) => rupiah(v.round()),
                onChanged: (v) => setState(() => _range = v),
              ),
            ),
            Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: [
              for (final (l, a, b) in presets) SelectChip(label: l, selected: _range.start.round() == a && _range.end.round() == b, onTap: () => _preset(a, b)),
            ]),
          ]),
        ),
        _section(
          CatalogStrings.ratingLabel,
          Row(children: [
            for (final (i, r) in const [0.0, 3.0, 4.0, 4.5].indexed) ...[
              if (i > 0) const SizedBox(width: Gap.sm),
              Expanded(child: SelectChip(label: r == 0 ? 'Semua' : '$r+', selected: _rating == r, onTap: () => setState(() => _rating = r))),
            ],
          ]),
        ),
      ]),
    );
  }
}
