import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF070E1E);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFE99A);
  static const Color goldButtonStart = Color(0xFFFFE27B);
  static const Color goldButtonEnd = Color(0xFFD4A017);
  static const Color cyanLight = Color(0xFF8ED8E8);
  static const Color whiteDim = Color(0xFFB0B8C8);
  static const Color borderGold = Color(0x66FFD700);
  static const Color fieldBg = Color(0x33FFFFFF);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldButtonStart, goldButtonEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxDecoration glassCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.white.withOpacity(0.07),
    border: Border.all(color: borderGold, width: 1),
  );

  static BoxDecoration textFieldDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    color: fieldBg,
    border: Border.all(color: Color(0x80FFD700), width: 1),
  );

  static BoxDecoration goldButtonDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    gradient: goldGradient,
  );

  static const TextStyle agencyName = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: goldLight,
  );

  static const TextStyle sub1 = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: cyanLight,
  );

  static const TextStyle sub2 = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 11,
    color: whiteDim,
  );

  static const TextStyle loginTitle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: goldLight,
  );

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: background,
      fontFamily: 'Cairo',
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: cyanLight,
      ),
    );
  }
}
