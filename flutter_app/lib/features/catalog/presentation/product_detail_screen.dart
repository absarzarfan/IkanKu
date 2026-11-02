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

/// Tag Hero foto produk: sama di daftar dan detail. [scope] membedakan daftar asal agar tag unik per layar.
String productHeroTag(String scope, String id) => 'hero-$scope-$id';

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
    final r = await showModalBottomSheet<(Variation, int)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (_) => _VariationSheet(product: p, actionLabel: buyNow ? CatalogStrings.buyNow : CatalogStrings.addToCart),
    );
    if (r == null || !mounted) return;
    final (v, qty) = r;
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

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(catalogProvider).byId(widget.productId);
    final cartCount = ref.watch(cartCountProvider);
    if (p == null) {
      return AppScaffold(title: 'Produk', body: EmptyState(CatalogStrings.productNotFound, icon: Icons.search_off, hint: CatalogStrings.productNotFoundHint, actionLabel: CatalogStrings.backHome, onAction: () => context.go('/home')));
    }
    final scope = GoRouterState.of(context).extra;
    Widget photo = ClipRRect(borderRadius: BorderRadius.circular(AppRadius.sheet), child: AspectRatio(aspectRatio: 1.6, child: productPicture(p.image, cacheWidth: 900)));
    if (scope is String) photo = Hero(tag: productHeroTag(scope, p.id), child: photo);
    final reviews = p.reviews;
    return AppScaffold(
      title: p.name,
      actions: [
        IconButton(
          tooltip: 'Keranjang',
          onPressed: () => context.push('/cart'),
          icon: NavBadge(count: cartCount, label: 'item di keranjang', child: const Icon(Icons.shopping_cart_outlined, color: Colors.white)),
        ),
      ],
      bottom: StickyActionBar(
        child: Row(children: [
          Expanded(child: PillButton(label: CatalogStrings.addToCart, onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: false))),
          const SizedBox(width: Gap.md),
          Expanded(child: PillButton(label: CatalogStrings.buyNow, color: AppColors.navy, onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: true))),
        ]),
      ),
      body: ListView(padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, Gap.xl), children: [
        photo,
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
        Text(p.stock == 0 ? CatalogStrings.soldOut : CatalogStrings.stock(p.stock), style: AppText.subheading.copyWith(color: p.stock == 0 ? AppColors.danger : null)),
        const SizedBox(height: Gap.md),
        const SectionHeader(CatalogStrings.description),
        Text(p.description, style: AppText.body),
        const SizedBox(height: Gap.lg),
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.storefront, color: AppColors.primary)),
            const SizedBox(width: Gap.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.sellerName, style: AppText.semi), Text('Tempat Budidaya Ikan Air Tawar, Restoran, Kolam Pemancingan', style: AppText.small)])),
            OutlinedButton(onPressed: () => context.push('/shop/${Uri.encodeComponent(p.sellerName)}'), child: Text(CatalogStrings.visitShop, style: AppText.caption.copyWith(color: AppColors.danger))),
          ]),
        ),
        const SectionHeader(CatalogStrings.reviewsTitle),
        const SizedBox(height: Gap.sm),
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.rating}/5', style: AppText.ratingLarge),
              RatingStars(rating: p.rating, size: 16),
              Text(CatalogStrings.reviewCount(reviews.length), style: AppText.small),
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
          child: TextButton.icon(onPressed: () => setState(() => _showReviews = !_showReviews), icon: Icon(_showReviews ? Icons.expand_less : Icons.expand_more), label: Text(_showReviews ? CatalogStrings.hideReviews : CatalogStrings.showReviews)),
        ),
        if (_showReviews)
          if (reviews.isEmpty)
            Text(CatalogStrings.noReviews, style: AppText.small)
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

/// Sheet variasi: harga dan stok mengikuti variasi terpilih, jumlah dibatasi stok.
class _VariationSheet extends StatefulWidget {
  const _VariationSheet({required this.product, required this.actionLabel});
  final Product product;
  final String actionLabel;
  @override
  State<_VariationSheet> createState() => _VariationSheetState();
}

class _VariationSheetState extends State<_VariationSheet> {
  Variation? _selected;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final v = _selected;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.xl, context.pagePadding, Gap.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader('${CatalogStrings.chooseVariation} (${p.variations.length} variasi)'),
          const SizedBox(height: Gap.md),
          Flexible(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final o in p.variations)
                    ChoiceChip(
                      key: Key('var-${o.id}'),
                      label: Text('${o.label}  ${rupiah(p.priceOf(o))}'),
                      selected: v?.id == o.id,
                      onSelected: o.stock == 0 ? null : (_) => setState(() {
                            _selected = o;
                            _qty = _qty.clamp(1, o.stock);
                          }),
                    ),
                ]),
                const SizedBox(height: Gap.lg),
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
            ),
          ),
          const SizedBox(height: Gap.lg),
          PillButton(label: widget.actionLabel, onPressed: v == null ? null : () => Navigator.pop(context, (v, _qty))),
        ]),
      ),
    );
  }
}
