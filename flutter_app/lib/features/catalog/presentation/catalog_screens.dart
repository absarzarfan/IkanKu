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
import 'package:ikanku/features/catalog/presentation/catalog_strings.dart';
import 'package:ikanku/features/catalog/presentation/product_detail_screen.dart' show productHeroTag;
import 'package:ikanku/core/router/tab_reselect.dart';

export 'package:ikanku/features/catalog/presentation/product_detail_screen.dart';
export 'package:ikanku/features/catalog/presentation/search_screen.dart';

/// Kartu produk vertikal dengan foto bulat menimpa tepi atas (Figma Container 36).
/// Satu unit: foto + kartu. Offset atas Stack = jari-jari foto, padding atas kartu = jari-jari + 8,
/// sehingga bagian paling atas unit adalah foto (jarak dari judul bagian diukur ke foto).
/// Lebar mengikuti induk, tinggi mengikuti isi.
class ProductCardWithPhoto extends StatelessWidget {
  const ProductCardWithPhoto({super.key, required this.product, this.photoKey, this.cardKey, this.heroScope});
  final Product product;

  /// Asal daftar untuk transisi Hero foto ke detail (null = tanpa Hero).
  final String? heroScope;
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
              onTap: () => context.push('/product/${product.id}', extra: heroScope),
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
                      Text('${product.rating}', style: AppText.rating),
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
          IgnorePointer(child: SizedBox(key: photoKey, width: photo, height: photo, child: _heroed(heroScope, product, ProductImage(asset: product.image, size: photo)))),
        ]),
      );
    });
  }
}

typedef ProductCard = ProductCardWithPhoto;

Widget _heroed(String? scope, Product p, Widget child) => scope == null ? child : Hero(tag: productHeroTag(scope, p.id), child: child);

/// Baris produk horizontal (Figma Container 38).
class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product, this.index, this.heroScope});
  final Product product;
  final int? index;
  final String? heroScope;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      revealIndex: index,
      onTap: () => context.push('/product/${product.id}', extra: heroScope),
      child: Row(children: [
        _heroed(heroScope, product, ProductImage(asset: product.image, size: fluid(context, 60))),
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
          Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 16, color: AppColors.star), Text('${product.rating}', style: AppText.rating)]),
        ]),
      ]),
    );
  }
}

