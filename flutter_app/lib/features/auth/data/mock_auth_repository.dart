import 'package:ikanku/features/auth/domain/auth.dart';

/// Autentikasi in-memory. Akun demo (bukan rahasia, hanya data mock):
/// pembeli: 6285274088734 atau fharaa@gmail.com / Admin123
/// penjual: 6281266680075 atau penjual@ikanku.id / Admin123
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _accounts.addAll([
      _Account(demoBuyer, 'Admin123'),
      _Account(const AppUser(id: 's1', name: 'Anna', email: 'penjual@ikanku.id', phone: '6281266680075', role: UserRole.seller), 'Admin123'),
    ]);
  }

  /// Akun pembeli demo; aplikasi dibuka langsung sebagai akun ini (backend masih mock).
  static const demoBuyer = AppUser(id: 'b1', name: 'Miftahul Fazra', email: 'fharaa@gmail.com', phone: '6285274088734', role: UserRole.buyer);

  @override
  AppUser? get initialUser => demoBuyer;

  final List<_Account> _accounts = [];
  static const validOtp = '1234';

  @override
  Future<AppUser> login(String identifier, String password) async {
    final id = identifier.trim().toLowerCase();
    for (final a in _accounts) {
      if ((a.user.email.toLowerCase() == id || a.user.phone == id) && a.password == password) return a.user;
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
