import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/config/app_config.dart';
import 'package:ikanku/core/data/backend.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/features/auth/data/supabase_auth_repository.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseAuthRepository? auth;
  if (AppConfig.useSupabase) {
    // anonKey: kunci publik (legacy anon); nama dart-define tetap SUPABASE_ANON_KEY.
    // ignore: deprecated_member_use
    await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
    auth = SupabaseAuthRepository(Supabase.instance.client);
    await auth.restoreSession();
  }
  runApp(ProviderScope(
    overrides: [if (auth != null) authRepositoryProvider.overrideWithValue(auth)],
    child: const IkanKuApp(),
  ));
}

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class IkanKuApp extends ConsumerWidget {
  const IkanKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Galat backend ditampilkan sebagai SnackBar berbahasa Indonesia (tanpa teks pengecualian mentah).
    ref.listen(backendErrorProvider, (_, err) {
      if (err == null) return;
      _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(err.message)));
      ref.read(backendErrorProvider.notifier).clear();
    });
    return MaterialApp.router(
      title: 'IkanKu',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
