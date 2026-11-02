import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/data/backend.dart';
import 'package:ikanku/features/auth/data/mock_auth_repository.dart';
import 'package:ikanku/features/auth/domain/auth.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());

/// State: pengguna yang login (null = belum login).
class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => ref.read(authRepositoryProvider).initialUser;

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> login(String identifier, String password) async {
    state = await _repo.login(identifier, password);
  }

  Future<void> register({required String name, required String phone, required String password, String? email}) async {
    state = await _repo.register(name: name, phone: phone, password: password, email: email);
  }

  /// Keluar langsung (UI tidak menunggu); sesi di backend diakhiri di latar belakang.
  void logout() {
    state = null;
    _repo.logout().catchError((Object _) {});
  }

  /// Nama/telepon disimpan ke backend bila aktif (email diubah lewat alur auth, belum dibuat: lokal saja).
  void updateProfile({String? name, String? email, String? phone}) {
    final u = state;
    if (u == null) return;
    state = u.copyWith(name: name, email: email, phone: phone);
    final remote = ref.read(profileRemoteProvider);
    if (remote != null && (name != null || phone != null)) {
      remote.updateProfile(name: name, phone: phone).catchError((Object e) {
        ref.read(backendErrorProvider.notifier).report(e);
        return u;
      });
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final u = state;
    if (u == null) throw AuthException('Belum login');
    await _repo.changePassword(u.id, oldPassword, newPassword);
  }
}

final authProvider = NotifierProvider<AuthController, AppUser?>(AuthController.new);

/// Data sementara alur registrasi (nomor -> OTP -> data diri).
class RegistrationDraft {
  const RegistrationDraft({this.phone = '', this.verified = false});
  final String phone;
  final bool verified;
}

class RegistrationController extends Notifier<RegistrationDraft> {
  @override
  RegistrationDraft build() => const RegistrationDraft();

  void setPhone(String phone) => state = RegistrationDraft(phone: phone);

  Future<bool> verify(String code) async {
    final ok = await ref.read(authRepositoryProvider).verifyOtp(state.phone, code);
    if (ok) state = RegistrationDraft(phone: state.phone, verified: true);
    return ok;
  }
}

final registrationProvider = NotifierProvider<RegistrationController, RegistrationDraft>(RegistrationController.new);
