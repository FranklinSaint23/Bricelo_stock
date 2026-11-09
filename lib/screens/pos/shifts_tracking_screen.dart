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
  String _selectedMemberFilter = 'ALL'; // 'ALL', 'ROLE:Caissier', 'ROLE:Magasinier', 'ROLE:Gérant', ou 'MEMBER:<nom>'
  DateTimeRange? _customDateRange;

  List<String> _getStoreOptions() {
    if (!appState.isOwnerAccount) {
      return [appState.assignedStoreForCurrentUser];
    }
    final stores = <String>{'Toutes les boutiques'};
    for (final s in appState.availableStores) {
      if (s.trim().isNotEmpty) stores.add(s.trim());
    }
    for (final o in appState.outlets) {
      if (o.name.trim().isNotEmpty) stores.add(o.name.trim());
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
    // Un compte invité ne voit que les données de la boutique à laquelle il est rattaché
    if (!appState.isOwnerAccount) {
      return appState.matchesAssignedStore(storeName);
    }
    if (_selectedStore == 'Toutes les boutiques') return true;
    final clean = (storeName ?? '').trim();
    if (clean.isEmpty) return true;
    if (includeGlobal && clean.toLowerCase() == 'toutes les boutiques') return true;
    return clean.toLowerCase() == _selectedStore.trim().toLowerCase();
  }

  String? get _activeFilteredMemberName {
    if (!appState.isOwnerAccount) {
      return appState.displayUserName.trim();
    }
    if (_selectedMemberFilter.startsWith('MEMBER:')) {
      return _selectedMemberFilter.substring('MEMBER:'.length).trim();
    }
    return null;
  }

  bool _matchesSelectedPerson(String? personName) {
    final targetName = _activeFilteredMemberName;
    if (targetName == null || targetName.isEmpty) return true;
    final cleanPerson = (personName ?? '').trim().toLowerCase();
    final cleanTarget = targetName.toLowerCase();
    if (cleanPerson.isEmpty) return false;
    return cleanPerson.contains(cleanTarget) || cleanTarget.contains(cleanPerson);
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
        SnackBar(content: Text('Aucun produit disponible dans le catalogue.'.tr)),
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
          final isDark = appState.isDarkMode;
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.inventory_2_rounded, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demande de réapprovisionnement'.tr,
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Le magasinier transmet cette demande d\'approvisionnement au propriétaire pour validation et paiement.'.tr,
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),

                  // Sélection du produit
                  DropdownButtonFormField<Product>(
                    value: selectedProd,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Article concerné *'.tr,
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: products.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (${'Stock:'.tr} ${p.stock})', overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A))),
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
                      color: isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${'Stock actuel :'.tr} ${selectedProd.stock} ${selectedProd.unit}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                        Text('${'Alerte seuil :'.tr} ${selectedProd.minStockAlert}', style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quantité souhaitée
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: '${'Quantité à commander'.tr} (${selectedProd.unit}) *',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
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
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: 'Fournisseur suggéré'.tr,
                      hintText: 'Ex: Quincaillerie Centrale',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Coût estimé
                  TextField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: 'Coût estimé (FCFA) *'.tr,
                      hintText: '0',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remarque
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      labelText: 'Remarque / Urgence'.tr,
                      hintText: 'Ex: Rupture imminente sur le chantier...',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Annuler'.tr, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
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
                      SnackBar(content: Text('Veuillez saisir une quantité supérieure à 0.'.tr), backgroundColor: const Color(0xFFDC2626)),
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
                        content: Text('${'Demande d\'approvisionnement envoyée au propriétaire pour'.tr} ${selectedProd.name} !'),
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                    );
                  }
                },
                child: Text('Soumettre au Propriétaire'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSettingsToggleDialog() {
    final isDark = appState.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) {
        final isEnabled = appState.isShiftsTrackingEnabled;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Configuration du suivi des shifts'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile.adaptive(
                value: isEnabled,
                title: Text('Activer le suivi des shifts'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                subtitle: Text('Exige l\'ouverture et fermeture de caisse avant encaissement.'.tr, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
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
              child: Text('Fermer'.tr, style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
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
      helpText: 'Sélectionner la période personnalisée'.tr,
      cancelText: 'Annuler'.tr,
      confirmText: 'Valider'.tr,
      saveText: 'Appliquer'.tr,
    );
    if (picked != null && mounted) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = 'Personnalisé';
      });
    }
  }

  void _confirmDeleteShift(CashShift shift) {
    final isDark = appState.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Supprimer ce shift passé ?'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Text(
          '${'Voulez-vous supprimer définitivement le shift de'.tr} ${shift.cashierName} (${shift.cashDeskName}) ${'du'.tr} ${shift.openedAt.day.toString().padLeft(2, "0")}/${shift.openedAt.month.toString().padLeft(2, "0")}/${shift.openedAt.year} ?',
          style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
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
                  SnackBar(
                    content: Text('Shift passé supprimé de l\'historique.'.tr),
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: Text('Supprimer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        .where((s) =>
            _isDateInSelectedPeriod(s.openedAt) &&
            _matchesSelectedStore(s.storeName) &&
            _matchesSelectedPerson(s.cashierName))
        .toList();
  }

  List<Sale> _filterSales(List<Sale> all) {
    return all
        .where((s) =>
            _isDateInSelectedPeriod(s.createdAt) &&
            _matchesSelectedStore(s.storeName) &&
            _matchesSelectedPerson(s.cashierName))
        .toList();
  }

  void _applyMemberOrRoleFilter(String filterVal) {
    setState(() {
      _selectedMemberFilter = filterVal;
      if (filterVal == 'ROLE:Caissier') {
        _tabController.animateTo(0);
      } else if (filterVal == 'ROLE:Magasinier') {
        _tabController.animateTo(1);
      } else if (filterVal == 'ROLE:Gérant') {
        _tabController.animateTo(2);
      } else if (filterVal.startsWith('MEMBER:')) {
        final memberName = filterVal.substring('MEMBER:'.length).trim().toLowerCase();
        final m = appState.teamMembers.firstWhere(
          (tm) => tm.name.trim().toLowerCase() == memberName,
          orElse: () => TeamMember(id: '', name: '', phone: '', role: 'Caissier'),
        );
        final r = m.role.toLowerCase();
        if (r.contains('magasinier')) {
          _tabController.animateTo(1);
        } else if (r.contains('gérant')) {
          _tabController.animateTo(2);
        } else {
          _tabController.animateTo(0);
        }
      }
    });
  }

  Widget _buildStoreSelectorBar() {
    final isDark = appState.isDarkMode;
    if (!appState.isOwnerAccount) {
      final myStore = appState.assignedStoreForCurrentUser;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            const Icon(Icons.storefront_rounded, size: 18, color: AppTheme.accentGold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${'Boutique rattachée :'.tr} $myStore • ${appState.displayUserName}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appState.userRole.tr,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF16A34A)),
              ),
            ),
          ],
        ),
      );
    }

    final storeOptions = _getStoreOptions();
    if (!storeOptions.contains(_selectedStore)) {
      _selectedStore = 'Toutes les boutiques';
    }
    final attachedMembers = appState.teamMembers
        .where((m) =>
            m.role.toLowerCase() != 'propriétaire' &&
            _matchesSelectedStore(m.storeName))
        .toList();
    final attachedCashiers = attachedMembers
        .where((m) => m.role.toLowerCase() == 'caissier')
        .length;
    final attachedWarehouse = attachedMembers
        .where((m) => m.role.toLowerCase().contains('magasinier'))
        .length;
    final attachedManagers = attachedMembers
        .where((m) => m.role.toLowerCase() == 'gérant')
        .length;

    final roleOrMemberItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: 'ALL',
        child: Text('${'Tous les rôles & équipiers'.tr} (${attachedMembers.length})', overflow: TextOverflow.ellipsis),
      ),
      DropdownMenuItem(
        value: 'ROLE:Caissier',
        child: Text('${'Rôle : Tous les Caissiers'.tr} ($attachedCashiers)', overflow: TextOverflow.ellipsis),
      ),
      DropdownMenuItem(
        value: 'ROLE:Magasinier',
        child: Text('${'Rôle : Tous les Magasiniers'.tr} ($attachedWarehouse)', overflow: TextOverflow.ellipsis),
      ),
      DropdownMenuItem(
        value: 'ROLE:Gérant',
        child: Text('${'Rôle : Tous les Gérants'.tr} ($attachedManagers)', overflow: TextOverflow.ellipsis),
      ),
      ...attachedMembers.map(
        (m) => DropdownMenuItem(
          value: 'MEMBER:${m.name}',
          child: Text('👤 ${m.name} (${m.role.tr} · ${m.storeName})', overflow: TextOverflow.ellipsis),
        ),
      ),
    ];

    final validFilterValues = roleOrMemberItems.map((e) => e.value).toSet();
    if (!validFilterValues.contains(_selectedMemberFilter)) {
      _selectedMemberFilter = 'ALL';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18, color: AppTheme.accentGold),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: Text(
                  'Boutique :'.tr,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStore,
                      dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.accentGold),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy),
                      items: storeOptions
                          .map(
                            (st) => DropdownMenuItem(
                              value: st,
                              child: Text(st.tr, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A))),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStore = val;
                            _selectedMemberFilter = 'ALL';
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18, color: AppTheme.accentGold),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: Text(
                  'Équipier :'.tr,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: _selectedMemberFilter != 'ALL'
                        ? (isDark ? const Color(0xFF2E2412) : const Color(0xFFFFFBEB))
                        : (isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedMemberFilter != 'ALL' ? AppTheme.accentGold : (isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMemberFilter,
                      dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.accentGold),
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy),
                      items: roleOrMemberItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.value,
                          child: DefaultTextStyle(
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 12.5),
                            child: item.child,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _applyMemberOrRoleFilter(val);
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (_selectedMemberFilter != 'ALL') ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => setState(() => _selectedMemberFilter = 'ALL'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      'Tous'.tr,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              InkWell(
                onTap: () => _applyMemberOrRoleFilter('ROLE:Caissier'),
                borderRadius: BorderRadius.circular(8),
                child: _buildStoreRoleBadge(Icons.point_of_sale_rounded, '$attachedCashiers Caissier(s)', const Color(0xFF0284C7)),
              ),
              InkWell(
                onTap: () => _applyMemberOrRoleFilter('ROLE:Magasinier'),
                borderRadius: BorderRadius.circular(8),
                child: _buildStoreRoleBadge(Icons.warehouse_rounded, '$attachedWarehouse Magasinier(s)', const Color(0xFF0D9488)),
              ),
              InkWell(
                onTap: () => _applyMemberOrRoleFilter('ROLE:Gérant'),
                borderRadius: BorderRadius.circular(8),
                child: _buildStoreRoleBadge(Icons.supervisor_account_rounded, '$attachedManagers Gérant(s)', const Color(0xFF92400E)),
              ),
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
    final isDark = appState.isDarkMode;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.tr,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white : const Color(0xFF111827),
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
        final isDark = appState.isDarkMode;
        final isEnabled = appState.isShiftsTrackingEnabled;
        final activeShift = appState.activeCashShift;
        final rawHistory = appState.cashShiftsHistory;
        final filteredHistory = _filterShifts(rawHistory);
        final filteredSales = _filterSales(appState.sales);
        final isOwner = appState.isOwnerAccount;
        final isInvited = !isOwner;
        final invitedRole = appState.userRole.toLowerCase().trim();
        final storeSuffix = appState.assignedStoreForCurrentUser.isNotEmpty && appState.assignedStoreForCurrentUser != 'Toutes les boutiques'
            ? ' (${appState.assignedStoreForCurrentUser})'
            : '';
        final invitedTitle = invitedRole.contains('magasinier')
            ? ('Mon Espace Magasinier'.tr + storeSuffix)
            : invitedRole.contains('gérant')
                ? ('Mon Suivi & Mes Activités'.tr + storeSuffix)
                : ('Mes Shifts & Ma Caisse'.tr + storeSuffix);

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: Navigator.canPop(context)
                ? Padding(
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
                  )
                : null,
            title: Text(
              isInvited ? invitedTitle : 'Suivi Shifts & Activités Équipe'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5, color: Colors.white),
            ),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  tooltip: 'Paramètres du suivi'.tr,
                  onPressed: _showSettingsToggleDialog,
                ),
            ],
            bottom: isInvited
                ? null
                : TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.accentGold,
                    indicatorWeight: 3,
                    labelColor: AppTheme.accentGold,
                    unselectedLabelColor: const Color(0xFF94A3B8),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.point_of_sale_rounded, size: 20),
                        text: 'Caissiers & Caisse'.tr,
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
                        text: 'Magasiniers'.tr,
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
                        text: 'Gérants'.tr,
                      ),
                    ],
                  ),
          ),
          body: Column(
            children: [
              _buildStoreSelectorBar(),
              Expanded(
                child: isInvited
                    ? (invitedRole.contains('magasinier')
                        ? _buildWarehouseTab()
                        : invitedRole.contains('gérant')
                            ? _buildManagersTab()
                            : _buildCashiersTab(isEnabled, activeShift, filteredHistory, filteredSales))
                    : TabBarView(
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
    final isDark = appState.isDarkMode;
    final now = DateTime.now();
    final isPast17h30 = now.hour > 17 || (now.hour == 17 && now.minute >= 30);

    // Calculs de synthèse globale sur la période (et filtrés par boutique et équipier)
    final activeInStore = activeShift != null &&
        _matchesSelectedStore(activeShift.storeName) &&
        _matchesSelectedPerson(activeShift.cashierName);
    final totalShiftsCount = history.length + (activeInStore ? 1 : 0);
    final totalSalesCount = periodSales.length;
    final totalSalesVolume = periodSales.fold(0.0, (sum, s) => sum + s.total);
    final totalCashCollected = periodSales
        .where((s) => s.paymentMethod.toLowerCase().contains('esp') || s.paymentMethod.toLowerCase().contains('cash'))
        .fold(0.0, (sum, s) => sum + s.total);

    final isOwner = appState.isOwnerAccount;
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
                color: isDark ? const Color(0xFF3B1219) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm_on_rounded, color: Color(0xFFDC2626), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alerte Clôture 17h30 !'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444), fontSize: 13)),
                        Text('L\'heure de clôture est dépassée. Effectuez le décompte et fermez votre caisse.'.tr, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D))),
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
                    child: Text('Clôturer'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6), width: 1.6),
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
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
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
                                '${activeShift.cashDeskName} ${'ouvert'.tr}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: isDark ? Colors.white : const Color(0xFF111827)),
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
                            '${'Caissier :'.tr} ${activeShift.cashierName} · ${activeShift.storeName}',
                            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                _buildDetailRow('Heure d\'ouverture :', '${activeShift.openedAt.day.toString().padLeft(2, "0")}/${activeShift.openedAt.month.toString().padLeft(2, "0")} ${'à'.tr} ${activeShift.openedAt.hour.toString().padLeft(2, "0")}:${activeShift.openedAt.minute.toString().padLeft(2, "0")}'),
                const SizedBox(height: 5),
                _buildDetailRow('Fond initial en caisse :', AppTheme.formatFCFA(activeShift.openingCash)),
                const SizedBox(height: 5),
                _buildDetailRow('Ventes espèces encaissées :', AppTheme.formatFCFA(activeShift.cashSalesTotal)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162540) : const Color(0xFFF3F4F6),
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
                    label: Text('Clôturer le shift (Faire la caisse)'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, size: 36, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aucun shift de caisse ouvert'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF374151))),
                      Text('Ouvrez un shift avant d\'encaisser des ventes.'.tr, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
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
                  child: Text('Ouvrir'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            Expanded(
              child: Text(
                'Rapport d\'activité caisse'.tr,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _periodOptions.contains(_selectedPeriod) ? _selectedPeriod : 'Tout',
                  dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                  isDense: true,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                  items: _periodOptions
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.tr, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)))))
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
                color: isDark ? const Color(0xFF162540) : AppTheme.primaryNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF1E3052) : AppTheme.primaryNavy.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range_rounded, size: 16, color: AppTheme.accentGold),
                  const SizedBox(width: 6),
                  Text(
                    '${'Du'.tr} ${_customDateRange!.start.day.toString().padLeft(2, "0")}/${_customDateRange!.start.month.toString().padLeft(2, "0")}/${_customDateRange!.start.year} ${'au'.tr} ${_customDateRange!.end.day.toString().padLeft(2, "0")}/${_customDateRange!.end.month.toString().padLeft(2, "0")}/${_customDateRange!.end.year}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
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

        // 3B. CAISSIERS RATTACHÉS À LA BOUTIQUE & STATS PAR CAISSIER (Visible uniquement par le Propriétaire)
        if (isOwner) ...[
          Text(
            _selectedStore == 'Toutes les boutiques'
                ? ('Caissiers rattachés'.tr + ' (${attachedCashiers.length}) — ' + 'touchez un équipier pour filtrer ses stats'.tr)
                : ('${'Caissiers rattachés à'.tr} $_selectedStore (${attachedCashiers.length})'),
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          if (attachedCashiers.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedStore == 'Toutes les boutiques'
                          ? 'Aucun caissier invité pour le moment.'.tr
                          : '${'Aucun caissier rattaché à la boutique'.tr} "$_selectedStore".',
                      style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                    ),
                  ),
                ],
              ),
            )
          else
            ...attachedCashiers.map((m) {
              final mLower = m.name.trim().toLowerCase();
              final isSelectedMember = _selectedMemberFilter == 'MEMBER:${m.name}';
              final mShifts = appState.cashShiftsHistory
                  .where((sh) =>
                      _isDateInSelectedPeriod(sh.openedAt) &&
                      _matchesSelectedStore(sh.storeName) &&
                      sh.cashierName.trim().toLowerCase().contains(mLower))
                  .length +
                  ((activeShift != null &&
                          _matchesSelectedStore(activeShift.storeName) &&
                          activeShift.cashierName.trim().toLowerCase().contains(mLower))
                      ? 1
                      : 0);
              final mSales = appState.sales
                  .where((s) =>
                      _isDateInSelectedPeriod(s.createdAt) &&
                      _matchesSelectedStore(s.storeName) &&
                      s.cashierName.trim().toLowerCase().contains(mLower))
                  .toList();
              final mRevenue = mSales.fold(0.0, (sum, s) => sum + s.total);
              return InkWell(
                onTap: () {
                  _applyMemberOrRoleFilter(isSelectedMember ? 'ALL' : 'MEMBER:${m.name}');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelectedMember
                        ? (isDark ? const Color(0xFF132A4A) : const Color(0xFFEFF6FF))
                        : (isDark ? AppTheme.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelectedMember ? const Color(0xFF0284C7) : (isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
                      width: isSelectedMember ? 1.5 : 1.0,
                    ),
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF111827)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${m.assignedCashDesk ?? "Caisse Principale"} · ${m.storeName}',
                              style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
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
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${mSales.length} ${'vente(s)'.tr} · $mShifts ${'shift(s)'.tr}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],

        // 4. RÉPARTITION DES MOYENS DE PAIEMENT (SOMME & %)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_outline_rounded, color: AppTheme.accentGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Moyens de paiement (Sommes & %)'.tr,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Répartition sur la période sélectionnée :'.tr,
                style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),

              if (paymentBreakdown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text('Aucune vente enregistrée sur cette période.'.tr, style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF))),
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
                              method.tr,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                            ),
                            Row(
                              children: [
                                Text(
                                  AppTheme.formatFCFA(amt),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
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
                            backgroundColor: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0),
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
        Text(
          'Détail des shifts clôturés (Heures & Durée)'.tr,
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
        ),
        const SizedBox(height: 10),

        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Text(
                'Aucun shift clôturé sur cette période.'.tr,
                style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
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
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
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
                            const Icon(Icons.person_pin_rounded, color: AppTheme.accentGold, size: 20),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                shift.cashierName,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: isDark ? Colors.white : const Color(0xFF111827)),
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
                              color: isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_outlined, size: 12, color: isDark ? AppTheme.accentGold : const Color(0xFF475569)),
                                const SizedBox(width: 4),
                                Text(
                                  shift.formattedDuration,
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : const Color(0xFF334155)),
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
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  ),
                  Divider(height: 14, color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),

                  _buildDetailRow('Heure d\'ouverture :', openStr),
                  const SizedBox(height: 4),
                  _buildDetailRow('Heure de clôture :', closeStr),
                  const SizedBox(height: 4),
                  if (shift.salesCount > 0 || shift.totalSalesAmount > 0) ...[
                    _buildDetailRow('Nombre de ventes :', '${shift.salesCount} ${'vente(s)'.tr}'),
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
                      Text('Résultat de caisse :'.tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: shift.discrepancy == 0
                              ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                              : (shift.discrepancy > 0
                                  ? (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE))
                                  : (isDark ? const Color(0xFF451A1A) : const Color(0xFFFEE2E2))),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          shift.discrepancy == 0
                              ? 'Caisse parfaite (Aucun écart)'.tr
                              : (shift.discrepancy > 0
                                  ? '${'Excédent : +'.tr}${AppTheme.formatFCFA(shift.discrepancy)}'
                                  : '${'Déficit : -'.tr}${AppTheme.formatFCFA(shift.discrepancy.abs())}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: shift.discrepancy == 0
                                ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                                : (shift.discrepancy > 0
                                    ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF))
                                    : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (shift.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${'Remarque :'.tr} ${shift.note}',
                      style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
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
    final isDark = appState.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title.tr, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value.tr, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(sub.tr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: MAGASINIERS (Supervision Propriétaire & Suivi des demandes de stock)
  // ===========================================================================
  Widget _buildWarehouseTab() {
    final isDark = appState.isDarkMode;
    final isOwner = appState.isOwnerAccount;
    final effectiveStore = isOwner ? _selectedStore : appState.assignedStoreForCurrentUser;
    final lowStockProds = appState.products.where((p) {
      if (effectiveStore == 'Toutes les boutiques') {
        return p.isLowStock || p.isOutOfStock;
      }
      final storeStock = p.stockForStore(effectiveStore);
      return storeStock <= p.minStockAlert;
    }).toList();
    final restockRequests = appState.approvalRequests
        .where((r) =>
            (r.type == 'Approvisionnement' || r.type == 'Transfert de stock') &&
            _matchesSelectedStore(r.storeName) &&
            _matchesSelectedPerson(r.requesterName))
        .toList();
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
                              ? 'Supervision des Magasiniers & Stocks'.tr
                              : '${'Magasiniers'.tr} · $_selectedStore')
                          : 'Mon Espace Magasinier & Stocks'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isOwner
                    ? 'Suivez les activités de vos magasiniers rattachés à la boutique sélectionnée, validez leurs demandes et réglez les fournisseurs.'.tr
                    : 'Quand un stock diminue, soumettez une demande d\'approvisionnement au propriétaire qui la validera et paiera le fournisseur.'.tr,
                style: const TextStyle(color: Color(0xFFCCFBF1), fontSize: 12.5, height: 1.35),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildHeaderStatChip(
                    icon: Icons.badge_outlined,
                    label: '${warehouseMembers.length} ${'Magasinier(s)'.tr}',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.pending_actions_rounded,
                    label: '$pendingRestocksCount ${'En attente'.tr}',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.warning_amber_rounded,
                    label: '${lowStockProds.length} ${'Stock(s) faible(s)'.tr}',
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
                    label: Text(
                      'Soumettre une demande d\'approvisionnement'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                sub: '$pendingRestocksCount ${'en attente'.tr}',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF0D9488),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiBox(
                title: 'Approvisionné validé',
                value: AppTheme.formatFCFA(approvedRestocksTotal),
                sub: '${restockRequests.where((r) => r.status == "approved").length} ${'validée(s)'.tr}',
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
                ? '${'Magasiniers rattachés'.tr} (${warehouseMembers.length})'
                : '${'Magasiniers rattachés à'.tr} $_selectedStore (${warehouseMembers.length})',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          if (warehouseMembers.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedStore == 'Toutes les boutiques'
                          ? 'Aucun magasinier invité pour le moment. Invitez un rôle "Magasinier" depuis Équipe pour suivre ses demandes ici.'.tr
                          : '${'Aucun magasinier rattaché à la boutique'.tr} "$_selectedStore".',
                      style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
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
              final isSelectedMember = _selectedMemberFilter == 'MEMBER:${m.name}';
              return InkWell(
                onTap: () {
                  _applyMemberOrRoleFilter(
                    isSelectedMember ? 'Tous les rôles & équipiers' : 'MEMBER:${m.name}',
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelectedMember
                        ? (isDark ? const Color(0xFF134E4A).withValues(alpha: 0.5) : const Color(0xFFF0FDFA))
                        : (isDark ? AppTheme.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelectedMember ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                      width: isSelectedMember ? 1.5 : 1.0,
                    ),
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF111827)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${m.storeName} · ${'Tél:'.tr} ${m.phone}',
                              style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
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
                              color: isDark ? const Color(0xFF134E4A).withValues(alpha: 0.4) : const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF99F6E4)),
                            ),
                            child: Text(
                              '${mReqs.length} ${'demande(s)'.tr} ($mApproved ${'validée(s)'.tr})',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            mPending > 0 ? '$mPending ${'en attente'.tr} · ${AppTheme.formatFCFA(mVolume)}' : AppTheme.formatFCFA(mVolume),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],

        // Section Demandes d'approvisionnement & transferts (Validation Propriétaire)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Demandes d\'approvisionnement & transferts'.tr,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
              ),
            ),
            if (pendingRestocksCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: const Color(0xFFB45309)) : null,
                ),
                child: Text(
                  '$pendingRestocksCount ${'à valider'.tr}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (restockRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Text(
                'Aucune demande d\'approvisionnement ou de transfert enregistrée.'.tr,
                style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF)),
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
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPending
                      ? const Color(0xFFFDE68A)
                      : (isApproved
                          ? const Color(0xFFA7F3D0)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB))),
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
                          req.type.tr,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPending
                              ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF3C7))
                              : (isPaid
                                  ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFDBEAFE))
                                  : (isApproved
                                      ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFD1FAE5))
                                      : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEE2E2)))),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPending
                              ? '🟡 ${'En attente Proprio'.tr}'
                              : (isPaid
                                  ? '💳 ${'Payé au fournisseur'.tr}'
                                  : (isApproved ? '🟢 ${'Validé par Proprio'.tr}' : '🔴 ${'Rejeté'.tr}')),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPending
                                ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E))
                                : (isPaid
                                    ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF))
                                    : (isApproved
                                        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                                        : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B)))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    req.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: isDark ? Colors.white : const Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${'Demandé par :'.tr} ${req.requesterName}',
                          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (req.amount > 0)
                        Text(
                          AppTheme.formatFCFA(req.amount),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.primaryNavy),
                        ),
                    ],
                  ),
                  if (req.details.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(req.details, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
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
                          child: Text('Rejeter'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                                  ? 'Valider & Payer le fournisseur'.tr
                                  : 'Approuver le transfert'.tr,
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
                                          ? 'Approvisionnement validé, stock mis à jour et paiement fournisseur enregistré !'.tr
                                          : 'Transfert de stock approuvé !'.tr,
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
            Text(
              'Alertes de stock faible en boutique'.tr,
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: lowStockProds.isNotEmpty
                    ? (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEE2E2))
                    : (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFD1FAE5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${lowStockProds.length} ${'alerte(s)'.tr}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: lowStockProds.isNotEmpty
                      ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
                      : (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669)),
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
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tous les niveaux de stock sont optimaux.'.tr,
                  style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                ),
              ],
            ),
          )
        else
          ...lowStockProds.map((prod) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEE2E2),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF111827)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${'Stock :'.tr} ${_selectedStore == "Toutes les boutiques" ? prod.stock : prod.stockForStore(_selectedStore)} ${prod.unit} · ${'Seuil d\'alerte :'.tr} ${prod.minStockAlert}',
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
                      child: Text('Demander réappro'.tr, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'À réapprovisionner'.tr,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626)),
                      ),
                    ),
                ],
              ),
            );
          }),

        if (recentMovements.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Derniers mouvements de stock enregistrés'.tr,
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
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
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
                        ),
                        Text(
                          '${mov.reason} · $formattedDate',
                          style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
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
    final isDark = appState.isDarkMode;
    final isOwner = appState.isOwnerAccount;
    final managerRequests = appState.approvalRequests
        .where((r) =>
            r.type != 'Approvisionnement' &&
            _matchesSelectedStore(r.storeName) &&
            _matchesSelectedPerson(r.requesterName))
        .toList();

    // Gérants rattachés à la boutique sélectionnée
    final managerMembers = appState.teamMembers.where((m) {
      final r = m.role.toLowerCase().trim();
      return r == 'gérant' && _matchesSelectedStore(m.storeName);
    }).toList();

    final storeSales = appState.sales
        .where((s) =>
            _matchesSelectedStore(s.storeName) &&
            (_activeFilteredMemberName == null || _matchesSelectedPerson(s.cashierName)))
        .toList();
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
                          ? 'Supervision des Gérants'.tr
                          : '${'Gérants'.tr} · $_selectedStore',
                      style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Retrouvez ici les gérants rattachés à la boutique sélectionnée, leurs performances de supervision ainsi que leurs opérations soumises à votre approbation.'.tr,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.35),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildHeaderStatChip(
                    icon: Icons.supervisor_account_rounded,
                    label: '${managerMembers.length} ${'Gérant(s)'.tr}',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.pending_actions_rounded,
                    label: '$pendingManagerReqs ${'En attente'.tr}',
                  ),
                  _buildHeaderStatChip(
                    icon: Icons.point_of_sale_rounded,
                    label: '${storeSales.length} ${'Vente(s) boutique'.tr}',
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
                sub: '${storeSales.length} ${'vente(s)'.tr}',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF92400E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiBox(
                title: 'Opérations Gérants',
                value: '${managerRequests.length}',
                sub: '$pendingManagerReqs ${'à valider'.tr}',
                icon: Icons.fact_check_outlined,
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Section Gérants rattachés à la boutique (visible uniquement pour le Propriétaire)
        if (isOwner) ...[
          Text(
            _selectedStore == 'Toutes les boutiques'
                ? '${'Gérants rattachés'.tr} (${managerMembers.length})'
                : '${'Gérants rattachés à'.tr} $_selectedStore (${managerMembers.length})',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          if (managerMembers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_add_outlined, color: Color(0xFF64748B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedStore == 'Toutes les boutiques'
                          ? 'Aucun Gérant invité pour l\'instant. Dès que vous invitez un Gérant dans Équipe, ses statistiques s\'affichent ici.'.tr
                          : '${'Aucun Gérant rattaché à la boutique'.tr} "$_selectedStore".',
                      style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
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
              final isSelectedMember = _selectedMemberFilter == 'MEMBER:${member.name}';

              return InkWell(
                onTap: () {
                  _applyMemberOrRoleFilter(
                    isSelectedMember ? 'Tous les rôles & équipiers' : 'MEMBER:${member.name}',
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelectedMember
                        ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : const Color(0xFFFEF3C7).withValues(alpha: 0.35))
                        : (isDark ? AppTheme.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelectedMember ? const Color(0xFFD97706) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                      width: isSelectedMember ? 1.5 : 1.0,
                    ),
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
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                                ),
                                Text(
                                  '${member.storeName} · ${'Tél:'.tr} ${member.phone}',
                                  style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              member.role.tr,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$activePermsCount ${'droit(s) actif(s)'.tr} · ${memberSales.length} ${'vente(s)'.tr} (${AppTheme.formatFCFA(memberSalesVol)})',
                            style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$memberReqsCount ${'opération(s)'.tr}',
                            style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white : AppTheme.primaryNavy, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],

        Text(
          isOwner ? 'Opérations sous validation du Propriétaire'.tr : 'Mes opérations soumises au Propriétaire'.tr,
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
        ),
        const SizedBox(height: 10),

        if (managerRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Text(
                'Aucune opération de supervision soumise pour le moment.'.tr,
                style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF)),
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
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
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
                          color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          req.type.tr,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPending
                              ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF3C7))
                              : (isApproved
                                  ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFD1FAE5))
                                  : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEE2E2))),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPending ? '🟡 ${'En attente'.tr}' : (isApproved ? '🟢 ${'Validé'.tr}' : '🔴 ${'Rejeté'.tr}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPending
                                ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E))
                                : (isApproved
                                    ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                                    : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    req.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: isDark ? Colors.white : const Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${'Soumis par :'.tr} ${req.requesterName}',
                          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (req.amount > 0)
                        Text(
                          AppTheme.formatFCFA(req.amount),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.primaryNavy),
                        ),
                    ],
                  ),
                  if (req.details.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(req.details, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
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
                            child: Text('Rejeter'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                            child: Text('Approuver'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
