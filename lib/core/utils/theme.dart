import 'package:flutter/material.dart';

class AppTheme {
  // ── Core Colours ──────────────────────────────────────────────
  static const Color primary    = Color(0xFF2DBE6C); // healthy green
  static const Color primaryDark= Color(0xFF1E9952);
  static const Color accent     = Color(0xFF57D68D);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface    = Color(0xFFF5FBF7);
  static const Color textDark   = Color(0xFF111827);
  static const Color textGrey   = Color(0xFF6B7280);
  static const Color border     = Color(0xFFE5E7EB);

  // ── Theme ─────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: ColorScheme.light(
      primary:   primary,
      secondary: accent,
      surface:   surface,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark, fontSize: 17, fontWeight: FontWeight.w700,
      ),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),

    // Input / TextFormField
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: const TextStyle(color: textGrey, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primary : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? accent : border,
      ),
    ),

    // Card
    // cardTheme: CardTheme(
    //   color: surface,
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(14),
    //     side: const BorderSide(color: border),
    //   ),
    // ),

    // Text
    textTheme: const TextTheme(
      titleLarge : TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium : TextStyle(color: textDark, fontSize: 14),
      bodySmall  : TextStyle(color: textGrey, fontSize: 12),
    ),
  );
}