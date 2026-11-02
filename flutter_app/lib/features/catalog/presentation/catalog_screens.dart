import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';

/// Kartu produk vertikal dengan foto bulat menimpa tepi atas (Figma Container 36).
/// Satu unit: foto + kartu. Offset atas Stack = jari-jari foto, padding atas kartu = jari-jari + 8,
/// sehingga bagian paling atas unit adalah foto (jarak dari judul bagian diukur ke foto).
/// Lebar mengikuti induk, tinggi mengikuti isi.
class ProductCardWithPhoto extends StatelessWidget {
  const ProductCardWithPhoto({super.key, required this.product, this.photoKey, this.cardKey});
  final Product product;
  final Key? photoKey;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final photo = (c.maxWidth * 0.55).clamp(72.0, 104.0);
      final radius = photo / 2;
      final pad = Space.cardPadding(context);
      return Semantics(
        button: true,
        label: product.name,
        child: Stack(alignment: Alignment.topCenter, children: [
          Padding(
            padding: EdgeInsets.only(top: radius),
            child: Pressable(
              key: cardKey,
              onTap: () => context.push('/product/${product.id}'),
              borderRadius: BorderRadius.circular(AppRadius.card),
              decoration: AppCard.decorationFor(AppColors.surface),
              minSize: 0,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, radius + Gap.sm, pad, pad),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(child: Text(product.name, style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(height: Gap.xs),
                    ConstrainedBox(constraints: BoxConstraints(minHeight: MediaQuery.textScalerOf(context).scale(36)), child: Text(product.description.split('\n').first, style: AppText.small, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    const Divider(height: Gap.lg),
                    Row(children: [
                      const Icon(Icons.star, size: 16, color: AppColors.star),
                      const SizedBox(width: Gap.xs),
                      Text('${product.rating}', style: AppText.caption),
                    ]),
                    Row(children: [
                      Expanded(child: Text(rupiah(product.startingPrice), style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.chevron_right),
                    ]),
                  ]),
                ),
              ),
            ),
          ),
          IgnorePointer(child: SizedBox(key: photoKey, width: photo, height: photo, child: ProductImage(asset: product.image, size: photo))),
        ]),
      );
    });
  }
}

typedef ProductCard = ProductCardWithPhoto;

