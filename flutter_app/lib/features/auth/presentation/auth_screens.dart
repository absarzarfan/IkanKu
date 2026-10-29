import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:ikanku/features/profile/presentation/profile_providers.dart';

/// Kotak biru dengan logo dan tab Login | Daftar (Figma "Login" 30:7).
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.tab, required this.child, this.showTabs = true, this.onBack});
  final int tab;
  final Widget child;
  final bool showTabs;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: showTabs ? 0 : 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 30)],
              ),
              child: Column(children: [
                if (onBack != null)
                  Align(alignment: Alignment.centerLeft, child: IconButton(tooltip: 'Kembali', icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onBack)),
                Image.asset('assets/images/logo.png', width: 196, height: 97, fit: BoxFit.contain),
                if (showTabs) ...[
                  const SizedBox(height: 40),
                  Row(children: [
                    Expanded(child: _Tab('Login', tab == 0, () => context.go('/login'))),
                    Expanded(child: _Tab('Daftar', tab == 1, () => context.go('/register'))),
                  ]),
                ],
              ]),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(21, 24, 21, 32), child: child),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.label, this.active, this.onTap);
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(children: [
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
            Container(height: 3, width: 134, margin: const EdgeInsets.only(bottom: 4), decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(40))),
          ]),
        ),
      );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _show = false;
  bool _busy = false;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).login(_id.text, _pw.text);
      // Redirect router mengarahkan ke beranda sesuai peran.
    } on AuthException catch (e) {
      if (mounted) showMsg(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      tab: 0,
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(fieldKey: const Key('login-id'), controller: _id, hint: 'Nomor Ponsel Ex 6282387436427 atau email', keyboard: TextInputType.emailAddress, validator: (v) => Validators.required(v, 'Nomor ponsel/email')),
          AppField(
            fieldKey: const Key('login-pw'),
            controller: _pw,
            hint: 'Kata sandi',
            obscure: !_show,
            validator: Validators.password,
            suffix: IconButton(tooltip: 'Tampilkan kata sandi', icon: Icon(_show ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _show = !_show)),
          ),
          InkWell(onTap: () => context.push('/forgot'), child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('Lupa kata sandi', style: AppText.semi.copyWith(fontSize: 14, color: AppColors.navy)))),
          const SizedBox(height: 24),
          PillButton(label: _busy ? 'Memproses...' : 'Login', height: 56, onPressed: _busy ? null : _submit),
          const SizedBox(height: 16),
          Center(child: Text('Atau', style: AppText.semi.copyWith(fontSize: 18, color: AppColors.navy))),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), side: const BorderSide(color: AppColors.greyLight)),
            onPressed: () => showMsg(context, 'Login dengan Google belum tersedia (backend belum ditentukan)'),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('G', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.primary)),
              SizedBox(width: 12),
              Flexible(child: Text('Login dengan google', overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Color(0x8A000000)))),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Demo: pembeli fharaa@gmail.com, penjual penjual@ikanku.id, kata sandi Admin123', style: TextStyle(fontSize: 11, color: AppColors.grey)),
        ]),
      ),
    );
  }
}

/// Registrasi langkah 1: nomor ponsel (Figma "Sign in 1").
class RegisterPhoneScreen extends ConsumerStatefulWidget {
  const RegisterPhoneScreen({super.key});
  @override
  ConsumerState<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends ConsumerState<RegisterPhoneScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      tab: 1,
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Masukkan Nomor Ponsel', style: AppText.semi.copyWith(fontSize: 18)),
          const SizedBox(height: 14),
          AppField(fieldKey: const Key('reg-phone'), controller: _phone, hint: 'Nomor Ponsel Ex 6282387436427', keyboard: TextInputType.phone, validator: Validators.phone),
          const SizedBox(height: 16),
          PillButton(
            label: 'Lanjut',
            height: 56,
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              ref.read(registrationProvider.notifier).setPhone(_phone.text.trim());
              context.push('/register/otp');
            },
          ),
        ]),
      ),
    );
  }
}

