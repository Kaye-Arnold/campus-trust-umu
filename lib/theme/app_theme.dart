import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const bgPrimary   = Color(0xFF0F172A); // deep midnight — scaffold
  static const bgSurface   = Color(0xFF1E293B); // card / bottom sheet surface
  static const bgInput     = Color(0xFF1E293B); // search bar / text field fill
  static const bgOverlay   = Color(0xFF2D1F10); // review sheet scrim tint

  // ── Accent ──────────────────────────────────────────────────────────────────
  static const primary     = Color(0xFFFF5722); // vibrant orange
  static const primaryDark = Color(0xFFE64A19); // pressed / gradient end
  static const primaryMuted= Color(0xFF3D1A0A); // orange icon circle bg

  // ── WhatsApp ────────────────────────────────────────────────────────────────
  static const whatsapp    = Color(0xFF25D366);
  static const whatsappDark= Color(0xFF128C3E);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const textPrimary  = Color(0xFFFFFFFF);
  static const textSecondary= Color(0xFF94A3B8); // slate-400
  static const textMuted    = Color(0xFF475569); // slate-600

  // ── Misc ────────────────────────────────────────────────────────────────────
  static const star         = Color(0xFFFF5722); // orange stars — matches mockup
  static const divider      = Color(0xFF1E293B);
  static const avatarBg     = Color(0xFF3D1A0A);
  static const border       = Color(0xFF334155);
  /// Warm amber used for the General Fundis illustration box in HomeScreen
  static const featuredIllustration = Color(0xFFF5A623);
  /// Warm dark brown for the review bottom sheet surface (mockup 3)
  static const bgSheet      = Color(0xFF1A120A);
}

class AppTheme {
  static ThemeData get dark {
    final base = GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.bgSurface,
        // NOTE: 'background' is deprecated in M3/Flutter 3.16+.
        // scaffoldBackgroundColor above handles the scaffold bg correctly.
      ),
      textTheme: base.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
