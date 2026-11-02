import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/cart/presentation/cart_providers.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_strings.dart';
import 'package:ikanku/features/catalog/presentation/product_cards.dart' show basePriceOf;

/// Tag Hero foto produk: sama di daftar dan detail. [scope] membedakan daftar asal agar tag unik per layar.
String productHeroTag(String scope, String id) => 'hero-$scope-$id';

/// Detail produk (tanpa bottom bar, CTA lengket): foto penuh di belakang, kartu info menimpa foto,
/// variasi, deskripsi dengan "Selengkapnya", ringkasan ulasan.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _showReviews = true;
  bool _expanded = false;
  Variation? _selected;

  Future<void> _addToCart(Product p, {required bool buyNow}) async {
    final r = await BottomSheetScaffold.show<(Variation, int)>(context, builder: (_) => _VariationSheet(product: p, initial: _selected, actionLabel: buyNow ? CatalogStrings.buyNow : CatalogStrings.addToCart));
    if (r == null || !mounted) return;
    final (v, qty) = r;
    setState(() => _selected = v);
    final cart = ref.read(cartProvider.notifier);
    cart.add(p, v, qty: qty);
    HapticFeedback.lightImpact();
    if (buyNow) {
      cart.toggleAll(false);
      cart.toggle('${p.id}|${v.id}');
      context.push('/checkout');
    } else {
      showActionMsg(context, CatalogStrings.addedToCart, actionLabel: CatalogStrings.viewCart, onAction: () => context.push('/cart'));
    }
  }

  Widget _circleButton({required String tooltip, required VoidCallback onPressed, required Widget icon}) => Padding(
        padding: const EdgeInsets.all(Gap.xs),
        child: Material(
          color: AppColors.buttonOnPhoto,
          shape: const CircleBorder(),
          child: IconButton(tooltip: tooltip, onPressed: onPressed, constraints: const BoxConstraints(minWidth: AppSize.buttonSmall, minHeight: AppSize.buttonSmall), icon: icon),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(catalogProvider).byId(widget.productId);
    final cartCount = ref.watch(cartCountProvider);
    if (p == null) {
      return AppScaffold(title: 'Produk', body: EmptyState(CatalogStrings.productNotFound, icon: Icons.search_off, hint: CatalogStrings.productNotFoundHint, actionLabel: CatalogStrings.backHome, onAction: () => context.go('/home')));
    }
    final scope = GoRouterState.of(context).extra;
    final photoH = (MediaQuery.sizeOf(context).width.clamp(0, kContentMaxWidth) * 0.95).toDouble();
    final g = Space.screenGutter(context);
    Widget photo = SizedBox(height: photoH + 28, width: double.infinity, child: productPicture(p.image, cacheWidth: 900));
    if (scope is String) photo = Hero(tag: productHeroTag(scope, p.id), child: photo);
    final reviews = p.reviews;
    final long = p.description.length > 140;
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: ContentFrame(
        padded: false,
        child: StickyActionBar(
          child: Row(children: [
            Expanded(child: PillButton(label: CatalogStrings.addToCart, outlined: true, onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: false))),
            const SizedBox(width: Gap.md),
            Expanded(child: PillButton(label: CatalogStrings.buyNow, onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: true))),
          ]),
        ),
      ),
      body: ContentFrame(
        padded: false,
        safe: true,
        child: Stack(children: [
          Positioned(top: 0, left: 0, right: 0, child: photo),
          SingleChildScrollView(child: Column(children: [
            SizedBox(height: photoH - 12),
            Container(
              decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
              padding: EdgeInsets.fromLTRB(g, g, g, Gap.xl),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: AppText.heading),
                    const SizedBox(height: Gap.sm),
                    Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: Gap.sm, children: [
                      Text(rupiah(p.startingPrice), style: AppText.price.copyWith(fontSize: 24, color: AppColors.primary)),
                      if (p.discountPercent > 0) Text(rupiah(basePriceOf(p)), style: AppText.small.copyWith(color: AppColors.grey, decoration: TextDecoration.lineThrough)),
                    ]),
                    const SizedBox(height: Gap.sm),
                    Wrap(spacing: Gap.sm, runSpacing: Gap.xs, children: [
                      InfoPill(label: '${p.rating} ${CatalogStrings.reviewCount(p.reviews.length)}', icon: Icons.star, iconColor: AppColors.star),
                      if (p.discountPercent > 0) InfoPill(label: 'Diskon ${p.discountPercent}%', tint: AppColors.danger),
                      InfoPill(label: p.stock == 0 ? CatalogStrings.soldOut : CatalogStrings.stock(p.stock), tint: p.stock == 0 ? AppColors.danger : AppColors.success),
                    ]),
                    const Divider(height: Gap.xxl),
                    Row(children: [
                      const IconChip(icon: Icons.storefront_outlined, size: 44),
                      const SizedBox(width: Gap.md),
                      Expanded(child: Text(p.sellerName, style: AppText.semi, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      Flexible(child: TextButton(onPressed: () => context.push('/shop/${Uri.encodeComponent(p.sellerName)}'), child: const Text(CatalogStrings.visitShop, textAlign: TextAlign.center))),
                    ]),
                  ]),
                ),
                const VGap.section(),
                const SectionHeader(CatalogStrings.variations),
                const VGap.title(),
                Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: [
                  for (final o in p.variations)
                    SelectChip(keyId: 'inline-var-${o.id}', label: '${o.label}  ${rupiah(p.priceOf(o))}', selected: _selected?.id == o.id, onTap: o.stock == 0 ? () {} : () => setState(() => _selected = o)),
                ]),
                const VGap.section(),
                const SectionHeader(CatalogStrings.description),
                const VGap.title(),
                AnimatedSize(
                  duration: AppMotion.of(context, AppMotion.base),
                  curve: AppMotion.curve,
                  alignment: Alignment.topCenter,
                  child: Text(p.description, style: AppText.body.copyWith(color: AppColors.text), maxLines: _expanded || !long ? null : 4, overflow: TextOverflow.fade),
                ),
                if (long) Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => setState(() => _expanded = !_expanded), child: Text(_expanded ? CatalogStrings.readLess : CatalogStrings.readMore))),
                const VGap.section(),
                const SectionHeader(CatalogStrings.reviewsTitle),
                const VGap.title(),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${p.rating}/5', style: AppText.ratingLarge),
                      RatingStars(rating: p.rating, size: 16),
                      Text(CatalogStrings.reviewCount(reviews.length), style: AppText.small),
                    ]),
                    const Spacer(),
                    const SizedBox(width: Gap.md),
                    Flexible(
                      child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Column(children: [
                        for (var s = 5; s >= 1; s--)
                          Row(children: [
                            Text('$s', style: AppText.caption),
                            const SizedBox(width: Gap.sm),
                            Expanded(child: LinearProgressIndicator(value: reviews.isEmpty ? 0 : reviews.where((r) => r.rating == s).length / reviews.length, color: AppColors.star, backgroundColor: AppColors.surfaceTint, borderRadius: BorderRadius.circular(6), minHeight: 6)),
                          ]),
                      ]),
                    )),
                  ]),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(onPressed: () => setState(() => _showReviews = !_showReviews), icon: Icon(_showReviews ? Icons.expand_less : Icons.expand_more), label: Text(_showReviews ? CatalogStrings.hideReviews : CatalogStrings.showReviews)),
                ),
                if (_showReviews)
                  if (reviews.isEmpty)
                    Text(CatalogStrings.noReviews, style: AppText.small)
                  else
                    for (final r in reviews)
                      AppCard(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(r.author, style: AppText.label)), RatingStars(rating: r.rating.toDouble(), size: 12)]),
                          const SizedBox(height: Gap.xs),
                          Text(r.text, style: AppText.small),
                        ]),
                      ),
              ]),
            ),
          ])),
          Positioned(
            top: MediaQuery.paddingOf(context).top + Gap.xs,
            left: Gap.xs,
            right: Gap.xs,
            child: Row(children: [
              _circleButton(tooltip: 'Kembali', onPressed: () => context.canPop() ? context.pop() : context.go('/home'), icon: const Icon(Icons.arrow_back, color: Colors.white)),
              const Spacer(),
              _circleButton(tooltip: 'Keranjang', onPressed: () => context.push('/cart'), icon: NavBadge(count: cartCount, label: 'item di keranjang', child: const Icon(Icons.shopping_cart_outlined, color: Colors.white))),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Sheet variasi (root navigator): harga dan stok mengikuti variasi terpilih, jumlah dibatasi stok.
class _VariationSheet extends StatefulWidget {
  const _VariationSheet({required this.product, required this.actionLabel, this.initial});
  final Product product;
  final String actionLabel;
  final Variation? initial;
  @override
  State<_VariationSheet> createState() => _VariationSheetState();
}

class _VariationSheetState extends State<_VariationSheet> {
  late Variation? _selected = widget.initial;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final v = _selected;
    return BottomSheetScaffold(
      title: '${CatalogStrings.chooseVariation} (${p.variations.length} variasi)',
      footer: PillButton(label: widget.actionLabel, onPressed: v == null ? null : () => Navigator.of(context).pop((v, _qty))),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: [
          for (final o in p.variations)
            SelectChip(
              keyId: 'var-${o.id}',
              label: '${o.label}  ${rupiah(p.priceOf(o))}',
              selected: v?.id == o.id,
              onTap: o.stock == 0
                  ? () {}
                  : () => setState(() {
                        _selected = o;
                        _qty = _qty.clamp(1, o.stock);
                      }),
            ),
        ]),
        const SizedBox(height: Gap.xl),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v == null ? CatalogStrings.pickVariationFirst : CatalogStrings.total(rupiah(p.priceOf(v) * _qty)), key: const Key('sheet-total'), style: AppText.semi),
              Text(v == null ? ' ' : (_qty >= v.stock ? CatalogStrings.maxStock : CatalogStrings.stockLeft(v.stock)), style: AppText.small.copyWith(color: AppColors.grey)),
            ]),
          ),
          QtyStepper(value: _qty, max: v?.stock ?? 1, onChanged: v == null ? (_) {} : (q) => setState(() => _qty = q)),
        ]),
      ]),
    );
  }
}
