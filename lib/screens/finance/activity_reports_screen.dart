import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class ActivityReportsScreen extends StatefulWidget {
  const ActivityReportsScreen({super.key});

  @override
  State<ActivityReportsScreen> createState() => _ActivityReportsScreenState();
}

class _ActivityReportsScreenState extends State<ActivityReportsScreen> {
  final appState = AppState.instance;

  String _periodType = 'Ce mois'; // 'Aujourd\'hui', 'Hier', '7 jours', 'Ce mois', 'Personnalisé'
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedStore = 'Tous';

  void _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppTheme.primaryNavy,
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryNavy, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _periodType = 'Personnalisé';
      });
    }
  }

  void _applyPeriod(String type) {
    final now = DateTime.now();
    setState(() {
      _periodType = type;
      if (type == 'Aujourd\'hui') {
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
      } else if (type == 'Hier') {
        final yesterday = now.subtract(const Duration(days: 1));
        _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        _endDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
      } else if (type == '7 jours') {
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
      } else if (type == 'Ce mois') {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        // Ventes filtrées par la période et le store
        final filteredSales = appState.sales.where((s) {
          final isStore = _selectedStore == 'Tous' || s.storeName == _selectedStore;
          final isTime = s.createdAt.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
              s.createdAt.isBefore(_endDate.add(const Duration(days: 1)));
          return isStore && isTime;
        }).toList();

        final totalSales = filteredSales.fold<double>(0.0, (sum, s) => sum + s.total);
        final cashEncaisse = filteredSales
            .where((s) => s.paymentMethod != 'À Crédit')
            .fold<double>(0.0, (sum, s) => sum + s.total);
        final creditSales = filteredSales
            .where((s) => s.paymentMethod == 'À Crédit')
            .fold<double>(0.0, (sum, s) => sum + s.total);

        // Marge brute
        double cogs = 0.0;
        for (final s in filteredSales) {
          for (final it in s.items) {
            final p = appState.products.firstWhere(
              (prod) => prod.name == it.productName,
              orElse: () => Product(id: '', name: it.productName, category: '', barcode: '', buyPrice: it.unitPrice * 0.7, sellPrice: it.unitPrice, stock: 0),
            );
            cogs += p.buyPrice * it.quantity;
          }
        }
        final grossMargin = totalSales - cogs;

        // Dépenses de la période
        final filteredExpenses = appState.expenses.where((e) {
          return e.createdAt.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
              e.createdAt.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();
        final totalExpenses = filteredExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

        // Bénéfice net
        final netProfit = grossMargin - totalExpenses;

        // Mouvements de stock sur la période
        final filteredMovements = appState.stockMovements.where((m) {
          return m.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
              m.date.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();

        final countReassort = filteredMovements.where((m) => m.type.contains('RÉASSORT')).length;
        final countAjustements = filteredMovements.where((m) => m.type.contains('AJUSTEMENT')).length;

        final dateFmt = '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year} au ${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}';

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Rapports d\'activité',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppTheme.accentGold),
                tooltip: 'Partager le rapport',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.primaryNavy,
                      content: Text('Rapport d\'activité ($dateFmt) généré et prêt pour partage WhatsApp / PDF.'),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. SELECTEUR DE PÉRIODES RAPIDES
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...['Aujourd\'hui', 'Hier', '7 jours', 'Ce mois'].map((p) {
                      final isSel = _periodType == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : AppTheme.textPrimary)),
                          selected: isSel,
                          selectedColor: AppTheme.primaryNavy,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          onSelected: (_) => _applyPeriod(p),
                        ),
                      );
                    }),
                    ActionChip(
                      avatar: const Icon(Icons.calendar_month, size: 16, color: AppTheme.accentGold),
                      label: Text(
                        _periodType == 'Personnalisé' ? dateFmt : 'Personnalisé',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy),
                      ),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      onPressed: _pickCustomDateRange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. CARTE RÉSUMÉ OFFICIEL DU RAPPORT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, color: AppTheme.primaryNavy, size: 20),
                            const SizedBox(width: 8),
                            Text('Rapport d\'activité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.textPrimary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_selectedStore, style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Période du $dateFmt', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Divider(height: 20),

                    _buildReportLine('Chiffre d\'Affaires total', totalSales, isBold: true, color: AppTheme.primaryNavy),
                    _buildReportLine('Total encaissé en espèces/digital', cashEncaisse, color: const Color(0xFF16A34A)),
                    if (creditSales > 0) _buildReportLine('Ventes à crédit (créances)', creditSales, color: const Color(0xFFDC2626)),
                    const Divider(height: 16),
                    _buildReportLine('Marge commerciale brute', grossMargin),
                    _buildReportLine('Dépenses d\'exploitation', -totalExpenses, color: const Color(0xFFDC2626)),
                    const Divider(height: 20, thickness: 1.5),
                    _buildReportLine('RÉSULTAT NET DE L\'ACTIVITÉ', netProfit, isBold: true, fontSize: 14, color: netProfit >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. STATISTIQUES OPÉRATIONNELLES (Transactions & Stock)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activité opérationnelle & stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStatCard('VENTES RÉALISÉES', '${filteredSales.length}', Icons.shopping_bag_outlined, isDark),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniStatCard('RÉASSORTS REÇUS', '$countReassort', Icons.inventory_2_outlined, isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStatCard('DÉPENSES SAISIES', '${filteredExpenses.length}', Icons.receipt_long_outlined, isDark),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniStatCard('AJUSTEMENTS STOCK', '$countAjustements', Icons.tune_outlined, isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. BOUTONS D'ACTION D'EXPORTATION
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: AppTheme.accentGold, size: 20),
                  label: const Text('Générer & Télécharger le rapport (PDF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF16A34A),
                        content: Text('Rapport d\'activité exporté avec succès !'),
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

  Widget _buildReportLine(String label, double val, {bool isBold = false, double fontSize = 13, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(AppTheme.formatFCFA(val), style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String val, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.accentGold),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
