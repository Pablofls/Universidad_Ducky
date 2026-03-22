import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colores principales (tomados del prototipo Figma) ──────────────────────
  static const Color primary = Color(0xFF0E7334);       // green universitario (--primary)
  static const Color primaryLight = Color(0xFFEFF6FF);  // blue-50
  static const Color primaryDark = Color(0xFF1D4ED8);   // blue-700

  // Semánticos
  static const Color success = Color(0xFF10B981);       // green-500
  static const Color successLight = Color(0xFFD1FAE5);  // green-100
  static const Color warning = Color(0xFFF59E0B);       // amber-500
  static const Color warningLight = Color(0xFFFEF3C7);  // amber-100
  static const Color error = Color(0xFFEF4444);         // red-500
  static const Color errorLight = Color(0xFFFEE2E2);    // red-100
  static const Color info = Color(0xFF8B5CF6);          // violet-500
  static const Color infoLight = Color(0xFFEDE9FE);     // violet-100

  // Grises (Tailwind gray)
  static const Color gray900 = Color(0xFF111827);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray50  = Color(0xFFF9FAFB);
  static const Color white   = Color(0xFFFFFFFF);

  // Background general
  static const Color backgroundGray = Color(0xFFF9FAFB);

  // ── Sidebar ────────────────────────────────────────────────────────────────
  static const double sidebarWidth = 256.0; // 64 * 4 = 256px (w-64)

  // ── Radios de borde ────────────────────────────────────────────────────────
  static const double radiusSm  = 6.0;
  static const double radiusMd  = 8.0;
  static const double radiusLg  = 12.0;
  static const double radiusXl  = 16.0;
  static const double radius2xl = 20.0;

  // ── Sombras ────────────────────────────────────────────────────────────────
  static final BoxShadow shadowSm = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 4,
    offset: const Offset(0, 1),
  );
  static final BoxShadow shadowMd = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  static final BoxShadow shadowLg = BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );

  // ── MaterialTheme ──────────────────────────────────────────────────────────
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        // Evita que Material3 inyecte tints de color en surfaces
        surface: white,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: backgroundGray,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        // Headings
        displayLarge: GoogleFonts.inter(
          fontSize: 36, fontWeight: FontWeight.w700, color: gray900,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 30, fontWeight: FontWeight.w700, color: gray900,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w600, color: gray900,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: gray900,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: gray900,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: gray900,
        ),
        // Body
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: gray700,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: gray700,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: gray500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: gray700,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: gray600,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500, color: gray500,
        ),
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: gray200),
        ),
        margin: EdgeInsets.zero,
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: gray400),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: gray600),
      ),
      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gray700,
          side: const BorderSide(color: gray300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      // Divider
      dividerTheme: const DividerThemeData(color: gray200, thickness: 1),
      // AppBar (no se usa mucho, tenemos sidebar)
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: gray900,
        ),
      ),
    );
  }
}
