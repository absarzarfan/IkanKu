enum UserRole { buyer, seller, admin }

class AppUser {
  const AppUser({required this.id, required this.name, required this.email, required this.phone, required this.role, this.isActive = true});
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final bool isActive;

  AppUser copyWith({String? name, String? email, String? phone, bool? isActive}) =>
      AppUser(id: id, name: name ?? this.name, email: email ?? this.email, phone: phone ?? this.phone, role: role, isActive: isActive ?? this.isActive);
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Kontrak autentikasi. Implementasi mock: [MockAuthRepository].
/// Backend nyata (REST/Firebase) cukup mengimplementasikan kelas ini.
abstract class AuthRepository {
  /// Pengguna saat aplikasi dibuka (sesi tersimpan); null = belum login. Backend nyata: pulihkan sesi di sini.
  AppUser? get initialUser => null;

  /// Memulihkan sesi tersimpan saat startup (backend nyata). Mock: tidak melakukan apa pun.
  Future<void> restoreSession() async {}

  /// Mengakhiri sesi di backend.
  Future<void> logout() async {}

  /// [identifier] boleh nomor ponsel atau email.
  Future<AppUser> login(String identifier, String password);
  Future<AppUser> register({required String name, required String phone, required String password, String? email});
  Future<void> requestPasswordReset(String email);
  Future<bool> verifyOtp(String phone, String code);
  Future<void> changePassword(String userId, String oldPassword, String newPassword);
}
