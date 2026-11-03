import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';

/// Halaman awal: logo, nilai jual dari web, "Masuk" (utama) dan "Daftar" (sekunder).
class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: ContentFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xxl),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: Gap.xxxl), child: Image.asset('assets/images/logo.png', width: fluid(context, 220), fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox(height: 96))),
                    const Text('Belanja Ikan Mudah Dengan IkanKu', textAlign: TextAlign.center, style: AppText.title),
                    const SizedBox(height: Gap.xl),
                    for (final (i, t) in ['Ikan Segar Langsung ke Rumah Anda', 'Mudah dan Praktis', 'Jaminan Kesegaran'].indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Gap.sm),
                        child: Reveal(
                          index: i,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.glassBorder)),
                            child: Padding(
                              padding: const EdgeInsets.all(Gap.md),
                              child: Row(children: [
                                IconChip(icon: const [Icons.local_shipping_outlined, Icons.touch_app_outlined, Icons.verified_outlined][i], glass: true, size: 40),
                                const SizedBox(width: Gap.md),
                                Expanded(child: Text(t, style: AppText.label.copyWith(color: Colors.white))),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: Gap.xl),
                    PillButton(label: 'Masuk', outlined: true, onPressed: () => context.go('/login')),
                    const SizedBox(height: Gap.md),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Daftar', textAlign: TextAlign.center, style: AppText.bannerButton),
                    ),
                    TextButton(
                      onPressed: () => showMsg(context, 'Website IkanKu: alamat belum ditentukan'),
                      child: Text('Jelajahi Website kami', textAlign: TextAlign.center, style: AppText.small.copyWith(color: Colors.white)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Koneksi internet terputus (Figma 528:2662). Dipakai sebagai layar error/offline.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xxxl),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 96, color: AppColors.grey),
            const SizedBox(height: Gap.lg),
            Text('Koneksi Internet Terputus!', style: AppText.heading, textAlign: TextAlign.center),
            const SizedBox(height: Gap.xxl),
            PillButton(label: 'Coba Kembali', onPressed: () => context.canPop() ? context.pop() : context.go('/')),
          ]),
        ),
      ),
    );
  }
}

/// Sesuaikan lokasi (Figma "Daftar" 1769:8280): tata letak peta berupa placeholder statis, tanpa paket peta.
class PickLocationScreen extends StatelessWidget {
  const PickLocationScreen({super.key});
  static const placeholderLabel = 'Lokasi pada peta (placeholder)';
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sesuaikan Lokasi',
      body: Column(children: [
        Expanded(
          child: Container(
            key: const Key('map-placeholder'),
            width: double.infinity,
            margin: Space.pad(context),
            decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.location_on, size: 56, color: AppColors.danger),
              SizedBox(height: Gap.sm),
              Text('Peta belum tersedia (placeholder statis)', textAlign: TextAlign.center, style: AppText.small.copyWith(color: AppColors.grey)),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(context.pagePadding, 0, context.pagePadding, Gap.xl),
          child: PillButton(label: 'Gunakan Lokasi Ini', onPressed: () => context.pop(placeholderLabel)),
        ),
      ]),
    );
  }
}
