import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    // Activités dynamiques calculées depuis les ventes, mouvements de stock, dépenses
    final List<Map<String, dynamic>> activities = [];

    for (final sale in appState.sales) {
      activities.add({
        'title': 'Vente enregistrée (${AppTheme.formatFCFA(sale.total)})',
        'subtitle': 'Ticket #${sale.ticketNumber} • ${sale.paymentMethod} • Caissier: ${sale.cashierName}',
        'date': sale.createdAt,
        'icon': Icons.point_of_sale_rounded,
        'color': const Color(0xFF10B981),
      });
    }

    for (final sm in appState.stockMovements) {
      activities.add({
        'title': 'Mouvement de stock: ${sm.productName}',
        'subtitle': '${sm.type} • Qté: ${sm.quantity} • Nouveau stock: ${sm.newStock} • ${sm.reason}',
        'date': sm.date,
        'icon': Icons.warehouse_rounded,
        'color': AppTheme.accentGold,
      });
    }

    for (final exp in appState.expenses) {
      activities.add({
        'title': 'Dépense enregistrée: ${exp.description}',
        'subtitle': '${AppTheme.formatFCFA(exp.amount)} • Catégorie: ${exp.category} • Par: ${exp.paidBy}',
        'date': exp.createdAt,
        'icon': Icons.payments_outlined,
        'color': const Color(0xFFDC2626),
      });
    }

    activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

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
          'Historique d\'activité'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: activities.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_toggle_off_rounded, size: 54, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune activité enregistrée'.tr,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Les ventes, approvisionnements et dépenses apparaîtront ici.'.tr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final act = activities[index];
                final dt = act['date'] as DateTime;
                final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (act['color'] as Color).withValues(alpha: isDark ? 0.3 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(act['icon'] as IconData, size: 20, color: act['color'] as Color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act['subtitle'] as String,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
