import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/sales/debts_screen.dart';
import 'package:stock_prime/screens/finance/accounting_detail_views.dart';
import 'package:stock_prime/widgets/dialogs/upgrade_dialog.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    final items = [
      {
        'icon': Icons.auto_stories_rounded,
        'title': 'Journal & activation',
        'requiresPro': false,
        'builder': (BuildContext ctx) => const AccountingJournalScreen(),
      },
      {
        'icon': Icons.scale_rounded,
        'title': 'Balance',
        'requiresPro': false,
        'builder': (BuildContext ctx) => const TrialBalanceScreen(),
      },
      {
        'icon': Icons.person_pin_circle_rounded,
        'title': 'Clients à crédit',
        'requiresPro': false,
        'builder': (BuildContext ctx) => const DebtsScreen(),
      },
      {
        'icon': Icons.query_stats_rounded,
        'title': 'Compte de résultat',
        'requiresPro': true,
        'builder': (BuildContext ctx) => const IncomeStatementScreen(),
      },
      {
        'icon': Icons.account_balance_rounded,
        'title': 'Bilan',
        'requiresPro': true,
        'builder': (BuildContext ctx) => const BalanceSheetScreen(),
      },
      {
        'icon': Icons.percent_rounded,
        'title': 'TVA',
        'requiresPro': true,
        'builder': (BuildContext ctx) => const VatReportScreen(),
      },
      {
        'icon': Icons.badge_rounded,
        'title': 'Paie',
        'requiresPro': true,
        'builder': (BuildContext ctx) => const PayrollScreen(),
      },
      {
        'icon': Icons.domain_rounded,
        'title': 'Immobilisations',
        'requiresPro': true,
        'builder': (BuildContext ctx) => const FixedAssetsScreen(),
      },
      {
        'icon': Icons.lock_clock_rounded,
        'title': 'Clôture',
        'requiresPro': true,
        'builder': (BuildContext ctx) => const DailyClosingScreen(),
      },
      {
        'icon': Icons.folder_shared_rounded,
        'title': 'Médiathèque',
        'requiresPro': true,
        'builder': (BuildContext ctx) => const AccountingMediaScreen(),
      },
    ];

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final isDiscovered = appState.isDiscoveredPlan;
        final pageBg = isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB);
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);
        final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
        final dividerCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFF3F4F6);

        return Scaffold(
          backgroundColor: pageBg,
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
              'Comptabilité & trésorerie'.tr,
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
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) Divider(height: 1, indent: 52, color: dividerCol),
                      _buildNavRow(
                        context,
                        icon: items[i]['icon'] as IconData,
                        title: (items[i]['title'] as String).tr,
                        textPrimary: textPrimary,
                        isDark: isDark,
                        isLocked: isDiscovered && (items[i]['requiresPro'] == true),
                        onTap: () {
                          final builder = items[i]['builder'] as Widget Function(BuildContext);
                          Navigator.push(context, MaterialPageRoute(builder: builder));
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color textPrimary,
    required bool isDark,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        if (isLocked) {
          showUpgradeDialog(context, title);
        } else {
          onTap();
        }
      },
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
            Icon(
              isLocked ? Icons.lock_rounded : Icons.chevron_right,
              size: isLocked ? 19 : 20,
              color: isLocked
                  ? const Color(0xFFD97706)
                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}
