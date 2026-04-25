import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────
  static const Color primary = Color(0xFFE53935); // GymSwift red
  static const Color primaryDark = Color(0xFFC62828); // pressed red
  static const Color primaryLight = Color(0xFFFFEBEE); // red tint bg

  static const Color dark = Color(0xFF212121);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);

  // ── Status Colors ─────────────────────────────────────────
  static const Color active = Color(0xFF4CAF50); // green
  static const Color activeLight = Color(0xFFE8F5E9);
  static const Color expired = Color(0xFFE53935); // red
  static const Color expiredLight = Color(0xFFFFEBEE);
  static const Color pending = Color(0xFFFF9800); // orange
  static const Color pendingLight = Color(0xFFFFF3E0);

  // ── Text Colors ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF9CA3AF);

  // ── Border & Shadow ───────────────────────────────────────
  static const Color border = Color(0xFFE0E0E0);
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 10,
    offset: const Offset(0, 3),
  );

  // ── Radius ────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // ── ThemeData ─────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: textOnPrimary,
      surface: surface,
      background: background,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Poppins',

    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: textOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textOnPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? primary
            : Colors.transparent,
      ),
      side: const BorderSide(color: border, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),
  );
}

// ── Reusable Widget Helpers ───────────────────────────────────
class AppColors {
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.active;
      case 'expired':
        return AppTheme.expired;
      case 'pending':
        return AppTheme.pending;
      default:
        return AppTheme.textSecondary;
    }
  }

  static Color statusLightColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.activeLight;
      case 'expired':
        return AppTheme.expiredLight;
      case 'pending':
        return AppTheme.pendingLight;
      default:
        return AppTheme.background;
    }
  }
}
