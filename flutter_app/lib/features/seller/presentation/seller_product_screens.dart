import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';

const _photoChoices = [
  'assets/images/cat_air_tawar.png',
  'assets/images/fish_discus.png',
  'assets/images/fish_cupang.png',
  'assets/images/fish_3.png',
  'assets/images/fish_4.png',
  'assets/images/cat_bibit.png',
];

/// Daftar produk & kategori penjual (Figma 1114:13648 dst).
class SellerProductsScreen extends ConsumerStatefulWidget {
  const SellerProductsScreen({super.key});
  @override
  ConsumerState<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends ConsumerState<SellerProductsScreen> {
  String _cat = 'Semua';
  @override
  Widget build(BuildContext context) {
    final cat = ref.watch(catalogProvider);
    final n = ref.read(catalogProvider.notifier);
    final names = ['Semua', ...cat.categories];
    final items = cat.search('', category: names.contains(_cat) ? _cat : 'Semua');
    return AppScaffold(
      title: 'Produk',
      showBack: false,
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('Daftar Kategori', style: AppText.semi)),
          TextButton.icon(onPressed: () => context.push('/seller/categories/new'), icon: const Icon(Icons.add), label: const Text('Tambah Kategori')),
        ]),
        Wrap(spacing: 8, children: [
          for (final c in names)
            InputChip(
              label: Text(c),
              selected: c == _cat,
              onPressed: () => setState(() => _cat = c),
              onDeleted: c == 'Semua'
                  ? null
                  : () async {
                      if (cat.products.any((p) => p.category == c)) {
                        showMsg(context, 'Kategori masih dipakai produk');
                      } else if (await confirmDialog(context, 'Hapus kategori "$c"?', 'Kategori akan dihapus.')) {
                        n.deleteCategory(c);
                      }
                    },
            ),
        ]),
        if (_cat != 'Semua')
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(onPressed: () => context.push('/seller/categories/${Uri.encodeComponent(_cat)}/edit'), icon: const Icon(Icons.edit_outlined), label: const Text('Ubah Kategori')),
          ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('Daftar Produk', style: AppText.semi)),
          TextButton.icon(onPressed: () => context.push('/seller/products/new'), icon: const Icon(Icons.add), label: const Text('Tambah produk')),
        ]),
        if (items.isEmpty) const Padding(padding: EdgeInsets.all(30), child: EmptyState('Belum ada produk')),
        for (final p in items)
          AppCard(
            onTap: () => context.push('/seller/products/${p.id}'),
            child: Row(children: [
              ProductImage(asset: p.image, size: 56),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: AppText.body), Text('${p.category} | Stok ${p.stock}', style: AppText.small), Text(rupiah(p.startingPrice), style: AppText.semi)])),
              IconButton(tooltip: 'Ubah', icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/seller/products/${p.id}/edit')),
            ]),
          ),
      ]),
    );
  }
}

/// Detail produk penjual + hapus (Figma 1114:12754, 1114:12791, 2546:8986).
class SellerProductDetailScreen extends ConsumerWidget {
  const SellerProductDetailScreen({super.key, required this.productId});
  final String productId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(catalogProvider).byId(productId);
    if (p == null) return const AppScaffold(title: 'Produk', body: EmptyState('Produk tidak ditemukan'));
    return AppScaffold(
      title: p.name,
      body: ListView(padding: const EdgeInsets.all(20), children: [
        ClipRRect(borderRadius: BorderRadius.circular(28), child: SizedBox(height: 200, child: Image.asset(p.image, fit: BoxFit.cover, cacheWidth: 900))),
        const SizedBox(height: 12),
        Text(rupiah(p.startingPrice), style: AppText.price),
        Text('Kategori: ${p.category}  |  Rating ${p.rating}', style: AppText.small),
        const SizedBox(height: 8),
        Text(p.description, style: AppText.body),
        const SizedBox(height: 12),
        Text('Variasi', style: AppText.semi),
        for (final v in p.variations) AppCard(margin: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: Text(v.label, style: AppText.body)), Text('${rupiah(v.price)} | Stok ${v.stock}', style: AppText.small)])),
        const SizedBox(height: 12),
        Text('Penilaian & Ulasan (${p.reviews.length})', style: AppText.semi),
        for (final r in p.reviews) AppCard(color: AppColors.field, child: Row(children: [Expanded(child: Text('${r.author}: ${r.text}', style: AppText.small)), RatingStars(rating: r.rating.toDouble(), size: 12)])),
        const SizedBox(height: 12),
        PillButton(label: 'Ubah Produk', onPressed: () => context.push('/seller/products/${p.id}/edit')),
        const SizedBox(height: 10),
        PillButton(label: 'Atur Variasi', outlined: true, onPressed: () => context.push('/seller/products/${p.id}/variants')),
        const SizedBox(height: 10),
        PillButton(
          label: 'Hapus Produk',
          color: AppColors.danger,
          outlined: true,
          onPressed: () async {
            if (await confirmDialog(context, 'Hapus produk?', 'Produk "${p.name}" akan dihapus.', yes: 'Hapus')) {
              ref.read(catalogProvider.notifier).deleteProduct(p.id);
              if (context.mounted) context.pop();
            }
          },
        ),
      ]),
    );
  }
}

