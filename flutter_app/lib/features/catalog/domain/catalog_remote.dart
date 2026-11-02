import 'dart:typed_data';

import 'package:ikanku/features/catalog/domain/catalog.dart';

/// Kontrak katalog asinkron (backend nyata). Implementasi: Supabase dan in-memory (untuk tes kontrak).
abstract class CatalogRemote {
  /// Produk aktif; [query] mencari nama, [category] memfilter kategori ('Semua'/null = semua).
  /// [mine] = hanya produk toko penjual yang login (termasuk yang nonaktif).
  Future<List<Product>> listProducts({String? query, String? category, bool mine = false});
  Future<Product?> getProduct(String id);
  Future<List<String>> categories();

  /// Penjual: simpan produk tokonya (id baru bila belum ada di backend); variasi diganti sesuai [p].
  Future<Product> saveProduct(Product p);
  Future<void> deleteProduct(String id);
  Future<void> addCategory(String name);

  /// Mengunggah gambar ke bucket product-images di folder pengguna; mengembalikan URL publik.
  Future<String> uploadProductImage(Uint8List bytes, {required String extension});
}
