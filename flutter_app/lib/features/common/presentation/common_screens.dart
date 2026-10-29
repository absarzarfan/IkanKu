import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/core/widgets/widgets.dart';

/// Start up page (Figma 528:2181): logo, "Masuk", "Jelajahi Website kami".
class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Image.asset('assets/images/logo.png', width: 220),
            const Spacer(),
            PillButton(label: 'Masuk', outlined: true, onPressed: () => context.go('/login')),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => showMsg(context, 'Website IkanKu: alamat belum ditentukan'),
              child: const Text('Jelajahi Website kami', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
            ),
          ]),
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 96, color: AppColors.grey),
            const SizedBox(height: 16),
            Text('Koneksi Internet Terputus!', style: AppText.semi.copyWith(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PillButton(label: 'Coba Kembali', onPressed: () => context.canPop() ? context.pop() : context.go('/')),
          ]),
        ),
      ),
    );
  }
}