/// Varian kartu ketiga: ubin ringkas untuk grid 2 kolom (foto persegi membulat, nama, harga, rating).
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.heroScope});
  final Product product;
  final String? heroScope;
  @override
  Widget build(BuildContext context) {
    final pad = Space.cardPadding(context);
    return Semantics(
      button: true,
      label: '${product.name}, ${rupiah(product.startingPrice)}',
      excludeSemantics: true,
      child: Pressable(
        onTap: () => context.push('/product/${product.id}', extra: heroScope),
        borderRadius: BorderRadius.circular(AppRadius.card),
        decoration: AppCard.decorationFor(AppColors.surface),
        minSize: 0,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _heroed(heroScope, product, AspectRatio(aspectRatio: 1.3, child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.icon), child: productPicture(product.image, cacheWidth: 400)))),
            const SizedBox(height: Gap.sm),
            Text(product.name, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: Gap.xs),
            Text(rupiah(product.startingPrice), style: AppText.semi, maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(children: [const Icon(Icons.star, size: 14, color: AppColors.star), const SizedBox(width: Gap.xs), Text('${product.rating}', style: AppText.rating)]),
          ]),
        ),
      ),
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
  final _scroll = ScrollController();
  int _banner = 0;
  static const _banners = [('assets/images/banner1.webp', 'Diskon 75%'), ('assets/images/banner2.webp', 'Diskon 30%'), ('assets/images/banner3.webp', 'Diskon 25%')];
  static const _cats = [('Hias', 'assets/images/cat_hias.webp'), ('Air Tawar', 'assets/images/cat_air_tawar.webp'), ('Bibit', 'assets/images/cat_bibit.webp')];

  @override
  void dispose() {
    _page.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(catalogProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    listenTabReselect(ref, context, 0, _scroll);
    final cat = ref.watch(catalogProvider);
    final user = ref.watch(authProvider);
    final cartCount = ref.watch(cartCountProvider);
    final recs = cat.products.take(6).toList();
    final list = cat.products.skip(3).take(3).toList();
    final topRated = ([...cat.products]..sort((a, b) => b.rating.compareTo(a.rating))).take(4).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: Space.minBottomClearance(context)),
          children: [
            GradientHeader(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + Gap.lg, bottom: 18),
              child: ContentFrame(
                safe: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(CatalogStrings.greeting(user?.name ?? CatalogStrings.guest), style: AppText.greeting, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      tooltip: CatalogStrings.cartTooltip,
                      onPressed: () => context.push('/cart'),
                      icon: NavBadge(count: cartCount, label: 'item di keranjang', child: const Icon(Icons.shopping_cart_outlined, color: AppColors.onPrimary)),
                    ),
                  ]),
                  const SizedBox(height: Gap.sm),
                  Semantics(
                    button: true,
                    label: CatalogStrings.searchEntry,
                    child: Pressable(
                      onTap: () => context.go('/search'),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                      minSize: AppSize.searchBar,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: Gap.md),
                        child: Row(children: [Icon(Icons.search, size: 18, color: AppColors.grey), SizedBox(width: Gap.sm), Text(CatalogStrings.searchEntry, style: AppText.searchHint)]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            const VGap.section(),
            ContentFrame(safe: true, child: SectionHeader(CatalogStrings.categories, action: CatalogStrings.seeAll, onAction: () => context.push('/category/Semua'))),
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
                                    child: IntrinsicWidth(child: Container(constraints: const BoxConstraints(minHeight: AppSize.buttonSmall), alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: Gap.md), child: const Text(CatalogStrings.buyBanner, textAlign: TextAlign.center, style: AppText.bannerButton))),
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
                    AnimatedContainer(duration: AppMotion.of(context, AppMotion.base), curve: AppMotion.curve, margin: const EdgeInsets.symmetric(horizontal: Gap.xs), width: i == _banner ? 18 : 7, height: 6, decoration: BoxDecoration(color: i == _banner ? AppColors.primary : AppColors.greyLight, borderRadius: BorderRadius.circular(AppRadius.chip))),
                ]),
              ]),
            ),
            const VGap.section(),
            ContentFrame(
              safe: true,
              child: SectionHeader(CatalogStrings.recommendations, key: const Key('home-reco-title'), action: CatalogStrings.seeAll, onAction: () => context.push('/recommendations')),
            ),
            const VGap.title(),
            if (recs.isEmpty)
              const ContentFrame(safe: true, child: EmptyState(CatalogStrings.noProducts, icon: Icons.set_meal_outlined))
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
                        heroScope: 'home-rail',
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
                for (final (i, p) in list.indexed) KeyedSubtree(key: i == 0 ? const Key('home-list-first') : null, child: ProductRow(product: p, index: i, heroScope: 'home-list')),
                if (topRated.isNotEmpty) ...[
                  const VGap.section(),
                  SectionHeader(CatalogStrings.topRated, action: CatalogStrings.seeAll, onAction: () => context.push('/recommendations')),
                  const VGap.title(),
                  ResponsiveGrid(maxCrossAxisExtent: 220, spacing: Space.itemGap, runSpacing: Space.itemGap, children: [for (final p in topRated) ProductTile(product: p, heroScope: 'home-grid')]),
                  const VGap.section(),
                ],
                PillButton(label: CatalogStrings.seeMore, outlined: true, onPressed: () => context.push('/recommendations')),
              ]),
            ),
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
              ? const EmptyState(CatalogStrings.noProductsInCategory, icon: Icons.set_meal_outlined)
              : RefreshableList(
                  onRefresh: () async => ref.invalidate(catalogProvider),
                  padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, Gap.xl),
                  children: [ResponsiveGrid(maxCrossAxisExtent: 200, spacing: Gap.lg, runSpacing: Gap.sm, children: [for (final p in items) ProductCard(product: p, heroScope: 'cat')])],
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
        const SectionHeader('Produk'),
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
      body: RefreshableList(onRefresh: () async => ref.invalidate(catalogProvider), padding: Space.pad(context), children: [for (final (i, p) in items.indexed) ProductRow(product: p, index: i, heroScope: 'reco')]),
    );
  }
}
