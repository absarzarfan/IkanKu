import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/auth/presentation/auth_screens.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:ikanku/features/profile/presentation/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    Widget tile(IconData icon, String label, String route) => AppCard(margin: const EdgeInsets.only(bottom: 10), onTap: () => context.push(route), child: Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 14), Expanded(child: Text(label, style: AppText.body)), const Icon(Icons.chevron_right)]));
    return AppScaffold(
      title: 'Profil',
      showBack: false,
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          const CircleAvatar(radius: 36, backgroundColor: AppColors.field, child: Icon(Icons.person, size: 40, color: AppColors.grey)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.name ?? '-', style: AppText.semi.copyWith(fontSize: 18)), Text(user?.email ?? '', style: AppText.small), Text(user?.phone ?? '', style: AppText.small)])),
        ]),
        const SizedBox(height: 20),
        Text('Pesanan Saya', style: AppText.semi),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (final (i, e) in [(Icons.account_balance_wallet_outlined, 'Belum Bayar'), (Icons.inventory_2_outlined, 'Dikemas'), (Icons.local_shipping_outlined, 'Dikirim'), (Icons.check_circle_outline, 'Selesai'), (Icons.cancel_outlined, 'Ditolak')].indexed)
            InkWell(onTap: () => context.push('/orders?tab=$i'), child: Padding(padding: const EdgeInsets.all(6), child: Column(children: [Icon(e.$1, color: AppColors.primary), Text(e.$2, style: const TextStyle(fontSize: 11))]))),
        ]),
        const SizedBox(height: 12),
        tile(Icons.receipt_long_outlined, 'Semua Pesanan', '/orders'),
        tile(Icons.person_outline, 'Data Profil', '/profile/data'),
        tile(Icons.location_on_outlined, 'Alamat', '/addresses'),
        tile(Icons.lock_outline, 'Ganti Kata Sandi', '/profile/password'),
        tile(Icons.email_outlined, 'Ubah Email', '/profile/email'),
        tile(Icons.phone_android, 'Ubah Nomor Ponsel', '/profile/phone'),
        tile(Icons.help_outline, 'Pusat Bantuan', '/help'),
        const SizedBox(height: 10),
        PillButton(label: 'Keluar', color: AppColors.danger, onPressed: () => ref.read(authProvider.notifier).logout()),
      ]),
    );
  }
}

class ProfileDataScreen extends ConsumerStatefulWidget {
  const ProfileDataScreen({super.key});
  @override
  ConsumerState<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends ConsumerState<ProfileDataScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(authProvider)?.name);
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    return AppScaffold(
      title: 'Data Profil',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          AppField(label: 'Nama lengkap', controller: _name, hint: 'Nama lengkap', validator: (v) => Validators.required(v, 'Nama')),
          AppField(label: 'Email', controller: TextEditingController(text: user?.email), hint: '', readOnly: true),
          AppField(label: 'Nomor Ponsel', controller: TextEditingController(text: user?.phone), hint: '', readOnly: true),
          const Text('Email dan nomor ponsel diubah lewat menu Ubah Email / Ubah Nomor Ponsel.', style: TextStyle(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 16),
          PillButton(
            label: 'Simpan',
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              ref.read(authProvider.notifier).updateProfile(name: _name.text.trim());
              showMsg(context, 'Profil disimpan');
              context.pop();
            },
          ),
        ]),
      ),
    );
  }
}

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authProvider.notifier).changePassword(_old.text, _new.text);
      if (!mounted) return;
      showMsg(context, 'Kata sandi diperbarui');
      context.pop();
    } on AuthException catch (e) {
      if (mounted) showMsg(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ganti Password',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          AppField(fieldKey: const Key('pw-old'), controller: _old, hint: 'Kata sandi lama', obscure: true, validator: Validators.password),
          AppField(fieldKey: const Key('pw-new'), controller: _new, hint: 'Kata sandi baru', obscure: true, validator: Validators.password),
          AppField(fieldKey: const Key('pw-confirm'), controller: _confirm, hint: 'Konfirmasi kata sandi baru', obscure: true, validator: (v) => v != _new.text ? 'Konfirmasi tidak sama' : null),
          PillButton(label: 'Simpan', onPressed: _save),
        ]),
      ),
    );
  }
}

