import 'package:flutter/material.dart';
import 'package:ikanku/features/catalog/presentation/product_browser.dart';

/// Telusuri: pencarian tersemat, filter, urutan, grid/daftar; kategori + rekomendasi saat belum mencari.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => const ProductBrowser(title: 'Telusuri', discovery: true, tabIndex: 1);
}
