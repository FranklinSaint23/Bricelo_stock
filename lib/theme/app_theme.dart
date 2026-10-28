import 'package:flutter/material.dart';

class AppTheme {
  // Palette Officielle BRICÉLO
  static const Color primaryNavy = Color(0xFF0D1B2E);
  // Alias de compatibilité
  static const Color navy900 = Color(0xFF0D1B2E);
  static const Color gold500 = Color(0xFFF5B000);
  static const Color gold400 = Color(0xFFFFD04D);
       // Bleu Nuit Bricélo officiel
  static const Color navy800 = Color(0xFF162540);          // Bleu Nuit relevé
  static const Color navy700 = Color(0xFF1E3052);
  static const Color circleNavy = Color(0xFF1E3052);        // Fond rond bouton retour
  
  static const Color accentGold = Color(0xFFF5B000);        // Or Bricélo officiel
  static const Color goldLight = Color(0xFFFEF3C7);         // Or clair doux pour sélections
  static const Color goldBorder = Color(0xFFFDE68A);
  static const Color gold600 = Color(0xFFD99C00);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF8FAFC);

  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0EA5E9);
  static const Color badgeOrange = Color(0xFFF97316);
  static const Color orangeMoney = Color(0xFFFF6600);
  static const Color mtnYellow = Color(0xFFFFCC00);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
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