class _VarRow {
  _VarRow(Variation v)
      : id = v.id,
        weight = TextEditingController(text: v.weight),
        count = TextEditingController(text: '${v.count}'),
        price = TextEditingController(text: '${v.price}'),
        stock = TextEditingController(text: '${v.stock}');
  final String id;
  final TextEditingController weight, count, price, stock;
  void dispose() {
    weight.dispose();
    count.dispose();
    price.dispose();
    stock.dispose();
  }

  Variation toVariation() => Variation(id: id, weight: weight.text.trim(), count: int.parse(count.text.trim()), price: int.parse(price.text.trim()), stock: int.parse(stock.text.trim()));
}

/// Editor variasi (Figma "Atur variasi produk", "Variasi"): berat, isi, harga, stok.
class VariationsEditor extends StatefulWidget {
  const VariationsEditor({super.key, required this.initial, required this.controllerOut});
  final List<Variation> initial;
  final ValueNotifier<List<Variation> Function()?> controllerOut;
  @override
  State<VariationsEditor> createState() => _VariationsEditorState();
}

class _VariationsEditorState extends State<VariationsEditor> {
  late final List<_VarRow> _rows = [for (final v in widget.initial) _VarRow(v)];
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    widget.controllerOut.value = () => [for (final r in _rows) r.toVariation()];
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? num(String? v) => Validators.number(v);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final (i, r) in _rows.indexed)
        AppCard(
          color: AppColors.field,
          child: Column(children: [
            Row(children: [
              Expanded(child: TextFormField(controller: r.weight, key: Key('var-weight-$i'), validator: (v) => Validators.required(v, 'Berat'), decoration: const InputDecoration(labelText: 'Berat (mis. 1 Kg)'))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: r.count, key: Key('var-count-$i'), keyboardType: TextInputType.number, validator: num, decoration: const InputDecoration(labelText: 'Isi (ekor)'))),
            ]),
            Row(children: [
              Expanded(child: TextFormField(controller: r.price, key: Key('var-price-$i'), keyboardType: TextInputType.number, validator: num, decoration: const InputDecoration(labelText: 'Harga (Rp)'))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: r.stock, key: Key('var-stock-$i'), keyboardType: TextInputType.number, validator: num, decoration: const InputDecoration(labelText: 'Stok'))),
              IconButton(tooltip: 'Hapus variasi', icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: _rows.length <= 1 ? null : () => setState(() => _rows.removeAt(i).dispose())),
            ]),
          ]),
        ),
      TextButton.icon(
        onPressed: () => setState(() => _rows.add(_VarRow(Variation(id: 'new-${DateTime.now().microsecondsSinceEpoch}-${_seq++}', weight: '1 Kg', count: 2, price: 0, stock: 0)))),
        icon: const Icon(Icons.add),
        label: const Text('Tambah variasi'),
      ),
    ]);
  }
}

/// Tambah / ubah produk (Figma "Tambah produk dan atur variasi" 1114:13107, "Edit produk" 1114:13537).
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final String? productId;
  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _varOut = ValueNotifier<List<Variation> Function()?>(null);
  String? _category;
  String _image = _photoChoices.first;
  Product? _existing;
  late final List<Variation> _initialVars;

  @override
  void initState() {
    super.initState();
    _existing = widget.productId == null ? null : ref.read(catalogProvider).byId(widget.productId!);
    final e = _existing;
    if (e != null) {
      _name.text = e.name;
      _desc.text = e.description;
      _category = e.category;
      _image = e.image;
    }
    _initialVars = e?.variations ?? [const Variation(id: 'v-new-0', weight: '1 Kg', count: 2, price: 0, stock: 0)];
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _varOut.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    if (_category == null) {
      showMsg(context, 'Pilih kategori');
      return;
    }
    final vars = _varOut.value!();
    final id = _existing?.id ?? 'p-${DateTime.now().microsecondsSinceEpoch}';
    final base = _existing;
    final product = base == null
        ? Product(id: id, name: _name.text.trim(), description: _desc.text.trim(), category: _category!, image: _image, variations: vars, reviews: const [])
        : base.copyWith(name: _name.text.trim(), description: _desc.text.trim(), category: _category, image: _image, variations: vars);
    ref.read(catalogProvider.notifier).upsertProduct(product);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(catalogProvider).categories;
    return AppScaffold(
      title: _existing == null ? 'Tambah produk' : 'Ubah Produk',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Foto (pilih contoh)', style: AppText.semi.copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          SizedBox(
            height: 72,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final a in _photoChoices)
                GestureDetector(
                  onTap: () => setState(() => _image = a),
                  child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: a == _image ? AppColors.primary : Colors.transparent, width: 3)), child: ProductImage(asset: a, size: 60)),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          AppField(fieldKey: const Key('prod-name'), label: 'Nama', controller: _name, hint: 'Nama produk', validator: (v) => Validators.required(v, 'Nama')),
          AppField(label: 'Deskripsi', controller: _desc, hint: 'Deskripsi produk', maxLines: 3),
          Text('Kategori', style: AppText.semi.copyWith(fontSize: 14)),
          Wrap(spacing: 8, children: [for (final c in cats) ChoiceChip(label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = c))]),
          const SizedBox(height: 14),
          Text('Variasi', style: AppText.semi.copyWith(fontSize: 14)),
          VariationsEditor(initial: _initialVars, controllerOut: _varOut),
          const SizedBox(height: 10),
          PillButton(label: 'Simpan', onPressed: _save),
        ]),
      ),
    );
  }
}

