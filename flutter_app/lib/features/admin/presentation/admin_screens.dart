import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/data/backend.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/utils/format.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/admin/domain/admin.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';

/// Teks admin dalam satu tempat.
class AdminStrings {
  static const title = 'Admin';
  static const users = 'Pengguna';
  static const orders = 'Pesanan';
  static const products = 'Produk';
  static const search = 'Cari';
  static const unavailable = 'Panel admin memerlukan koneksi Supabase.';
  static const empty = 'Tidak ada data';
  static const logout = 'Keluar';
  static String role(UserRole r) => switch (r) { UserRole.buyer => 'pembeli', UserRole.seller => 'penjual', UserRole.admin => 'admin' };
}

final _adminUsersProvider = FutureProvider.autoDispose.family<List<AppUser>, String>((ref, q) async => await ref.read(adminRemoteProvider)?.users(query: q) ?? const []);
final _adminOrdersProvider = FutureProvider.autoDispose<List<AdminOrder>>((ref) async => await ref.read(adminRemoteProvider)?.orders() ?? const []);
final _adminProductsProvider = FutureProvider.autoDispose.family<List<AdminProduct>, String>((ref, q) async => await ref.read(adminRemoteProvider)?.products(query: q) ?? const []);

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRemote = ref.watch(adminRemoteProvider) != null;
    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        title: AdminStrings.title,
        showBack: false,
        actions: [IconButton(tooltip: AdminStrings.logout, icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => ref.read(authProvider.notifier).logout())],
        body: !hasRemote
            ? const EmptyState(AdminStrings.unavailable, icon: Icons.cloud_off)
            : const Column(children: [
                TabBar(tabs: [Tab(text: AdminStrings.users), Tab(text: AdminStrings.orders), Tab(text: AdminStrings.products)]),
                Expanded(child: TabBarView(children: [_UsersTab(), _OrdersTab(), _ProductsTab()])),
              ]),
      ),
    );
  }
}

Widget _async<T>(AsyncValue<List<T>> v, VoidCallback onRetry, Widget Function(List<T>) build) => v.when(
      data: (d) => d.isEmpty ? const EmptyState(AdminStrings.empty, icon: Icons.inbox_outlined) : build(d),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(message: 'Gagal memuat data.', onRetry: onRetry),
    );

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onSubmit});
  final ValueChanged<String> onSubmit;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Gap.md),
        child: TextField(
          key: const Key('admin-search'),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: AdminStrings.search),
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmit,
        ),
      );
}

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();
  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  String _q = '';

  Future<void> _toggle(AppUser u) async {
    try {
      await ref.read(adminRemoteProvider)!.setUserActive(u.id, !u.isActive);
      ref.invalidate(_adminUsersProvider(_q));
    } catch (e) {
      ref.read(backendErrorProvider.notifier).report(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authProvider)?.id;
    return Column(children: [
      _SearchBox(onSubmit: (v) => setState(() => _q = v)),
      Expanded(
        child: _async(ref.watch(_adminUsersProvider(_q)), () => ref.invalidate(_adminUsersProvider(_q)), (list) => ListView(children: [
              for (final u in list)
                ListTile(
                  title: Text(u.name.isEmpty ? u.email : u.name, style: AppText.body),
                  subtitle: Text('${u.email} · ${AdminStrings.role(u.role)}${u.isActive ? '' : ' · nonaktif'}'),
                  trailing: u.id == me
                      ? null
                      : Switch(key: Key('user-${u.id}'), value: u.isActive, onChanged: (_) => _toggle(u)),
                ),
            ])),
      ),
    ]);
  }
}

class _OrdersTab extends ConsumerStatefulWidget {
  const _OrdersTab();
  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab> {
  static const _all = 'Semua';
  String _status = _all;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_adminOrdersProvider);
    final statuses = [_all, ...{for (final o in async.value ?? const <AdminOrder>[]) o.status}];
    return Column(children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
        child: Row(children: [
          for (final s in statuses)
            Padding(
              padding: const EdgeInsets.only(right: Gap.sm),
              child: ChoiceChip(key: Key('admin-status-$s'), label: Text(s), selected: _status == s, onSelected: (_) => setState(() => _status = s)),
            ),
        ]),
      ),
      Expanded(
        child: _async(async, () => ref.invalidate(_adminOrdersProvider), (list) {
          final shown = _status == _all ? list : list.where((o) => o.status == _status).toList();
          if (shown.isEmpty) return const EmptyState(AdminStrings.empty, icon: Icons.inbox_outlined);
          return ListView(children: [
            for (final o in shown)
              ListTile(
                title: Text('${o.code} · ${o.status}', style: AppText.body),
                subtitle: Text('${o.buyerName} → ${o.shopName} · ${o.payment}'),
                trailing: Text(rupiah(o.total)),
              ),
          ]);
        }),
      ),
    ]);
  }
}

class _ProductsTab extends ConsumerStatefulWidget {
  const _ProductsTab();
  @override
  ConsumerState<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends ConsumerState<_ProductsTab> {
  String _q = '';

  Future<void> _toggle(AdminProduct p) async {
    try {
      await ref.read(adminRemoteProvider)!.setProductActive(p.id, !p.isActive);
      ref.invalidate(_adminProductsProvider(_q));
    } catch (e) {
      ref.read(backendErrorProvider.notifier).report(e);
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        _SearchBox(onSubmit: (v) => setState(() => _q = v)),
        Expanded(
          child: _async(ref.watch(_adminProductsProvider(_q)), () => ref.invalidate(_adminProductsProvider(_q)), (list) => ListView(children: [
                for (final p in list)
                  ListTile(
                    title: Text(p.name, style: AppText.body),
                    subtitle: Text(p.shopName),
                    trailing: Switch(key: Key('product-${p.id}'), value: p.isActive, onChanged: (_) => _toggle(p)),
                  ),
              ])),
        ),
      ]);
}
