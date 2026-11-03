export 'package:stock_prime/services/translations.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Palette Officielle BRICELO STOCK
  // Bleu Nuit profond du logo
  static const Color primaryNavy = Color(0xFF0D1B2E);
  static const Color navy900 = Color(0xFF0D1B2E);
  static const Color navy800 = Color(0xFF162540);
  static const Color navy700 = Color(0xFF1E3052);
  static const Color circleNavy = Color(0xFF1E3052);

  // Or Bricélo chaleureux & éclatant (fidèle au chariot éclair du logo officiel)
  static const Color accentGold = Color(0xFFFFB800);
  static const Color gold500 = Color(0xFFFFB800);
  static const Color gold600 = Color(0xFFE5A600);
  static const Color gold400 = Color(0xFFFFCC33);
  static const Color goldLight = Color(0xFFFFF9E6);
  static const Color goldBorder = Color(0xFFFFE082);

  // Rouge dynamique de l'étiquette 'MARKET & STOCK'
  static const Color badgeRed = Color(0xFFFF3B30);
  static const Color danger = Color(0xFFDC2626);

  // Fonds & surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF8FAFC);

  // Ardoise neutre
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);

  // Statuts
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0EA5E9);
  static const Color badgeOrange = Color(0xFFF97316);
  static const Color orangeMoney = Color(0xFFFF6600);
  static const Color mtnYellow = Color(0xFFFFCC00);

  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF09121E),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentGold,
        brightness: Brightness.dark,
        primary: accentGold,
        secondary: accentGold,
        surface: const Color(0xFF0F1E31),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: primaryNavy,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F1E31),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E3052), width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentGold,
        primary: primaryNavy,
        secondary: accentGold,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: primaryNavy,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
    );
  }

  // Formatage monétaire F CFA
  static String formatFCFA(num amount) {
    final rounded = amount.round();
    final str = rounded.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return '$formatted F CFA';
  }
}
