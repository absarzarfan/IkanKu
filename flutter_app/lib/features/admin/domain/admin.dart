import 'package:ikanku/features/auth/domain/auth.dart';

class AdminProduct {
  const AdminProduct({required this.id, required this.name, required this.shopName, required this.isActive});
  final String id;
  final String name;
  final String shopName;
  final bool isActive;
}

/// Ringkasan pesanan untuk admin (hanya baca).
class AdminOrder {
  const AdminOrder({required this.code, required this.status, required this.buyerName, required this.shopName, required this.total, required this.payment});
  final String code;
  final String status;
  final String buyerName;
  final String shopName;
  final int total;
  final String payment;
}

abstract class AdminRemote {
  Future<List<AppUser>> users({String? query});
  Future<void> setUserActive(String userId, bool active);
  Future<List<AdminOrder>> orders();
  Future<List<AdminProduct>> products({String? query});
  Future<void> setProductActive(String productId, bool active);
}