/// Baris produk horizontal (Figma Container 38).
class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product, this.index});
  final Product product;
  final int? index;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      revealIndex: index,
      onTap: () => context.push('/product/${product.id}'),
      child: Row(children: [
        ProductImage(asset: product.image, size: fluid(context, 60)),
        const SizedBox(width: Gap.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: Gap.xs),
            Text(rupiah(product.startingPrice), style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: Gap.sm),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Icon(Icons.chevron_right),
          Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 16, color: AppColors.star), Text('${product.rating}', style: AppText.caption)]),
        ]),
      ]),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _page = PageController(viewportFraction: 0.88);
  int _banner = 0;
  static const _banners = [('assets/images/banner1.png', 'Diskon 75%'), ('assets/images/banner2.png', 'Diskon 30%'), ('assets/images/banner3.png', 'Diskon 25%')];
  static const _cats = [('Hias', 'assets/images/cat_hias.png'), ('Air Tawar', 'assets/images/cat_air_tawar.png'), ('Bibit', 'assets/images/cat_bibit.png')];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(catalogProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final cat = ref.watch(catalogProvider);
    final user = ref.watch(authProvider);
    final cartCount = ref.watch(cartCountProvider);
    final recs = cat.products.take(6).toList();
    final list = cat.products.skip(3).take(3).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + Gap.lg, bottom: 18),
              child: ContentFrame(
                safe: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('Hallo, ${user?.name ?? 'Tamu'}!', style: AppText.greeting, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      tooltip: 'Keranjang',
                      onPressed: () => context.push('/cart'),
                      icon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), child: const Icon(Icons.shopping_cart_outlined, color: AppColors.onPrimary)),
                    ),
                  ]),
                  const SizedBox(height: Gap.sm),
                  Semantics(
                    button: true,
                    label: 'Telusuri',
                    child: Pressable(
                      onTap: () => context.go('/search'),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                      minSize: AppSize.searchBar,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: Gap.md),
                        child: Row(children: [Icon(Icons.search, size: 18, color: AppColors.grey), SizedBox(width: Gap.sm), Text('Telusuri', style: AppText.searchHint)]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            const VGap.section(),
            ContentFrame(safe: true, child: const SectionHeader('Semua Kategori')),
            const VGap.title(),
            ContentFrame(
              padded: false,
              safe: true,
              child: HorizontalCardList(
                key: const Key('home-categories'),
                gap: Space.itemGap,
                preferred: 140,
                min: 130,
                max: 200,
                children: [
                  for (final c in _cats)
                    Pressable(
                      onTap: () => context.push('/category/${c.$1}'),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      decoration: AppCard.decorationFor(AppColors.surface),
                      child: Padding(
                        padding: const EdgeInsets.all(Gap.sm),
                        child: Row(children: [
                          ProductImage(asset: c.$2, size: fluid(context, 46), radius: AppRadius.icon),
                          const SizedBox(width: Gap.sm + 2),
                          Expanded(child: Text(c.$1, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            const VGap.section(),
            ContentFrame(
              padded: false,
              safe: true,
              child: Column(children: [
                AspectRatio(
                  key: const Key('home-banner'),
                  aspectRatio: 1.55,
                  child: PageView.builder(
                    controller: _page,
                    itemCount: _banners.length,
                    onPageChanged: (i) => setState(() => _banner = i),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sheet),
                        child: Stack(fit: StackFit.expand, children: [
                          Image.asset(_banners[i].$1, fit: BoxFit.cover, cacheWidth: 800, errorBuilder: (_, _, _) => Container(color: AppColors.field)),
                          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [AppColors.scrim, AppColors.scrimClear]))),
                          Padding(
                            padding: const EdgeInsets.all(Gap.md),
                            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              Flexible(child: Align(alignment: Alignment.centerLeft, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(_banners[i].$2, style: AppText.banner)))),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Pressable(
                                  decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(AppRadius.chip)),
                                  borderRadius: BorderRadius.circular(AppRadius.chip),
                                  onTap: () => context.push('/category/Semua'),
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: IntrinsicWidth(child: Container(constraints: const BoxConstraints(minHeight: AppSize.buttonSmall), alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: Gap.md), child: const Text('Beli Sekarang', textAlign: TextAlign.center, style: AppText.bannerButton))),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Space.dotsGap),
                Row(key: const Key('home-banner-dots'), mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < _banners.length; i++)
                    AnimatedContainer(duration: AppMotion.of(context, AppMotion.base), curve: AppMotion.curve, margin: const EdgeInsets.symmetric(horizontal: Gap.xs), width: i == _banner ? 18 : 7, height: 6, decoration: BoxDecoration(color: i == _banner ? AppColors.primary : AppColors.greyLight, borderRadius: BorderRadius.circular(8))),
                ]),
              ]),
            ),
            const VGap.section(),
            ContentFrame(
              safe: true,
              child: SectionHeader('Rekomendasi untuk anda', key: const Key('home-reco-title'), action: 'Lihat semua', onAction: () => context.push('/recommendations')),
            ),
            const VGap.title(),
            if (recs.isEmpty)
              const ContentFrame(safe: true, child: EmptyState('Belum ada produk'))
            else
              ContentFrame(
                padded: false,
                safe: true,
                child: HorizontalCardList(
                  gap: Space.itemGap,
                  preferred: 160,
                  min: 140,
                  max: 200,
                  children: [
                    for (final (i, p) in recs.indexed)
                      ProductCardWithPhoto(
                        product: p,
                        photoKey: i < 2 ? Key('home-reco-photo-$i') : null,
                        cardKey: i < 2 ? Key('home-reco-card-$i') : null,
                      ),
                  ],
                ),
              ),
            const VGap.section(),
            ContentFrame(
              safe: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (final (i, p) in list.indexed) KeyedSubtree(key: i == 0 ? const Key('home-list-first') : null, child: ProductRow(product: p, index: i)),
                PillButton(label: 'Lihat Lebih', outlined: true, onPressed: () => context.push('/recommendations')),
              ]),
            ),
            SizedBox(height: Space.minBottomClearance(context)),
          ],
        ),
      ),
    );
  }
}