/// Registrasi langkah 2: OTP 4 digit (Figma "Sign in 2/10"). Kode demo: 1234.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.title = 'Konfirmasi', this.onVerified, this.phone});
  final String title;
  final VoidCallback? onVerified;
  final String? phone;
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.text.length != 4) {
      setState(() => _error = 'Masukkan 4 digit kode');
      return;
    }
    final ok = await ref.read(authRepositoryProvider).verifyOtp(widget.phone ?? ref.read(registrationProvider).phone, _code.text);
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = 'Kode salah. Gunakan 1234 (demo).');
      return;
    }
    if (widget.onVerified != null) {
      widget.onVerified!();
    } else {
      await ref.read(registrationProvider.notifier).verify(_code.text);
      if (mounted) context.push('/register/data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone ?? ref.watch(registrationProvider).phone;
    return AuthShell(
      tab: 1,
      showTabs: false,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.title, style: AppText.semi.copyWith(fontSize: 18)),
        const SizedBox(height: 6),
        Text('Kode 4 digit dikirim ke $phone (mock: 1234)', style: AppText.body.copyWith(fontSize: 13, color: AppColors.grey)),
        const SizedBox(height: 14),
        TextField(
          key: const Key('otp-field'),
          controller: _code,
          maxLength: 4,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, letterSpacing: 16, fontFamily: 'Nunito'),
          decoration: InputDecoration(counterText: '', errorText: _error, filled: true, fillColor: AppColors.field, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 20),
        PillButton(label: 'Lanjut', height: 56, onPressed: _verify),
      ]),
    );
  }
}

/// Registrasi langkah 3: Lengkapi Data (Figma "Daftar" 1769:8280).
class RegisterDataScreen extends ConsumerStatefulWidget {
  const RegisterDataScreen({super.key});
  @override
  ConsumerState<RegisterDataScreen> createState() => _RegisterDataScreenState();
}

class _RegisterDataScreenState extends ConsumerState<RegisterDataScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _area = TextEditingController();
  final _street = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _pw, _area, _street]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickArea() async {
    await context.push('/pick-kecamatan');
    final k = ref.read(pickedKecamatanProvider);
    if (k != null) _area.text = k.toString();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final k = ref.read(pickedKecamatanProvider);
    final phone = ref.read(registrationProvider).phone;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).register(name: _name.text.trim(), phone: phone, password: _pw.text, email: _email.text.trim());
      if (k != null) {
        ref.read(addressProvider.notifier).add(Address(id: 'a${DateTime.now().microsecondsSinceEpoch}', recipient: _name.text.trim(), phone: phone, street: _street.text.trim(), area: k, isPrimary: true));
      }
      ref.read(pickedKecamatanProvider.notifier).pick(null);
    } on AuthException catch (e) {
      if (mounted) showMsg(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(registrationProvider).phone;
    return AuthShell(
      tab: 1,
      showTabs: false,
      onBack: () => Navigator.of(context).maybePop(),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Lengkapi Data', style: AppText.semi.copyWith(fontSize: 18)),
          const SizedBox(height: 14),
          AppField(fieldKey: const Key('reg-name'), controller: _name, hint: 'Nama lengkap', validator: (v) => Validators.required(v, 'Nama lengkap')),
          AppField(controller: TextEditingController(text: phone), hint: 'Nomor Ponsel', readOnly: true),
          AppField(fieldKey: const Key('reg-email'), controller: _email, hint: 'Email', keyboard: TextInputType.emailAddress, validator: Validators.email),
          AppField(fieldKey: const Key('reg-pw'), controller: _pw, hint: 'Kata sandi (min. 6 karakter)', obscure: true, validator: Validators.password),
          AppField(controller: _area, hint: 'Kota, Kecamatan, Kode Pos', readOnly: true, onTap: _pickArea, suffix: const Icon(Icons.chevron_right), validator: (v) => Validators.required(v, 'Kecamatan')),
          AppField(controller: _street, hint: 'Nama Jalan, Gedung, No. Rumah', validator: (v) => Validators.required(v, 'Alamat')),
          const SizedBox(height: 8),
          PillButton(label: _busy ? 'Memproses...' : 'Lengkapi Data', height: 56, onPressed: _busy ? null : _submit),
        ]),
      ),
    );
  }
}

/// Lupa kata sandi (Figma 108:415).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (e) {
      if (mounted) showMsg(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      tab: 0,
      showTabs: false,
      onBack: () => Navigator.of(context).maybePop(),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Lupa Kata sandi?', style: AppText.semi.copyWith(fontSize: 18)),
          const SizedBox(height: 6),
          Text('Masukkan alamat email anda', style: AppText.body.copyWith(color: AppColors.grey)),
          const SizedBox(height: 14),
          AppField(fieldKey: const Key('forgot-email'), controller: _email, hint: 'Email', keyboard: TextInputType.emailAddress, validator: Validators.email),
          if (_sent) Padding(padding: const EdgeInsets.only(bottom: 14), child: Text('Tautan reset telah dikirim (simulasi) ke ${_email.text.trim()}.', key: const Key('forgot-sent'), style: AppText.body.copyWith(color: AppColors.success))),
          PillButton(label: 'Lanjut', height: 56, onPressed: _submit),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Kembali ke Login')),
        ]),
      ),
    );
  }
}
