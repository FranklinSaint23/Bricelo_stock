import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/pos/shift_dialog_helper.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ShiftsTrackingScreen extends StatefulWidget {
  final int initialTabIndex;
  const ShiftsTrackingScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ShiftsTrackingScreen> createState() => _ShiftsTrackingScreenState();
}

class _ShiftsTrackingScreenState extends State<ShiftsTrackingScreen> with SingleTickerProviderStateMixin {
  final appState = AppState.instance;
  late TabController _tabController;
  Timer? _refreshTimer;
  String _selectedPeriod = 'Aujourd\'hui';
  String _selectedStore = 'Toutes les boutiques';
  DateTimeRange? _customDateRange;

  List<String> _getStoreOptions() {
    final stores = <String>{'Toutes les boutiques'};
    for (final s in appState.availableStores) {
      if (s.trim().isNotEmpty) stores.add(s.trim());
    }
    if (appState.currentStore.trim().isNotEmpty) {
      stores.add(appState.currentStore.trim());
    }
    for (final m in appState.teamMembers) {
      if (m.storeName.trim().isNotEmpty && m.storeName.trim() != 'Toutes les boutiques') {
        stores.add(m.storeName.trim());
      }
    }
    for (final sh in appState.cashShiftsHistory) {
      if (sh.storeName.trim().isNotEmpty && sh.storeName.trim() != 'Toutes les boutiques') {
        stores.add(sh.storeName.trim());
      }
    }
    return stores.toList();
  }

  bool _matchesSelectedStore(String? storeName, {bool includeGlobal = true}) {
    if (_selectedStore == 'Toutes les boutiques') return true;
    final clean = (storeName ?? '').trim();
    if (clean.isEmpty) return true;
    if (includeGlobal && clean.toLowerCase() == 'toutes les boutiques') return true;
    return clean.toLowerCase() == _selectedStore.trim().toLowerCase();
  }

  static const List<String> _periodOptions = [
    'Aujourd\'hui',
    'Hier',
    'Cette semaine',
    'Semaine passée',
    'Ce mois',
    'Le mois passé',
    'Cette année',
    'L\'année dernière',
    'Personnalisé',
    'Tout',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    // Rafraîchir le chronomètre de shift et l'heure chaque 15 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _showOpenShiftDialog() {
    ShiftDialogHelper.showOpenShiftDialog(context);
  }

  void _showCloseShiftDialog(CashShift shift) {
    ShiftDialogHelper.showCloseShiftDialog(context, shift);
  }

