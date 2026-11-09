import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/services/app_state.dart';

class SalesAndCustomersScreen extends StatelessWidget {
  const SalesAndCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);
        final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
        final dividerCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFF3F4F6);

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
            ),
            title: Text(
              'Ventes & clients'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Ventes'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Historique des ventes'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
                      },
                    ),
                    Divider(height: 1, indent: 52, color: dividerCol),
                    _buildRow(
                      icon: Icons.request_quote_rounded,
                      title: 'Devis'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotesScreen()));
                      },
                    ),
                    Divider(height: 1, indent: 52, color: dividerCol),
                    _buildRow(
                      icon: Icons.analytics_rounded,
                      title: 'Analyse des ventes'.tr,
                      trailingIcon: Icons.chevron_right,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesAnalyticsScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Clients'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      icon: Icons.groups_rounded,
                      title: 'Clients'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
                      },
                    ),
                    Divider(height: 1, indent: 52, color: dividerCol),
                    _buildRow(
                      icon: Icons.price_check_rounded,
                      title: 'Recouvrement des dettes'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textPrimary,
    required bool isDark,
    IconData trailingIcon = Icons.chevron_right,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDark ? AppTheme.accentGold : const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
              ),
            ),
            Icon(trailingIcon, size: 20, color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
