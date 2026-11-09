import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/global_stats_pdf_service.dart';

class ActivityReportsScreen extends StatefulWidget {
  const ActivityReportsScreen({super.key});

  @override
  State<ActivityReportsScreen> createState() => _ActivityReportsScreenState();
}

class _ActivityReportsScreenState extends State<ActivityReportsScreen> {
  final appState = AppState.instance;

  String _selectedStore = 'Tous';
  String _selectedPeriod = 'Ce mois';
  DateTimeRange? _customDateRange;

  final List<String> _periods = const [
    'Aujourd\'hui',
    'Hier',
    'Cette semaine',
    'Semaine passée',
    'Ce mois',
    'Le mois passé',
    'Cette année',
    'L\'année dernière',
    'Personnalisé',
  ];

  String _monthName(int m) {
    const months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    if (m >= 1 && m <= 12) return months[m - 1];
    return '';
  }

  String _formatDayMonth(DateTime d) {
    return '${d.day} ${_monthName(d.month)}';
  }

  DateTimeRange _getDateRangeForPeriod(String period, DateTime now) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (period) {
      case 'Aujourd\'hui':
        return DateTimeRange(start: todayStart, end: todayEnd);

      case 'Hier':
        final yStart = todayStart.subtract(const Duration(days: 1));
        final yEnd = DateTime(yStart.year, yStart.month, yStart.day, 23, 59, 59, 999);
        return DateTimeRange(start: yStart, end: yEnd);

      case 'Cette semaine':
        final weekday = now.weekday; // 1 = Lundi, 7 = Dimanche
        final startMonday = todayStart.subtract(Duration(days: weekday - 1));
        final endSunday = DateTime(startMonday.year, startMonday.month, startMonday.day + 6, 23, 59, 59, 999);
        return DateTimeRange(start: startMonday, end: endSunday);

      case 'Semaine passée':
        final weekday = now.weekday; // 1 = Lundi, 7 = Dimanche
        final startLastMonday = todayStart.subtract(Duration(days: weekday - 1 + 7));
        final endLastSunday = DateTime(startLastMonday.year, startLastMonday.month, startLastMonday.day + 6, 23, 59, 59, 999);
        return DateTimeRange(start: startLastMonday, end: endLastSunday);

      case 'Ce mois':
        final firstDayThisMonth = DateTime(now.year, now.month, 1);
        final lastDayThisMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(start: firstDayThisMonth, end: lastDayThisMonth);

      case 'Le mois passé':
        final firstDayPrevMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayPrevMonth = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        return DateTimeRange(start: firstDayPrevMonth, end: lastDayPrevMonth);

      case 'Cette année':
        final firstDayThisYear = DateTime(now.year, 1, 1);
        final lastDayThisYear = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: firstDayThisYear, end: lastDayThisYear);

      case 'L\'année dernière':
        final firstDayPrevYear = DateTime(now.year - 1, 1, 1);
        final lastDayPrevYear = DateTime(now.year - 1, 12, 31, 23, 59, 59, 999);
        return DateTimeRange(start: firstDayPrevYear, end: lastDayPrevYear);

