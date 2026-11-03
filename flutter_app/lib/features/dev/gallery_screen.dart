import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ikanku/core/config/app_config.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';

/// Galeri komponen remake. Hanya ada di debug dan mode mock (lihat [devGalleryEnabled]).
bool get devGalleryEnabled => kDebugMode && !AppConfig.useSupabase;

class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});
  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  int _tab = 0;
  int _bar = 0;
  @override
  Widget build(BuildContext context) {
    Widget block(String name, Widget child) => Padding(padding: const EdgeInsets.only(bottom: Gap.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppText.label.copyWith(color: AppColors.grey)), const SizedBox(height: Gap.sm), child]));
    return AppScaffold(
      title: 'Galeri komponen',
      body: ListView(padding: Space.pad(context), children: [
        block('HeroHeader + FloatingSearchField', ClipRRect(borderRadius: BorderRadius.circular(AppRadius.card), child: HeroHeader(floating: FloatingSearchField(label: 'Cari ikan air tawar', onTap: () {}), child: const Text('Halo, Uji!', style: AppText.greeting)))),
        block('SectionHeader', const SectionHeader('Rekomendasi untuk Anda', eyebrow: 'Pilihan untuk Anda', action: 'Lihat semua')),
        block('ValuePropCard', const ValuePropCard(icon: Icons.verified_outlined, title: 'Jaminan Kesegaran')),
        block('StatCard', StatRow(cards: const [StatCard(value: '12', label: 'Total pesanan', icon: Icons.receipt_long_outlined), StatCard(value: '3', label: 'Pesanan aktif')])),
        block('StatusChip', Wrap(spacing: Gap.sm, children: const [StatusChip('Menunggu', color: AppColors.warning), StatusChip('Selesai', color: AppColors.success), StatusChip('Ditolak', color: AppColors.danger)])),
        block('StatusTimeline', const StatusTimeline(steps: ['Pesanan dibuat', 'Dikemas', 'Dikirim', 'Selesai'], current: 1)),
        block('FilterChipBar', FilterChipBar(labels: const ['Hias', 'Rating 4.5+'], onRemove: (_) {})),
        block('SegmentedTabs', SegmentedTabs(labels: const ['Menunggu', 'Dikemas', 'Dikirim'], counts: const [1, 2, 0], index: _tab, onChanged: (i) => setState(() => _tab = i))),
        block('MenuGroup', MenuGroup(title: 'Akun', items: [MenuItem(icon: Icons.person_outline, label: 'Data Profil', onTap: () {}), MenuItem(icon: Icons.logout, label: 'Keluar', destructive: true, onTap: () {})])),
        block('SuccessMoment', const SuccessMoment(title: 'Pesanan berhasil dibuat', subtitle: 'Pantau di Pesanan Saya')),
        block('EmptyState', SizedBox(height: 260, child: EmptyState('Tidak ada hasil', icon: Icons.search_off, hint: 'Coba kata kunci lain.', actionLabel: 'Atur ulang filter', onAction: () {}))),
        block('SkeletonGrid', const SkeletonGrid(count: 2)),
        block('BottomSheetScaffold', PillButton(label: 'Buka sheet', outlined: true, onPressed: () => BottomSheetScaffold.show<void>(context, builder: (_) => BottomSheetScaffold(title: 'Contoh sheet', body: const Text('Isi menggulir'), footer: PillButton(label: 'Terapkan - 3 produk', onPressed: () => Navigator.of(context).pop()))))),
        block('AppBottomBar', AppBottomBar(items: const [BarItem(Icons.home_outlined, Icons.home, 'Beranda'), BarItem(Icons.search, Icons.search, 'Telusuri'), BarItem(Icons.person_outline, Icons.person, 'Profil')], index: _bar, badgeIndex: 2, badgeCount: 3, onTap: (i) => setState(() => _bar = i))),
      ]),
    );
  }
}
