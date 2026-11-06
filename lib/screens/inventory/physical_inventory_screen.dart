import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/services/inventory_pdf_service.dart';

class PhysicalInventoryScreen extends StatefulWidget {
  const PhysicalInventoryScreen({super.key});

  @override
  State<PhysicalInventoryScreen> createState() => _PhysicalInventoryScreenState();
}

class _PhysicalInventoryScreenState extends State<PhysicalInventoryScreen> {
  final appState = AppState.instance;

  // Segment: 0 = Nouveau / En cours, 1 = Inventaires passés
  int _selectedSegment = 0;

  late String _selectedStore;
  bool _isInventoryInProgress = false;
  DateTime? _inventoryStartedAt;
  final Map<String, TextEditingController> _countedControllers = {};
  final Map<String, String> _reasonsControllers = {};

  // Filtres de périodes pour inventaires passés
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

  @override
  void initState() {
    super.initState();
    _selectedStore = appState.currentStore;
  }

  @override
  void dispose() {
    for (final c in _countedControllers.values) {
      c.dispose();
    }
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
        final weekday = now.weekday;
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

  void _startInventorySession() {
    setState(() {
      _inventoryStartedAt = DateTime.now();
      _isInventoryInProgress = true;
      _countedControllers.clear();
      _reasonsControllers.clear();

      for (final p in appState.products) {
        final cur = p.stockForStore(_selectedStore);
        _countedControllers[p.id] = TextEditingController(text: cur.toString());
      }
    });
  }

  List<String> _findRecentBuyersForProduct(String productName) {
    final buyers = <String>{};
    for (final s in appState.sales) {
      if (s.items.any((i) => i.productName.toLowerCase() == productName.toLowerCase())) {
        if (s.customerName.isNotEmpty && s.customerName != 'Client Comptoir') {
          buyers.add(s.customerName);
        }
      }
    }
    return buyers.toList();
  }

  void _confirmAndFinalizeInventory() {
    final completedAt = DateTime.now();
    final startedAt = _inventoryStartedAt ?? completedAt.subtract(const Duration(minutes: 5));

    final now = completedAt;
    final yyyy = now.year.toString();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final seq = (appState.inventorySessions.length + 1).toString().padLeft(4, '0');
    final ref = 'BS-INV-$yyyy$mm$dd-$seq';

    final List<InventoryItemRecord> records = [];

    for (final p in appState.products) {
      final ctrl = _countedControllers[p.id];
      final counted = (ctrl != null ? int.tryParse(ctrl.text.trim()) : null) ?? p.stockForStore(_selectedStore);
      final theo = p.stockForStore(_selectedStore);
      final reason = _reasonsControllers[p.id] ?? '';

      records.add(InventoryItemRecord(
        productId: p.id,
        productName: p.name,
        category: p.category,
        barcode: p.barcode,
        unit: p.unit,
        theoreticalStock: theo,
        countedStock: counted,
        buyPrice: p.buyPrice,
        sellPrice: p.sellPrice,
        supplierName: p.supplierName ?? '',
        recentBuyers: _findRecentBuyersForProduct(p.name),
        discrepancyReason: reason,
      ));
    }

    final session = InventorySession(
      id: 'inv_${completedAt.millisecondsSinceEpoch}',
      reference: ref,
      storeName: _selectedStore,
      startedAt: startedAt,
      completedAt: completedAt,
      conductedBy: appState.displayUserName,
      status: 'Validé',
      items: records,
    );

    appState.saveInventorySession(session);

    setState(() {
      _isInventoryInProgress = false;
      _inventoryStartedAt = null;
      _selectedSegment = 1; // Basculer automatiquement sur l'historique des inventaires
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF059669),
        content: Text('Inventaire $ref clôturé et enregistré avec succès !'),
      ),
    );
  }