      case 'Personnalisé':
      default:
        return _customDateRange ??
            DateTimeRange(
              start: todayStart.subtract(const Duration(days: 6)),
              end: todayEnd,
            );
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _customDateRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryNavy,
              onPrimary: Colors.white,
              secondary: AppTheme.accentGold,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = DateTimeRange(
          start: DateTime(picked.start.year, picked.start.month, picked.start.day),
          end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999),
        );
        _selectedPeriod = 'Personnalisé';
      });
    }
  }

  void _showStorePickerModal() {
    final stores = ['Tous', ...appState.outlets.map((o) => o.name)];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Sélectionner une boutique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(),
              ...stores.map((s) {
                final isSel = _selectedStore == s;
                return ListTile(
                  leading: Icon(
                    s == 'Tous' ? Icons.store_mall_directory : Icons.storefront,
                    color: isSel ? AppTheme.accentGold : AppTheme.primaryNavy,
                  ),
                  title: Text(s == 'Tous' ? 'Toutes les boutiques' : s, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSel ? const Icon(Icons.check, color: AppTheme.accentGold) : null,
                  onTap: () {
                    setState(() => _selectedStore = s);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final now = DateTime.now();
        final range = _getDateRangeForPeriod(_selectedPeriod, now);

        // 1. FILTRAGE DES VENTES
        final filteredSales = appState.sales.where((s) {
          if (_selectedStore != 'Tous' && s.storeName.trim().toLowerCase() != _selectedStore.trim().toLowerCase()) {
            return false;
          }
          return s.createdAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              s.createdAt.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        // 2. FILTRAGE DES DÉPENSES
        final filteredExpenses = appState.expenses.where((e) {
          return e.createdAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              e.createdAt.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        // 3. CALCULS FINANCIERS
        final totalRevenue = filteredSales.fold<double>(0.0, (sum, s) => sum + s.total);
        final totalSalesCount = filteredSales.length;
        final averageBasket = totalSalesCount > 0 ? (totalRevenue / totalSalesCount) : 0.0;
        final totalDiscounts = filteredSales.fold<double>(0.0, (sum, s) => sum + s.discountTotal);

        final cashEncaisse = filteredSales
            .where((s) => s.paymentMethod != 'À Crédit')
            .fold<double>(0.0, (sum, s) => sum + s.total);
        final creditSales = filteredSales
            .where((s) => s.paymentMethod == 'À Crédit')
            .fold<double>(0.0, (sum, s) => sum + s.total);

        double totalCOGS = 0.0;
        for (final s in filteredSales) {
          for (final it in s.items) {
            double buyP = it.buyPrice;
            if (buyP <= 0) {
              final match = appState.products.firstWhereOrNull(
                (p) => p.name.trim().toLowerCase() == it.productName.trim().toLowerCase(),
              );
              buyP = match?.buyPrice ?? (it.unitPrice * 0.7);
            }
            totalCOGS += (buyP * it.quantity);
          }
        }

        final grossMargin = totalRevenue - totalCOGS;
        final marginRate = totalRevenue > 0 ? (grossMargin / totalRevenue * 100) : 0.0;
        final totalExpenses = filteredExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

        // 2b. FILTRAGE DES PERTES ET DÉPRÉCIATIONS DE STOCK (PÉREMPTIONS, CASSE, ÉCARTS)
        final filteredDepreciations = appState.stockDepreciations.where((d) {
          if (_selectedStore != 'Tous' && d.storeName.trim().toLowerCase() != _selectedStore.trim().toLowerCase()) {
            return false;
          }
          return d.date.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              d.date.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        final totalDepreciations = filteredDepreciations.fold<double>(0.0, (sum, d) => sum + d.totalLoss);
        // Bénéfice Net = Marge Brute - Dépenses - Pertes de stock
        final netProfit = grossMargin - totalExpenses - totalDepreciations;

        // 4. MOUVEMENTS DE STOCK & OPÉRATIONS SUR LA PÉRIODE
        final filteredMovements = appState.stockMovements.where((m) {
          return m.date.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              m.date.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        final countReassort = filteredMovements.where((m) => m.type.toUpperCase().contains('RÉASSORT') || m.type.toUpperCase().contains('APPROVISIONNEMENT')).length;
        final countAjustements = filteredMovements.where((m) => m.type.toUpperCase().contains('AJUSTEMENT')).length;
        final countTransferts = filteredMovements.where((m) => m.type.toUpperCase().contains('TRANSFERT')).length;

        // 5. INVENTAIRES PHYSIQUES
        final filteredInventories = appState.inventorySessions.where((inv) {
          if (_selectedStore != 'Tous' && inv.storeName.trim().toLowerCase() != _selectedStore.trim().toLowerCase()) {
            return false;
          }
          return inv.completedAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              inv.completedAt.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        final totalInvCount = filteredInventories.length;
        final totalDiscrepancyValue = filteredInventories.fold<double>(0.0, (sum, i) => sum + i.totalDiscrepancyValue.abs());
        final totalCountedUnits = filteredInventories.fold<int>(0, (sum, inv) => sum + inv.items.fold<int>(0, (s, it) => s + it.countedStock));
        final totalTheorUnits = filteredInventories.fold<int>(0, (sum, inv) => sum + inv.items.fold<int>(0, (s, it) => s + it.theoreticalStock));

        // 6. CALCUL DES RECORDS POUR LE PDF
        final isDaily = _selectedPeriod == 'Aujourd\'hui' || _selectedPeriod == 'Hier';
        final isYearly = _selectedPeriod == 'Cette année' || _selectedPeriod == 'L\'année dernière';
        final Map<String, ({String label, double rev, double cogs, double exp})> slotMap = {};

        for (final s in filteredSales) {
          String key;
          String label;
          if (isDaily) {
            key = '${s.createdAt.hour}h';
            label = 'à ${s.createdAt.hour}h-${s.createdAt.hour + 1}h';
          } else if (isYearly) {
            key = '${s.createdAt.year}-${s.createdAt.month.toString().padLeft(2, '0')}';
            label = 'en ${_monthName(s.createdAt.month)}';
          } else {
            key = '${s.createdAt.year}-${s.createdAt.month.toString().padLeft(2, '0')}-${s.createdAt.day.toString().padLeft(2, '0')}';
            label = 'le ${_formatDayMonth(s.createdAt)}';
          }

          double itemCogs = 0;
          for (final it in s.items) {
            double buyP = it.buyPrice;
            if (buyP <= 0) {
              final match = appState.products.firstWhereOrNull((p) => p.name.trim().toLowerCase() == it.productName.trim().toLowerCase());
              buyP = match?.buyPrice ?? (it.unitPrice * 0.7);
            }
            itemCogs += buyP * it.quantity;
          }

          final ex = slotMap[key];
          if (ex != null) {
            slotMap[key] = (label: label, rev: ex.rev + s.total, cogs: ex.cogs + itemCogs, exp: ex.exp);
          } else {
            slotMap[key] = (label: label, rev: s.total, cogs: itemCogs, exp: 0);
          }
        }

        for (final e in filteredExpenses) {
          String key;
          String label;
          if (isDaily) {
            key = '${e.createdAt.hour}h';
            label = 'à ${e.createdAt.hour}h-${e.createdAt.hour + 1}h';
          } else if (isYearly) {
            key = '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}';
            label = 'en ${_monthName(e.createdAt.month)}';
          } else {
            key = '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')}';
            label = 'le ${_formatDayMonth(e.createdAt)}';
          }

          final ex = slotMap[key];
          if (ex != null) {
            slotMap[key] = (label: label, rev: ex.rev, cogs: ex.cogs, exp: ex.exp + e.amount);
          } else {
            slotMap[key] = (label: label, rev: 0, cogs: 0, exp: e.amount);
          }
        }

        String peakRevText = '';
        String peakGrossText = '';
        String peakNetText = '';
        if (slotMap.isNotEmpty) {
          final maxRevSlot = slotMap.values.reduce((a, b) => a.rev > b.rev ? a : b);
          if (maxRevSlot.rev > 0) {
            peakRevText = 'Fr.${maxRevSlot.rev.round()} est le plus élevé (${maxRevSlot.label})';
          }
          final maxGrossSlot = slotMap.values.reduce((a, b) => (a.rev - a.cogs) > (b.rev - b.cogs) ? a : b);
          final gVal = maxGrossSlot.rev - maxGrossSlot.cogs;
          if (gVal > 0) {
            peakGrossText = 'Fr.${gVal.round()} est le plus élevé (${maxGrossSlot.label})';
          }
          final maxNetSlot = slotMap.values.reduce((a, b) => (a.rev - a.cogs - a.exp) > (b.rev - b.cogs - b.exp) ? a : b);
          final nVal = maxNetSlot.rev - maxNetSlot.cogs - maxNetSlot.exp;
          if (nVal > 0) {
            peakNetText = 'Fr.${nVal.round()} est le plus élevé (${maxNetSlot.label})';
          }
        }

        final dateFmt = '${range.start.day.toString().padLeft(2, '0')}/${range.start.month.toString().padLeft(2, '0')}/${range.start.year} au ${range.end.day.toString().padLeft(2, '0')}/${range.end.month.toString().padLeft(2, '0')}/${range.end.year}';

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              'Rapport d\'activité',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.accentGold),
                tooltip: 'Télécharger le rapport (PDF)',
                onPressed: () => _triggerPdfDownload(
                  range: range,
                  totalRevenue: totalRevenue,
                  peakRevenueText: peakRevText,
                  grossMargin: grossMargin,
                  marginRate: marginRate,
                  peakGrossText: peakGrossText,
                  netProfit: netProfit,
                  peakNetText: peakNetText,
                  totalExpenses: totalExpenses,
                  totalDepreciations: totalDepreciations,
                  totalSalesCount: totalSalesCount,
                  totalDiscounts: totalDiscounts,
                  averageBasket: averageBasket,
                  filteredSales: filteredSales,
                  totalInvCount: totalInvCount,
                  totalDiscrepancyValue: totalDiscrepancyValue,
                  totalCountedUnits: totalCountedUnits,
                  totalTheorUnits: totalTheorUnits,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            children: [
              // 1. SÉLECTEUR DE BOUTIQUE
              InkWell(
                onTap: _showStorePickerModal,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, color: AppTheme.primaryNavy, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedStore == 'Tous' ? 'Toutes les boutiques' : _selectedStore,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _selectedStore == 'Tous' ? '${appState.outlets.length} boutique(s)' : '1 boutique',
                          style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. BARRE HORIZONTALE DES PÉRIODES RAPIDES
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _periods.map((p) {
                    final isSel = _selectedPeriod == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(p),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) {
                            if (p == 'Personnalisé') {
                              _pickCustomRange();
                            } else {
                              setState(() => _selectedPeriod = p);
                            }
                          }
                        },
                        selectedColor: AppTheme.primaryNavy,
                        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSel ? AppTheme.primaryNavy : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // 3. CARTE SYNTHÈSE OFFICIELLE DU RAPPORT D'ACTIVITÉ
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
                            Text(
                              'Synthèse financière d\'activité',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_selectedPeriod, style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Période du $dateFmt', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const Divider(height: 20),

                    _buildReportLine('Chiffre d\'Affaires total', totalRevenue, isBold: true, color: AppTheme.primaryNavy, isDark: isDark),
                    _buildReportLine('Total encaissé (espèces / digital)', cashEncaisse, color: const Color(0xFF16A34A), isDark: isDark),
                    if (creditSales > 0)
                      _buildReportLine('Ventes à crédit (créances clients)', creditSales, color: const Color(0xFFDC2626), isDark: isDark),
                    if (totalDiscounts > 0)
                      _buildReportLine('Total des remises accordées', -totalDiscounts, color: const Color(0xFFE11D48), isDark: isDark),
                    const Divider(height: 16),
                    _buildReportLine('Marge commerciale brute', grossMargin, color: AppTheme.accentGold, isDark: isDark),
                    _buildReportLine('Dépenses d\'exploitation & charges', -totalExpenses, color: const Color(0xFFDC2626), isDark: isDark),
                    _buildReportLine('Pertes & Dépréciations de stock', -totalDepreciations, color: const Color(0xFFDC2626), isDark: isDark),
                    const Divider(height: 20, thickness: 1.5),
                    _buildReportLine(
                      'BÉNÉFICE NET DE L\'ACTIVITÉ',
                      netProfit,
                      isBold: true,
                      fontSize: 14.5,
                      color: netProfit >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. PERFORMANCE OPÉRATIONNELLE & MOUVEMENTS DE STOCK
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
                    Text(
                      'Activité opérationnelle & inventaires',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? Colors.white : AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStatCard('VENTES TRAITÉES', '$totalSalesCount', Icons.shopping_bag_outlined, isDark),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniStatCard('PANIER MOYEN', AppTheme.formatFCFA(averageBasket), Icons.shopping_basket_outlined, isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStatCard('RÉASSORTS REÇUS', '$countReassort', Icons.inventory_2_outlined, isDark),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniStatCard('TRANSFERTS / AJUST.', '${countTransferts + countAjustements}', Icons.tune_outlined, isDark),
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
                          child: _buildMiniStatCard('INVENTAIRES CLÔTURÉS', '$totalInvCount', Icons.checklist_rtl_rounded, isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. GRAND BOUTON OFFICIEL DE TÉLÉCHARGEMENT DU RAPPORT (PDF)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.accentGold, size: 22),
                  label: const Text(
                    'Télécharger le rapport (PDF)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: () => _triggerPdfDownload(
                    range: range,
                    totalRevenue: totalRevenue,
                    peakRevenueText: peakRevText,
                    grossMargin: grossMargin,
                    marginRate: marginRate,
                    peakGrossText: peakGrossText,
                    netProfit: netProfit,
                    peakNetText: peakNetText,
                    totalExpenses: totalExpenses,
                    totalSalesCount: totalSalesCount,
                    totalDiscounts: totalDiscounts,
                    averageBasket: averageBasket,
                    filteredSales: filteredSales,
                    totalInvCount: totalInvCount,
                    totalDiscrepancyValue: totalDiscrepancyValue,
                    totalCountedUnits: totalCountedUnits,
                    totalTheorUnits: totalTheorUnits,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportLine(String label, double val, {bool isBold = false, double fontSize = 13, Color? color, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.white70 : const Color(0xFF334155))),
          Text(AppTheme.formatFCFA(val), style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w700, color: color ?? (isDark ? Colors.white : const Color(0xFF0F172A)))),
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
                Text(title, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(val, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerPdfDownload({
    required DateTimeRange range,
    required double totalRevenue,
    required String peakRevenueText,
    required double grossMargin,
    required double marginRate,
    required String peakGrossText,
    required double netProfit,
    required String peakNetText,
    required double totalExpenses,
    double totalDepreciations = 0.0,
    required int totalSalesCount,
    required double totalDiscounts,
    required double averageBasket,
    required List<Sale> filteredSales,
    required int totalInvCount,
    required double totalDiscrepancyValue,
    required int totalCountedUnits,
    required int totalTheorUnits,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Génération du rapport PDF des statistiques globales en cours...'),
          duration: Duration(seconds: 1),
        ),
      );

      // 1. TOP PRODUITS
      final Map<String, ({int quantity, double revenue})> prodMap = {};
      for (final s in filteredSales) {
        for (final it in s.items) {
          final ex = prodMap[it.productName];
          if (ex != null) {
            prodMap[it.productName] = (quantity: ex.quantity + it.quantity, revenue: ex.revenue + it.total);
          } else {
            prodMap[it.productName] = (quantity: it.quantity, revenue: it.total);
          }
        }
      }
      final topProductsList = prodMap.entries.toList()
        ..sort((a, b) => b.value.quantity.compareTo(a.value.quantity));
      final topProductsFormatted = topProductsList.take(10).map((e) => (
        name: e.key,
        quantity: e.value.quantity,
        revenue: e.value.revenue,
      )).toList();

      // 2. MEILLEURS CLIENTS
      final Map<String, ({double totalSpent, int count, Map<String, int> bought})> custMap = {};
      for (final s in filteredSales) {
        final cName = s.customerName.trim().isEmpty ? 'Client Comptoir' : s.customerName.trim();
        final ex = custMap[cName];
        if (ex != null) {
          for (final it in s.items) {
            ex.bought[it.productName] = (ex.bought[it.productName] ?? 0) + it.quantity;
          }
          custMap[cName] = (totalSpent: ex.totalSpent + s.total, count: ex.count + 1, bought: ex.bought);
        } else {
          final bMap = <String, int>{};
          for (final it in s.items) {
            bMap[it.productName] = it.quantity;
          }
          custMap[cName] = (totalSpent: s.total, count: 1, bought: bMap);
        }
      }
      final topCustomersFormatted = custMap.entries.toList()
        ..sort((a, b) => b.value.totalSpent.compareTo(a.value.totalSpent));
      final topCusts = topCustomersFormatted.take(5).map((e) {
        final topP = e.value.bought.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        return (
          name: e.key,
          totalSpent: e.value.totalSpent,
          ordersCount: e.value.count,
          favProduct: topP.isNotEmpty ? topP.first.key : 'Divers',
        );
      }).toList();

      // 3. MEILLEURS FOURNISSEURS
      final Map<String, ({double totalSpent, int count, Map<String, int> prods})> supMap = {};
      for (final po in appState.purchaseOrders) {
        if (_selectedStore != 'Tous' && po.destinationStore.trim().toLowerCase() != _selectedStore.trim().toLowerCase()) {
          continue;
        }
        if (po.createdAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
            po.createdAt.isBefore(range.end.add(const Duration(milliseconds: 1)))) {
          final sName = po.supplierName.trim().isEmpty ? 'Direct' : po.supplierName.trim();
          final ex = supMap[sName];
          if (ex != null) {
            for (final it in po.items) {
              ex.prods[it.productName] = (ex.prods[it.productName] ?? 0) + it.quantityRequested;
            }
            supMap[sName] = (totalSpent: ex.totalSpent + po.totalAmount, count: ex.count + 1, prods: ex.prods);
          } else {
            final pMap = <String, int>{};
            for (final it in po.items) {
              pMap[it.productName] = it.quantityRequested;
            }
            supMap[sName] = (totalSpent: po.totalAmount, count: 1, prods: pMap);
          }
        }
      }
      if (supMap.isEmpty && appState.suppliers.isNotEmpty) {
        for (final s in appState.suppliers) {
          final pList = appState.products.where((p) => p.supplierName?.toLowerCase() == s.name.toLowerCase()).toList();
          final val = pList.fold<double>(0.0, (sum, p) => sum + (p.buyPrice * p.stock));
          final pMap = <String, int>{};
          for (final p in pList) {
            pMap[p.name] = p.stock;
          }
          supMap[s.name] = (totalSpent: val, count: pList.length, prods: pMap);
        }
      }
      final topSups = supMap.entries.toList()..sort((a, b) => b.value.totalSpent.compareTo(a.value.totalSpent));
      final topSuppliersFormatted = topSups.take(5).map((e) {
        final tp = e.value.prods.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        return (
          name: e.key,
          totalSpent: e.value.totalSpent,
          supplyCount: e.value.count,
          mainProduct: tp.isNotEmpty ? tp.first.key : 'Divers',
        );
      }).toList();

      // 4. MODES DE PAIEMENT
      final Map<String, double> payMap = {};
      final Map<String, int> payCountMap = {};
      for (final s in filteredSales) {
        final pm = s.paymentMethod.trim().isEmpty ? 'Espèces' : s.paymentMethod.trim();
        payMap[pm] = (payMap[pm] ?? 0.0) + s.total;
        payCountMap[pm] = (payCountMap[pm] ?? 0) + 1;
      }
      final sortedPayments = payMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final paymentMethodsFormatted = sortedPayments.map((e) => (
        method: e.key,
        amount: e.value,
        count: payCountMap[e.key] ?? 0,
        percent: totalRevenue > 0 ? (e.value / totalRevenue * 100) : 0.0,
      )).toList();

      // 5. ÉQUIPE
      final Map<String, ({int count, double rev})> teamM = {};
      for (final s in filteredSales) {
        final c = s.cashierName.trim().isEmpty ? appState.displayUserName : s.cashierName.trim();
        final ex = teamM[c];
        if (ex != null) {
          teamM[c] = (count: ex.count + 1, rev: ex.rev + s.total);
        } else {
          teamM[c] = (count: 1, rev: s.total);
        }
      }
      final sortedTeam = teamM.entries.toList()..sort((a, b) => b.value.rev.compareTo(a.value.rev));
      final teamFormatted = sortedTeam.map((e) => (
        name: e.key,
        role: e.key == appState.displayUserName ? appState.userRole : 'Caissier',
        count: e.value.count,
        revenue: e.value.rev,
      )).toList();

      // 6. STOCKS FAIBLES & ÉLEVÉS
      final physicalProducts = appState.products.where((p) => p.productType != 'Service').toList();
      final lowestList = [...physicalProducts]..sort((a, b) {
        final sa = _selectedStore == 'Tous' ? a.stock : a.stockForStore(_selectedStore);
        final sb = _selectedStore == 'Tous' ? b.stock : b.stockForStore(_selectedStore);
        return sa.compareTo(sb);
      });
      final lowestStocksFormatted = lowestList.take(5).map((p) => (
        name: p.name,
        stock: _selectedStore == 'Tous' ? p.stock : p.stockForStore(_selectedStore),
        unit: p.unit,
      )).toList();

      final highestList = [...physicalProducts]..sort((a, b) {
        final sa = _selectedStore == 'Tous' ? a.stock : a.stockForStore(_selectedStore);
        final sb = _selectedStore == 'Tous' ? b.stock : b.stockForStore(_selectedStore);
        return sb.compareTo(sa);
      });
      final highestStocksFormatted = highestList.take(5).map((p) => (
        name: p.name,
        stock: _selectedStore == 'Tous' ? p.stock : p.stockForStore(_selectedStore),
        unit: p.unit,
      )).toList();

      // 7. BOUTIQUES PRODUCTIVES
      final Map<String, ({double rev, int count})> stMap = {};
      if (_selectedStore == 'Tous') {
        for (final s in filteredSales) {
          final sn = s.storeName.trim().isEmpty ? 'Boutique Principale' : s.storeName.trim();
          final ex = stMap[sn];
          if (ex != null) {
            stMap[sn] = (rev: ex.rev + s.total, count: ex.count + 1);
          } else {
            stMap[sn] = (rev: s.total, count: 1);
          }
        }
      }
      final sortedStores = stMap.entries.toList()..sort((a, b) => b.value.rev.compareTo(a.value.rev));
      final storeProdFormatted = sortedStores.map((e) => (
        storeName: e.key,
        revenue: e.value.rev,
        count: e.value.count,
        percent: totalRevenue > 0 ? (e.value.rev / totalRevenue * 100) : 0.0,
      )).toList();

      await GlobalStatsPdfService.generateAndSharePdf(
        companyName: appState.displayCompanyName.isNotEmpty ? appState.displayCompanyName : 'Bricelo Confort Nkolmesseng',
        userName: appState.displayUserName.isNotEmpty ? appState.displayUserName : 'BRICE',
        userEmail: appState.userEmail,
        storeName: _selectedStore == 'Tous' ? 'Toutes les boutiques' : _selectedStore,
        periodName: _selectedPeriod,
        startDate: range.start,
        endDate: range.end,
        totalRevenue: totalRevenue,
        peakRevenueText: peakRevenueText,
        grossMargin: grossMargin,
        marginRate: marginRate,
        peakGrossText: peakGrossText,
        netProfit: netProfit,
        peakNetText: peakNetText,
        totalExpenses: totalExpenses,
        totalDepreciations: totalDepreciations,
        totalSalesCount: totalSalesCount,
        totalDiscounts: totalDiscounts,
        averageBasket: averageBasket,
        topProducts: topProductsFormatted,
        topCustomers: topCusts,
        topSuppliers: topSuppliersFormatted,
        paymentMethods: paymentMethodsFormatted,
        teamMembers: teamFormatted,
        lowestStocks: lowestStocksFormatted,
        highestStocks: highestStocksFormatted,
        totalInventoriesCount: totalInvCount,
        totalDiscrepancyValue: totalDiscrepancyValue,
        totalCountedUnits: totalCountedUnits,
        totalTheoreticalUnits: totalTheorUnits,
        storeProductivity: storeProdFormatted,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Erreur lors de la génération du rapport PDF: $e'),
        ),
      );
    }
  }
}