/// Ubah email / nomor ponsel: input baru -> OTP -> simpan (Figma 2204:6090, 2216:5410).
class ChangeContactScreen extends ConsumerStatefulWidget {
  const ChangeContactScreen({super.key, required this.isEmail});
  final bool isEmail;
  @override
  ConsumerState<ChangeContactScreen> createState() => _ChangeContactScreenState();
}

class _ChangeContactScreenState extends ConsumerState<ChangeContactScreen> {
  final _form = GlobalKey<FormState>();
  final _c = TextEditingController();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _next() {
    if (!_form.currentState!.validate()) return;
    final value = _c.text.trim();
    final phoneForOtp = ref.read(authProvider)?.phone ?? value;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) => OtpScreen(
        title: 'Konfirmasi',
        phone: widget.isEmail ? phoneForOtp : value,
        onVerified: () {
          final n = ref.read(authProvider.notifier);
          widget.isEmail ? n.updateProfile(email: value) : n.updateProfile(phone: value);
          Navigator.of(ctx).pop();
          showMsg(context, widget.isEmail ? 'Email diperbarui' : 'Nomor ponsel diperbarui');
          context.pop();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    return AppScaffold(
      title: widget.isEmail ? 'Ubah Email' : 'Ganti Nomor Ponsel',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text(widget.isEmail ? 'Email saat ini: ${user?.email}' : 'Nomor saat ini: ${user?.phone}', style: AppText.body),
          const SizedBox(height: 12),
          AppField(fieldKey: const Key('contact-new'), controller: _c, hint: widget.isEmail ? 'Email baru' : 'Nomor ponsel baru', keyboard: widget.isEmail ? TextInputType.emailAddress : TextInputType.phone, validator: widget.isEmail ? Validators.email : Validators.phone),
          Row(children: [
            Expanded(child: PillButton(label: 'Batal', outlined: true, color: AppColors.danger, onPressed: () => context.pop())),
            const SizedBox(width: 12),
            Expanded(child: PillButton(label: 'Selanjutnya', onPressed: _next)),
          ]),
        ]),
      ),
    );
  }
}

/// Alamat (Figma 608:4967). `pick=true`: mode memilih alamat untuk checkout.
class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key, this.pick = false});
  final bool pick;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(addressProvider);
    final n = ref.read(addressProvider.notifier);
    return AppScaffold(
      title: 'Alamat',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (list.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: EmptyState('Belum ada alamat', icon: Icons.location_off_outlined)),
        for (final a in list)
          AppCard(
            onTap: pick
                ? () {
                    ref.read(selectedAddressIdProvider.notifier).select(a.id);
                    context.pop();
                  }
                : null,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(a.recipient, style: AppText.semi)), if (a.isPrimary) const Padding(padding: EdgeInsets.only(left: 8), child: StatusChip('Utama'))]),
                  Text(a.phone, style: AppText.small),
                  Text(a.full, style: AppText.small),
                ]),
              ),
              PopupMenuButton<String>(
                tooltip: 'Menu alamat',
                onSelected: (v) => v == 'primary' ? n.setPrimary(a.id) : n.remove(a.id),
                itemBuilder: (_) => [if (!a.isPrimary) const PopupMenuItem(value: 'primary', child: Text('Jadikan utama')), const PopupMenuItem(value: 'delete', child: Text('Hapus'))],
              ),
            ]),
          ),
        PillButton(label: '+Tambah Alamat', onPressed: () => context.push('/addresses/add')),
      ]),
    );
  }
}

