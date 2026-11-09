import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/services/app_state.dart';

class PurchasesAndExpensesScreen extends StatelessWidget {
  const PurchasesAndExpensesScreen({super.key});

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
              'Achats & dépenses'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(Icons.domain_rounded, 'Fournisseurs'.tr, isLocked: false, textPrimary: textPrimary, isDark: isDark, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen()));
                    }),
                    _buildDivider(dividerCol),
                    _buildRow(Icons.receipt_long_rounded, 'Bons d\'achat'.tr, isLocked: false, textPrimary: textPrimary, isDark: isDark, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseOrdersScreen()));
                    }),
                    _buildDivider(dividerCol),
                    _buildRow(Icons.price_change_rounded, 'Dépenses'.tr, isLocked: false, textPrimary: textPrimary, isDark: isDark, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
                    }),
                    _buildDivider(dividerCol),
                    _buildRow(Icons.insights_rounded, 'Analyse des sorties'.tr, isLocked: false, textPrimary: textPrimary, isDark: isDark, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesAnalyticsScreen()));
                    }),
                    _buildDivider(dividerCol),
                    _buildRow(Icons.request_quote_rounded, 'Coût d\'achat'.tr, isLocked: false, textPrimary: textPrimary, isDark: isDark, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseCostsScreen()));
                    }),
                    _buildDivider(dividerCol),
                    _buildRow(Icons.credit_card_off_rounded, 'Dettes fournisseurs'.tr, isLocked: false, textPrimary: textPrimary, isDark: isDark, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierDebtsScreen()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(
    IconData icon,
    String title, {
    required bool isLocked,
    required Color textPrimary,
    required bool isDark,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
            if (badgeText != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.goldBorder),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.gold600),
                ),
              ),
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, indent: 52, color: color);
  }
}
