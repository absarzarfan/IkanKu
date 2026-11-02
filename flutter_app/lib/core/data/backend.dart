import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/config/app_config.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/admin/data/supabase_admin_remote.dart';
import 'package:ikanku/features/admin/domain/admin.dart';
import 'package:ikanku/features/catalog/data/supabase_catalog_remote.dart';
import 'package:ikanku/features/catalog/domain/catalog_remote.dart';
import 'package:ikanku/features/orders/data/supabase_order_remote.dart';
import 'package:ikanku/features/orders/domain/orders_remote.dart';
import 'package:ikanku/features/profile/data/supabase_profile_remote.dart';
import 'package:ikanku/features/profile/domain/profile_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Remote bernilai null pada mode mock (tanpa kunci); UI lalu memakai repository in-memory seperti sebelumnya.
/// Tes menimpa provider ini dengan implementasi in-memory.
sb.SupabaseClient? _client() => AppConfig.useSupabase ? sb.Supabase.instance.client : null;

final catalogRemoteProvider = Provider<CatalogRemote?>((ref) {
  final c = _client();
  return c == null ? null : SupabaseCatalogRemote(c);
});

final orderRemoteProvider = Provider<OrderRemote?>((ref) {
  final c = _client();
  return c == null ? null : SupabaseOrderRemote(c);
});

final cartRemoteProvider = Provider<CartRemote?>((ref) {
  final c = _client();
  return c == null ? null : SupabaseCartRemote(c);
});

final profileRemoteProvider = Provider<ProfileRemote?>((ref) {
  final c = _client();
  return c == null ? null : SupabaseProfileRemote(c);
});

final adminRemoteProvider = Provider<AdminRemote?>((ref) {
  final c = _client();
  return c == null ? null : SupabaseAdminRemote(c);
});

/// Pesan galat backend terakhir (Indonesia); ditampilkan sebagai SnackBar oleh root aplikasi.
class BackendErrorNotifier extends Notifier<AppError?> {
  @override
  AppError? build() => null;
  void report(Object e) => state = mapError(e);
  void clear() => state = null;
}

final backendErrorProvider = NotifierProvider<BackendErrorNotifier, AppError?>(BackendErrorNotifier.new);
