import 'package:flutter/material.dart';

class AppTheme {
  // ============ الألوان المأخوذة من الصورة بالضبط ============
  static const Color background = Color(0xFF070E1E); // الخلفية الداكنة
  static const Color gold = Color(0xFFFFD700); // الذهبي
  static const Color goldLight = Color(0xFFFFE99A); // ذهبي فاتح للعناوين
  static const Color goldButtonStart = Color(0xFFFFE27B);
  static const Color goldButtonEnd = Color(0xFFD4A017);
  static const Color cyanLight = Color(0xFF8ED8E8); // الأزرق الفاتح للنص الثاني
  static const Color whiteDim = Color(0xFFB0B8C8);
  static const Color glass = Color(0x1AFFFFFF); // الزجاج
  static const Color borderGold = Color(0x66FFD700);
  static const Color fieldBg = Color(0x33FFFFFF);

  // ============ تدرجات وزخرفات ============
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldButtonStart, goldButtonEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============ ديكور الفورم والحقول ============
  static BoxDecoration glassCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.white.withOpacity(0.07),
    border: Border.all(color: borderGold, width: 1),
  );

  static BoxDecoration textFieldDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    color: fieldBg,
    border: Border.all(color: borderGold.withOpacity(0.5)),
  );

  static BoxDecoration goldButtonDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    gradient: goldGradient,
    boxShadow: [BoxShadow(color: gold.withOpacity(0.4), blurRadius: 12, offset: Offset(0,4))],
  );

  // ============ ألوان الخطوط ============
  static const TextStyle agencyName = TextStyle(
    fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.bold, color: goldLight
  );
  static const TextStyle sub1 = TextStyle(
    fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w500, color: cyanLight
  );
  static const TextStyle sub2 = TextStyle(
    fontFamily: 'Cairo', fontSize: 11, color: whiteDim
  );
  static const TextStyle loginTitle = TextStyle(
    fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: goldLight
  );
}
