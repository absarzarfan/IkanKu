import 'package:flutter/material.dart';
import 'package:ikanku/core/theme/app_theme.dart';

/// Transisi halaman: fade + geser kecil dari kanan (sekitar 200 ms, easeOutCubic).
/// Hanya opacity dan transform; durasi nol bila animasi dimatikan sistem.
class FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeSlidePageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (AppMotion.reduced(context)) return child;
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.curve, reverseCurve: AppMotion.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(curved), child: child),
    );
  }
}
