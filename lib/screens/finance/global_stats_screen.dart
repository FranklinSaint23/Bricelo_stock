import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/services/global_stats_pdf_service.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';

class GlobalStatsScreen extends StatefulWidget {
  const GlobalStatsScreen({super.key});

  @override
  State<GlobalStatsScreen> createState() => _GlobalStatsScreenState();
}

class _PeriodSlot {
  final String label;
  double revenue = 0.0;
  double cogs = 0.0;
  double expenses = 0.0;
  double depreciations = 0.0;

  _PeriodSlot(this.label);

  double get grossProfit => revenue - cogs;
  double get netProfit => grossProfit - expenses - depreciations;
}

class _GlobalStatsScreenState extends State<GlobalStatsScreen> {
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

        // 2b. FILTRAGE DES PERTES ET DÉPRÉCIATIONS DE STOCK (PÉREMPTIONS, CASSE, ÉCARTS)
        final filteredDepreciations = appState.stockDepreciations.where((d) {
          if (_selectedStore != 'Tous' && d.storeName.trim().toLowerCase() != _selectedStore.trim().toLowerCase()) {
            return false;
          }
          return d.date.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              d.date.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        final totalDepreciations = filteredDepreciations.fold<double>(0.0, (sum, d) => sum + d.totalLoss);

        // 3. CALCULS FINANCIERS GLOBAUX
        final totalRevenue = filteredSales.fold<double>(0.0, (sum, s) => sum + s.total);
        final totalSalesCount = filteredSales.length;
        final averageBasket = totalSalesCount > 0 ? (totalRevenue / totalSalesCount) : 0.0;
        final totalDiscounts = filteredSales.fold<double>(0.0, (sum, s) => sum + s.discountTotal);

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
        // Formule commerciale rigoureuse : Bénéfice Net Réel = Marge Brute - Dépenses - Pertes de stock
        final netProfit = grossMargin - totalExpenses - totalDepreciations;

        // 4. CALCUL DES RECORDS / PICS
        final isDaily = _selectedPeriod == 'Aujourd\'hui' || _selectedPeriod == 'Hier';
        final isYearly = _selectedPeriod == 'Cette année' || _selectedPeriod == 'L\'année dernière';
        final Map<String, _PeriodSlot> slots = {};

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

          final slot = slots.putIfAbsent(key, () => _PeriodSlot(label));
          slot.revenue += s.total;
          for (final it in s.items) {
            double buyP = it.buyPrice;
            if (buyP <= 0) {
              final match = appState.products.firstWhereOrNull(
                (p) => p.name.trim().toLowerCase() == it.productName.trim().toLowerCase(),
              );
              buyP = match?.buyPrice ?? (it.unitPrice * 0.7);
            }
            slot.cogs += (buyP * it.quantity);
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

          final slot = slots.putIfAbsent(key, () => _PeriodSlot(label));
          slot.expenses += e.amount;
        }

        for (final d in filteredDepreciations) {
          String key;
          String label;
          if (isDaily) {
            key = '${d.date.hour}h';
            label = 'à ${d.date.hour}h-${d.date.hour + 1}h';
          } else if (isYearly) {
            key = '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}';
            label = 'en ${_monthName(d.date.month)}';
          } else {
            key = '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}-${d.date.day.toString().padLeft(2, '0')}';
            label = 'le ${_formatDayMonth(d.date)}';
          }

          final slot = slots.putIfAbsent(key, () => _PeriodSlot(label));
          slot.depreciations += d.totalLoss;
        }

        _PeriodSlot? peakRevenueSlot;
        _PeriodSlot? peakGrossSlot;
        _PeriodSlot? peakNetSlot;

        if (slots.isNotEmpty) {
          peakRevenueSlot = slots.values.reduce((a, b) => a.revenue > b.revenue ? a : b);
          peakGrossSlot = slots.values.reduce((a, b) => a.grossProfit > b.grossProfit ? a : b);
          peakNetSlot = slots.values.reduce((a, b) => a.netProfit > b.netProfit ? a : b);
        }

        // 5. TOP PRODUITS PLUS VENDUS (avec photos)
        final Map<String, ({int quantity, double revenue, double unitPrice})> productStats = {};
        for (final s in filteredSales) {
          for (final it in s.items) {
            final existing = productStats[it.productName];
            if (existing != null) {
              productStats[it.productName] = (
                quantity: existing.quantity + it.quantity,
                revenue: existing.revenue + it.total,
                unitPrice: it.unitPrice,
              );
            } else {
              productStats[it.productName] = (
                quantity: it.quantity,
                revenue: it.total,
                unitPrice: it.unitPrice,
              );
            }
          }
        }
        final sortedProducts = productStats.entries.toList()
          ..sort((a, b) => b.value.quantity.compareTo(a.value.quantity));

        // 6. MEILLEURS CLIENTS
        final Map<String, ({double totalSpent, int ordersCount, Map<String, int> boughtProducts})> customerStats = {};
        for (final s in filteredSales) {
          final cName = s.customerName.trim().isEmpty ? 'Client Comptoir' : s.customerName.trim();
          final existing = customerStats[cName];
          if (existing != null) {
            for (final it in s.items) {
              existing.boughtProducts[it.productName] = (existing.boughtProducts[it.productName] ?? 0) + it.quantity;
            }
            customerStats[cName] = (
              totalSpent: existing.totalSpent + s.total,
              ordersCount: existing.ordersCount + 1,
              boughtProducts: existing.boughtProducts,
            );
          } else {
            final bMap = <String, int>{};
            for (final it in s.items) {
              bMap[it.productName] = it.quantity;
            }
            customerStats[cName] = (
              totalSpent: s.total,
              ordersCount: 1,
              boughtProducts: bMap,
            );
          }
        }
        final sortedCustomers = customerStats.entries.toList()
          ..sort((a, b) => b.value.totalSpent.compareTo(a.value.totalSpent));

        // 7. MEILLEURS FOURNISSEURS
        final Map<String, ({double totalSpent, int supplyCount, Map<String, int> productsSupplied})> supplierStats = {};
        for (final po in appState.purchaseOrders) {
          if (_selectedStore != 'Tous' && po.destinationStore.trim().toLowerCase() != _selectedStore.trim().toLowerCase()) {
            continue;
          }
          if (po.createdAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              po.createdAt.isBefore(range.end.add(const Duration(milliseconds: 1)))) {
            final sName = po.supplierName.trim().isEmpty ? 'Direct' : po.supplierName.trim();
            final existing = supplierStats[sName];
            if (existing != null) {
              for (final it in po.items) {
                existing.productsSupplied[it.productName] = (existing.productsSupplied[it.productName] ?? 0) + it.quantityRequested;
              }
              supplierStats[sName] = (
                totalSpent: existing.totalSpent + po.totalAmount,
                supplyCount: existing.supplyCount + 1,
                productsSupplied: existing.productsSupplied,
              );
            } else {
              final pMap = <String, int>{};
              for (final it in po.items) {
                pMap[it.productName] = it.quantityRequested;
              }
              supplierStats[sName] = (
                totalSpent: po.totalAmount,
                supplyCount: 1,
                productsSupplied: pMap,
              );
            }
          }
        }
        // Fallback avec les fournisseurs enregistrés si aucun bon n'a été créé sur la période
        if (supplierStats.isEmpty && appState.suppliers.isNotEmpty) {
          for (final sup in appState.suppliers) {
            final prods = appState.products.where((p) => p.supplierName?.toLowerCase() == sup.name.toLowerCase()).toList();
            final totalSuppliedVal = prods.fold<double>(0.0, (sum, p) => sum + (p.buyPrice * p.stock));
            final pMap = <String, int>{};
            for (final p in prods) {
              pMap[p.name] = p.stock;
            }
            supplierStats[sup.name] = (
              totalSpent: totalSuppliedVal,
              supplyCount: prods.length,
              productsSupplied: pMap,
            );
          }
        }
        final sortedSuppliers = supplierStats.entries.toList()
          ..sort((a, b) => b.value.totalSpent.compareTo(a.value.totalSpent));

        // 8. MODES DE PAIEMENT (Classés du plus utilisé au moins utilisé)
        final Map<String, double> paymentsMap = {};
        final Map<String, int> paymentsCount = {};
        for (final s in filteredSales) {
          final pm = s.paymentMethod.trim().isEmpty ? 'Espèces' : s.paymentMethod.trim();
          paymentsMap[pm] = (paymentsMap[pm] ?? 0.0) + s.total;
          paymentsCount[pm] = (paymentsCount[pm] ?? 0) + 1;
        }
        final sortedPayments = paymentsMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // 9. ÉQUIPE & CAISSIERS
        final Map<String, ({int salesCount, double totalRevenue})> teamStats = {};
        for (final s in filteredSales) {
          final cName = s.cashierName.trim().isEmpty ? appState.displayUserName : s.cashierName.trim();
          final existing = teamStats[cName];
          if (existing != null) {
            teamStats[cName] = (
              salesCount: existing.salesCount + 1,
              totalRevenue: existing.totalRevenue + s.total,
            );
          } else {
            teamStats[cName] = (
              salesCount: 1,
              totalRevenue: s.total,
            );
          }
        }
        final sortedTeam = teamStats.entries.toList()
          ..sort((a, b) => b.value.totalRevenue.compareTo(a.value.totalRevenue));

        // 10. STOCKS LES PLUS FAIBLES & STOCKS LES PLUS ÉLEVÉS
        final storeProds = appState.products.where((p) => p.productType != 'Service').toList();
        final sortedByStockAsc = [...storeProds]
          ..sort((a, b) {
            final stA = _selectedStore == 'Tous' ? a.stock : a.stockForStore(_selectedStore);
            final stB = _selectedStore == 'Tous' ? b.stock : b.stockForStore(_selectedStore);
            return stA.compareTo(stB);
          });
        final lowestStock = sortedByStockAsc.take(5).toList();

        final sortedByStockDesc = [...storeProds]
          ..sort((a, b) {
            final stA = _selectedStore == 'Tous' ? a.stock : a.stockForStore(_selectedStore);
            final stB = _selectedStore == 'Tous' ? b.stock : b.stockForStore(_selectedStore);
            return stB.compareTo(stA);
          });
        final highestStock = sortedByStockDesc.take(5).toList();

        // 11. RÉSULTATS DES INVENTAIRES PHYSIQUES
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

        // 12. BOUTIQUE LA PLUS PRODUCTIVE (quand 'Tous' est sélectionné)
        final Map<String, ({double revenue, int salesCount})> storeStats = {};
        if (_selectedStore == 'Tous') {
          for (final s in filteredSales) {
            final sName = s.storeName.trim().isEmpty ? 'Boutique Principale' : s.storeName.trim();
            final existing = storeStats[sName];
            if (existing != null) {
              storeStats[sName] = (
                revenue: existing.revenue + s.total,
                salesCount: existing.salesCount + 1,
              );
            } else {
              storeStats[sName] = (
                revenue: s.total,
                salesCount: 1,
              );
            }
          }
        }
        final sortedStoreProductivity = storeStats.entries.toList()
          ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));

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
              'Statistiques globales',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.accentGold),
                tooltip: 'Télécharger le rapport (PDF)',
                onPressed: () => _exportPdf(
                  range: range,
                  totalRevenue: totalRevenue,
                  peakRevenueText: peakRevenueSlot != null && peakRevenueSlot.revenue > 0
                      ? 'Fr.${peakRevenueSlot.revenue.round()} est le plus élevé (${peakRevenueSlot.label})'
                      : '',
                  grossMargin: grossMargin,
                  marginRate: marginRate,
                  peakGrossText: peakGrossSlot != null && peakGrossSlot.grossProfit > 0
                      ? 'Fr.${peakGrossSlot.grossProfit.round()} est le plus élevé (${peakGrossSlot.label})'
                      : '',
                  netProfit: netProfit,
                  peakNetText: peakNetSlot != null && peakNetSlot.netProfit > 0
                      ? 'Fr.${peakNetSlot.netProfit.round()} est le plus élevé (${peakNetSlot.label})'
                      : '',
                  totalExpenses: totalExpenses,
                  totalDepreciations: totalDepreciations,
                  totalSalesCount: totalSalesCount,
                  totalDiscounts: totalDiscounts,
                  averageBasket: averageBasket,
                  sortedProducts: sortedProducts,
                  sortedCustomers: sortedCustomers,
                  sortedSuppliers: sortedSuppliers,
                  sortedPayments: sortedPayments,
                  paymentsCount: paymentsCount,
                  sortedTeam: sortedTeam,
                  lowestStock: lowestStock,
                  highestStock: highestStock,
                  totalInvCount: totalInvCount,
                  totalDiscrepancyValue: totalDiscrepancyValue,
                  totalCountedUnits: totalCountedUnits,
                  totalTheorUnits: totalTheorUnits,
                  sortedStoreProductivity: sortedStoreProductivity,
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

              // 2. BARRE HORIZONTALE DES PÉRIODES
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

              // 3. CARTES FINANCIÈRES AVEC RECORDS / MONTANT LE PLUS ÉLEVÉ EN DESSOUS
              _buildMetricCard(
                title: 'VENTES TOTALES',
                amount: AppTheme.formatFCFA(totalRevenue),
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF059669),
                subRecord: peakRevenueSlot != null && peakRevenueSlot.revenue > 0
                    ? '🏆 Record : ${AppTheme.formatFCFA(peakRevenueSlot.revenue)} (${peakRevenueSlot.label})'
                    : 'Aucun pic de vente sur la période',
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'BÉNÉFICE BRUT',
                      amount: AppTheme.formatFCFA(grossMargin),
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppTheme.accentGold,
                      badgeText: '${marginRate.toStringAsFixed(1)}%',
                      subRecord: peakGrossSlot != null && peakGrossSlot.grossProfit > 0
                          ? '🏆 Record : ${AppTheme.formatFCFA(peakGrossSlot.grossProfit)} (${peakGrossSlot.label})'
                          : 'Aucun record enregistré',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'BÉNÉFICE NET RÉEL',
                      amount: AppTheme.formatFCFA(netProfit),
                      icon: Icons.monetization_on_outlined,
                      iconColor: netProfit >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      badgeText: 'Net Réel',
                      subRecord: peakNetSlot != null && peakNetSlot.netProfit > 0
                          ? '🏆 Record : ${AppTheme.formatFCFA(peakNetSlot.netProfit)} (${peakNetSlot.label})'
                          : (totalDepreciations > 0 ? 'Pertes stock déduites : -${AppTheme.formatFCFA(totalDepreciations)}' : 'Aucun record enregistré'),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 4. INDICATEURS SECONDAIRES (Nombre de ventes, Remises, Panier moyen, Dépenses)
              Row(
                children: [
                  Expanded(
                    child: _buildSmallKpiCard(
                      title: 'Nombre de ventes',
                      value: '$totalSalesCount transaction(s)',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFF3B82F6),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSmallKpiCard(
                      title: 'Remises accordées',
                      value: AppTheme.formatFCFA(totalDiscounts),
                      icon: Icons.local_offer_outlined,
                      color: const Color(0xFFE11D48),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildSmallKpiCard(
                      title: 'Panier moyen',
                      value: AppTheme.formatFCFA(averageBasket),
                      icon: Icons.shopping_basket_outlined,
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSmallKpiCard(
                      title: 'Charges & Dépenses',
                      value: AppTheme.formatFCFA(totalExpenses),
                      icon: Icons.money_off_rounded,
                      color: const Color(0xFFDC2626),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // CARTE PERTES & DÉPRÉCIATIONS DE STOCK (PÉREMPTIONS, CASSE, ÉCARTS)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF261515) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF5A2323) : const Color(0xFFFECACA),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove_shopping_cart_rounded, color: Color(0xFFDC2626), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pertes & Dépréciations de stock',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalDepreciations > 0
                                ? 'Péremptions, casse & avaries déduits du bénéfice net réel'
                                : 'Aucune dépréciation de stock enregistrée sur la période',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      totalDepreciations > 0 ? '- ${AppTheme.formatFCFA(totalDepreciations)}' : '0 F CFA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: totalDepreciations > 0 ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. BOUTIQUE LA PLUS PRODUCTIVE (Si toutes les boutiques sélectionnées)
              if (_selectedStore == 'Tous' && sortedStoreProductivity.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D1B2E), Color(0xFF1E3052)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_events_rounded, color: AppTheme.accentGold, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'BOUTIQUE LA PLUS PRODUCTIVE',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppTheme.accentGold, borderRadius: BorderRadius.circular(6)),
                            child: const Text('N°1 VENTES', style: TextStyle(color: AppTheme.primaryNavy, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sortedStoreProductivity.first.key,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppTheme.formatFCFA(sortedStoreProductivity.first.value.revenue)} (${sortedStoreProductivity.first.value.salesCount} ventes)',
                        style: const TextStyle(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      if (sortedStoreProductivity.length > 1) ...[
                        const Divider(color: Colors.white24, height: 16),
                        ...sortedStoreProductivity.skip(1).map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(
                                  '${AppTheme.formatFCFA(entry.value.revenue)} • ${entry.value.salesCount} vts',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 6. TOP PRODUITS PLUS VENDUS (Avec photo, nom, quantité et CA)
              _buildSectionCard(
                title: 'Meilleurs produits vendus',
                subtitle: '${sortedProducts.length} référence(s) vendue(s)',
                icon: Icons.star_rounded,
                iconColor: AppTheme.accentGold,
                isDark: isDark,
                child: sortedProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(child: Text('Aucune vente sur la période', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      )
                    : Column(
                        children: sortedProducts.take(5).mapIndexed((idx, entry) {
                          final prodName = entry.key;
                          final stats = entry.value;
                          final prod = appState.products.firstWhereOrNull(
                            (p) => p.name.trim().toLowerCase() == prodName.trim().toLowerCase(),
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ProductImageWidget(
                                      imageUrl: prod?.imageUrl,
                                      size: 42,
                                      borderRadius: 8,
                                    ),
                                    Positioned(
                                      top: -3,
                                      left: -3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: idx == 0 ? AppTheme.accentGold : AppTheme.primaryNavy,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('#${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(prodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                                      Text('${stats.quantity} unité(s) vendue(s)', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppTheme.formatFCFA(stats.revenue),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // 7. MEILLEURS CLIENTS
              _buildSectionCard(
                title: 'Meilleurs clients',
                subtitle: '${sortedCustomers.length} client(s) actif(s)',
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF3B82F6),
                isDark: isDark,
                child: sortedCustomers.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(child: Text('Aucun client enregistré', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      )
                    : Column(
                        children: sortedCustomers.take(5).mapIndexed((idx, entry) {
                          final cName = entry.key;
                          final stats = entry.value;
                          final topItem = stats.boughtProducts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                          final favProd = topItem.isNotEmpty ? topItem.first.key : 'Divers';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                  child: Text(
                                    cName.isNotEmpty ? cName[0].toUpperCase() : 'C',
                                    style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                                      Text('${stats.ordersCount} visite(s) • Préféré : $favProd', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppTheme.formatFCFA(stats.totalSpent),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF059669)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // 8. MEILLEURS FOURNISSEURS
              _buildSectionCard(
                title: 'Meilleurs fournisseurs',
                subtitle: '${sortedSuppliers.length} fournisseur(s) répertorié(s)',
                icon: Icons.local_shipping_rounded,
                iconColor: const Color(0xFF8B5CF6),
                isDark: isDark,
                child: sortedSuppliers.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(child: Text('Aucun approvisionnement enregistré', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      )
                    : Column(
                        children: sortedSuppliers.take(5).mapIndexed((idx, entry) {
                          final sName = entry.key;
                          final stats = entry.value;
                          final topProd = stats.productsSupplied.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                          final mainItem = topProd.isNotEmpty ? topProd.first.key : 'Divers';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.business_rounded, color: Color(0xFF8B5CF6), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                                      Text('Fournit : $mainItem (${stats.supplyCount} comm.)', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppTheme.formatFCFA(stats.totalSpent),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // 9. MODES DE PAIEMENT (Du plus utilisé au moins utilisé)
              _buildSectionCard(
                title: 'Modes de paiement',
                subtitle: 'Classés du plus utilisé au moins utilisé',
                icon: Icons.payments_rounded,
                iconColor: const Color(0xFF0D9488),
                isDark: isDark,
                child: sortedPayments.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(child: Text('Aucun paiement enregistré', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      )
                    : Column(
                        children: sortedPayments.map((entry) {
                          final count = paymentsCount[entry.key] ?? 0;
                          final pct = totalRevenue > 0 ? (entry.value / totalRevenue * 100) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Icon(
                                  entry.key.toLowerCase().contains('esp') ? Icons.payments_outlined : (entry.key.toLowerCase().contains('crédit') ? Icons.assignment_late_outlined : Icons.account_balance_wallet_outlined),
                                  size: 18,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('${entry.key} ($count ventes)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  '${AppTheme.formatFCFA(entry.value)} (${pct.toStringAsFixed(1)}%)',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // 10. ÉQUIPE & CAISSIERS DE LA BOUTIQUE
              _buildSectionCard(
                title: 'Équipe & Caissiers',
                subtitle: 'Performance des ventes par équipier',
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFF0F172A),
                isDark: isDark,
                child: sortedTeam.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('${appState.displayUserName} • ${appState.userRole}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            const Text('Actif', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      )
                    : Column(
                        children: sortedTeam.map((entry) {
                          final isOwner = entry.key == appState.displayUserName;
                          final role = isOwner ? appState.userRole : 'Caissier / Vendeur';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                  child: Text(entry.key.isNotEmpty ? entry.key[0].toUpperCase() : 'U', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text(role, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(AppTheme.formatFCFA(entry.value.totalRevenue), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.primaryNavy)),
                                    Text('${entry.value.salesCount} vente(s)', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // 11. GESTION DES STOCKS : PLUS FAIBLES & PLUS ÉLEVÉS
              _buildSectionCard(
                title: 'Niveaux de stock critiques & Tops stocks',
                subtitle: 'Surveillance des ruptures et des surstocks',
                icon: Icons.inventory_2_rounded,
                iconColor: const Color(0xFFEA580C),
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔴 STOCKS LES PLUS FAIBLES (URGENCES)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                    const SizedBox(height: 6),
                    ...lowestStock.map((p) {
                      final st = _selectedStore == 'Tous' ? p.stock : p.stockForStore(_selectedStore);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            ProductImageWidget(imageUrl: p.imageUrl, size: 32, borderRadius: 6),
                            const SizedBox(width: 8),
                            Expanded(child: Text(p.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: st <= 0 ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                st <= 0 ? 'Épuisé (0)' : '$st ${p.unit}(s)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: st <= 0 ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 18),
                    const Text('🟢 STOCKS LES PLUS ÉLEVÉS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    const SizedBox(height: 6),
                    ...highestStock.map((p) {
                      final st = _selectedStore == 'Tous' ? p.stock : p.stockForStore(_selectedStore);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            ProductImageWidget(imageUrl: p.imageUrl, size: 32, borderRadius: 6),
                            const SizedBox(width: 8),
                            Expanded(child: Text(p.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                            Text('$st ${p.unit}(s)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 12. RÉSULTATS DES INVENTAIRES PHYSIQUES
              _buildSectionCard(
                title: 'Résultats des inventaires',
                subtitle: 'Audits de stock réalisés sur la période',
                icon: Icons.checklist_rtl_rounded,
                iconColor: AppTheme.primaryNavy,
                isDark: isDark,
                child: totalInvCount == 0
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: Text('Aucun inventaire réalisé sur cette période', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Inventaires clôturés :', style: TextStyle(fontSize: 12.5)),
                              Text('$totalInvCount session(s)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Unités comptées / théoriques :', style: TextStyle(fontSize: 12.5)),
                              Text('$totalCountedUnits / $totalTheorUnits', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Écart total constaté :', style: TextStyle(fontSize: 12.5)),
                              Text(
                                AppTheme.formatFCFA(totalDiscrepancyValue),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: totalDiscrepancyValue == 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required String subRecord,
    required bool isDark,
    String? badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 15),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subRecord,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.textPrimary)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _exportPdf({
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
    required List<MapEntry<String, ({int quantity, double revenue, double unitPrice})>> sortedProducts,
    required List<MapEntry<String, ({double totalSpent, int ordersCount, Map<String, int> boughtProducts})>> sortedCustomers,
    required List<MapEntry<String, ({double totalSpent, int supplyCount, Map<String, int> productsSupplied})>> sortedSuppliers,
    required List<MapEntry<String, double>> sortedPayments,
    required Map<String, int> paymentsCount,
    required List<MapEntry<String, ({int salesCount, double totalRevenue})>> sortedTeam,
    required List<Product> lowestStock,
    required List<Product> highestStock,
    required int totalInvCount,
    required double totalDiscrepancyValue,
    required int totalCountedUnits,
    required int totalTheorUnits,
    required List<MapEntry<String, ({double revenue, int salesCount})>> sortedStoreProductivity,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Génération du rapport PDF en cours...'),
          duration: Duration(seconds: 1),
        ),
      );

      final topProductsList = sortedProducts.take(10).map((e) => (
        name: e.key,
        quantity: e.value.quantity,
        revenue: e.value.revenue,
      )).toList();

      final topCustomersList = sortedCustomers.take(5).map((e) {
        final topProd = e.value.boughtProducts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        return (
          name: e.key,
          totalSpent: e.value.totalSpent,
          ordersCount: e.value.ordersCount,
          favProduct: topProd.isNotEmpty ? topProd.first.key : 'Divers',
        );
      }).toList();

      final topSuppliersList = sortedSuppliers.take(5).map((e) {
        final topP = e.value.productsSupplied.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        return (
          name: e.key,
          totalSpent: e.value.totalSpent,
          supplyCount: e.value.supplyCount,
          mainProduct: topP.isNotEmpty ? topP.first.key : 'Articles divers',
        );
      }).toList();

      final paymentMethodsList = sortedPayments.map((e) => (
        method: e.key,
        amount: e.value,
        count: paymentsCount[e.key] ?? 0,
        percent: totalRevenue > 0 ? (e.value / totalRevenue * 100) : 0.0,
      )).toList();

      final teamList = sortedTeam.map((e) => (
        name: e.key,
        role: e.key == appState.displayUserName ? appState.userRole : 'Caissier',
        count: e.value.salesCount,
        revenue: e.value.totalRevenue,
      )).toList();

      final lowList = lowestStock.map((p) => (
        name: p.name,
        stock: _selectedStore == 'Tous' ? p.stock : p.stockForStore(_selectedStore),
        unit: p.unit,
      )).toList();

      final highList = highestStock.map((p) => (
        name: p.name,
        stock: _selectedStore == 'Tous' ? p.stock : p.stockForStore(_selectedStore),
        unit: p.unit,
      )).toList();

      final storeProdList = sortedStoreProductivity.map((e) => (
        storeName: e.key,
        revenue: e.value.revenue,
        count: e.value.salesCount,
        percent: totalRevenue > 0 ? (e.value.revenue / totalRevenue * 100) : 0.0,
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
        topProducts: topProductsList,
        topCustomers: topCustomersList,
        topSuppliers: topSuppliersList,
        paymentMethods: paymentMethodsList,
        teamMembers: teamList,
        lowestStocks: lowList,
        highestStocks: highList,
        totalInventoriesCount: totalInvCount,
        totalDiscrepancyValue: totalDiscrepancyValue,
        totalCountedUnits: totalCountedUnits,
        totalTheoreticalUnits: totalTheorUnits,
        storeProductivity: storeProdList,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Erreur lors de la génération du PDF: $e'),
        ),
      );
    }
  }
}
