import 'package:flutter/material.dart';

/// Luxury navy-and-gold theme for Mada Pay Central.
/// Uses Flutter SDK only; no additional package dependencies.
abstract final class MadaLuxuryTheme {
  static const navy = Color(0xFF071120);
  static const navy2 = Color(0xFF101D31);
  static const panel = Color(0xE8263040);
  static const gold = Color(0xFFFFD77A);
  static const goldDeep = Color(0xFFC79535);
  static const cyan = Color(0xFF9CECF4);
  static const muted = Color(0xFFB9C5D4);
  static const danger = Color(0xFFFF7777);
  static const success = Color(0xFF75E0A0);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: goldDeep,
      brightness: Brightness.dark,
      primary: gold,
      secondary: cyan,
      surface: navy2,
      error: danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: navy,
      fontFamily: null, // Keep the app's existing Arabic font configuration.
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: gold,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: gold.withValues(alpha: .55), width: 1),
        ),
      ),
      dividerColor: gold.withValues(alpha: .22),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navy2,
        indicatorColor: gold.withValues(alpha: .22),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? gold : muted,
            fontSize: 11,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? gold : muted,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navy2,
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: gold.withValues(alpha: .3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: gold.withValues(alpha: .3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
      ),
    );
  }
}
