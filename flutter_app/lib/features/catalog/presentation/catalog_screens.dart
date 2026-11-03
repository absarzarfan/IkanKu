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

/// Kartu produk vertikal dengan gambar bulat menimpa tepi atas (Figma Container 36).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.width = 176});
  final Product product;
  final double width;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(top: 48),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 2)]),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(top: -48, left: 0, right: 0, child: Center(child: ProductImage(asset: product.image, size: 96))),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 52, 12, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Text(product.name, style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 6),
              SizedBox(height: 34, child: Text(product.description.split('\n').first, style: AppText.small, maxLines: 2, overflow: TextOverflow.ellipsis)),
              const Divider(height: 14),
              Row(children: [
                Icon(Icons.star, size: 16, color: AppColors.star),
                const SizedBox(width: 2),
                Text('${product.rating}', style: const TextStyle(fontSize: 11)),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(rupiah(product.startingPrice), style: AppText.body, overflow: TextOverflow.ellipsis)),
                const Icon(Icons.chevron_right),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Baris produk horizontal (Figma Container 38).
class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/product/${product.id}'),
      child: Row(children: [
        ProductImage(asset: product.image, size: 60),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: AppText.body),
            const SizedBox(height: 4),
            Text(rupiah(product.startingPrice), style: AppText.body),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Icon(Icons.chevron_right),
          Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 16, color: AppColors.star), Text('${product.rating}', style: const TextStyle(fontSize: 11))]),
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
  final _page = PageController(viewportFraction: 0.85);
  int _banner = 0;
  static const _banners = [('assets/images/banner1.png', 'Diskon 75%'), ('assets/images/banner2.png', 'Diskon 30%'), ('assets/images/banner3.png', 'Diskon 25%')];
  static const _cats = [('Hias', 'assets/images/cat_hias.png'), ('Air Tawar', 'assets/images/cat_air_tawar.png'), ('Bibit', 'assets/images/cat_bibit.png')];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = ref.watch(catalogProvider);
    final user = ref.watch(authProvider);
    final cartCount = ref.watch(cartCountProvider);
    final recs = cat.products.take(6).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 18),
            decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)), boxShadow: [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Hallo, ${user?.name ?? 'Tamu'}!', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.white), overflow: TextOverflow.ellipsis)),
                IconButton(
                  tooltip: 'Keranjang',
                  onPressed: () => context.push('/cart'),
                  icon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), child: const Icon(Icons.shopping_cart_outlined, color: Colors.white)),
                ),
              ]),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => context.go('/search'),
                child: Container(
                  height: 39,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Row(children: [Icon(Icons.search, size: 16, color: AppColors.grey), SizedBox(width: 8), Text('Telusuri', style: TextStyle(fontSize: 14, color: AppColors.grey))]),
                ),
              ),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Text('Semua Kategori', style: AppText.body)),
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              children: [
                for (final c in _cats)
                  GestureDetector(
                    onTap: () => context.push('/category/${c.$1}'),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 2))]),
                      child: Row(children: [ProductImage(asset: c.$2, size: 46, radius: 16), const SizedBox(width: 10), Expanded(child: Text(c.$1, style: AppText.body, overflow: TextOverflow.ellipsis))]),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 205,
            child: PageView.builder(
              controller: _page,
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _banner = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset(_banners[i].$1, fit: BoxFit.cover, cacheWidth: 800),
                    Positioned(left: 14, top: 64, child: Text(_banners[i].$2, style: const TextStyle(fontFamily: 'Poppins', fontSize: 30, color: Colors.white))),
                    Positioned(
                      left: 14,
                      bottom: 24,
                      child: GestureDetector(
                        onTap: () => context.push('/category/Semua'),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(7)), child: const Text('Beli Sekarang', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white))),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _banners.length; i++)
              Container(margin: const EdgeInsets.all(4), width: i == _banner ? 17 : 7, height: 6, decoration: BoxDecoration(color: i == _banner ? AppColors.grey : AppColors.greyLight, borderRadius: BorderRadius.circular(8))),
          ]),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SectionRow(title: 'Rekomendasi untuk anda', action: 'Lihat semua', onAction: () => context.push('/recommendations'))),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 20),
              itemBuilder: (_, i) => ProductCard(product: recs[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(children: [
              for (final p in cat.products.skip(3).take(3)) ProductRow(product: p),
              PillButton(label: 'Lihat Lebih', outlined: true, height: 39, onPressed: () => context.push('/recommendations')),
            ]),
          ),
        ],
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
        SizedBox(
          height: 52,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), children: [
            for (final n in names)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(n), selected: n == category, onSelected: (_) => context.pushReplacement('/category/$n')),
              ),
          ]),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState('Belum ada produk di kategori ini')
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 20, mainAxisExtent: 245 + (MediaQuery.textScalerOf(context).scale(14) / 14 - 1).clamp(0.0, 1.0) * 60),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ProductCard(product: items[i]),
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
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.storefront, color: AppColors.primary)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppText.semi), Text('${items.length} produk', style: AppText.small)])),
          ]),
        ),
        Text('Produk', style: AppText.semi),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const EmptyState('Belum ada produk di toko ini')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 20, mainAxisExtent: 245 + (MediaQuery.textScalerOf(context).scale(14) / 14 - 1).clamp(0.0, 1.0) * 60),
            itemCount: items.length,
            itemBuilder: (_, i) => ProductCard(product: items[i]),
          ),
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
      body: ListView(padding: const EdgeInsets.all(20), children: [for (final p in items) ProductRow(product: p)]),
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
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
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
          ? ListView(padding: const EdgeInsets.all(20), children: [
              const SectionRow(title: 'Rekomendasi untuk anda'),
              for (final p in cat.products.take(5)) ProductRow(product: p),
            ])
          : results.isEmpty
              ? EmptyState('Tidak ada hasil untuk "$_q"', icon: Icons.search_off)
              : ListView(padding: const EdgeInsets.all(20), children: [
                  if (_submitted) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${results.length} hasil untuk "$_q"', style: AppText.small)),
                  for (final p in results) ProductRow(product: p),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(children: [
            Expanded(child: PillButton(label: 'Masukkan Keranjang', onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: false))),
            const SizedBox(width: 10),
            Expanded(child: PillButton(label: 'Beli Sekarang', color: AppColors.navy, onPressed: p.stock == 0 ? null : () => _addToCart(p, buyNow: true))),
          ]),
        ),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), children: [
        ClipRRect(borderRadius: BorderRadius.circular(28), child: SizedBox(height: 240, child: Image.asset(p.image, fit: BoxFit.cover, cacheWidth: 900))),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rupiah(p.startingPrice), style: AppText.price),
            if (p.discountPercent > 0) Text('Diskon ${p.discountPercent}%', style: AppText.small.copyWith(color: AppColors.danger)),
          ]),
          Row(children: [const Icon(Icons.star, size: 18, color: AppColors.star), Text(' ${p.rating}', style: AppText.body)]),
        ]),
        const SizedBox(height: 12),
        Text('Stok: ${p.stock} ekor', style: AppText.semi.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        Text('Deskripsi', style: AppText.semi.copyWith(fontSize: 16)),
        Text(p.description, style: AppText.body),
        const SizedBox(height: 16),
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.storefront, color: AppColors.primary)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.sellerName, style: AppText.semi), Text('Tempat Budidaya Ikan Air Tawar, Restoran, Kolam Pemancingan', style: AppText.small)])),
            OutlinedButton(onPressed: () => context.push('/shop/${Uri.encodeComponent(p.sellerName)}'), child: const Text('Kunjungi Toko', style: TextStyle(fontSize: 10, color: AppColors.danger))),
          ]),
        ),
        Text('Penilaian & Ulasan Produk', style: AppText.semi),
        const SizedBox(height: 8),
        AppCard(
          color: AppColors.field,
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.rating}/5', style: const TextStyle(fontSize: 20, fontFamily: 'Lato')),
              RatingStars(rating: p.rating, size: 16),
              Text('(${reviews.length} Ulasan)', style: AppText.small),
            ]),
            const Spacer(),
            SizedBox(
              width: 130,
              child: Column(children: [
                for (var s = 5; s >= 1; s--)
                  Row(children: [
                    Text('$s', style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 6),
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
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(r.author, style: AppText.semi.copyWith(fontSize: 14)), RatingStars(rating: r.rating.toDouble(), size: 12)]),
                const SizedBox(height: 4),
                Text(r.text, style: AppText.small.copyWith(fontWeight: FontWeight.w300, fontSize: 13)),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pilih Variasi (${p.variations.length} variasi)', style: AppText.semi),
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          PillButton(label: widget.actionLabel, onPressed: _selected == null ? null : () => Navigator.pop(context, _selected)),
        ]),
      ),
    );
  }
}
