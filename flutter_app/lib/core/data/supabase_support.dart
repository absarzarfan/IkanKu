import 'package:ikanku/core/errors/app_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

final _uuidRe = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

bool isUuid(String s) => _uuidRe.hasMatch(s);

/// Membungkus panggilan jaringan: semua galat menjadi [AppError] berpesan Indonesia.
Future<T> guarded<T>(Future<T> Function() f) async {
  try {
    return await f();
  } catch (e) {
    throw mapError(e);
  }
}

/// Membuang karakter yang memiliki arti khusus pada filter PostgREST (ilike/or).
String safeQuery(String q) => q.trim().replaceAll(RegExp(r'[%,()*\\]'), ' ');

String requireUid(sb.SupabaseClient c) {
  final id = c.auth.currentUser?.id;
  if (id == null) throw const AppError.auth('Sesi berakhir. Silakan masuk kembali.');
  return id;
}
