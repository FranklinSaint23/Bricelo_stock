import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/sales/sale_detail_screen.dart';
import 'package:stock_prime/widgets/sale_receipt_dialog.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final appState = AppState.instance;
  String _selectedPeriod = 'Aujourd\'hui';
  String _statusFilter = 'Actives'; // Actives, Tout, Annulées, Remboursées
  DateTimeRange? _customDateRange;
  final _searchCtrl = TextEditingController();

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
        final weekday = now.weekday;
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

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
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

  List<Sale> get _filteredSales {
    final now = DateTime.now();
    final q = _searchCtrl.text.trim().toLowerCase();
    final range = _getDateRangeForPeriod(_selectedPeriod, now);

    return appState.sales.where((s) {
      if (q.isNotEmpty) {
        final matchId = s.ticketNumber.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
        final matchCustomer = s.customerName.toLowerCase().contains(q);
        final matchItem = s.items.any((i) => i.productName.toLowerCase().contains(q));
        if (!matchId && !matchCustomer && !matchItem) return false;
      }

      if (_statusFilter == 'Actives') {
        // Toutes les ventes en cours ou terminées
      } else if (_statusFilter == 'Annulées') {
        return false;
      } else if (_statusFilter == 'Remboursées') {
        return false;
      }

      return s.createdAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
          s.createdAt.isBefore(range.end.add(const Duration(milliseconds: 1)));
    }).toList();
  }

  String _formatDateTime(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$min';
  }

  String _formatDateOnly(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    return '$day/$month/$year';
  }

  void _showFilterBottomSheet() {
    String tempStatus = _statusFilter;
    DateTime? tempStart = _customDateRange?.start;
    DateTime? tempEnd = _customDateRange?.end;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Filtres',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Statut',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Actives', 'Tout', 'Annulees', 'Remboursees'].map((st) {
                    final isSel = tempStatus == st;
                    return InkWell(
                      onTap: () => setModalState(() => tempStatus = st),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFED7AA) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          st,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            color: isSel ? const Color(0xFF9A3412) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Période personnalisée',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempStart ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => tempStart = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tempStart != null ? _formatDateOnly(tempStart!) : 'Début',
                                style: TextStyle(
                                  color: tempStart != null ? Colors.black : const Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempEnd ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => tempEnd = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tempEnd != null ? _formatDateOnly(tempEnd!) : 'Fin',
                                style: TextStyle(
                                  color: tempEnd != null ? Colors.black : const Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _statusFilter = 'Actives';
                          _customDateRange = null;
                          _selectedPeriod = 'Aujourd\'hui';
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Réinitialiser', style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: AppTheme.primaryNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          _statusFilter = tempStatus;
                          if (tempStart != null && tempEnd != null) {
                            _customDateRange = DateTimeRange(start: tempStart!, end: tempEnd!);
                            _selectedPeriod = 'Personnalisé';
                          } else {
                            _customDateRange = null;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Appliquer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final sales = _filteredSales;
        final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.total);
        final totalEncaisse = sales.fold<double>(0, (sum, s) => sum + s.amountReceived);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
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
              'Historique des ventes'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Partager', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rapport (${sales.length} ventes) prêt à partager')),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. RECHERCHE & BOUTON FILTRE
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par numero ou client...',
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4B5563)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, color: Color(0xFF4B5563)),
                          tooltip: 'Filtres',
                          onPressed: _showFilterBottomSheet,
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),

              // 2. SÉLECTEUR DE PÉRIODES CHRONOLOGIQUES (HORIZONTALE AVEC SCROLL)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _periods.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final p = _periods[idx];
                      final isSelected = _selectedPeriod == p;
                      return InkWell(
                        onTap: () {
                          if (p == 'Personnalisé') {
                            _pickCustomDateRange();
                          } else {
                            setState(() {
                              _selectedPeriod = p;
                              _customDateRange = null;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentGold : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentGold : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? AppTheme.primaryNavy : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 3. BANNIÈRE RÉSUMÉ STYLE STOCKPLUS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFFFFBEB), // Light gold tint
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${sales.length} vente(s) • ${AppTheme.formatFCFA(totalRevenue)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Encaissé ${AppTheme.formatFCFA(totalEncaisse)}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  'Votre formule affiche les 30 derniers jours.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),

              // 4. LISTE DYNAMIQUE DES VENTES
              Expanded(
                child: sales.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_outlined, size: 70, color: Color(0xFFD1D5DB)),
                            SizedBox(height: 14),
                            Text(
                              'Aucune vente enregistrée',
                              style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: sales.length,
                        itemBuilder: (context, index) {
                          final sale = sales[index];
                          final isToday = sale.createdAt.day == DateTime.now().day &&
                              sale.createdAt.month == DateTime.now().month &&
                              sale.createdAt.year == DateTime.now().year;

                          final showHeader = index == 0 ||
                              (sales[index - 1].createdAt.day != sale.createdAt.day);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isToday ? 'AUJOURD\'HUI' : _formatDateOnly(sale.createdAt).toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        AppTheme.formatFCFA(sale.total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => SaleDetailScreen(sale: sale)),
                                  );
                                },
                                onLongPress: () => SaleReceiptDialog.show(context, sale),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sale.ticketNumber,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _formatDateTime(sale.createdAt),
                                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            AppTheme.formatFCFA(sale.total),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14.5,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: sale.paymentMethod == 'À Crédit'
                                                  ? const Color(0xFFFEF3C7)
                                                  : const Color(0xFFFFFBEB),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              sale.paymentMethod == 'À Crédit' ? 'À Crédit' : 'Terminé',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: sale.paymentMethod == 'À Crédit'
                                                    ? const Color(0xFFB45309)
                                                    : const Color(0xFFD97706),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
}
