import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikanku/core/router/app_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';

/// Menjalankan aplikasi penuh pada layar 412x917 dp.
Future<ProviderContainer> pumpApp(WidgetTester tester, {ProviderContainer? container}) async {
  tester.view.physicalSize = const Size(412 * 2, 917 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final c = container ?? ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: Consumer(builder: (context, ref, _) => MaterialApp.router(theme: buildTheme(), routerConfig: ref.watch(routerProvider))),
  ));
  await tester.pumpAndSettle();
  return c;
}

/// Aplikasi dibuka sebagai pembeli demo (langsung beranda); helper ini keluar dulu dan menampilkan startup page.
Future<ProviderContainer> pumpAppSignedOut(WidgetTester tester) async {
  final c = await pumpApp(tester);
  c.read(authProvider.notifier).logout();
  await tester.pumpAndSettle();
  c.read(routerProvider).go('/');
  await tester.pumpAndSettle();
  return c;
}

Future<void> loginAs(WidgetTester tester, String id) async {
  await tester.enterText(find.byKey(const Key('login-id')), id);
  await tester.enterText(find.byKey(const Key('login-pw')), 'Admin123');
  await tester.tap(find.text('Login').last);
  await tester.pumpAndSettle();
}

/// flutter test memakai font Ahem (lebar) kecuali font dimuat manual.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final l = FontLoader(family);
    for (final f in files) {
      l.addFont(rootBundle.load('assets/fonts/$f'));
    }
    await l.load();
  }

  await load('Poppins', ['Poppins-Regular.ttf']);
  await load('Nunito', ['Nunito.ttf']);
  await load('Montserrat', ['Montserrat.ttf']);
}
