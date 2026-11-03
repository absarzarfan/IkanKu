import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/router/tab_reselect.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_strings.dart';
import 'package:ikanku/features/catalog/presentation/product_browser.dart';
import 'package:ikanku/features/catalog/presentation/product_cards.dart';
import 'package:ikanku/features/catalog/presentation/search_filter.dart';

export 'package:ikanku/features/catalog/presentation/product_cards.dart';
export 'package:ikanku/features/catalog/presentation/product_detail_screen.dart';
export 'package:ikanku/features/catalog/presentation/search_screen.dart';

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
  static const _valueIcons = [Icons.local_shipping_outlined, Icons.touch_app_outlined, Icons.verified_outlined];

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
    final grid = cat.products.take(6).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: Space.minBottomClearance(context)),
          children: [
            HeroHeader(
              floating: const _HomeSearch(),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(CatalogStrings.greeting(user?.name ?? CatalogStrings.guest), style: AppText.greeting, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(CatalogStrings.tagline, style: AppText.small.copyWith(color: AppColors.onPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                IconButton(
                  tooltip: CatalogStrings.cartTooltip,
                  onPressed: () => context.push('/cart'),
                  icon: NavBadge(count: cartCount, label: 'item di keranjang', child: const Icon(Icons.shopping_cart_outlined, color: AppColors.onPrimary)),
                ),
              ]),
            ),
            const VGap.section(),
            ContentFrame(safe: true, child: SectionHeader(CatalogStrings.categories, eyebrow: CatalogStrings.categoriesEyebrow, action: CatalogStrings.seeAll, onAction: () => context.push('/category/Semua'))),
            const VGap.title(),
            ContentFrame(
              padded: false,
              safe: true,
              child: HorizontalCardList(
                key: const Key('home-categories'),
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
                          ProductImage(asset: c.$2, size: fluid(context, 44), radius: AppRadius.icon),
                          const SizedBox(width: Gap.sm + 2),
                          Expanded(child: Text(c.$1, style: AppText.label, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            const VGap.section(),
            ContentFrame(padded: false, safe: true, child: _banners_(context)),
            const VGap.section(),
            ContentFrame(
              padded: false,
              safe: true,
              child: HorizontalCardList(
                key: const Key('home-valueprops'),
                preferred: 150,
                min: 140,
                max: 200,
                children: [for (final (i, t) in CatalogStrings.valueProps.indexed) ValuePropCard(icon: _valueIcons[i], title: t)],
              ),
            ),
            const VGap.section(),
            ContentFrame(safe: true, child: SectionHeader(CatalogStrings.recommendations, key: const Key('home-reco-title'), eyebrow: CatalogStrings.recoEyebrow, action: CatalogStrings.seeAll, onAction: () => context.push('/recommendations'))),
            const VGap.title(),
            if (recs.isEmpty)
              const ContentFrame(safe: true, child: EmptyState(CatalogStrings.noProducts, icon: Icons.set_meal_outlined))
            else
              ContentFrame(
                padded: false,
                safe: true,
                child: HorizontalCardList(
                  preferred: 170,
                  min: 150,
                  max: 220,
                  children: [
                    for (final (i, p) in recs.indexed)
                      ProductFeaturedCard(product: p, heroScope: 'home-rail', photoKey: i < 2 ? Key('home-reco-photo-$i') : null, cardKey: i < 2 ? Key('home-reco-card-$i') : null),
                  ],
                ),
              ),
            const VGap.section(),
            ContentFrame(
              safe: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeader(CatalogStrings.allFish, key: const Key('home-all-title'), action: CatalogStrings.seeAll, onAction: () => context.push('/category/Semua')),
                const VGap.title(),
                if (grid.isEmpty) const EmptyState(CatalogStrings.noProducts, icon: Icons.set_meal_outlined) else ProductGrid(products: grid, heroScope: 'home-grid', firstKey: const Key('home-list-first')),
                const VGap.section(),
                PillButton(label: CatalogStrings.seeMore, outlined: true, onPressed: () => context.push('/recommendations')),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banners_(BuildContext context) => Column(children: [
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
                          child: Container(constraints: const BoxConstraints(minHeight: AppSize.buttonSmall), alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: Gap.lg), child: const Text(CatalogStrings.buyBanner, style: AppText.bannerButton)),
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
            // Hanya warna dan skala (transform) yang dianimasikan; ukuran layout tetap.
            AnimatedScale(
              scale: i == _banner ? 1.25 : 1,
              duration: AppMotion.of(context, AppMotion.base),
              curve: AppMotion.curve,
              child: AnimatedContainer(
                duration: AppMotion.of(context, AppMotion.base),
                curve: AppMotion.curve,
                margin: const EdgeInsets.symmetric(horizontal: Gap.xs),
                width: 8,
                height: 6,
                decoration: BoxDecoration(color: i == _banner ? AppColors.primary : AppColors.greyLight, borderRadius: BorderRadius.circular(AppRadius.chip)),
              ),
            ),
        ]),
      ]);
}

class _HomeSearch extends StatelessWidget {
  const _HomeSearch();
  @override
  Widget build(BuildContext context) => FloatingSearchField(label: CatalogStrings.searchEntry, onTap: () => context.go('/search'));
}

/// Pilih Kategori / Lihat semua: komponen daftar yang sama dengan Telusuri, preset kategori dari titik masuk.
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.category});
  final String category;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ProductBrowser(
        key: ValueKey('cat-$category'),
        title: category == 'Semua' ? 'Semua ikan' : category,
        showBack: true,
        heroScope: 'cat',
        initialFilter: category == 'Semua' ? const SearchFilter() : SearchFilter(category: category),
      );
}

/// Halaman toko: ringkasan toko + produknya (grid).
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
          child: Row(children: [
            const IconChip(icon: Icons.storefront_outlined, size: 52),
            const SizedBox(width: Gap.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppText.semi), Text('${items.length} produk', style: AppText.small.copyWith(color: AppColors.grey))])),
          ]),
        ),
        const SectionHeader('Produk'),
        const VGap.title(),
        if (items.isEmpty) const EmptyState('Belum ada produk di toko ini', icon: Icons.set_meal_outlined) else ProductGrid(products: items, heroScope: 'shop'),
      ]),
    );
  }
}

/// Rekomendasi untuk Anda: daftar bersama dengan urutan paling sesuai.
class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => const ProductBrowser(key: ValueKey('reco'), title: 'Rekomendasi', showBack: true, heroScope: 'reco');
}