/// Atur variasi produk (Figma 1114:12929, 3118:6992, 3801:6924).
class VariantsScreen extends ConsumerStatefulWidget {
  const VariantsScreen({super.key, required this.productId});
  final String productId;
  @override
  ConsumerState<VariantsScreen> createState() => _VariantsScreenState();
}

class _VariantsScreenState extends ConsumerState<VariantsScreen> {
  final _form = GlobalKey<FormState>();
  final _out = ValueNotifier<List<Variation> Function()?>(null);
  @override
  void dispose() {
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(catalogProvider).byId(widget.productId);
    if (p == null) return const AppScaffold(title: 'Variasi', body: EmptyState('Produk tidak ditemukan'));
    return AppScaffold(
      title: 'Variasi',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text(p.name, style: AppText.semi),
          VariationsEditor(initial: p.variations, controllerOut: _out),
          PillButton(
            label: 'Simpan',
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              ref.read(catalogProvider.notifier).upsertProduct(p.copyWith(variations: _out.value!()));
              context.pop();
            },
          ),
        ]),
      ),
    );
  }
}

/// Tambah kategori (Figma 3168:7137, 1114:14202). Foto kategori: placeholder.
/// Tambah kategori (Figma 3168:7137) dan ubah kategori (Figma 1114:14301) bila [editing] diisi.
class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key, this.editing});
  final String? editing;
  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.editing);
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.editing == null ? 'Tambah Kategori' : 'Ubah Kategori',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          AppField(
            fieldKey: const Key('cat-name'),
            label: 'Kategori',
            controller: _name,
            hint: 'Nama kategori',
            validator: (v) {
              final r = Validators.required(v, 'Nama kategori');
              if (r != null) return r;
              final n = v!.trim();
              return n != widget.editing && ref.read(catalogProvider).categories.contains(n) ? 'Kategori sudah ada' : null;
            },
          ),
          Text('Gambar Kategori*', style: AppText.semi.copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          InkWell(onTap: () => showMsg(context, 'Unggah foto belum tersedia (placeholder)'), child: Container(height: 90, decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('Tambah foto (placeholder)')))),
          const SizedBox(height: 20),
          PillButton(
            label: widget.editing == null ? 'Tambah Kategori' : 'Simpan Perubahan',
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              final old = widget.editing;
              if (old == null) {
                ref.read(catalogProvider.notifier).addCategory(_name.text);
              } else {
                ref.read(catalogProvider.notifier).renameCategory(old, _name.text);
              }
              context.canPop() ? context.pop() : context.go('/seller/products');
            },
          ),
        ]),
      ),
    );
  }
}

/// Diskon per produk (Figma 2583:10861).
class DiscountScreen extends ConsumerStatefulWidget {
  const DiscountScreen({super.key});
  @override
  ConsumerState<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends ConsumerState<DiscountScreen> {
  final Map<String, TextEditingController> _c = {};
  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(catalogProvider).products;
    for (final p in products) {
      _c.putIfAbsent(p.id, () => TextEditingController(text: '${p.discountPercent}'));
    }
    return AppScaffold(
      title: 'Diskon',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (final p in products)
          AppCard(child: Row(children: [
            ProductImage(asset: p.image, size: 46),
            const SizedBox(width: 12),
            Expanded(child: Text(p.name, style: AppText.body)),
            SizedBox(width: 80, child: TextField(key: Key('disc-${p.id}'), controller: _c[p.id], keyboardType: TextInputType.number, decoration: const InputDecoration(suffixText: '%', isDense: true))),
          ])),
        PillButton(
          label: 'Simpan',
          onPressed: () {
            final n = ref.read(catalogProvider.notifier);
            for (final p in products) {
              final v = int.tryParse(_c[p.id]!.text.trim()) ?? 0;
              if (v != p.discountPercent) n.setDiscount(p.id, v);
            }
            showMsg(context, 'Diskon disimpan');
          },
        ),
      ]),
    );
  }
}
