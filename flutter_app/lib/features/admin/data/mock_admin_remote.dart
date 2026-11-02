import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/features/admin/domain/admin.dart';
import 'package:ikanku/features/auth/data/mock_auth_repository.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/catalog/presentation/catalog_providers.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';

/// Admin mode mock: pengguna dari [MockAuthRepository], pesanan dari data pesanan mock, produk dari katalog mock.
/// Menonaktifkan pengguna membuatnya tidak bisa login; menonaktifkan produk menyembunyikannya dari katalog.
class MockAdminRemote implements AdminRemote {
  MockAdminRemote(this._ref);
  final Ref _ref;

  MockAuthRepository? get _auth {
    final r = _ref.read(authRepositoryProvider);
    return r is MockAuthRepository ? r : null;
  }

  @override
  Future<List<AppUser>> users({String? query}) async => _auth?.allUsers(query: query) ?? const [];

  @override
  Future<void> setUserActive(String userId, bool active) async => _auth?.setActive(userId, active);

  @override
  Future<List<AdminOrder>> orders() async => [
        for (final o in _ref.read(ordersProvider))
          AdminOrder(
            code: o.id,
            status: o.status.label,
            buyerName: o.buyerName,
            shopName: o.lines.first.product.sellerName,
            total: o.total,
            payment: o.payment == PaymentMethod.transfer ? 'Transfer' : 'COD',
          ),
      ];

  @override
  Future<List<AdminProduct>> products({String? query}) async {
    final q = (query ?? '').trim().toLowerCase();
    final hidden = _ref.read(inactiveProductsProvider);
    return [
      for (final p in _ref.read(catalogRepositoryProvider).products())
        if (q.isEmpty || p.name.toLowerCase().contains(q)) AdminProduct(id: p.id, name: p.name, shopName: p.sellerName, isActive: !hidden.contains(p.id)),
    ];
  }

  @override
  Future<void> setProductActive(String productId, bool active) async => _ref.read(inactiveProductsProvider.notifier).setActive(productId, active);
}
