import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GTTP Official Design System — Color Palette
/// Source: Figma GTTP-App-Design / Colors Page
/// All colors are exact brand values — do NOT modify without CEO approval.
class AppTheme {
  // ─────────────────────────────────────────────────────────────────
  // PRIMARY BRAND BLUE — Main identity color
  // ─────────────────────────────────────────────────────────────────
  static const Color primaryBlueLight5   = Color(0xFFE6F0FF);
  static const Color primaryBlueLight4   = Color(0xFFCCE0FF);
  static const Color primaryBlueLight3   = Color(0xFF99C2FF);
  static const Color primaryBlueLight2   = Color(0xFF66A3FF);
  static const Color primaryBlueLight1   = Color(0xFF3385FF);
  static const Color primaryBlue         = Color(0xFF0066FF); // ★ MAIN
  static const Color primaryBlueDark1    = Color(0xFF0052CC);
  static const Color primaryBlueDark2    = Color(0xFF003D99);
  static const Color primaryBlueDark3    = Color(0xFF002966);
  static const Color primaryBlueDark4    = Color(0xFF001433);

  // ─────────────────────────────────────────────────────────────────
  // DEEP NAVY — Dark mode, backgrounds, professional base
  // ─────────────────────────────────────────────────────────────────
  static const Color navyLight5          = Color(0xFFE5F0FF);
  static const Color navyLight4          = Color(0xFFB3D1FF);
  static const Color navyLight3          = Color(0xFF80B3FF);
  static const Color navyLight2          = Color(0xFF4D94FF);
  static const Color navyLight1          = Color(0xFF1A75FF);
  static const Color navyBrand           = Color(0xFF005CB5);
  static const Color navyDark1           = Color(0xFF004783);
  static const Color navyDark2           = Color(0xFF003360);
  static const Color navyDark3           = Color(0xFF001F4D);
  static const Color deepNavy            = Color(0xFF001A33); // ★ HERO COLOR

  // ─────────────────────────────────────────────────────────────────
  // ERROR RED — Alerts, pain points, validation errors
  // ─────────────────────────────────────────────────────────────────
  static const Color errorLight5         = Color(0xFFFEF2F2);
  static const Color errorLight4         = Color(0xFFFEE2E2);
  static const Color errorLight3         = Color(0xFFFECACA);
  static const Color errorLight2         = Color(0xFFFCA5A5);
  static const Color errorLight1         = Color(0xFFF87171);
  static const Color signalRed           = Color(0xFFEF4444); // ★ MAIN ERROR
  static const Color errorDark1          = Color(0xFFDC2626);
  static const Color errorDark2          = Color(0xFFB91C1C);
  static const Color errorDark3          = Color(0xFF991B1B);
  static const Color errorDark4          = Color(0xFF7F1D1D);

  // ─────────────────────────────────────────────────────────────────
  // SUCCESS GREEN — Positive outcomes, confirmations
  // ─────────────────────────────────────────────────────────────────
  static const Color successLight5       = Color(0xFFECFDF5);
  static const Color successLight4       = Color(0xFFD1FAE5);
  static const Color successLight3       = Color(0xFFA7F3D0);
  static const Color successLight2       = Color(0xFF6EE7B7);
  static const Color successLight1       = Color(0xFF34D399);
  static const Color signalGreen         = Color(0xFF10B981); // ★ MAIN SUCCESS
  static const Color successDark1        = Color(0xFF059669);
  static const Color successDark2        = Color(0xFF047857);
  static const Color successDark3        = Color(0xFF065F46);
  static const Color successDark4        = Color(0xFF064E3B);

  // ─────────────────────────────────────────────────────────────────
  // AMBER — Warnings, tips, highlights, ratings
  // ─────────────────────────────────────────────────────────────────
  static const Color amberLight5         = Color(0xFFFFFBEB);
  static const Color amberLight4         = Color(0xFFFEF3C7);
  static const Color amberLight3         = Color(0xFFFDE68A);
  static const Color amberLight2         = Color(0xFFFCD34D);
  static const Color amberLight1         = Color(0xFFFBBF24);
  static const Color signalAmber         = Color(0xFFF59E0B); // ★ MAIN WARNING
  static const Color amberDark1          = Color(0xFFD97706);
  static const Color amberDark2          = Color(0xFFB45309);
  static const Color amberDark3          = Color(0xFF92400E);
  static const Color amberDark4          = Color(0xFF78350F);

  // ─────────────────────────────────────────────────────────────────
  // SAFFRON ORANGE — Indian tricolour accent, CTA buttons (Figma exact)
  // ─────────────────────────────────────────────────────────────────
  static const Color saffronLight3       = Color(0xFFFFE0C2);
  static const Color saffronLight2       = Color(0xFFFFBF80);
  static const Color saffronLight1       = Color(0xFFFF9A3D);
  static const Color saffronOrange       = Color(0xFFF97316); // ★ MAIN CTA (Figma)
  static const Color saffronDark1        = Color(0xFFEA6B0A);
  static const Color saffronDark2        = Color(0xFFCC5A05);

  // ─────────────────────────────────────────────────────────────────
  // TECH CYAN — AI, innovation, future tech accents
  // ─────────────────────────────────────────────────────────────────
  static const Color cyanLight5          = Color(0xFFECFEFF);
  static const Color cyanLight4          = Color(0xFFCFFAFE);
  static const Color cyanLight3          = Color(0xFFA5F3FC);
  static const Color cyanLight2          = Color(0xFF67E8F9);
  static const Color cyanLight1          = Color(0xFF22D3EE);
  static const Color techCyan            = Color(0xFF06B6D4); // ★ MAIN ACCENT
  static const Color cyanDark1           = Color(0xFF0891B2);
  static const Color cyanDark2           = Color(0xFF0E7490);
  static const Color cyanDark3           = Color(0xFF155E75);
  static const Color cyanDark4           = Color(0xFF164E63);

  // ─────────────────────────────────────────────────────────────────
  // TEXT & BACKGROUNDS — UI Foundation
  // ─────────────────────────────────────────────────────────────────
  static const Color white               = Color(0xFFFFFFFF);
  static const Color bgLight             = Color(0xFFF8FAFC); // Main white / card bg
  static const Color bgPage              = Color(0xFFF1F5F9); // Page background
  static const Color borderLight         = Color(0xFFE2E8F0); // Dividers/borders
  static const Color borderMid           = Color(0xFFCBD5E1); // Disabled/placeholder
  static const Color textPlaceholder     = Color(0xFF94A3B8); // Inactive icons
  static const Color textMuted           = Color(0xFF64748B); // Captions, timestamps
  static const Color textBody            = Color(0xFF475569); // Body paragraphs
  static const Color textSubhead         = Color(0xFF334155); // H3, H4 sub-headlines
  static const Color textHeading         = Color(0xFF1E293B); // H1, H2 main headlines
  static const Color textDark            = Color(0xFF0F172A); // Darkest text color

  // ─────────────────────────────────────────────────────────────────
  // THEME — Light Mode
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgPage,
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: techCyan,
        error: signalRed,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onError: white,
        onSurface: textDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: signalRed),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        filled: true,
        fillColor: white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // THEME — Dark Mode (coming soon)
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: deepNavy,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: techCyan,
        error: signalRed,
        surface: navyDark3,
        onPrimary: white,
        onSecondary: white,
        onError: white,
        onSurface: bgLight,
      ),
    );
  }
}
