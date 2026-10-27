import 'package:flutter/material.dart';

class AppTheme {
  // Palette officielle BRICÉLO
  static const Color navy900 = Color(0xFF0D1B2E);
  static const Color navy800 = Color(0xFF162540);
  static const Color navy700 = Color(0xFF1E3052);
  static const Color navy600 = Color(0xFF264063);

  static const Color gold500 = Color(0xFFF5B000);
  static const Color gold400 = Color(0xFFFFD04D);
  static const Color gold600 = Color(0xFFD99C00);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceRaised = Color(0xFFF1F5F9);

  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0EA5E9);
  static const Color orangeMoney = Color(0xFFFF6600);
  static const Color mtnYellow = Color(0xFFFFCC00);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy900,
        primary: navy900,
        secondary: gold500,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy900,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy900,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Formatage monétaire FCFA avec séparateur '.'
  static String formatFCFA(num amount) {
    final rounded = amount.round();
    final str = rounded.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return '$formatted FCFA';
  }
}
