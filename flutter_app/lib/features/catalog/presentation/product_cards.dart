import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/product_detail_screen.dart' show productHeroTag;

Widget _heroed(String? scope, Product p, Widget child) => scope == null ? child : Hero(tag: productHeroTag(scope, p.id), child: child);

/// Harga sebelum diskon (variasi termurah); dipakai untuk coretan harga bila ada diskon.
int basePriceOf(Product p) => p.variations.isEmpty ? 0 : p.variations.map((v) => v.price).reduce((a, b) => a < b ? a : b);

/// Lencana yang dihitung hanya dari data produk: diskon, stok habis, rating.
List<Widget> productBadges(Product p, {bool onPhoto = false}) => [
      if (p.discountPercent > 0) InfoPill(label: '-${p.discountPercent}%', tint: AppColors.danger, solid: onPhoto),
      if (p.stock == 0) InfoPill(label: 'Stok habis', onPhoto: onPhoto),
    ];

Widget _ratingPill(Product p, {bool onPhoto = false}) => InfoPill(label: '${p.rating}', icon: Icons.star, iconColor: AppColors.star, onPhoto: onPhoto);

void _open(BuildContext context, Product p, String? scope) => context.push('/product/${p.id}', extra: scope);

/// Kartu unggulan untuk carousel: foto besar, gradien bawah gelap agar teks putih terbaca (>= 4.5:1).
class ProductFeaturedCard extends StatelessWidget {
  const ProductFeaturedCard({super.key, required this.product, this.heroScope, this.photoKey, this.cardKey});
  final Product product;
  final String? heroScope;
  final Key? photoKey;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Semantics(
      button: true,
      label: '${p.name}, ${rupiah(p.startingPrice)}, penilaian ${p.rating}',
      excludeSemantics: true,
      child: Pressable(
        key: cardKey,
        onTap: () => _open(context, p, heroScope),
        borderRadius: BorderRadius.circular(AppRadius.card),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadow.card),
        minSize: 0,
        child: AspectRatio(
          aspectRatio: 0.78,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Stack(fit: StackFit.expand, children: [
              KeyedSubtree(key: photoKey, child: _heroed(heroScope, p, productPicture(p.image, cacheWidth: 500))),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [AppColors.photoShade, AppColors.photoShadeClear]))),
              Positioned(left: Gap.sm, top: Gap.sm, right: Gap.sm, child: Wrap(spacing: Gap.xs, runSpacing: Gap.xs, children: [_ratingPill(p, onPhoto: true), ...productBadges(p, onPhoto: true)])),
              Positioned(
                left: Gap.md,
                right: Gap.md,
                bottom: Gap.md,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: AppText.label.copyWith(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(rupiah(p.startingPrice), style: AppText.semi.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Ubin grid: foto atas radius 16, nama, harga, chip rating, lencana.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.heroScope});
  final Product product;
  final String? heroScope;
  @override
  Widget build(BuildContext context) {
    final p = product;
    final pad = Space.cardPadding(context);
    return Semantics(
      button: true,
      label: '${p.name}, ${rupiah(p.startingPrice)}',
      excludeSemantics: true,
      child: Pressable(
        onTap: () => _open(context, p, heroScope),
        borderRadius: BorderRadius.circular(AppRadius.card),
        decoration: AppCard.decorationFor(AppColors.surface),
        minSize: 0,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _heroed(heroScope, p, AspectRatio(aspectRatio: 1.15, child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.thumb), child: productPicture(p.image, cacheWidth: 400)))),
            const SizedBox(height: Gap.sm),
            Text(p.name, style: AppText.label, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: Gap.xs),
            Text(rupiah(p.startingPrice), style: AppText.semi.copyWith(color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: Gap.sm),
            Wrap(spacing: Gap.xs, runSpacing: Gap.xs, children: [_ratingPill(p), ...productBadges(p)]),
          ]),
        ),
      ),
    );
  }
}

/// Baris daftar: thumbnail PERSEGI radius 16 (tanpa foto bulat), nama, harga (+ coretan bila diskon), rating, lencana.
class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product, this.index, this.heroScope});
  final Product product;
  final int? index;
  final String? heroScope;
  @override
  Widget build(BuildContext context) {
    final p = product;
    final side = fluid(context, 84);
    return AppCard(
      revealIndex: index,
      onTap: () => _open(context, p, heroScope),
      child: Row(children: [
        _heroed(heroScope, p, ClipRRect(borderRadius: BorderRadius.circular(AppRadius.thumb), child: productPicture(p.image, width: side, height: side, cacheWidth: (side * 3).round()))),
        const SizedBox(width: Gap.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: AppText.label, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: Gap.xs),
            Text(rupiah(p.startingPrice), style: AppText.semi.copyWith(color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (p.discountPercent > 0) Text(rupiah(basePriceOf(p)), style: AppText.caption.copyWith(color: AppColors.grey, decoration: TextDecoration.lineThrough), maxLines: 1),
            const SizedBox(height: Gap.xs),
            Wrap(spacing: Gap.xs, runSpacing: Gap.xs, children: [_ratingPill(p), ...productBadges(p)]),
          ]),
        ),
      ]),
    );
  }
}
