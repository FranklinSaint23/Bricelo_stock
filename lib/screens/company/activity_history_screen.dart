import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

enum ActivityType { all, sale, supply, expense }

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final appState = AppState.instance;
  ActivityType _selectedFilter = ActivityType.all;

  List<Map<String, dynamic>> _buildActivities() {
    final List<Map<String, dynamic>> list = [];

    // 1. VENTES
    for (final sale in appState.sales) {
      list.add({
        'type': ActivityType.sale,
        'badge': 'VENTE',
        'title': 'Ticket #${sale.ticketNumber}',
        'subtitle': '${sale.items.length} article(s) • ${sale.paymentMethod} • ${sale.storeName}',
        'amount': sale.total,
        'amountPrefix': '+',
        'amountColor': const Color(0xFFD97706), // Warm Gold
        'date': sale.createdAt,
        'icon': Icons.point_of_sale_rounded,
        'iconBg': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFB45309),
        'raw': sale,
      });
    }

    // 2. APPROVISIONNEMENTS (Commandes fournisseurs & réceptions)
    for (final po in appState.purchaseOrders) {
      list.add({
        'type': ActivityType.supply,
        'badge': 'APPROV.',
        'title': po.supplierName.isNotEmpty ? po.supplierName : 'Approvisionnement',
        'subtitle': '${po.reference} • ${po.items.length} article(s) • ${po.destinationStore}',
        'amount': po.totalAmount,
        'amountPrefix': '',
        'amountColor': AppTheme.primaryNavy,
        'date': po.createdAt,
        'icon': Icons.move_to_inbox_rounded,
        'iconBg': const Color(0xFFE0E7FF),
        'iconColor': const Color(0xFF3730A3),
        'raw': po,
      });
    }

    // 3. DÉPENSES
    for (final exp in appState.expenses) {
      list.add({
        'type': ActivityType.expense,
        'badge': 'DÉPENSE',
        'title': exp.description.isNotEmpty ? exp.description : exp.category,
        'subtitle': 'Catégorie : ${exp.category} • ${exp.paidFromCaisse}',
        'amount': exp.amount,
        'amountPrefix': '-',
        'amountColor': const Color(0xFFDC2626), // Rouge dépense
        'date': exp.createdAt,
        'icon': Icons.payments_outlined,
        'iconBg': const Color(0xFFFEE2E2),
        'iconColor': const Color(0xFF991B1B),
        'raw': exp,
      });
    }

    // Tri chronologique strict (plus récent en haut)
    list.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Filtrage par onglet
    if (_selectedFilter == ActivityType.all) return list;
    return list.where((item) => item['type'] == _selectedFilter).toList();
  }

  void _showActivityDetail(BuildContext context, Map<String, dynamic> act) {
    final isDark = appState.isDarkMode;
    final type = act['type'] as ActivityType;
    final dt = act['date'] as DateTime;
    final dateStr = '${dt.day.toString().padLeft(2, "0")}/${dt.month.toString().padLeft(2, "0")}/${dt.year} à ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: act['iconBg'] as Color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(act['icon'] as IconData, color: act['iconColor'] as Color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Activité enregistrée',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Montant
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${act['amountPrefix']}${AppTheme.formatFCFA(act['amount'] as double)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: act['amountColor'] as Color,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Détails clés
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildRowDetail('Opération', act['badge'] as String),
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                      _buildRowDetail('Détails', act['subtitle'] as String),
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                      _buildRowDetail('Date & Heure', dateStr),
                      if (type == ActivityType.sale) ...[
                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                        _buildRowDetail('Caissier', (act['raw']).cashierName ?? 'Admin'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: AppTheme.accentGold,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF8FAFC);
        final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

        final activities = _buildActivities();

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
          body: Column(
            children: [
              // 1. BARRE DE FILTRES SEGMENTÉE (TOUT, VENTES, APPROV., DÉPENSES)
              Container(
                color: AppTheme.primaryNavy,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildFilterTab(ActivityType.all, 'Tout'),
                      _buildFilterTab(ActivityType.sale, 'Ventes'),
                      _buildFilterTab(ActivityType.supply, 'Approv.'),
                      _buildFilterTab(ActivityType.expense, 'Dépenses'),
                    ],
                  ),
                ),
              ),

              // 2. LISTE D'ACTIVITÉ OU ÉTAT VIDE
              Expanded(
                child: activities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history_toggle_off_rounded, size: 36, color: AppTheme.accentGold),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Aucune activité enregistrée'.tr,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Les ventes, approvisionnements et dépenses apparaîtront ici de manière ordonnée.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final act = activities[index];
                          final dt = act['date'] as DateTime;
                          final dateStr = '${dt.day.toString().padLeft(2, "0")}/${dt.month.toString().padLeft(2, "0")}/${dt.year} à ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}';

                          return InkWell(
                            onTap: () => _showActivityDetail(context, act),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: act['iconBg'] as Color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(act['icon'] as IconData, size: 22, color: act['iconColor'] as Color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (act['iconBg'] as Color).withValues(alpha: 0.6),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                act['badge'] as String,
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: act['iconColor'] as Color,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                act['title'] as String,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          act['subtitle'] as String,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          dateStr,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${act['amountPrefix']}${AppTheme.formatFCFA(act['amount'] as double)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: act['amountColor'] as Color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(ActivityType type, String label) {
    final isSelected = _selectedFilter == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = type),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentGold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? AppTheme.primaryNavy : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
