import 'package:flutter/material.dart';

/// Token tema pusat. Widget hanya memakai token di sini (tanpa hex atau ukuran huruf mentah).
/// Sumber nilai per token dicatat di docs/figma-fidelity.md. Cabang berikutnya cukup mengganti nilai di berkas ini.
class AppColors {
  static const primary = Color(0xFF177BCD);
  static const background = Color(0xFFF6F6F6);
  static const surface = Colors.white;
  static const field = Color(0xFFE8E8E8);
  static const danger = Color(0xFFFF3848);
  static const dangerSoft = Color(0xFFFFF2F1);
  static const navy = Color(0xFF1A2151);
  static const grey = Color(0xFF9095A0);
  static const greyLight = Color(0xFFBCC1CA);
  static const text = Color(0xFF171A1F);
  static const textStrong = Colors.black;
  static const onPrimary = Colors.white;
  static const onPrimarySoft = Color(0xFFF6F6F9);
  static const titleOnPrimary = Color(0xFFEEEEEE);
  static const hint = Color(0x99A0A0A0);
  static const googleLabel = Color(0x8A000000);
  static const star = Color(0xFFFFB91B); // Tree Poppy 400
  static const success = Color(0xFF299722); // Malachite 600
  static const shadow = Color(0x40000000);
  static const shadowSoft = Color(0x33000000);
  static const shadowFaint = Color(0x0F000000);
}

class AppRadius {
  static const double field = 10, chip = 7, card = 16, sheet = 28, pill = 30, header = 16, headerAuth = 30;
}

class AppShadow {
  static const header = [BoxShadow(color: AppColors.shadow, offset: Offset(0, 4), blurRadius: 4)];
  static const card = [BoxShadow(color: AppColors.shadow, offset: Offset(0, 4), blurRadius: 2)];
  static const soft = [BoxShadow(color: AppColors.shadowSoft, blurRadius: 3, offset: Offset(0, 2))];
  static const auth = [BoxShadow(color: AppColors.shadowFaint, offset: Offset(0, 4), blurRadius: 30)];
}

/// Dimensi kontrol (dp). Tinggi minimum tombol 48 agar lolos pedoman target sentuh.
class AppSize {
  static const double button = 50, buttonLarge = 56, buttonSmall = 48, searchBar = 48;
}

class AppText {
  static const _f = 'Poppins';
  static const body = TextStyle(fontFamily: _f, fontSize: 15, color: AppColors.textStrong);
  static const small = TextStyle(fontFamily: _f, fontSize: 12, color: AppColors.textStrong);
  static const caption = TextStyle(fontFamily: _f, fontSize: 11, color: AppColors.textStrong);
  static const medium = TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textStrong);
  static const semi = TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textStrong);
  static const label = TextStyle(fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textStrong);
  static const subheading = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textStrong);
  static const heading = TextStyle(fontFamily: _f, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textStrong);
  static const title = TextStyle(fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.titleOnPrimary);
  static const price = TextStyle(fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textStrong);
  static const score = TextStyle(fontFamily: _f, fontSize: 20, color: AppColors.textStrong);
  static const greeting = TextStyle(fontFamily: _f, fontSize: 20, color: AppColors.onPrimary);
  static const banner = TextStyle(fontFamily: _f, fontSize: 30, color: AppColors.onPrimary);
  static const bannerButton = TextStyle(fontFamily: _f, fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.onPrimary);
  static const tabOnPrimary = TextStyle(fontFamily: _f, fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.onPrimary);
  static const navLabel = TextStyle(fontFamily: _f, fontSize: 13, color: AppColors.onPrimary);
  static const searchHint = TextStyle(fontFamily: _f, fontSize: 14, color: AppColors.grey);
  static const googleMark = TextStyle(fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.primary);
  static const googleButton = TextStyle(fontFamily: _f, fontSize: 16, color: AppColors.googleLabel);
  static const buttonLabel = TextStyle(fontFamily: _f, fontWeight: FontWeight.w600, fontSize: 15);
  static const hint = TextStyle(fontFamily: 'Nunito', fontSize: 16, color: AppColors.hint);
  static const input = TextStyle(fontFamily: 'Nunito', fontSize: 16, color: AppColors.text);
  static const otp = TextStyle(fontFamily: 'Nunito', fontSize: 28, letterSpacing: 16, color: AppColors.text);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, surface: AppColors.surface);
  OutlineInputBorder border([Color? c]) => OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.field), borderSide: c == null ? BorderSide.none : BorderSide(color: c));
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(minimumSize: const Size(64, AppSize.buttonSmall))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(64, AppSize.buttonSmall))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(64, AppSize.buttonSmall))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.field,
      hintStyle: AppText.hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: border(),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card))),
  );
}
