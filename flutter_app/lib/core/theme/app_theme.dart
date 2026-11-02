import 'package:flutter/material.dart';
import 'package:ikanku/core/theme/page_transitions.dart';

/// Token tema pusat. Widget hanya memakai token di sini (tanpa hex atau ukuran huruf mentah).
/// Sumber nilai per token dicatat di docs/figma-fidelity.md. Cabang berikutnya cukup mengganti nilai di berkas ini.
class AppColors {
  // Merek (web: --color-brand #1672c4 = hsl(207 80% 43%); putih di atasnya 4.96:1).
  static const primary = Color(0xFF1672C4);
  static final primaryDark = HSLColor.fromAHSL(1, 207, 0.8, 0.37).toColor();
  static const background = Color(0xFFF3F8FD); // web --color-surface (tint biru muda)
  static const surface = Colors.white;
  static const surfaceTint = Color(0xFFE8F1FA); // web --color-surface-2
  static const field = Color(0xFFE8F1FA);
  static const danger = Color(0xFFC8160D); // web red-orange-700 (kontras >= 4.5 di putih)
  static const dangerSoft = Color(0xFFFFF2F1);
  static const navy = Color(0xFF1A2151);
  static const grey = Color(0xFF4F5868); // web --color-muted
  static const greyLight = Color(0xFFBCC1CA);
  static const text = Color(0xFF2F3542); // web --color-body
  static const textStrong = Color(0xFF050315); // web --color-heading / ink
  static const onPrimary = Colors.white;
  static const onPrimarySoft = Colors.white;
  static const titleOnPrimary = Colors.white;
  static const hint = Color(0xFF5F636C); // web --color-placeholder #6b6f78, diperdalam (kontras >= 4.5 di atas field)
  static const googleLabel = Color(0x8A000000);
  static const star = Color(0xFFFFB91B); // Tree Poppy 400
  static const success = Color(0xFF299722); // Malachite 600
  static const warning = Color(0xFFBB4A02); // Tree Poppy 700 (teks status, kontras >= 4.5)
  static const info = Color(0xFF0072A7); // Malibu 700
  static const border = Color(0x1F1672C4); // web .card border rgba(22,114,196,.12)
  static const shadow = Color(0x40000000);
  static const scrim = Color(0x73050315);
  static const scrimClear = Color(0x00050315);
  static const shadowSoft = Color(0x33000000);
  static const shadowFaint = Color(0x0F000000);
}

/// Gradien web (--grad-primary, --grad-surface) dengan selisih terang maksimal 6% dari warna datar.
/// Titik terang = warna merek (43%), titik gelap 37%, sehingga teks putih tetap >= 4.5:1.
class AppGradients {
  static final _light = HSLColor.fromAHSL(1, 207, 0.8, 0.43).toColor();
  static final _dark = HSLColor.fromAHSL(1, 207, 0.8, 0.37).toColor();
  static final primary = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_light, _dark]);
  static final surface = primary;
  static final nav = primary;
  static final colors = [_light, _dark];

  /// Tint ikon (web .icon-chip-tint): merek 16% -> 7% di atas putih.
  static final chipTint = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.alphaBlend(AppColors.primary.withValues(alpha: 0.16), Colors.white), Color.alphaBlend(AppColors.primary.withValues(alpha: 0.07), Colors.white)]);
}

class AppRadius {
  static const double field = 10, chip = 7, icon = 14, card = 20, sheet = 28, pill = 30, header = 28, headerAuth = 30;
}

class AppShadow {
  static const header = [BoxShadow(color: AppColors.shadow, offset: Offset(0, 4), blurRadius: 4)];
  // web .card: 0 1px 2px rgba(5,3,21,.04), 0 12px 28px -16px rgba(22,114,196,.28)
  static const card = [BoxShadow(color: Color(0x0A050315), offset: Offset(0, 1), blurRadius: 2), BoxShadow(color: Color(0x471672C4), offset: Offset(0, 12), blurRadius: 28, spreadRadius: -16)];
  static const soft = card;
  static const auth = [BoxShadow(color: AppColors.shadowFaint, offset: Offset(0, 4), blurRadius: 30)];
}

/// Token gerak: 150/220/300 ms, easeOutCubic. Dengan disableAnimations semuanya nol.
class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 300);
  static const press = Duration(milliseconds: 130);
  static const stagger = Duration(milliseconds: 60);
  static const curve = Curves.easeOutCubic;
  static const revealOffset = 14.0;
  static const revealMaxItems = 8;

  static bool reduced(BuildContext c) => MediaQuery.maybeDisableAnimationsOf(c) ?? false;
  static Duration of(BuildContext c, Duration d) => reduced(c) ? Duration.zero : d;
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
  /// Angka penilaian: Poppins, angka tabular agar lebar konsisten.
  static const rating = TextStyle(fontFamily: _f, fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textStrong, fontFeatures: [FontFeature.tabularFigures()]);
  static const ratingLarge = TextStyle(fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textStrong, fontFeatures: [FontFeature.tabularFigures()]);
  static const score = TextStyle(fontFamily: _f, fontSize: 20, color: AppColors.textStrong);
  static const greeting = TextStyle(fontFamily: _f, fontSize: 20, color: AppColors.onPrimary);
  static const banner = TextStyle(fontFamily: _f, fontSize: 30, color: AppColors.onPrimary);
  static const bannerButton = TextStyle(fontFamily: _f, fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.onPrimary);
  static const tabOnPrimary = TextStyle(fontFamily: _f, fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.onPrimary);
  static const navLabel = TextStyle(fontFamily: _f, fontSize: 15, color: AppColors.onPrimary);
  static const searchHint = TextStyle(fontFamily: _f, fontSize: 14, color: AppColors.grey);
  static const googleMark = TextStyle(fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.primary);
  static const googleButton = TextStyle(fontFamily: _f, fontSize: 16, color: AppColors.googleLabel);
  static const buttonLabel = TextStyle(fontFamily: _f, fontWeight: FontWeight.w600, fontSize: 15);
  static const eyebrow = TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.primary);
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
    pageTransitionsTheme: PageTransitionsTheme(builders: {for (final p in TargetPlatform.values) p: const FadeSlidePageTransitionsBuilder()}),
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(minimumSize: const Size(64, AppSize.buttonSmall))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(64, AppSize.buttonSmall))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(64, AppSize.buttonSmall))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.field,
      hintStyle: AppText.hint,
      helperStyle: AppText.small,
      errorStyle: AppText.small.copyWith(color: AppColors.danger),
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
