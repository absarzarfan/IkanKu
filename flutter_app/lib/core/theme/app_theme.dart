import 'package:flutter/material.dart';

/// Warna diambil dari get_design_context frame mobile (bukan palet Design System,
/// yang berbeda: lihat docs/decisions-flutter.md).
class AppColors {
  static const primary = Color(0xFF177BCD);
  static const background = Color(0xFFF6F6F6);
  static const field = Color(0xFFE8E8E8);
  static const danger = Color(0xFFFF3848);
  static const navy = Color(0xFF1A2151);
  static const grey = Color(0xFF9095A0);
  static const greyLight = Color(0xFFBCC1CA);
  static const text = Color(0xFF171A1F);
  static const onPrimarySoft = Color(0xFFF6F6F9);
  static const star = Color(0xFFFFB91B); // Tree Poppy 400
  static const success = Color(0xFF299722); // Malachite 600
}

class AppText {
  static const _f = 'Poppins';
  static const body = TextStyle(fontFamily: _f, fontSize: 15, color: Colors.black);
  static const small = TextStyle(fontFamily: _f, fontSize: 12, color: Colors.black);
  static const medium = TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black);
  static const semi = TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black);
  static const title = TextStyle(fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFFEEEEEE));
  static const price = TextStyle(fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black);
  static const hint = TextStyle(fontFamily: 'Nunito', fontSize: 16, color: Color(0x99A0A0A0));
  static const input = TextStyle(fontFamily: 'Nunito', fontSize: 16, color: AppColors.text);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, surface: Colors.white),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
  );
}
