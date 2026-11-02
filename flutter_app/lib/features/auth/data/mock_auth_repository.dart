import 'package:ikanku/core/config/app_config.dart';
import 'package:ikanku/features/auth/domain/auth.dart';

/// Autentikasi in-memory. Akun demo (bukan rahasia, hanya data mock):
/// pembeli: 6285274088734 atau fharaa@gmail.com / Admin123
/// penjual: 6281266680075 atau penjual@ikanku.id / Admin123
/// admin: admin@ikanku.id / Admin123 (panel admin mode mock memakai MockAdminRemote)
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _accounts.addAll([
      _Account(demoBuyer, 'Admin123'),
      _Account(const AppUser(id: 's1', name: 'Anna', email: 'penjual@ikanku.id', phone: '6281266680075', role: UserRole.seller), 'Admin123'),
      _Account(const AppUser(id: 'a1', name: 'Admin', email: 'admin@ikanku.id', phone: '6280000000000', role: UserRole.admin), 'Admin123'),
      _Account(const AppUser(id: 'b2', name: 'Rina Putri', email: 'rina@ikanku.id', phone: '6281211110001', role: UserRole.buyer), 'Admin123'),
      _Account(const AppUser(id: 'b3', name: 'Dedi Kurniawan', email: 'dedi@ikanku.id', phone: '6281211110002', role: UserRole.buyer), 'Admin123'),
      _Account(const AppUser(id: 's2', name: 'Budi', email: 'budi.mina@ikanku.id', phone: '6281211110003', role: UserRole.seller), 'Admin123'),
    ]);
  }

  /// Akun pembeli demo; aplikasi dibuka langsung sebagai akun ini (backend masih mock).
  static const demoBuyer = AppUser(id: 'b1', name: 'Miftahul Fazra', email: 'fharaa@gmail.com', phone: '6285274088734', role: UserRole.buyer);

  /// Hanya kelas mock ini yang membaca `MOCK_AUTOLOGIN_ROLE` (buyer|seller|admin); tidak ada di jalur Supabase.
  /// Dipakai untuk pemeriksaan visual tanpa login: `--dart-define=MOCK_AUTOLOGIN_ROLE=seller`.
  static const _autologinRole = String.fromEnvironment('MOCK_AUTOLOGIN_ROLE');

  @override
  AppUser? get initialUser {
    if (AppConfig.useSupabase || _autologinRole.isEmpty) return demoBuyer;
    for (final a in _accounts) {
      if (a.user.role.name == _autologinRole) return a.user;
    }
    return demoBuyer;
  }

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> logout() async {}

  final List<_Account> _accounts = [];
  static const validOtp = '1234';

  @override
  Future<AppUser> login(String identifier, String password) async {
    final id = identifier.trim().toLowerCase();
    for (final a in _accounts) {
      if ((a.user.email.toLowerCase() == id || a.user.phone == id) && a.password == password) {
        if (!a.user.isActive) throw AuthException('Akun ini sedang dinonaktifkan. Silakan hubungi admin IkanKu.');
        return a.user;
      }
    }
    throw AuthException('Nomor/email atau kata sandi salah');
  }

  @override
  Future<AppUser> register({required String name, required String phone, required String password, String? email}) async {
    if (_accounts.any((a) => a.user.phone == phone)) throw AuthException('Nomor ponsel sudah terdaftar');
    final u = AppUser(id: 'b${_accounts.length + 1}', name: name, email: email ?? '', phone: phone, role: UserRole.buyer);
    _accounts.add(_Account(u, password));
    return u;
  }

  /// Daftar pengguna untuk panel admin mock (cari nama/email).
  List<AppUser> allUsers({String? query}) {
    final q = (query ?? '').trim().toLowerCase();
    return [for (final a in _accounts) if (q.isEmpty || a.user.name.toLowerCase().contains(q) || a.user.email.toLowerCase().contains(q)) a.user];
  }

  void setActive(String userId, bool active) {
    final i = _accounts.indexWhere((a) => a.user.id == userId);
    if (i >= 0) _accounts[i] = _Account(_accounts[i].user.copyWith(isActive: active), _accounts[i].password);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    if (!_accounts.any((a) => a.user.email.toLowerCase() == email.trim().toLowerCase())) {
      throw AuthException('Email tidak terdaftar');
    }
  }

  @override
  Future<bool> verifyOtp(String phone, String code) async => code == validOtp;

  @override
  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {
    final i = _accounts.indexWhere((a) => a.user.id == userId);
    if (i < 0 || _accounts[i].password != oldPassword) throw AuthException('Kata sandi lama salah');
    _accounts[i] = _Account(_accounts[i].user, newPassword);
  }
}

class _Account {
  _Account(this.user, this.password);
  final AppUser user;
  final String password;
}
