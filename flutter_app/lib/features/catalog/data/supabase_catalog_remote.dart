import 'dart:typed_data';

import 'package:ikanku/core/data/mappers.dart';
import 'package:ikanku/core/data/supabase_support.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/catalog/domain/catalog.dart';
import 'package:ikanku/features/catalog/domain/catalog_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

const _select = '*, categories(name), shops(name), product_variants(*), reviews(rating, comment, reviewer_name)';
const _bucket = 'product-images';

class SupabaseCatalogRemote implements CatalogRemote {
  SupabaseCatalogRemote(this._db);
  final sb.SupabaseClient _db;

  @override
  Future<List<Product>> listProducts({String? query, String? category, bool mine = false}) => guarded(() async {
        final hasCat = category != null && category != 'Semua';
        var q = _db.from('products').select(hasCat ? _select.replaceFirst('categories(name)', 'categories!inner(name)') : _select);
        if (mine) {
          final shop = await _db.from('shops').select('id').eq('owner_id', requireUid(_db)).maybeSingle();
          if (shop == null) return <Product>[];
          q = q.eq('shop_id', shop['id'] as String);
        } else {
          q = q.eq('is_active', true);
        }
        if (hasCat) q = q.eq('categories.name', category);
        final text = safeQuery(query ?? '');
        if (text.isNotEmpty) q = q.ilike('name', '%$text%');
        final rows = await q.order('created_at', ascending: false).limit(200);
        return rows.map(productFromRow).toList();
      });

  @override
  Future<Product?> getProduct(String id) => guarded(() async {
        if (!isUuid(id)) return null;
        final row = await _db.from('products').select(_select).eq('id', id).maybeSingle();
        return row == null ? null : productFromRow(row);
      });

  @override
  Future<List<String>> categories() => guarded(() async {
        final rows = await _db.from('categories').select('name').order('name');
        return [for (final r in rows) r['name'] as String];
      });

  @override
  Future<void> addCategory(String name) => guarded(() async {
        final n = name.trim();
        if (n.isEmpty) throw const AppError.validation('Nama kategori wajib diisi.');
        await _db.from('categories').upsert({'name': n}, onConflict: 'name', ignoreDuplicates: true);
      });

  @override
  Future<Product> saveProduct(Product p) => guarded(() async {
        final uid = requireUid(_db);
        final shop = await _db.from('shops').select('id').eq('owner_id', uid).maybeSingle();
        if (shop == null) throw const AppError.permission('Anda belum memiliki toko.');
        String? categoryId;
        if (p.category.isNotEmpty) {
          final c = await _db.from('categories').select('id').eq('name', p.category).maybeSingle();
          categoryId = c?['id'] as String?;
        }
        final row = productToRow(p, shopId: shop['id'] as String, categoryId: categoryId);
        late final String productId;
        if (isUuid(p.id)) {
          row.remove('shop_id');
          await _db.from('products').update(row).eq('id', p.id);
          productId = p.id;
        } else {
          final created = await _db.from('products').insert(row).select('id').single();
          productId = created['id'] as String;
        }
        final existing = await _db.from('product_variants').select('id').eq('product_id', productId);
        final keep = <String>{};
        for (final v in p.variations) {
          if (isUuid(v.id) && existing.any((e) => e['id'] == v.id)) {
            await _db.from('product_variants').update(variationToRow(v, productId)..remove('product_id')).eq('id', v.id);
            keep.add(v.id);
          } else {
            final c = await _db.from('product_variants').insert(variationToRow(v, productId)).select('id').single();
            keep.add(c['id'] as String);
          }
        }
        for (final e in existing) {
          if (!keep.contains(e['id'])) await _db.from('product_variants').delete().eq('id', e['id'] as String);
        }
        final saved = await getProduct(productId);
        return saved ?? p;
      });

  @override
  Future<void> deleteProduct(String id) => guarded(() async {
        if (isUuid(id)) await _db.from('products').delete().eq('id', id);
      });

  @override
  Future<String> uploadProductImage(Uint8List bytes, {required String extension}) => guarded(() async {
        final ext = extension.toLowerCase().replaceAll('.', '');
        const types = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'webp': 'image/webp'};
        final type = types[ext];
        if (type == null) throw const AppError.validation('Format gambar harus JPG, PNG, atau WebP.');
        if (bytes.length > 2 * 1024 * 1024) throw const AppError.validation('Ukuran gambar maksimal 2 MB.');
        final path = '${requireUid(_db)}/${DateTime.now().microsecondsSinceEpoch}.$ext';
        await _db.storage.from(_bucket).uploadBinary(path, bytes, fileOptions: sb.FileOptions(contentType: type, upsert: false));
        return _db.storage.from(_bucket).getPublicUrl(path);
      });
}