/// Pilih Kategori (Figma 378:7086): chip kategori + daftar produk.
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.category});
  final String category;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(catalogProvider);
    final names = ['Semua', ...cat.categories];
    final items = cat.search('', category: category);
    return AppScaffold(
      title: category == 'Semua' ? 'Semua Kategori' : category,
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding, vertical: Gap.sm),
          child: Row(children: [
            for (final n in names)
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: ChoiceChip(label: Text(n), selected: n == category, onSelected: (_) => context.pushReplacement('/category/$n')),
              ),
          ]),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState('Belum ada produk di kategori ini')
              : RefreshableList(
                  onRefresh: () async => ref.invalidate(catalogProvider),
                  padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, Gap.xl),
                  children: [ResponsiveGrid(maxCrossAxisExtent: 200, spacing: Gap.lg, runSpacing: Gap.sm, children: [for (final p in items) ProductCard(product: p)])],
                ),
        ),
      ]),
    );
  }
}

/// Halaman toko ("Kunjungi Toko"): tidak ada frame di Figma/inventaris, versi paling sederhana (lihat decisions.md).
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(catalogProvider).products.where((p) => p.sellerName == name).toList();
    return AppScaffold(
      title: 'Toko',
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      body: ListView(padding: Space.pad(context), children: [
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.storefront, color: AppColors.primary)),
            const SizedBox(width: Gap.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppText.semi), Text('${items.length} produk', style: AppText.small)])),
          ]),
        ),
        Text('Produk', style: AppText.semi),
        const SizedBox(height: Gap.sm),
        if (items.isEmpty)
          const EmptyState('Belum ada produk di toko ini')
        else
          ResponsiveGrid(maxCrossAxisExtent: 200, spacing: Gap.lg, runSpacing: Gap.sm, children: [for (final p in items) ProductCard(product: p)])
      ]),
    );
  }
}

/// Rekomendasi untuk anda (Figma 2451:8597).
class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(catalogProvider).products;
    return AppScaffold(
      title: 'Rekomendasi',
      onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      body: RefreshableList(onRefresh: () async => ref.invalidate(catalogProvider), padding: Space.pad(context), children: [for (final (i, p) in items.indexed) ProductRow(product: p, index: i)]),
    );
  }
}

/// Telusuri + hasil pencarian (Figma "Contoh Pencarian" dan "Contoh Hasil Pencarian").
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _c = TextEditingController();
  String _q = '';
  bool _submitted = false;
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = ref.watch(catalogProvider);
    final results = cat.search(_q);
    return AppScaffold(
      title: 'Telusuri',
      showBack: false,
      headerExtra: Padding(
        padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, 0),
        child: TextField(
          key: const Key('search-field'),
          controller: _c,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() {
            _q = v;
            _submitted = false;
          }),
          onSubmitted: (_) => setState(() => _submitted = true),
          decoration: InputDecoration(
            hintText: 'Cari ikan',
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: _q.isEmpty ? null : IconButton(tooltip: 'Hapus', icon: const Icon(Icons.close), onPressed: () => setState(() { _c.clear(); _q = ''; _submitted = false; })),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ),
      body: _q.trim().isEmpty
          ? ListView(padding: Space.padTab(context), children: [
              const SectionHeader('Rekomendasi untuk anda'),
              for (final (i, p) in cat.products.take(5).indexed) ProductRow(product: p, index: i),
            ])
          : results.isEmpty
              ? EmptyState('Tidak ada hasil untuk "$_q"', icon: Icons.search_off)
              : ListView(padding: Space.padTab(context), children: [
                  if (_submitted) Padding(padding: const EdgeInsets.only(bottom: Gap.sm), child: Text('${results.length} hasil untuk "$_q"', style: AppText.small)),
                  for (final (i, p) in results.indexed) ProductRow(product: p, index: i),
                ]),
    );
  }
}

