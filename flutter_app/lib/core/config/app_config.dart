/// Konfigurasi dari `--dart-define-from-file=dart_defines.json` (berkas tidak masuk git).
/// Hanya kunci publik (anon). Kunci rahasia server (service role) tidak boleh dipakai di aplikasi.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True hanya bila kedua nilai terisi; selain itu aplikasi memakai repository mock.
  static bool get useSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