  void _showRestockDialog([Product? preselectedProduct]) {
    final products = appState.products;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun produit disponible dans le catalogue.')),
      );
      return;
    }

    Product selectedProd = preselectedProduct ?? products.first;
    final qtyCtrl = TextEditingController(text: '10');
    final supplierCtrl = TextEditingController(text: selectedProd.supplierName ?? 'Fournisseur principal');
    final costCtrl = TextEditingController(text: (selectedProd.buyPrice * 10).toInt().toString());
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDlgState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.inventory_2_rounded, color: AppTheme.primaryNavy),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demande de réapprovisionnement',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Le magasinier transmet cette demande d\'approvisionnement au propriétaire pour validation et paiement.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),

                  // Sélection du produit
                  DropdownButtonFormField<Product>(
                    value: selectedProd,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Article concerné *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: products.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (Stock: ${p.stock})', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDlgState(() {
                          selectedProd = val;
                          supplierCtrl.text = val.supplierName ?? 'Fournisseur principal';
                          final q = int.tryParse(qtyCtrl.text.trim()) ?? 10;
                          costCtrl.text = (val.buyPrice * q).toInt().toString();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Stock actuel et alerte
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stock actuel : ${selectedProd.stock} ${selectedProd.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('Alerte seuil : ${selectedProd.minStockAlert}', style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quantité souhaitée
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantité à commander (${selectedProd.unit}) *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (v) {
                      final q = int.tryParse(v.trim()) ?? 0;
                      setDlgState(() {
                        costCtrl.text = (selectedProd.buyPrice * q).toInt().toString();
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Fournisseur
                  TextField(
                    controller: supplierCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fournisseur suggéré',
                      hintText: 'Ex: Quincaillerie Centrale',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Coût estimé
                  TextField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Coût estimé (FCFA) *',
                      hintText: '0',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remarque
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Remarque / Urgence',
                      hintText: 'Ex: Rupture imminente sur le chantier...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final q = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                  if (q <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez saisir une quantité supérieure à 0.'), backgroundColor: Color(0xFFDC2626)),
                    );
                    return;
                  }
                  final c = double.tryParse(costCtrl.text.trim()) ?? (selectedProd.buyPrice * q);

                  await appState.requestStockRestock(
                    product: selectedProd,
                    quantity: q,
                    supplierName: supplierCtrl.text.trim().isNotEmpty ? supplierCtrl.text.trim() : null,
                    customCost: c,
                    note: noteCtrl.text.trim(),
                  );

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Demande d\'approvisionnement envoyée au propriétaire pour ${selectedProd.name} !'),
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                    );
                  }
                },
                child: const Text('Soumettre au Propriétaire', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSettingsToggleDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isEnabled = appState.isShiftsTrackingEnabled;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Configuration du suivi des shifts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile.adaptive(
                value: isEnabled,
                title: const Text('Activer le suivi des shifts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Exige l\'ouverture et fermeture de caisse avant encaissement.', style: TextStyle(fontSize: 12)),
                activeColor: AppTheme.accentGold,
                onChanged: (val) {
                  appState.setShiftsTrackingEnabled(val);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: initialRange,
      helpText: 'Sélectionner la période personnalisée',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      saveText: 'Appliquer',
    );
    if (picked != null && mounted) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = 'Personnalisé';
      });
    }
  }

  void _confirmDeleteShift(CashShift shift) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Supprimer ce shift passé ?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous supprimer définitivement le shift de ${shift.cashierName} (${shift.cashDeskName}) du ${shift.openedAt.day.toString().padLeft(2, "0")}/${shift.openedAt.month.toString().padLeft(2, "0")}/${shift.openedAt.year} ?',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await appState.deleteCashShift(shift.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shift passé supprimé de l\'historique.'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool _isDateInSelectedPeriod(DateTime date) {
    if (_selectedPeriod == 'Tout') return true;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final dDay = DateTime(date.year, date.month, date.day);

    switch (_selectedPeriod) {
      case 'Aujourd\'hui':
        return dDay == todayStart;
      case 'Hier':
        final yesterday = todayStart.subtract(const Duration(days: 1));
        return dDay == yesterday;
      case 'Cette semaine':
        final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
        return !dDay.isBefore(weekStart) && !dDay.isAfter(todayStart);
      case 'Semaine passée':
        final thisWeekStart = todayStart.subtract(Duration(days: now.weekday - 1));
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
        final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
        return !dDay.isBefore(lastWeekStart) && !dDay.isAfter(lastWeekEnd);
      case 'Ce mois':
        return date.year == now.year && date.month == now.month;
      case 'Le mois passé':
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        return date.year == lastMonthDate.year && date.month == lastMonthDate.month;
      case 'Cette année':
        return date.year == now.year;
      case 'L\'année dernière':
        return date.year == now.year - 1;
      case 'Personnalisé':
        if (_customDateRange == null) return true;
        final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
        final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day);
        return !dDay.isBefore(start) && !dDay.isAfter(end);
      default:
        return true;
    }
  }

  List<CashShift> _filterShifts(List<CashShift> all) {
    return all
        .where((s) => _isDateInSelectedPeriod(s.openedAt) && _matchesSelectedStore(s.storeName))
        .toList();
  }

  List<Sale> _filterSales(List<Sale> all) {
    return all
        .where((s) => _isDateInSelectedPeriod(s.createdAt) && _matchesSelectedStore(s.storeName))
        .toList();
  }

  Widget _buildStoreSelectorBar() {
    final storeOptions = _getStoreOptions();
    if (!storeOptions.contains(_selectedStore)) {
      _selectedStore = 'Toutes les boutiques';
    }
    final attachedCashiers = appState.teamMembers
        .where((m) => m.role.toLowerCase() == 'caissier' && _matchesSelectedStore(m.storeName))
        .length;
    final attachedWarehouse = appState.teamMembers
        .where((m) => m.role.toLowerCase().contains('magasinier') && _matchesSelectedStore(m.storeName))
        .length;
    final attachedManagers = appState.teamMembers
        .where((m) => m.role.toLowerCase() == 'gérant' && _matchesSelectedStore(m.storeName))
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18, color: AppTheme.primaryNavy),
              const SizedBox(width: 8),
              const Text(
                'Boutique :',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStore,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryNavy),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      items: storeOptions
                          .map(
                            (st) => DropdownMenuItem(
                              value: st,
                              child: Text(st, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStore = val);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildStoreRoleBadge(Icons.point_of_sale_rounded, '$attachedCashiers Caissier(s)', const Color(0xFF0284C7)),
              _buildStoreRoleBadge(Icons.warehouse_rounded, '$attachedWarehouse Magasinier(s)', const Color(0xFF0D9488)),
              _buildStoreRoleBadge(Icons.supervisor_account_rounded, '$attachedManagers Gérant(s)', const Color(0xFF92400E)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreRoleBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: const Color(0xFF4B5563),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: const Color(0xFF111827),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
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
        final isEnabled = appState.isShiftsTrackingEnabled;
        final activeShift = appState.activeCashShift;
        final rawHistory = appState.cashShiftsHistory;
        final filteredHistory = _filterShifts(rawHistory);
        final filteredSales = _filterSales(appState.sales);
        final isCashierOnly = !appState.hasPermission('Validation des approbations') &&
            appState.userRole.toLowerCase() == 'caissier';

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
            title: Text(
              isCashierOnly ? 'Mes Shifts & Ma Caisse' : 'Suivi Shifts & Activités Équipe',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5, color: Colors.white),
            ),
            actions: [
              if (appState.hasPermission('Validation des approbations'))
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  tooltip: 'Paramètres du suivi',
                  onPressed: _showSettingsToggleDialog,
                ),
            ],
            bottom: isCashierOnly
                ? null
                : TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.accentGold,
                    indicatorWeight: 3,
                    labelColor: AppTheme.accentGold,
                    unselectedLabelColor: const Color(0xFF94A3B8),
                    tabs: [
                      const Tab(
                        icon: Icon(Icons.point_of_sale_rounded, size: 20),
                        text: 'Caissiers & Caisse',
                      ),
                      Tab(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.warehouse_rounded, size: 20),
                            if (appState.approvalRequests.any((r) =>
                                (r.type == 'Approvisionnement' || r.type == 'Transfert de stock') &&
                                r.status == 'pending'))
                              Positioned(
                                right: -4,
                                top: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                        text: 'Magasiniers',
                      ),
                      Tab(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.supervisor_account_rounded, size: 20),
                            if (appState.approvalRequests.any((r) =>
                                r.type != 'Approvisionnement' &&
                                r.type != 'Transfert de stock' &&
                                r.status == 'pending'))
                              Positioned(
                                right: -4,
                                top: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                        text: 'Gérants',
                      ),
                    ],
                  ),
          ),
          body: isCashierOnly
              ? _buildCashiersTab(isEnabled, activeShift, filteredHistory, filteredSales)
              : Column(
                  children: [
                    _buildStoreSelectorBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // TAB 1: CAISSIERS & SHIFTS
                          _buildCashiersTab(isEnabled, activeShift, filteredHistory, filteredSales),

                          // TAB 2: MAGASINIERS (SUPERVISION STOCK & APPROVISIONNEMENT)
                          _buildWarehouseTab(),

                          // TAB 3: GÉRANTS
                          _buildManagersTab(),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ===========================================================================
  // TAB 1: CAISSIERS & SHIFTS (Analyse détaillée, répartition paiements & temps)
  // ===========================================================================
  Widget _buildCashiersTab(
    bool isEnabled,
    CashShift? activeShift,
    List<CashShift> history,
    List<Sale> periodSales,
  ) {
    final now = DateTime.now();
    final isPast17h30 = now.hour > 17 || (now.hour == 17 && now.minute >= 30);

    // Calculs de synthèse globale sur la période
    final activeInStore = activeShift != null && _matchesSelectedStore(activeShift.storeName);
    final totalShiftsCount = history.length + (activeInStore ? 1 : 0);
    final totalSalesCount = periodSales.length;
    final totalSalesVolume = periodSales.fold(0.0, (sum, s) => sum + s.total);
    final totalCashCollected = periodSales
        .where((s) => s.paymentMethod.toLowerCase().contains('esp') || s.paymentMethod.toLowerCase().contains('cash'))
        .fold(0.0, (sum, s) => sum + s.total);

    final isOwnerOrManager = appState.hasPermission('Validation des approbations') ||
        appState.userRole.toLowerCase() != 'caissier';
    final attachedCashiers = appState.teamMembers
        .where((m) => m.role.toLowerCase() == 'caissier' && _matchesSelectedStore(m.storeName))
        .toList();

    // Répartition détaillée des paiements (Somme et Pourcentage %)
    final Map<String, double> paymentBreakdown = {};
    for (final sale in periodSales) {
      final method = sale.paymentMethod.isNotEmpty ? sale.paymentMethod : 'Espèces';
      paymentBreakdown[method] = (paymentBreakdown[method] ?? 0.0) + sale.total;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. SERVICE EN COURS
        if (isEnabled && activeShift != null) ...[
          // Alerte 17h30
          if (isPast17h30) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm_on_rounded, color: Color(0xFFDC2626), size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alerte Clôture 17h30 !', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 13)),
                        Text('L\'heure de clôture est dépassée. Effectuez le décompte et fermez votre caisse.', style: TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showCloseShiftDialog(activeShift),
                    child: const Text('Clôturer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lock_open_rounded, color: Color(0xFF059669), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${activeShift.cashDeskName} ouvert',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: Color(0xFF111827)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF065F46),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF6EE7B7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      activeShift.formattedDuration,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF6EE7B7)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Caissier : ${activeShift.cashierName} · ${activeShift.storeName}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildDetailRow('Heure d\'ouverture :', '${activeShift.openedAt.day.toString().padLeft(2, "0")}/${activeShift.openedAt.month.toString().padLeft(2, "0")} à ${activeShift.openedAt.hour.toString().padLeft(2, "0")}:${activeShift.openedAt.minute.toString().padLeft(2, "0")}'),
                const SizedBox(height: 5),
                _buildDetailRow('Fond initial en caisse :', AppTheme.formatFCFA(activeShift.openingCash)),
                const SizedBox(height: 5),
                _buildDetailRow('Ventes espèces encaissées :', AppTheme.formatFCFA(activeShift.cashSalesTotal)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildDetailRow(
                    'Espèces théoriques en caisse :',
                    AppTheme.formatFCFA(activeShift.openingCash + activeShift.cashSalesTotal),
                    isBold: true,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.lock_clock, size: 18),
                    label: const Text('Clôturer le shift (Faire la caisse)', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showCloseShiftDialog(activeShift),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else if (isEnabled) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, size: 36, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aucun shift de caisse ouvert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151))),
                      Text('Ouvrez un shift avant d\'encaisser des ventes.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _showOpenShiftDialog,
                  child: const Text('Ouvrir', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 2. FILTRE DE PÉRIODE COMPLET (Aujourd'hui, Hier, Cette semaine, Semaine passée, Ce mois, Le mois passé, Cette année, L'année dernière, Personnalisé)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Rapport d\'activité caisse',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _periodOptions.contains(_selectedPeriod) ? _selectedPeriod : 'Tout',
                  isDense: true,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  items: _periodOptions
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) async {
                    if (v == null) return;
                    if (v == 'Personnalisé') {
                      await _pickCustomDateRange();
                    } else {
                      setState(() => _selectedPeriod = v);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        if (_selectedPeriod == 'Personnalisé' && _customDateRange != null) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickCustomDateRange,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range_rounded, size: 16, color: AppTheme.primaryNavy),
                  const SizedBox(width: 6),
                  Text(
                    'Du ${_customDateRange!.start.day.toString().padLeft(2, "0")}/${_customDateRange!.start.month.toString().padLeft(2, "0")}/${_customDateRange!.start.year} au ${_customDateRange!.end.day.toString().padLeft(2, "0")}/${_customDateRange!.end.month.toString().padLeft(2, "0")}/${_customDateRange!.end.year}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_calendar_rounded, size: 15, color: AppTheme.accentGold),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),

        // 3. SYNTHÈSE GLOBALE DE LA PÉRIODE (KPI CARDS)
        Row(
          children: [
            Expanded(
              child: _buildKpiBox(
                title: 'Ventes totales',
                value: AppTheme.formatFCFA(totalSalesVolume),
                sub: '$totalSalesCount transaction(s)',
                icon: Icons.payments_outlined,
                color: const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiBox(
                title: 'Espèces encaissées',
                value: AppTheme.formatFCFA(totalCashCollected),
                sub: '$totalShiftsCount shift(s)',
                icon: Icons.savings_outlined,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3B. CAISSIERS RATTACHÉS À LA BOUTIQUE & STATS PAR CAISSIER
        if (isOwnerOrManager) ...[
          Text(
            _selectedStore == 'Toutes les boutiques'
                ? 'Caissiers rattachés (${attachedCashiers.length})'
                : 'Caissiers rattachés à $_selectedStore (${attachedCashiers.length})',
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          if (attachedCashiers.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedStore == 'Toutes les boutiques'
                          ? 'Aucun caissier invité pour le moment.'
                          : 'Aucun caissier rattaché à la boutique "$_selectedStore".',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF4B5563)),
                    ),
                  ),
                ],
              ),
            )
          else
            ...attachedCashiers.map((m) {
              final mLower = m.name.trim().toLowerCase();
              final mShifts = history
                  .where((sh) => sh.cashierName.trim().toLowerCase().contains(mLower))
                  .length +
                  ((activeInStore && activeShift.cashierName.trim().toLowerCase().contains(mLower)) ? 1 : 0);
              final mSales = periodSales
                  .where((s) => s.cashierName.trim().toLowerCase().contains(mLower))
                  .toList();
              final mRevenue = mSales.fold(0.0, (sum, s) => sum + s.total);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      child: const Icon(Icons.point_of_sale_rounded, color: Color(0xFF0284C7), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.assignedCashDesk ?? "Caisse Principale"} · ${m.storeName}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppTheme.formatFCFA(mRevenue),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${mSales.length} vente(s) · $mShifts shift(s)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
        ],

        // 4. RÉPARTITION DES MOYENS DE PAIEMENT (SOMME & %)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pie_chart_outline_rounded, color: AppTheme.primaryNavy, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Moyens de paiement (Sommes & %)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Répartition sur la période sélectionnée :',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),

              if (paymentBreakdown.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text('Aucune vente enregistrée sur cette période.', style: TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF))),
                  ),
                )
              else
                ...paymentBreakdown.entries.map((entry) {
                  final method = entry.key;
                  final amt = entry.value;
                  final pct = totalSalesVolume > 0 ? (amt / totalSalesVolume) * 100 : 0.0;
                  final isCash = method.toLowerCase().contains('esp');
                  final isMomo = method.toLowerCase().contains('mtn');
                  final isOrange = method.toLowerCase().contains('orange');

                  Color barColor = const Color(0xFF0284C7);
                  if (isCash) barColor = const Color(0xFF059669);
                  if (isMomo) barColor = const Color(0xFFF59E0B);
                  if (isOrange) barColor = const Color(0xFFEA580C);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              method,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                            Row(
                              children: [
                                Text(
                                  AppTheme.formatFCFA(amt),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: barColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${pct.toStringAsFixed(1)}%',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (pct / 100).clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 5. HISTORIQUE DÉTAILLÉ DES SHIFTS CLÔTURÉS
        const Text(
          'Détail des shifts clôturés (Heures & Durée)',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 10),

        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Text(
                'Aucun shift clôturé sur cette période.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
            ),
          )
        else
          ...history.map((shift) {
            final openStr = '${shift.openedAt.day.toString().padLeft(2, "0")}/${shift.openedAt.month.toString().padLeft(2, "0")} à ${shift.openedAt.hour.toString().padLeft(2, "0")}:${shift.openedAt.minute.toString().padLeft(2, "0")}';
            final closeStr = shift.closedAt != null
                ? '${shift.closedAt!.day.toString().padLeft(2, "0")}/${shift.closedAt!.month.toString().padLeft(2, "0")} à ${shift.closedAt!.hour.toString().padLeft(2, "0")}:${shift.closedAt!.minute.toString().padLeft(2, "0")}'
                : 'En cours';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.person_pin_rounded, color: AppTheme.primaryNavy, size: 20),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                shift.cashierName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF111827)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF475569)),
                                const SizedBox(width: 4),
                                Text(
                                  shift.formattedDuration,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _confirmDeleteShift(shift),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shift.cashDeskName} · ${shift.storeName}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const Divider(height: 14),

                  _buildDetailRow('Heure d\'ouverture :', openStr),
                  const SizedBox(height: 4),
                  _buildDetailRow('Heure de clôture :', closeStr),
                  const SizedBox(height: 4),
                  if (shift.salesCount > 0 || shift.totalSalesAmount > 0) ...[
                    _buildDetailRow('Nombre de ventes :', '${shift.salesCount} vente(s)'),
                    const SizedBox(height: 4),
                    _buildDetailRow('Total des ventes :', AppTheme.formatFCFA(shift.totalSalesAmount)),
                    const SizedBox(height: 4),
                  ],
                  _buildDetailRow('Ventes espèces décomptées :', AppTheme.formatFCFA(shift.cashSalesTotal)),
                  const SizedBox(height: 4),
                  _buildDetailRow('Espèces réelles comptées :', AppTheme.formatFCFA(shift.closingCashCounted), isBold: true),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Résultat de caisse :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: shift.discrepancy == 0
                              ? const Color(0xFFD1FAE5)
                              : (shift.discrepancy > 0 ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          shift.discrepancy == 0
                              ? 'Caisse parfaite (Aucun écart)'
                              : (shift.discrepancy > 0
                                  ? 'Excédent : +${AppTheme.formatFCFA(shift.discrepancy)}'
                                  : 'Déficit : -${AppTheme.formatFCFA(shift.discrepancy.abs())}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: shift.discrepancy == 0
                                ? const Color(0xFF065F46)
                                : (shift.discrepancy > 0 ? const Color(0xFF1E40AF) : const Color(0xFF991B1B)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (shift.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Remarque : ${shift.note}',
                      style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                    ),
                  ],
                ],
              ),
            );
          }),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildKpiBox({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: MAGASINIERS (Supervision Propriétaire & Suivi des demandes de stock)
  // ===========================================================================
  Widget _buildWarehouseTab() {
    final lowStockProds = appState.products.where((p) {
      if (_selectedStore == 'Toutes les boutiques') {
        return p.isLowStock || p.isOutOfStock;
      }
      final storeStock = p.stockForStore(_selectedStore);
      return storeStock <= p.minStockAlert;
    }).toList();
    final restockRequests = appState.approvalRequests
        .where((r) =>
            (r.type == 'Approvisionnement' || r.type == 'Transfert de stock') &&
            _matchesSelectedStore(r.storeName))
        .toList();
    final isOwner = appState.hasPermission('Validation des approbations');
    final warehouseMembers = appState.teamMembers
        .where((m) => m.role.toLowerCase().contains('magasinier') && _matchesSelectedStore(m.storeName))
        .toList();
    final recentMovements = appState.stockMovements.take(6).toList();
    final pendingRestocksCount = restockRequests.where((r) => r.status == 'pending').length;
    final approvedRestocksTotal = restockRequests
        .where((r) => r.status == 'approved')
        .fold(0.0, (sum, r) => sum + r.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // En-tête adapté : Supervision Propriétaire vs Espace Équipier Magasinier
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warehouse_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOwner
                          ? (_selectedStore == 'Toutes les boutiques'
                              ? 'Supervision des Magasiniers & Stocks'
                              : 'Magasiniers · $_selectedStore')
                          : 'Mon Espace Magasinier & Stocks',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isOwner
                    ? 'Suivez les activités de vos magasiniers rattachés à la boutique sélectionnée, validez leurs demandes et réglez les fournisseurs.'
                    : 'Quand un stock diminue, soumettez une demande d\'approvisionnement au propriétaire qui la validera et paiera le fournisseur.',
                style: const TextStyle(color: Color(0xFFCCFBF1), fontSize: 12.5, height: 1.35),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildHeaderStatChip(
                    icon: Icons.badge_outlined,
                    label: '${warehouseMembers.length} Magasinier(s)',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.pending_actions_rounded,
                    label: '$pendingRestocksCount En attente',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.warning_amber_rounded,
                    label: '${lowStockProds.length} Stock(s) faible(s)',
                  ),
                ],
              ),
              // Le bouton de soumission de demande n'apparaît QUE côté équipier invité (Magasinier), pas côté Propriétaire
              if (!isOwner) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text(
                      'Soumettre une demande d\'approvisionnement',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showRestockDialog(),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // KPI Statistiques Magasiniers de la boutique
        Row(
          children: [
            Expanded(
              child: _buildKpiBox(
                title: 'Demandes soumises',
                value: '${restockRequests.length}',
                sub: '$pendingRestocksCount en attente',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF0D9488),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiBox(
                title: 'Approvisionné validé',
                value: AppTheme.formatFCFA(approvedRestocksTotal),
                sub: '${restockRequests.where((r) => r.status == "approved").length} validée(s)',
                icon: Icons.verified_outlined,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Section Magasiniers invités (visible par le Propriétaire)
        if (isOwner) ...[
          Text(
            _selectedStore == 'Toutes les boutiques'
                ? 'Magasiniers rattachés (${warehouseMembers.length})'
                : 'Magasiniers rattachés à $_selectedStore (${warehouseMembers.length})',
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          if (warehouseMembers.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedStore == 'Toutes les boutiques'
                          ? 'Aucun magasinier invité pour le moment. Invitez un rôle "Magasinier" depuis Équipe pour suivre ses demandes ici.'
                          : 'Aucun magasinier rattaché à la boutique "$_selectedStore".',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF4B5563)),
                    ),
                  ),
                ],
              ),
            )
          else
            ...warehouseMembers.map((m) {
              final mReqs = restockRequests
                  .where((r) => r.requesterName.toLowerCase().contains(m.name.toLowerCase()))
                  .toList();
              final mPending = mReqs.where((r) => r.status == 'pending').length;
              final mApproved = mReqs.where((r) => r.status == 'approved').length;
              final mVolume = mReqs.fold(0.0, (sum, r) => sum + r.amount);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
                      child: const Icon(Icons.warehouse_rounded, color: Color(0xFF0F766E), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.storeName} · Tél: ${m.phone}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF99F6E4)),
                          ),
                          child: Text(
                            '${mReqs.length} demande(s) ($mApproved validée(s))',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          mPending > 0 ? '$mPending en attente · ${AppTheme.formatFCFA(mVolume)}' : AppTheme.formatFCFA(mVolume),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
        ],

        // Section Demandes d'approvisionnement & transferts (Validation Propriétaire)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Demandes d\'approvisionnement & transferts',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
            ),
            if (pendingRestocksCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$pendingRestocksCount à valider',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (restockRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Text(
                'Aucune demande d\'approvisionnement ou de transfert enregistrée.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
            ),
          )
        else
          ...restockRequests.map((req) {
            final isPending = req.status == 'pending';
            final isApproved = req.status == 'approved';
            final isPaid = req.paymentStatus == 'paid';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPending
                      ? const Color(0xFFFDE68A)
                      : (isApproved ? const Color(0xFFA7F3D0) : const Color(0xFFE5E7EB)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          req.type,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPending
                              ? const Color(0xFFFEF3C7)
                              : (isPaid
                                  ? const Color(0xFFDBEAFE)
                                  : (isApproved ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2))),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPending
                              ? '🟡 En attente Proprio'
                              : (isPaid
                                  ? '💳 Payé au fournisseur'
                                  : (isApproved ? '🟢 Validé par Proprio' : '🔴 Rejeté')),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPending
                                ? const Color(0xFF92400E)
                                : (isPaid
                                    ? const Color(0xFF1E40AF)
                                    : (isApproved ? const Color(0xFF065F46) : const Color(0xFF991B1B))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    req.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Demandé par : ${req.requesterName}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (req.amount > 0)
                        Text(
                          AppTheme.formatFCFA(req.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                        ),
                    ],
                  ),
                  if (req.details.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(req.details, style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                    ),
                  ],

                  // Actions Propriétaire : Rejeter ou Valider & Payer le fournisseur
                  if (isPending && isOwner) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () => appState.rejectApprovalRequest(req.id),
                          child: const Text('Rejeter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: Text(
                              req.type == 'Approvisionnement'
                                  ? 'Valider & Payer le fournisseur'
                                  : 'Approuver le transfert',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () async {
                              if (req.type == 'Approvisionnement') {
                                await appState.approveAndPaySupplier(req.id);
                              } else {
                                await appState.approveApprovalRequest(req.id);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      req.type == 'Approvisionnement'
                                          ? 'Approvisionnement validé, stock mis à jour et paiement fournisseur enregistré !'
                                          : 'Transfert de stock approuvé !',
                                    ),
                                    backgroundColor: const Color(0xFF059669),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        const SizedBox(height: 24),

        // Section Articles en stock faible
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alertes de stock faible en boutique',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: lowStockProds.isNotEmpty ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${lowStockProds.length} alerte(s)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: lowStockProds.isNotEmpty ? const Color(0xFFDC2626) : const Color(0xFF059669),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (lowStockProds.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 20),
                SizedBox(width: 8),
                Text('Tous les niveaux de stock sont optimaux.', style: TextStyle(fontSize: 13, color: Color(0xFF374151))),
              ],
            ),
          )
        else
          ...lowStockProds.map((prod) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stock : ${_selectedStore == "Toutes les boutiques" ? prod.stock : prod.stockForStore(_selectedStore)} ${prod.unit} · Seuil d\'alerte : ${prod.minStockAlert}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (!isOwner)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showRestockDialog(prod),
                      child: const Text('Demander réappro', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'À réapprovisionner',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                      ),
                    ),
                ],
              ),
            );
          }),

        if (recentMovements.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Derniers mouvements de stock enregistrés',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          ...recentMovements.map((mov) {
            final isPositive = !mov.type.toUpperCase().contains('SORTIE') && mov.quantity >= 0;
            final formattedDate =
                '${mov.date.day.toString().padLeft(2, '0')}/${mov.date.month.toString().padLeft(2, '0')} à ${mov.date.hour.toString().padLeft(2, '0')}:${mov.date.minute.toString().padLeft(2, '0')}';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.south_west_rounded : Icons.north_east_rounded,
                    color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mov.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                        ),
                        Text(
                          '${mov.reason} · $formattedDate',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : '-'}${mov.quantity.abs()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHeaderStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: GÉRANTS (Supervision Propriétaire & Statistiques par Boutique)
  // ===========================================================================
  Widget _buildManagersTab() {
    final managerRequests = appState.approvalRequests
        .where((r) => r.type != 'Approvisionnement' && _matchesSelectedStore(r.storeName))
        .toList();
    final isOwner = appState.hasPermission('Validation des approbations');

    // Gérants rattachés à la boutique sélectionnée
    final managerMembers = appState.teamMembers.where((m) {
      final r = m.role.toLowerCase().trim();
      return r == 'gérant' && _matchesSelectedStore(m.storeName);
    }).toList();

    final storeSales = appState.sales.where((s) => _matchesSelectedStore(s.storeName)).toList();
    final storeRevenue = storeSales.fold(0.0, (sum, s) => sum + s.total);
    final pendingManagerReqs = managerRequests.where((r) => r.status == 'pending').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.supervisor_account_rounded, color: AppTheme.accentGold, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedStore == 'Toutes les boutiques'
                          ? 'Supervision des Gérants'
                          : 'Gérants · $_selectedStore',
                      style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Retrouvez ici les gérants rattachés à la boutique sélectionnée, leurs performances de supervision ainsi que leurs opérations soumises à votre approbation.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.35),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildHeaderStatChip(
                    icon: Icons.supervisor_account_rounded,
                    label: '${managerMembers.length} Gérant(s)',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.pending_actions_rounded,
                    label: '$pendingManagerReqs En attente',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.point_of_sale_rounded,
                    label: '${storeSales.length} Vente(s) boutique',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // KPI Statistiques Gérants de la boutique
        Row(
          children: [
            Expanded(
              child: _buildKpiBox(
                title: 'CA Boutique supervisé',
                value: AppTheme.formatFCFA(storeRevenue),
                sub: '${storeSales.length} vente(s)',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF92400E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiBox(
                title: 'Opérations Gérants',
                value: '${managerRequests.length}',
                sub: '$pendingManagerReqs à valider',
                icon: Icons.fact_check_outlined,
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Section Gérants rattachés à la boutique
        Text(
          _selectedStore == 'Toutes les boutiques'
              ? 'Gérants rattachés (${managerMembers.length})'
              : 'Gérants rattachés à $_selectedStore (${managerMembers.length})',
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 10),
        if (managerMembers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.group_add_outlined, color: Color(0xFF64748B), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedStore == 'Toutes les boutiques'
                        ? 'Aucun Gérant invité pour l\'instant. Dès que vous invitez un Gérant dans Équipe, ses statistiques s\'affichent ici.'
                        : 'Aucun Gérant rattaché à la boutique "$_selectedStore".',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          )
        else
          ...managerMembers.map((member) {
            final group = appState.accessGroups.firstWhere(
              (g) => (g['role'] ?? '').toString().toLowerCase() == member.role.toLowerCase(),
              orElse: () => <String, dynamic>{},
            );
            final rawPerms = group['permissions'];
            final activePermsCount = rawPerms is Map
                ? rawPerms.values.where((v) => v == true).length
                : (rawPerms is List ? rawPerms.length : 0);
            final memberReqsCount = managerRequests
                .where((r) => r.requesterName.toLowerCase().contains(member.name.toLowerCase()))
                .length;
            final memberSales = storeSales
                .where((s) => s.cashierName.toLowerCase().contains(member.name.toLowerCase()))
                .toList();
            final memberSalesVol = memberSales.fold(0.0, (sum, s) => sum + s.total);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                        child: const Icon(Icons.supervisor_account_rounded, color: AppTheme.primaryNavy, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                            ),
                            Text(
                              '${member.storeName} · Tél: ${member.phone}',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.role,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$activePermsCount droit(s) actif(s) · ${memberSales.length} vente(s) (${AppTheme.formatFCFA(memberSalesVol)})',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$memberReqsCount opération(s)',
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryNavy, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 20),

        const Text(
          'Opérations sous validation du Propriétaire',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 10),

        if (managerRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Text(
                'Aucune opération de supervision soumise pour le moment.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
            ),
          )
        else
          ...managerRequests.map((req) {
            final isPending = req.status == 'pending';
            final isApproved = req.status == 'approved';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          req.type,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPending
                              ? const Color(0xFFFEF3C7)
                              : (isApproved ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPending ? '🟡 En attente' : (isApproved ? '🟢 Validé' : '🔴 Rejeté'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPending
                                ? const Color(0xFF92400E)
                                : (isApproved ? const Color(0xFF065F46) : const Color(0xFF991B1B)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    req.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Soumis par : ${req.requesterName}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (req.amount > 0)
                        Text(
                          AppTheme.formatFCFA(req.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                        ),
                    ],
                  ),
                  if (req.details.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(req.details, style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                    ),
                  ],
                  if (isPending && isOwner) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => appState.rejectApprovalRequest(req.id),
                            child: const Text('Rejeter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => appState.approveApprovalRequest(req.id),
                            child: const Text('Approuver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        const SizedBox(height: 30),
      ],
    );
  }
}
