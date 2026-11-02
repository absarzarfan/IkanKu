import 'package:ikanku/core/data/mappers.dart';
import 'package:ikanku/core/errors/app_error.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Autentikasi Supabase (email + kata sandi). Semua galat diubah menjadi [AuthException] berpesan Indonesia
/// agar layar yang sudah ada tidak berubah.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final sb.SupabaseClient _client;
  AppUser? _initial;

  @override
  AppUser? get initialUser => _initial;

  Future<T> _wrap<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(mapError(e).message);
    }
  }

  Future<AppUser> _profile(String id) async {
    final row = await _client.from('profiles').select().eq('id', id).single();
    return userFromRow(row);
  }

  Future<AppUser> _activeProfile(String id) async {
    final u = await _profile(id);
    if (!u.isActive) {
      await _client.auth.signOut();
      throw AuthException('Akun Anda dinonaktifkan. Hubungi admin.');
    }
    return u;
  }

  /// Memulihkan sesi tersimpan. Gagal (offline/kedaluwarsa) berarti tampil login, bukan masuk otomatis.
  @override
  Future<void> restoreSession() async {
    final s = _client.auth.currentSession;
    if (s == null) return;
    try {
      final u = await _profile(s.user.id);
      if (u.isActive) {
        _initial = u;
      } else {
        await _client.auth.signOut();
      }
    } catch (_) {
      _initial = null;
    }
  }

  @override
  Future<AppUser> login(String identifier, String password) async {
    final email = identifier.trim();
    if (!email.contains('@')) throw AuthException('Masuk dengan alamat email.');
    return _wrap(() async {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      return _activeProfile(res.user!.id);
    });
  }

  @override
  Future<AppUser> register({required String name, required String phone, required String password, String? email}) async {
    final mail = (email ?? '').trim();
    if (mail.isEmpty) throw AuthException('Email wajib diisi.');
    return _wrap(() async {
      final res = await _client.auth.signUp(email: mail, password: password, data: {'full_name': name, 'phone': phone});
      if (res.session == null) throw AuthException('Pendaftaran berhasil. Periksa email Anda untuk konfirmasi, lalu masuk.');
      return _activeProfile(res.user!.id);
    });
  }

  @override
  Future<void> requestPasswordReset(String email) => _wrap(() => _client.auth.resetPasswordForEmail(email.trim()));

  /// Mode Supabase tidak memakai OTP SMS (lihat docs/decisions.md); langkah OTP selalu lolos.
  @override
  Future<bool> verifyOtp(String phone, String code) async => true;

  @override
  Future<void> changePassword(String userId, String oldPassword, String newPassword) => _wrap(() async {
        final email = _client.auth.currentUser?.email;
        if (email == null) throw AuthException('Sesi berakhir. Silakan masuk kembali.');
        try {
          await _client.auth.signInWithPassword(email: email, password: oldPassword);
        } on sb.AuthException {
          throw AuthException('Kata sandi lama salah');
        }
        await _client.auth.updateUser(sb.UserAttributes(password: newPassword));
      });

  @override
  Future<void> logout() => _client.auth.signOut();
}
