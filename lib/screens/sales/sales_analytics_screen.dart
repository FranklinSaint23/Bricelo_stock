import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class _ChartBucket {
  final String label;
  final double amount;
  final int count;

  const _ChartBucket({
    required this.label,
    required this.amount,
    this.count = 0,
  });
}

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  final appState = AppState.instance;

  String _selectedStore = 'Toutes les boutiques';
  String _selectedPeriod = '30j'; // 'Aujourd\'hui', 'Hier', '1 semaine', 'Semaine passée', '1 mois', 'Mois passé', '30j', '90j', 'L\'an passé', 'Personnalisé'
  DateTimeRange? _customDateRange;

  final List<String> _periods = const [
    'Aujourd\'hui',
    'Hier',
    '1 semaine',
    'Semaine passée',
    '1 mois',
    'Mois passé',
    '30j',
    '90j',
    'L\'an passé',
    'Personnalisé',
  ];

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

      case '1 semaine':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 6)),
          end: todayEnd,
        );

      case 'Semaine passée':
        final weekday = now.weekday; // 1 = Lundi, 7 = Dimanche
        final thisMonday = todayStart.subtract(Duration(days: weekday - 1));
        final lastMonday = thisMonday.subtract(const Duration(days: 7));
        final lastSunday = lastMonday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateTimeRange(start: lastMonday, end: lastSunday);

      case '30j':
      case '1 mois':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 29)),
          end: todayEnd,
        );

      case 'Mois passé':
        final firstDayThisMonth = DateTime(now.year, now.month, 1);
        final lastDayPrevMonth = firstDayThisMonth.subtract(const Duration(milliseconds: 1));
        final firstDayPrevMonth = DateTime(lastDayPrevMonth.year, lastDayPrevMonth.month, 1);
        return DateTimeRange(start: firstDayPrevMonth, end: lastDayPrevMonth);

      case '90j':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 89)),
          end: todayEnd,
        );

      case 'L\'an passé':
        final firstDayPrevYear = DateTime(now.year - 1, 1, 1);
        final lastDayPrevYear = DateTime(now.year - 1, 12, 31, 23, 59, 59);
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

  void _showStorePickerModal() {
    final stores = ['Toutes les boutiques', ...appState.outlets.map((o) => o.name)];

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
                    s == 'Toutes les boutiques' ? Icons.store_mall_directory : Icons.storefront,
                    color: isSel ? AppTheme.accentGold : AppTheme.primaryNavy,
                  ),
                  title: Text(s, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSel ? const Icon(Icons.check, color: AppTheme.accentGold) : null,
                  onTap: () {
                    setState(() => _selectedStore = s);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
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
        _customDateRange = picked;
        _selectedPeriod = 'Personnalisé';
      });
    }
  }

  List<_ChartBucket> _generateBuckets(List<Sale> filteredSales, DateTimeRange range) {
    final period = _selectedPeriod;

    if (period == 'Aujourd\'hui' || period == 'Hier') {
      // 5 créneaux horaires
      final slots = [
        (label: '08h-11h', startH: 8, endH: 11),
        (label: '11h-14h', startH: 11, endH: 14),
        (label: '14h-17h', startH: 14, endH: 17),
        (label: '17h-20h', startH: 17, endH: 20),
        (label: '20h-23h', startH: 20, endH: 23),
      ];

      return slots.map((s) {
        final matches = filteredSales.where((sale) {
          final h = sale.createdAt.hour;
          return h >= s.startH && h < s.endH;
        });
        final total = matches.fold(0.0, (sum, sale) => sum + sale.total);
        return _ChartBucket(label: s.label, amount: total, count: matches.length);
      }).toList();
    }

    if (period == '1 semaine' || period == 'Semaine passée') {
      // 7 jours
      final List<_ChartBucket> buckets = [];
      for (int i = 0; i < 7; i++) {
        final day = range.start.add(Duration(days: i));
        final matches = filteredSales.where((sale) =>
            sale.createdAt.year == day.year &&
            sale.createdAt.month == day.month &&
            sale.createdAt.day == day.day);
        final total = matches.fold(0.0, (sum, sale) => sum + sale.total);
        final dayStr = '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';
        buckets.add(_ChartBucket(label: dayStr, amount: total, count: matches.length));
      }
      return buckets;
    }

    if (period == '30j' || period == '1 mois' || period == 'Mois passé') {
      // 6 tranches de 5 jours
      final List<_ChartBucket> buckets = [];
      for (int i = 0; i < 6; i++) {
        final startDay = range.start.add(Duration(days: i * 5));
        final endDay = range.start.add(Duration(days: (i + 1) * 5 - 1));
        final matches = filteredSales.where((sale) =>
            sale.createdAt.isAfter(startDay.subtract(const Duration(milliseconds: 1))) &&
            sale.createdAt.isBefore(endDay.add(const Duration(days: 1))));
        final total = matches.fold(0.0, (sum, sale) => sum + sale.total);
        final label = '${startDay.day}-${endDay.day}';
        buckets.add(_ChartBucket(label: label, amount: total, count: matches.length));
      }
      return buckets;
    }

    if (period == '90j') {
      // 6 tranches de 15 jours
      final List<_ChartBucket> buckets = [];
      for (int i = 0; i < 6; i++) {
        final startDay = range.start.add(Duration(days: i * 15));
        final endDay = range.start.add(Duration(days: (i + 1) * 15 - 1));
        final matches = filteredSales.where((sale) =>
            sale.createdAt.isAfter(startDay.subtract(const Duration(milliseconds: 1))) &&
            sale.createdAt.isBefore(endDay.add(const Duration(days: 1))));
        final total = matches.fold(0.0, (sum, sale) => sum + sale.total);
        final label = 'Q${i + 1}';
        buckets.add(_ChartBucket(label: label, amount: total, count: matches.length));
      }
      return buckets;
    }

    if (period == 'L\'an passé') {
      // 12 mois
      final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
      return List.generate(12, (idx) {
        final m = idx + 1;
        final matches = filteredSales.where((sale) => sale.createdAt.month == m);
        final total = matches.fold(0.0, (sum, sale) => sum + sale.total);
        return _ChartBucket(label: months[idx], amount: total, count: matches.length);
      });
    }

    // Personnalisé
    final diffDays = range.end.difference(range.start).inDays.abs() + 1;
    if (diffDays <= 7) {
      final List<_ChartBucket> buckets = [];
      for (int i = 0; i < diffDays; i++) {
        final day = range.start.add(Duration(days: i));
        final matches = filteredSales.where((sale) =>
            sale.createdAt.year == day.year &&
            sale.createdAt.month == day.month &&
            sale.createdAt.day == day.day);
        final total = matches.fold(0.0, (sum, sale) => sum + sale.total);
        buckets.add(_ChartBucket(
          label: '${day.day}/${day.month}',
          amount: total,
          count: matches.length,
        ));
      }
      return buckets;
    }

    // Sinon 5 buckets répartis
    final List<_ChartBucket> buckets = [];
    final step = (diffDays / 5).ceil();
    for (int i = 0; i < 5; i++) {
      final startDay = range.start.add(Duration(days: i * step));
      final endDay = range.start.add(Duration(days: math.min((i + 1) * step - 1, diffDays - 1)));
      final matches = filteredSales.where((sale) =>
          sale.createdAt.isAfter(startDay.subtract(const Duration(milliseconds: 1))) &&
          sale.createdAt.isBefore(endDay.add(const Duration(days: 1))));
      final total = matches.fold(0.0, (sum, sale) => sum + sale.total);
      final label = '${startDay.day}/${startDay.month}';
      buckets.add(_ChartBucket(label: label, amount: total, count: matches.length));
    }
    return buckets;
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final now = DateTime.now();
        final range = _getDateRangeForPeriod(_selectedPeriod, now);

        // Filtrage dynamique des ventes
        final filteredSales = appState.sales.where((sale) {
          if (_selectedStore != 'Toutes les boutiques') {
            if (sale.storeName.trim().toLowerCase() != _selectedStore.trim().toLowerCase()) {
              return false;
            }
          }
          return sale.createdAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              sale.createdAt.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        // Statistiques calculées dynamiquement
        final totalSales = filteredSales.fold(0.0, (sum, s) => sum + s.total);
        final salesCount = filteredSales.length;
        final averageBasket = salesCount > 0 ? (totalSales / salesCount) : 0.0;

        // Bénéfice brut estimé
        double estimatedProfit = 0.0;
        for (final sale in filteredSales) {
          for (final it in sale.items) {
            final pIdx = appState.products.indexWhere((prod) => prod.name.toLowerCase() == it.productName.toLowerCase());
            final buyPrice = pIdx != -1 ? appState.products[pIdx].buyPrice : (it.unitPrice * 0.7);
            final lineMargin = (it.unitPrice - buyPrice) * it.quantity;
            estimatedProfit += lineMargin;
          }
        }
        if (estimatedProfit < 0) estimatedProfit = 0;

        // Produits les plus vendus calculés dynamiquement
        final Map<String, ({int quantity, double revenue, double unitPrice})> productStats = {};
        for (final sale in filteredSales) {
          for (final it in sale.items) {
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

        // Données du diagramme (Histogramme dynamique)
        final buckets = _generateBuckets(filteredSales, range);
        final maxAmount = buckets.isEmpty ? 0.0 : buckets.map((b) => b.amount).reduce(math.max);
        final yCeiling = maxAmount > 0 ? (maxAmount * 1.25) : 100000.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            leading: TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
              label: const Text('Plus', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            leadingWidth: 80,
            title: const Text('Analyse des ventes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SÉLECTEUR DE BOUTIQUE DYNAMIQUE
                InkWell(
                  onTap: _showStorePickerModal,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, color: AppTheme.primaryNavy, size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedStore,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedStore == 'Toutes les boutiques'
                                ? '${appState.outlets.length} boutiques'
                                : 'Actif',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. SÉLECTEUR DE PÉRIODES (Pills déroulantes / cliquables)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _periods.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final p = _periods[idx];
                      final isSel = _selectedPeriod == p;

                      return InkWell(
                        onTap: () {
                          if (p == 'Personnalisé') {
                            _pickCustomDateRange();
                          } else {
                            setState(() => _selectedPeriod = p);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primaryNavy : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSel ? AppTheme.primaryNavy : const Color(0xFFCBD5E1)),
                            boxShadow: isSel ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : null,
                          ),
                          child: Center(
                            child: Text(
                              p == 'Personnalisé' && _customDateRange != null
                                  ? '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                                  : p,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                color: isSel ? AppTheme.accentGold : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // 3. GRILLE DE 4 CARTES KPI (100% Dynamiques)
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiBox(
                        'Chiffre d\'affaires',
                        AppTheme.formatFCFA(totalSales),
                        AppTheme.primaryNavy,
                        subtitle: '$salesCount transactions',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiBox(
                        'Nombre de ventes',
                        '$salesCount',
                        const Color(0xFF111827),
                        subtitle: _selectedStore,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiBox(
                        'Panier moyen',
                        AppTheme.formatFCFA(averageBasket),
                        const Color(0xFF111827),
                        subtitle: 'Moyenne par vente',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiBox(
                        'Bénéfice estimé',
                        AppTheme.formatFCFA(estimatedProfit),
                        const Color(0xFF15803D),
                        subtitle: totalSales > 0
                            ? '${((estimatedProfit / totalSales) * 100).toStringAsFixed(1)}% de marge'
                            : '0% de marge',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. GRAPHIQUE ÉVOLUTION DU CHIFFRE D'AFFAIRES (100% Dynamique)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Evolution du chiffre d\'affaires',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                          ),
                          Text(
                            AppTheme.formatFCFA(totalSales),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Histogramme vertical stylisé Bricelo
                      SizedBox(
                        height: 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Axe Y dynamique
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatCompact(yCeiling), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                Text(_formatCompact(yCeiling * 0.75), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                Text(_formatCompact(yCeiling * 0.5), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                Text(_formatCompact(yCeiling * 0.25), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                const Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                              ],
                            ),
                            const SizedBox(width: 12),

                            // Barres dynamiques
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: buckets.map((b) {
                                  final double barHeight = yCeiling > 0
                                      ? (b.amount / yCeiling) * 140
                                      : 4.0;
                                  final isPeak = b.amount == maxAmount && maxAmount > 0;
                                  return _buildBar(b.label, math.max(barHeight, 4.0), b.amount, isPeak: isPeak);
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. PRODUITS LES PLUS VENDUS (100% Dynamiques)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Produits les plus vendus',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827)),
                    ),
                    Text(
                      '${sortedProducts.length} référence(s)',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: sortedProducts.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 36, color: Color(0xFFCBD5E1)),
                                SizedBox(height: 8),
                                Text(
                                  'Aucun produit vendu sur cette période',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedProducts.take(5).length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, idx) {
                            final entry = sortedProducts[idx];
                            final prodName = entry.key;
                            final stats = entry.value;

                            return ListTile(
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: idx == 0 ? AppTheme.accentGold.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '#${idx + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: idx == 0 ? const Color(0xFFB45309) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                prodName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                              ),
                              subtitle: Text(
                                '${stats.quantity} unité(s) vendue(s)',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                              trailing: Text(
                                AppTheme.formatFCFA(stats.revenue),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.primaryNavy),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiBox(String title, String value, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(String date, double height, double amount, {bool isPeak = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (amount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _formatCompact(amount),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isPeak ? AppTheme.accentGold : const Color(0xFF64748B),
              ),
            ),
          ),
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isPeak ? AppTheme.primaryNavy : const Color(0xFF3B82F6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            border: isPeak ? Border.all(color: AppTheme.accentGold, width: 1.5) : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
