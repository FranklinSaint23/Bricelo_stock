import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

void showUpgradeDialog(BuildContext context, String featureName) {
  final isDark = AppState.instance.isDarkMode;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fonctionnalité Pro'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'La fonctionnalité "$featureName" nécessite un abonnement Formule Pro ou Entreprise.\n\n'
        'Activez votre abonnement sur le portail web ou auprès de votre administrateur pour débloquer l\'accès immédiat.'.tr,
        style: TextStyle(
          fontSize: 13,
          height: 1.45,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Compris'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
            ),
          ),
        ),
      ],
    ),
  );
}
