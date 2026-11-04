import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class ExpensesAnalyticsScreen extends StatelessWidget {
  const ExpensesAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    final expenses = appState.expenses;
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

    // Regroupement par catégorie
    final Map<String, double> categoryTotals = {};
    for (final e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0.0) + e.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: pageBg,
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
        title: Text(
          'Analyse des sorties'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // CARTE RÉSUMÉ TOTAL SORTIES
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL DÉPENSES & CHARGES'.tr,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.analytics_outlined, color: AppTheme.accentGold, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppTheme.formatFCFA(totalExpenses),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${expenses.length} dépense(s) enregistrée(s) au total'.tr,
                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Répartition par catégorie de dépense'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
          ),
          const SizedBox(height: 12),

          if (sortedCategories.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Center(
                child: Text('Aucune dépense enregistrée pour le moment.'.tr, style: const TextStyle(color: Color(0xFF94A3B8))),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: sortedCategories.map((entry) {
                  final pct = totalExpenses > 0 ? (entry.value / totalExpenses) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: textColor),
                            ),
                            Text(
                              '${AppTheme.formatFCFA(entry.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentGold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: isDark ? const Color(0xFF0F1A28) : const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

