import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/auth/presentation/auth_screens.dart';
import 'package:ikanku/features/profile/domain/profile.dart';
import 'package:ikanku/features/profile/presentation/profile_providers.dart';

/// Sel "Pesanan Saya": ikon + badge hitungan + label yang membungkus (maks 2 baris), lebar sama (Expanded).
class OrderStatusCell extends StatelessWidget {
  const OrderStatusCell({super.key, required this.icon, required this.label, required this.count, required this.onTap});
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: count > 0 ? '$label, $count pesanan' : label,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.icon),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.buttonLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.sm, horizontal: 2),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                NavBadge(count: count, badgeKey: Key('order-cell-badge-$label'), child: Icon(icon, size: 26, color: AppColors.primary)),
                const SizedBox(height: Gap.xs),
                FittedBox(fit: BoxFit.scaleDown, child: Text(label, textAlign: TextAlign.center, maxLines: 1, style: AppText.caption.copyWith(color: AppColors.text))),
              ]),
            ),
          ),
        ),
      );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final orders = ref.watch(ordersProvider);
    final addresses = ref.watch(addressProvider);
    int count(OrderStatus s) => orders.where((o) => o.status == s).length;
    final active = orders.where((o) => o.status == OrderStatus.menunggu || o.status == OrderStatus.dikemas || o.status == OrderStatus.dikirim).length;
    final reviews = orders.where((o) => o.review != null).length;
    // Kelengkapan profil dari field yang ada: nama, email, ponsel, alamat.
    final fields = [(user?.name ?? '').trim().isNotEmpty, (user?.email ?? '').trim().isNotEmpty, (user?.phone ?? '').trim().isNotEmpty, addresses.isNotEmpty];
    final done = fields.where((e) => e).length;
    final g = Space.screenGutter(context);
    const cells = [(Icons.hourglass_top_outlined, OrderStatus.menunggu), (Icons.inventory_2_outlined, OrderStatus.dikemas), (Icons.local_shipping_outlined, OrderStatus.dikirim), (Icons.check_circle_outline, OrderStatus.selesai), (Icons.cancel_outlined, OrderStatus.ditolak)];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(padding: EdgeInsets.only(bottom: Space.minBottomClearance(context)), children: [
        HeroHeader(
          bottomPadding: Gap.xxl,
          child: Row(children: [
            Container(
              width: AppSize.avatar,
              height: AppSize.avatar,
              decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.glassBorder)),
              child: const ExcludeSemantics(child: Icon(Icons.person, size: 36, color: Colors.white)),
            ),
            const SizedBox(width: Gap.lg),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name ?? '-', style: AppText.heading.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(user?.email ?? '', style: AppText.small.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(user?.phone ?? '', style: AppText.small.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        ),
        ContentFrame(
          safe: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: Gap.lg),
            if (done < fields.length)
              AppCard(
                onTap: () => context.push('/profile/data'),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Expanded(child: Text('Lengkapi profil Anda', style: AppText.label)), Text('${done * 100 ~/ fields.length}%', style: AppText.label.copyWith(color: AppColors.primary))]),
                  const SizedBox(height: Gap.sm),
                  ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(key: const Key('profile-completeness'), value: done / fields.length, minHeight: 8, color: AppColors.primary, backgroundColor: AppColors.surfaceTint)),
                  const SizedBox(height: Gap.xs),
                  Text('$done dari ${fields.length} data terisi', style: AppText.caption.copyWith(color: AppColors.grey)),
                ]),
              ),
            SectionHeader('Pesanan Saya', action: 'Semua pesanan', onAction: () => context.push('/orders')),
            const VGap.title(),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: Gap.xs, vertical: Gap.xs),
              child: Row(key: const Key('orders-row'), crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final (i, e) in cells.indexed) Expanded(child: OrderStatusCell(icon: e.$1, label: e.$2.label, count: count(e.$2), onTap: () => context.push('/orders?tab=$i'))),
              ]),
            ),
            StatRow(cards: [
              StatCard(value: '${orders.length}', label: 'Total pesanan', icon: Icons.receipt_long_outlined),
              StatCard(value: '$active', label: 'Pesanan aktif', icon: Icons.local_shipping_outlined),
              StatCard(value: '$reviews', label: 'Ulasan diberikan', icon: Icons.star_outline),
            ]),
            const VGap.section(),
            MenuGroup(title: 'Akun', items: [
              MenuItem(icon: Icons.person_outline, label: 'Data Profil', onTap: () => context.push('/profile/data')),
              MenuItem(icon: Icons.location_on_outlined, label: 'Alamat', onTap: () => context.push('/addresses')),
              MenuItem(icon: Icons.lock_outline, label: 'Ganti Kata Sandi', onTap: () => context.push('/profile/password')),
              MenuItem(icon: Icons.email_outlined, label: 'Ubah Email', onTap: () => context.push('/profile/email')),
              MenuItem(icon: Icons.phone_android, label: 'Ubah Nomor Ponsel', onTap: () => context.push('/profile/phone')),
            ]),
            const VGap.section(),
            MenuGroup(title: 'Bantuan', items: [
              MenuItem(icon: Icons.help_outline, label: 'Pusat Bantuan', hint: 'Pertanyaan yang sering diajukan', onTap: () => context.push('/help')),
            ]),
            const VGap.section(),
            Semantics(
              button: true,
              label: 'Keluar',
              excludeSemantics: true,
              child: Pressable(
                onTap: () async {
                  if (await confirmDialog(context, 'Keluar dari akun?', 'Anda perlu masuk lagi untuk berbelanja.', yes: 'Keluar', no: 'Batal')) {
                    ref.read(authProvider.notifier).logout();
                  }
                },
                borderRadius: BorderRadius.circular(AppRadius.pill),
                decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: AppColors.danger)),
                minSize: AppSize.button,
                child: Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: Gap.md), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.logout, color: AppColors.danger, size: 20), const SizedBox(width: Gap.sm), Text('Keluar', style: AppText.buttonLabel.copyWith(color: AppColors.danger))]))),
              ),
            ),
            SizedBox(height: g),
          ]),
        ),
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
      bottom: StickyActionBar(child: PillButton(
            label: 'Simpan',
            onPressed: () {
              if (!validateAndFocus(_form)) return;
              ref.read(authProvider.notifier).updateProfile(name: _name.text.trim());
              showMsg(context, 'Profil disimpan');
              context.pop();
            },
          )),
      body: Form(
        key: _form,
        child: ListView(padding: Space.pad(context), children: [
          AppField(label: 'Nama lengkap', controller: _name, hint: 'Nama lengkap', validator: (v) => Validators.required(v, 'Nama')),
          AppField(label: 'Email', controller: TextEditingController(text: user?.email), hint: '', readOnly: true),
          AppField(label: 'Nomor Ponsel', controller: TextEditingController(text: user?.phone), hint: '', readOnly: true),
          Text('Email dan nomor ponsel diubah lewat menu Ubah Email / Ubah Nomor Ponsel.', style: AppText.small.copyWith(color: AppColors.grey)),
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
    if (!validateAndFocus(_form)) return;
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
      bottom: StickyActionBar(child: PillButton(label: 'Simpan', onPressed: _save)),
      body: Form(
        key: _form,
        child: ListView(padding: Space.pad(context), children: [
          AppField(fieldKey: const Key('pw-old'), controller: _old, hint: 'Kata sandi lama', obscure: true, validator: Validators.password),
          AppField(fieldKey: const Key('pw-new'), controller: _new, hint: 'Kata sandi baru', obscure: true, validator: Validators.password),
          AppField(fieldKey: const Key('pw-confirm'), controller: _confirm, hint: 'Konfirmasi kata sandi baru', obscure: true, validator: (v) => v != _new.text ? 'Konfirmasi tidak sama' : null),
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
    if (!validateAndFocus(_form)) return;
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
        child: ListView(padding: Space.pad(context), children: [
          Text(widget.isEmail ? 'Email saat ini: ${user?.email}' : 'Nomor saat ini: ${user?.phone}', style: AppText.body),
          const SizedBox(height: Gap.md),
          AppField(fieldKey: const Key('contact-new'), controller: _c, hint: widget.isEmail ? 'Email baru' : 'Nomor ponsel baru', keyboard: widget.isEmail ? TextInputType.emailAddress : TextInputType.phone, textInputAction: TextInputAction.done, autofillHints: [widget.isEmail ? AutofillHints.email : AutofillHints.telephoneNumber], inputFormatters: widget.isEmail ? null : [FilteringTextInputFormatter.digitsOnly], onSubmitted: (_) => _next(), validator: widget.isEmail ? Validators.email : Validators.phone),
          Row(children: [
            Expanded(child: PillButton(label: 'Batal', outlined: true, color: AppColors.danger, onPressed: () => context.pop())),
            const SizedBox(width: Gap.md),
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
      body: ListView(padding: Space.pad(context), children: [
        if (list.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: Gap.xxxl), child: EmptyState('Belum ada alamat', icon: Icons.location_off_outlined, hint: 'Tambahkan alamat agar pesanan Anda bisa dikirim.')),
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
                  Row(children: [Flexible(child: Text(a.recipient, style: AppText.semi)), if (a.isPrimary) const Padding(padding: EdgeInsets.only(left: Gap.sm), child: StatusChip('Utama'))]),
                  Text(a.phone, style: AppText.small),
                  Text(a.full, style: AppText.small),
                ]),
              ),
              PopupMenuButton<String>(
                tooltip: 'Menu alamat',
                onSelected: (v) async {
                  if (v == 'primary') {
                    HapticFeedback.selectionClick();
                    n.setPrimary(a.id);
                  } else if (await confirmDialog(context, 'Hapus alamat ini?', '${a.recipient}\n${a.full}', yes: 'Hapus', no: 'Batal')) {
                    n.remove(a.id);
                  }
                },
                itemBuilder: (_) => [if (!a.isPrimary) const PopupMenuItem(value: 'primary', child: Text('Jadikan utama')), const PopupMenuItem(value: 'delete', child: Text('Hapus'))],
              ),
            ]),
          ),
        PillButton(label: 'Tambah alamat', onPressed: () => context.push('/addresses/add')),
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
      bottom: StickyActionBar(child: PillButton(
            label: 'Simpan',
            onPressed: () {
              if (!validateAndFocus(_form)) return;
              final k = ref.read(pickedKecamatanProvider);
              if (k == null) return;
              ref.read(addressProvider.notifier).add(Address(id: 'a${DateTime.now().microsecondsSinceEpoch}', recipient: _name.text.trim(), phone: _phone.text.trim(), street: _street.text.trim(), area: k, isPrimary: _primary));
              context.pop();
            },
          )),
      body: Form(
        key: _form,
        child: ListView(padding: Space.pad(context), children: [
          AppField(fieldKey: const Key('addr-name'), controller: _name, hint: 'Nama lengkap', textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.name], validator: (v) => Validators.required(v, 'Nama')),
          AppField(fieldKey: const Key('addr-phone'), controller: _phone, hint: 'Nomor Ponsel', keyboard: TextInputType.phone, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.telephoneNumber], inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: Validators.phone),
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
        Padding(padding: const EdgeInsets.all(Gap.lg), child: TextField(onChanged: (v) => setState(() => _q = v), decoration: InputDecoration(hintText: 'Cari kecamatan', prefixIcon: const Icon(Icons.search), filled: true, fillColor: AppColors.field, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.field), borderSide: BorderSide.none)))),
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
      body: ListView(padding: Space.pad(context), children: [
        for (final f in faqs) AppCard(padding: EdgeInsets.zero, child: ExpansionTile(shape: const Border(), title: Text(f.$1, style: AppText.body), childrenPadding: const EdgeInsets.all(Gap.md), children: [Text(f.$2, style: AppText.small)])),
        const SizedBox(height: Gap.md),
        PillButton(label: 'Lanjutkan Whatsapp', color: AppColors.success, onPressed: () => showMsg(context, 'Membuka WhatsApp belum tersedia (nomor admin belum ditentukan)')),
      ]),
    );
  }
}