/// Tambah alamat (Figma 608:5068, 3499:4141).
class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});
  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _area = TextEditingController();
  final _street = TextEditingController();
  bool _primary = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authProvider);
    _name.text = u?.name ?? '';
    _phone.text = u?.phone ?? '';
    Future.microtask(() => ref.read(pickedKecamatanProvider.notifier).pick(null));
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _area, _street]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tambah Alamat',
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          AppField(fieldKey: const Key('addr-name'), controller: _name, hint: 'Nama lengkap', validator: (v) => Validators.required(v, 'Nama')),
          AppField(fieldKey: const Key('addr-phone'), controller: _phone, hint: 'Nomor Ponsel', keyboard: TextInputType.phone, validator: Validators.phone),
          AppField(
            fieldKey: const Key('addr-area'),
            controller: _area,
            hint: 'Kota, Kecamatan, Kode Pos',
            readOnly: true,
            suffix: const Icon(Icons.chevron_right),
            validator: (v) => Validators.required(v, 'Kecamatan'),
            onTap: () async {
              await context.push('/pick-kecamatan');
              final k = ref.read(pickedKecamatanProvider);
              if (k != null) _area.text = k.toString();
            },
          ),
          AppField(fieldKey: const Key('addr-street'), controller: _street, hint: 'Nama Jalan, Gedung, No. Rumah', validator: (v) => Validators.required(v, 'Alamat')),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Atur sebagai alamat utama'), value: _primary, onChanged: (v) => setState(() => _primary = v)),
          const SizedBox(height: 12),
          PillButton(
            label: 'Simpan',
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              final k = ref.read(pickedKecamatanProvider);
              if (k == null) return;
              ref.read(addressProvider.notifier).add(Address(id: 'a${DateTime.now().microsecondsSinceEpoch}', recipient: _name.text.trim(), phone: _phone.text.trim(), street: _street.text.trim(), area: k, isPrimary: _primary));
              context.pop();
            },
          ),
        ]),
      ),
    );
  }
}

/// Pilih Kecamatan (Figma 5132:6248).
class PickKecamatanScreen extends ConsumerStatefulWidget {
  const PickKecamatanScreen({super.key});
  @override
  ConsumerState<PickKecamatanScreen> createState() => _PickKecamatanScreenState();
}

class _PickKecamatanScreenState extends ConsumerState<PickKecamatanScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final items = mockKecamatan.where((k) => k.name.toLowerCase().contains(_q.toLowerCase())).toList();
    return AppScaffold(
      title: 'Pilih Kecamatan',
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: (v) => setState(() => _q = v), decoration: InputDecoration(hintText: 'Cari kecamatan', prefixIcon: const Icon(Icons.search), filled: true, fillColor: AppColors.field, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
        Expanded(
          child: ListView(children: [
            for (final k in items)
              ListTile(
                key: Key('kec-${k.name}'),
                title: Text(k.name, style: AppText.body),
                subtitle: Text('${k.city} ${k.postalCode}'),
                onTap: () {
                  ref.read(pickedKecamatanProvider.notifier).pick(k);
                  context.pop();
                },
              ),
          ]),
        ),
      ]),
    );
  }
}

/// Pusat Bantuan (Figma 3431:6761): FAQ + tombol WhatsApp (tanpa launcher: simulasi).
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});
  static const faqs = [
    ('Bagaimana cara memesan?', 'Pilih produk, pilih variasi, masukkan keranjang, lalu Beli Sekarang.'),
    ('Bagaimana cara membayar?', 'Pilih Transfer lalu unggah bukti, atau COD (bayar di tempat).'),
    ('Pesanan saya ditolak, apa yang harus dilakukan?', 'Buka tab Ditolak, lihat alasan, lalu Bayar Ulang.'),
  ];
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pusat Bantuan',
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (final f in faqs) AppCard(padding: EdgeInsets.zero, child: ExpansionTile(shape: const Border(), title: Text(f.$1, style: AppText.body), childrenPadding: const EdgeInsets.all(14), children: [Text(f.$2, style: AppText.small)])),
        const SizedBox(height: 12),
        PillButton(label: 'Lanjutkan Whatsapp', color: AppColors.success, onPressed: () => showMsg(context, 'Membuka WhatsApp belum tersedia (nomor admin belum ditentukan)')),
      ]),
    );
  }
}