/// Detail produk (Figma 923:6663) + variasi (3382:12700).
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _showReviews = true;

  Future<void> _addToCart(Product p, {required bool buyNow}) async {
    final v = await showModalBottomSheet<Variation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _VariationSheet(product: p, actionLabel: buyNow ? 'Beli Sekarang' : 'Masukkan Keranjang'),
    );
    if (v == null || !mounted) return;
    ref.read(cartProvider.notifier).add(p, v);
    if (buyNow) {
      ref.read(cartProvider.notifier).toggleAll(false);
      ref.read(cartProvider.notifier).toggle('${p.id}|${v.id}');
      context.push('/checkout');
    } else {
      showMsg(context, 'Ditambahkan ke keranjang');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(catalogProvider).byId(widget.productId);
    if (p == null) {
      return AppScaffold(title: 'Produk', body: const EmptyState('Produk tidak ditemukan'));
    }
    final reviews = p.reviews;
    return AppScaffold(
      title: p.name,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, Gap.md),
          child: Row(children: [
            Expanded(child: PillButton(label: 'Masukkan Keranjang', onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: false))),
            const SizedBox(width: Gap.md),
            Expanded(child: PillButton(label: 'Beli Sekarang', color: AppColors.navy, onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: true))),
          ]),
        ),
      ),
      body: ListView(padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, Gap.xl), children: [
        ClipRRect(borderRadius: BorderRadius.circular(AppRadius.sheet), child: AspectRatio(aspectRatio: 1.6, child: productPicture(p.image, cacheWidth: 900))),
        const SizedBox(height: Gap.md),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rupiah(p.startingPrice), style: AppText.price),
            if (p.discountPercent > 0) Text('Diskon ${p.discountPercent}%', style: AppText.small.copyWith(color: AppColors.danger)),
          ])),
          const SizedBox(width: Gap.sm),
          Row(children: [const Icon(Icons.star, size: 18, color: AppColors.star), Text(' ${p.rating}', style: AppText.body)]),
        ]),
        const SizedBox(height: Gap.md),
        Text('Stok: ${p.stock} ekor', style: AppText.subheading),
        const SizedBox(height: Gap.md),
        Text('Deskripsi', style: AppText.subheading),
        Text(p.description, style: AppText.body),
        const SizedBox(height: Gap.lg),
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.storefront, color: AppColors.primary)),
            const SizedBox(width: Gap.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.sellerName, style: AppText.semi), Text('Tempat Budidaya Ikan Air Tawar, Restoran, Kolam Pemancingan', style: AppText.small)])),
            OutlinedButton(onPressed: () => context.push('/shop/${Uri.encodeComponent(p.sellerName)}'), child: Text('Kunjungi Toko', style: AppText.caption.copyWith(color: AppColors.danger))),
          ]),
        ),
        Text('Penilaian & Ulasan Produk', style: AppText.semi),
        const SizedBox(height: Gap.sm),
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.rating}/5', style: AppText.score),
              RatingStars(rating: p.rating, size: 16),
              Text('(${reviews.length} Ulasan)', style: AppText.small),
            ]),
            const Spacer(),
            const SizedBox(width: Gap.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Column(children: [
                for (var s = 5; s >= 1; s--)
                  Row(children: [
                    Text('$s', style: AppText.caption),
                    const SizedBox(width: Gap.sm),
                    Expanded(child: LinearProgressIndicator(value: reviews.isEmpty ? 0 : reviews.where((r) => r.rating == s).length / reviews.length, color: AppColors.text, backgroundColor: AppColors.greyLight, minHeight: 6)),
                  ]),
              ]),
            ),
          ]),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: () => setState(() => _showReviews = !_showReviews), icon: Icon(_showReviews ? Icons.expand_less : Icons.expand_more), label: Text(_showReviews ? 'Sembunyikan' : 'Tampilkan')),
        ),
        if (_showReviews)
          if (reviews.isEmpty)
            Text('Belum ada ulasan', style: AppText.small)
          else
            for (final r in reviews)
              AppCard(color: AppColors.field, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(r.author, style: AppText.label)), RatingStars(rating: r.rating.toDouble(), size: 12)]),
                const SizedBox(height: Gap.xs),
                Text(r.text, style: AppText.small.copyWith(fontWeight: FontWeight.w300)),
              ])),
      ]),
    );
  }
}

class _VariationSheet extends StatefulWidget {
  const _VariationSheet({required this.product, required this.actionLabel});
  final Product product;
  final String actionLabel;
  @override
  State<_VariationSheet> createState() => _VariationSheetState();
}

class _VariationSheetState extends State<_VariationSheet> {
  Variation? _selected;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.xl, context.pagePadding, Gap.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pilih Variasi (${p.variations.length} variasi)', style: AppText.semi),
          const SizedBox(height: Gap.md),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final v in p.variations)
                  ChoiceChip(
                    key: Key('var-${v.id}'),
                    label: Text('${v.label}  ${rupiah(p.priceOf(v))}'),
                    selected: _selected?.id == v.id,
                    onSelected: v.stock == 0 ? null : (_) => setState(() => _selected = v),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: Gap.lg),
          PillButton(label: widget.actionLabel, onPressed: _selected == null ? null : () => Navigator.pop(context, _selected)),
        ]),
      ),
    );
  }
}