  void _showSessionDetailModal(BuildContext context, InventorySession session) {
    final startStr = '${session.startedAt.day.toString().padLeft(2, "0")}/${session.startedAt.month.toString().padLeft(2, "0")}/${session.startedAt.year} à ${session.startedAt.hour.toString().padLeft(2, "0")}:${session.startedAt.minute.toString().padLeft(2, "0")}';
    final endStr = '${session.completedAt.day.toString().padLeft(2, "0")}/${session.completedAt.month.toString().padLeft(2, "0")}/${session.completedAt.year} à ${session.completedAt.hour.toString().padLeft(2, "0")}:${session.completedAt.minute.toString().padLeft(2, "0")}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.reference, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.primaryNavy)),
                      Text('Boutique : ${session.storeName} • Par ${session.conductedBy}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => InventoryPdfService.downloadSessionInventoryPdf(session),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // DATES DÉBUT ET FIN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Début : $startStr', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                    Text('Fin : $endStr', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // RÉSUMÉ STATISTIQUE
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Articles', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          Text('${session.totalArticlesCounted}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: session.articlesWithDiscrepancy > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Écarts', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          Text(
                            '${session.articlesWithDiscrepancy}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: session.articlesWithDiscrepancy > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Valeur écart', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          Text(
                            '${session.totalDiscrepancyValue.toInt()} F',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: session.totalDiscrepancyValue < 0 ? const Color(0xFFDC2626) : AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              const Text('Détails complets par produit :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),

              Expanded(
                child: ListView.separated(
                  itemCount: session.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final item = session.items[idx];
                    final hasDiff = item.difference != 0;

                    final prod = appState.products.firstWhereOrNull(
                      (p) => p.id == item.productId || p.name.trim().toLowerCase() == item.productName.trim().toLowerCase(),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ProductImageWidget(
                                imageUrl: prod?.imageUrl,
                                size: 36,
                                borderRadius: 6,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: hasDiff ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hasDiff ? 'Écart : ${item.difference > 0 ? "+" : ""}${item.difference}' : 'Conforme',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: hasDiff ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fournisseur : ${item.supplierName.isNotEmpty ? item.supplierName : "Direct"} • P. Achat : ${item.buyPrice.toInt()} F • P. Vente : ${item.sellPrice.toInt()} F',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Théorique: ${item.theoreticalStock} | Réel compté: ${item.countedStock} ${item.unit}(s)',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              if (hasDiff)
                                Text(
                                  'Impact: ${item.discrepancyValue.toInt()} F CFA',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                ),
                            ],
                          ),
                          if (item.recentBuyers.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Clients acheteurs : ${item.recentBuyers.join(", ")}',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ],
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

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final stores = appState.outlets.map((o) => o.name).toList();
    if (stores.isEmpty) stores.add(appState.currentStore);
    if (!stores.contains(_selectedStore)) {
      _selectedStore = stores.first;
    }

    final products = appState.products;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final now = DateTime.now();
        final range = _getDateRangeForPeriod(_selectedPeriod, now);

        final pastSessions = appState.inventorySessions.where((s) {
          if (s.storeName.trim().toLowerCase() != _selectedStore.trim().toLowerCase() && _selectedStore != 'Tous') {
            return false;
          }
          return s.completedAt.isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
              s.completedAt.isBefore(range.end.add(const Duration(milliseconds: 1)));
        }).toList();

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF09121E) : const Color(0xFFF8FAFC),
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
            title: const Text('Inventaires de stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
          ),
          body: Column(
            children: [
              // 1. SEGMENTED BOUTON (SOUS LE HEADER) : [ NOUVEAU / EN COURS ] [ INVENTAIRES PASSÉS ]
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280), width: 1.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedSegment = 0),
                        child: Container(
                          height: double.infinity,
                          color: _selectedSegment == 0
                              ? (isDark ? AppTheme.primaryNavy : const Color(0xFFFED7AA))
                              : Colors.transparent,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 18,
                                  color: _selectedSegment == 0 ? const Color(0xFF111827) : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Faire un inventaire',
                                  style: TextStyle(
                                    fontWeight: _selectedSegment == 0 ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                    color: _selectedSegment == 0 ? const Color(0xFF111827) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1.0, height: double.infinity, color: const Color(0xFF6B7280)),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedSegment = 1),
                        child: Container(
                          height: double.infinity,
                          color: _selectedSegment == 1
                              ? (isDark ? AppTheme.primaryNavy : const Color(0xFFFED7AA))
                              : Colors.transparent,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 18,
                                  color: _selectedSegment == 1 ? const Color(0xFF111827) : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Inventaires passés',
                                  style: TextStyle(
                                    fontWeight: _selectedSegment == 1 ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                    color: _selectedSegment == 1 ? const Color(0xFF111827) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. SÉLECTION DE LA BOUTIQUE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStore,
                      isExpanded: true,
                      items: stores.map((s) => DropdownMenuItem(value: s, child: Text('Boutique : $s', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)))).toList(),
                      onChanged: _isInventoryInProgress
                          ? null
                          : (val) {
                              if (val != null) setState(() => _selectedStore = val);
                            },
                    ),
                  ),
                ),
              ),

              // 4. CONTENU SELON LE SEGMENT
              Expanded(
                child: _selectedSegment == 0
                    ? _buildNewInventoryView(products, isDark)
                    : _buildPastInventoriesView(pastSessions, isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  // VUE 1 : FAIRE UN NOUVEL INVENTAIRE
  Widget _buildNewInventoryView(List<Product> products, bool isDark) {
    if (!_isInventoryInProgress) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fact_check_outlined, size: 38, color: AppTheme.accentGold),
              ),
              const SizedBox(height: 16),
              Text(
                'Prêt à démarrer l\'inventaire ?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                'L\'heure et la date précises seront enregistrées dès que vous lancerez la session pour une traçabilité comptable parfaite.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: AppTheme.accentGold),
                label: const Text('+ Faire un inventaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                onPressed: _startInventorySession,
              ),
            ],
          ),
        ),
      );
    }

    // SESSION EN COURS
    final startStr = _inventoryStartedAt != null
        ? '${_inventoryStartedAt!.day.toString().padLeft(2, "0")}/${_inventoryStartedAt!.month.toString().padLeft(2, "0")}/${_inventoryStartedAt!.year} à ${_inventoryStartedAt!.hour.toString().padLeft(2, "0")}:${_inventoryStartedAt!.minute.toString().padLeft(2, "0")}'
        : '';

    return Column(
      children: [
        // BANDEAU HEURE DE DÉMARRAGE ENREGISTRÉE
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF059669), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Session démarrée le $startStr ($_selectedStore)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF065F46)),
                ),
              ),
            ],
          ),
        ),

        // LISTE DES ARTICLES À COMPTER
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final p = products[idx];
              final theo = p.stockForStore(_selectedStore);
              final ctrl = _countedControllers[p.id];
              final counted = (ctrl != null ? int.tryParse(ctrl.text.trim()) : null) ?? theo;
              final diff = counted - theo;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProductImageWidget(
                          imageUrl: p.imageUrl,
                          size: 36,
                          borderRadius: 6,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: diff == 0
                                ? const Color(0xFFECFDF5)
                                : (diff > 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            diff == 0 ? 'Conforme' : (diff > 0 ? '+$diff' : '$diff'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                              color: diff == 0 ? const Color(0xFF059669) : (diff > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fournisseur : ${p.supplierName ?? "Direct"} • P. Achat : ${p.buyPrice.toInt()} F',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 10),

                    // STEPPER DE COMPTAGE PHYSIQUE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stock théorique : $theo ${p.unit}(s)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                if (counted > 0 && ctrl != null) {
                                  ctrl.text = (counted - 1).toString();
                                  setState(() {});
                                }
                              },
                            ),
                            SizedBox(
                              width: 55,
                              height: 38,
                              child: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryNavy),
                              onPressed: () {
                                if (ctrl != null) {
                                  ctrl.text = (counted + 1).toString();
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // BOUTON CLÔTURE & VALIDATION
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _confirmAndFinalizeInventory,
                child: const Text('Clôturer et valider l\'inventaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // VUE 2 : INVENTAIRES PASSÉS & ARCHIVES
  Widget _buildPastInventoriesView(List<InventorySession> pastSessions, bool isDark) {
    return Column(
      children: [
        // SÉLECTEUR DE PÉRIODES CHRONOLOGIQUES
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _periods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                      color: isSel ? AppTheme.accentGold : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSel ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                    ),
                    child: Center(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                          color: isSel ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // LISTE DES SESSIONS
        Expanded(
          child: pastSessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history, size: 50, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 12),
                      Text('Aucun inventaire passé sur cette période', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      SizedBox(height: 4),
                      Text('Les inventaires validés seront archivés ici pour consultation et traçabilité.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pastSessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final s = pastSessions[idx];
                    final dtStr = '${s.completedAt.day.toString().padLeft(2, "0")}/${s.completedAt.month.toString().padLeft(2, "0")}/${s.completedAt.year}';

                    return InkWell(
                      onTap: () => _showSessionDetailModal(context, s),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(s.reference, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryNavy)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: s.articlesWithDiscrepancy > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    s.articlesWithDiscrepancy > 0 ? '${s.articlesWithDiscrepancy} écart(s)' : '100% Conforme',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: s.articlesWithDiscrepancy > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Boutique : ${s.storeName} • Réalisé par : ${s.conductedBy}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Date : $dtStr', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                Text(
                                  'Valeur : ${s.totalCountedValue.toInt()} F CFA',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
