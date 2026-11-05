import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/sales/debts_screen.dart';
import 'package:stock_prime/screens/finance/accounting_detail_views.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.auto_stories_rounded,
        'title': 'Journal & activation',
        'builder': (BuildContext ctx) => const AccountingJournalScreen(),
      },
      {
        'icon': Icons.scale_rounded,
        'title': 'Balance',
        'builder': (BuildContext ctx) => const TrialBalanceScreen(),
      },
      {
        'icon': Icons.person_pin_circle_rounded,
        'title': 'Clients à crédit',
        'builder': (BuildContext ctx) => const DebtsScreen(),
      },
      {
        'icon': Icons.query_stats_rounded,
        'title': 'Compte de résultat',
        'builder': (BuildContext ctx) => const IncomeStatementScreen(),
      },
      {
        'icon': Icons.account_balance_rounded,
        'title': 'Bilan',
        'builder': (BuildContext ctx) => const BalanceSheetScreen(),
      },
      {
        'icon': Icons.percent_rounded,
        'title': 'TVA',
        'builder': (BuildContext ctx) => const VatReportScreen(),
      },
      {
        'icon': Icons.badge_rounded,
        'title': 'Paie',
        'builder': (BuildContext ctx) => const PayrollScreen(),
      },
      {
        'icon': Icons.domain_rounded,
        'title': 'Immobilisations',
        'builder': (BuildContext ctx) => const FixedAssetsScreen(),
      },
      {
        'icon': Icons.lock_clock_rounded,
        'title': 'Clôture',
        'builder': (BuildContext ctx) => const DailyClosingScreen(),
      },
      {
        'icon': Icons.folder_shared_rounded,
        'title': 'Médiathèque',
        'builder': (BuildContext ctx) => const AccountingMediaScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
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
        title: const Text(
          'Comptabilité & trésorerie',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6)),
                  _buildNavRow(
                    context,
                    icon: items[i]['icon'] as IconData,
                    title: items[i]['title'] as String,
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
  }

  Widget _buildNavRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
