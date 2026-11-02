import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/core/theme/app_theme.dart';

/// Dipicu saat pengguna mengetuk ulang tab yang sedang aktif: (indeks cabang, hitungan).
/// Layar tab mendengarkan ini dan menggulir ke atas.
class TabReselectNotifier extends Notifier<(int, int)> {
  @override
  (int, int) build() => (-1, 0);
  void fire(int branch) => state = (branch, state.$2 + 1);
}

final tabReselectProvider = NotifierProvider<TabReselectNotifier, (int, int)>(TabReselectNotifier.new);

/// Pasang di State layar tab: gulir ke atas saat tab [branch] diketuk ulang. Instan bila animasi dimatikan.
void listenTabReselect(WidgetRef ref, BuildContext context, int branch, ScrollController controller) {
  ref.listen(tabReselectProvider, (_, v) {
    if (v.$1 != branch || !controller.hasClients || controller.offset <= 0) return;
    if (AppMotion.reduced(context)) {
      controller.jumpTo(0);
    } else {
      controller.animateTo(0, duration: AppMotion.slow, curve: AppMotion.curve);
    }
  });
}
