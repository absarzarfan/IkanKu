import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: IkanKuApp()));
}

class IkanKuApp extends ConsumerWidget {
  const IkanKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'IkanKu',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
