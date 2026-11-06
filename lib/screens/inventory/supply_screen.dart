import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/inventory/supply_success_screen.dart';

class SupplyFee {
  String type; // 'Transport', 'Douane', 'Taxe', 'Assurance', 'Autre'
  final TextEditingController amountController;

  SupplyFee({
    required this.type,
    String initialAmount = '0',
  }) : amountController = TextEditingController(text: initialAmount);

  double get amount => double.tryParse(amountController.text.trim()) ?? 0.0;
}

class SupplyItem {
  final Product product;
  int quantity;
  double buyPrice;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final bool hasPreviousSupply;
  final String? lastSupplier;
  final double? lastPrice;

  SupplyItem({
    required this.product,
    this.quantity = 1,
    required this.buyPrice,
    this.hasPreviousSupply = false,
    this.lastSupplier,
    this.lastPrice,
  })  : quantityController = TextEditingController(text: quantity.toString()),
        priceController = TextEditingController(text: buyPrice > 0 ? buyPrice.toInt().toString() : '');

  double get total => quantity * buyPrice;

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}

class SupplyScreen extends StatefulWidget {
  const SupplyScreen({super.key});

  @override
  State<SupplyScreen> createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  final appState = AppState.instance;

  String _selectedMode = 'Achat fournisseur'; // 'Achat fournisseur', 'Stock existant'
  String? _selectedSupplier;
  String _selectedStore = '';
  bool _tvaDeductible = false;
  bool _alreadyPaid = false;
  String _supplyPaymentMethod = 'Caisse';
  DateTime _supplyPaymentDate = DateTime.now();
  final _notesCtrl = TextEditingController();

  // Liste des articles ajoutés
  final List<SupplyItem> _items = [];

  // Liste des frais
  bool _isFeesExpanded = false;
  final List<SupplyFee> _fees = [];

  final List<String> _feeTypes = const [
    'Transport',
    'Douane',
    'Taxe',
    'Assurance',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    if (appState.suppliers.isNotEmpty) {
      _selectedSupplier = appState.suppliers.first.name;
    }
    if (appState.outlets.isNotEmpty) {
      final def = appState.outlets.firstWhere((o) => o.isDefault, orElse: () => appState.outlets.first);
      _selectedStore = def.name;
    } else {
      _selectedStore = appState.currentStore;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final i in _items) {
      i.dispose();
    }
    for (final f in _fees) {
      f.amountController.dispose();
    }
    super.dispose();
  }

  SupplyItem _createSupplyItem(Product product) {
    // Vérifier les approvisionnements précédents dans les mouvements de stock
    final pastMovements = appState.stockMovements.where(
      (sm) => sm.productId == product.id && (sm.type.contains('RÉASSORT') || sm.type.contains('ACHAT')),
    ).toList();

    // S'il y a eu au moins un approvisionnement passé ou un buyPrice enregistré
    final bool isRepeatSupply = pastMovements.isNotEmpty || product.buyPrice > 0;
    
    double lastCost = 0.0;
    String supplierName = product.supplierName?.isNotEmpty == true ? product.supplierName! : 'Jean';

    if (pastMovements.isNotEmpty) {
      final latest = pastMovements.first;
      if (latest.reason.contains('Fournisseur:')) {
        final match = RegExp(r'Fournisseur:\s*([^\(]+)').firstMatch(latest.reason);
        if (match != null && match.group(1) != null) {
          supplierName = match.group(1)!.trim();
        }
      }
      lastCost = product.buyPrice > 0 ? product.buyPrice : 0.0;
    } else if (product.buyPrice > 0) {
      lastCost = product.buyPrice;
    }

    // Le prix ne doit être pré-écrit que si c'est le 2ème+ approvisionnement
    final initialBuyPrice = isRepeatSupply && lastCost > 0 ? lastCost : 0.0;

    return SupplyItem(
      product: product,
      quantity: 1,
      buyPrice: initialBuyPrice,
      hasPreviousSupply: isRepeatSupply && lastCost > 0,
      lastSupplier: supplierName.isNotEmpty ? supplierName : (_selectedSupplier ?? 'Jean'),
      lastPrice: lastCost > 0 ? lastCost : null,
    );
  }

  double get _itemsTotal => _items.fold(0.0, (sum, i) => sum + i.total);
  double get _feesTotal => _fees.fold(0.0, (sum, f) => sum + f.amount);
  double get _grandTotal => _itemsTotal + _feesTotal;

  int get _itemsWithoutCostCount => _items.where((i) => i.buyPrice <= 0).length;

  void _showAddProductsModal() {
    final isDark = appState.isDarkMode;
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final products = appState.products.where((p) {
              if (query.isNotEmpty) {
                return p.name.toLowerCase().contains(query) || p.category.toLowerCase().contains(query);
              }
              return true;
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ajouter des articles',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: isDark ? Colors.white : AppTheme.primaryNavy,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_rounded, color: AppTheme.accentGold, size: 28),
                          tooltip: 'Valider',
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                      ),
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: (_) => setModalState(() {}),
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher un produit...',
                          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: products.isEmpty
                          ? Center(
                              child: Text(
                                'Aucun produit trouvé',
                                style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF9CA3AF)),
                              ),
                            )
                          : ListView.separated(
                              itemCount: products.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final p = products[idx];
                                final existingIndex = _items.indexWhere((i) => i.product.id == p.id);
                                final alreadyAdded = existingIndex != -1;
                                final item = alreadyAdded ? _items[existingIndex] : null;

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: alreadyAdded
                                          ? AppTheme.accentGold
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                      width: alreadyAdded ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ProductImageWidget(
                                            imageUrl: p.imageUrl,
                                            size: 42,
                                            borderRadius: 8,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Stock (${_selectedStore.isNotEmpty ? _selectedStore : "Boutique"}): ${p.stockForStore(_selectedStore)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!alreadyAdded)
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryNavy,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _items.add(_createSupplyItem(p));
                                                });
                                                setModalState(() {});
                                              },
                                              child: const Text('+ Ajouter'),
                                            )
                                          else
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              onPressed: () {
                                                setState(() {
                                                  _items.removeAt(existingIndex);
                                                });
                                                setModalState(() {});
                                              },
                                            ),
                                        ],
                                      ),
                                      if (alreadyAdded && item != null) ...[
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            // Contrôle direct de la quantité
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (item.quantity > 1) {
                                                          item.quantity -= 1;
                                                          item.quantityController.text = item.quantity.toString();
                                                        } else {
                                                          _items.removeAt(existingIndex);
                                                        }
                                                      });
                                                      setModalState(() {});
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                      child: Icon(Icons.remove, size: 16, color: Color(0xFF475569)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        item.quantity += 1;
                                                        item.quantityController.text = item.quantity.toString();
                                                      });
                                                      setModalState(() {});
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                      child: Icon(Icons.add, size: 16, color: Color(0xFF475569)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // Saisie directe du coût unitaire
                                            Expanded(
                                              child: SizedBox(
                                                height: 36,
                                                child: TextFormField(
                                                  controller: item.priceController,
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                  decoration: InputDecoration(
                                                    labelText: 'Coût unitaire',
                                                    suffixText: 'F CFA',
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                    isDense: true,
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      item.buyPrice = double.tryParse(val.trim()) ?? 0.0;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
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
              ),
            );
          },
        );
      },
    );
  }

  void _addLowStockProducts() {
    int added = 0;
    for (final p in appState.products) {
      if (p.stock <= 5 && !_items.any((i) => i.product.id == p.id)) {
        final item = _createSupplyItem(p);
        item.quantity = 5;
        item.quantityController.text = '5';
        _items.add(item);
        added++;
      }
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryNavy,
        content: Text(
          added > 0
              ? '$added article(s) en stock critique ajouté(s) au réassort !'
              : 'Tous les articles en stock bas sont déjà ajoutés.',
        ),
      ),
    );
  }

  void _saveSupply() {
    if (_items.isEmpty && _fees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Veuillez ajouter au moins un article ou un frais.'),
        ),
      );
      return;
    }

    if (_itemsWithoutCostCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Veuillez renseigner le coût unitaire de tous les articles ($_itemsWithoutCostCount manquant(s)).'),
        ),
      );
      return;
    }

    // Mettre à jour le stock des articles avec traçabilité
    for (final item in _items) {
      appState.restockProduct(
        productId: item.product.id,
        quantity: item.quantity,
        buyCost: item.buyPrice,
        supplier: _selectedSupplier ?? 'Fournisseur',
        storeName: _selectedStore,
      );
    }

    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seq = (appState.purchaseOrders.length + 1).toString().padLeft(4, '0');
    final orderRef = 'BS-ACH-$dateStr-$seq';
    final receptionRef = 'BS-REC-$dateStr-$seq';
    final invoiceRef = 'BS-FAF-$dateStr-$seq';

    final sup = _selectedSupplier != null
        ? appState.suppliers.firstWhere(
            (s) => s.name.trim().toLowerCase() == _selectedSupplier!.trim().toLowerCase(),
            orElse: () => Supplier(id: 'sup_${DateTime.now().millisecondsSinceEpoch}', name: _selectedSupplier!),
          )
        : null;

    // Enregistrer le bon d'achat dans l'historique
    if (sup != null) {
      final po = PurchaseOrder(
        id: 'po_${DateTime.now().millisecondsSinceEpoch}',
        reference: orderRef,
        supplierId: sup.id,
        supplierName: sup.name,
        destinationStore: _selectedStore,
        createdAt: now,
        status: 'Reçu',
        items: _items
            .map((i) => PurchaseOrderItem(
                  productId: i.product.id,
                  productName: i.product.name,
                  quantityRequested: i.quantity,
                  quantityReceived: i.quantity,
                  unitPrice: i.buyPrice,
                ))
            .toList(),
        receptions: [
          PurchaseOrderReception(
            reference: receptionRef,
            date: now,
            storeName: _selectedStore,
            articlesCount: _items.fold(0, (sum, i) => sum + i.quantity),
            supplierPrice: _grandTotal,
            costPrice: _grandTotal,
          ),
        ],
      );
      appState.addPurchaseOrder(po);
    }

    String? debtId;
    if (_selectedMode == 'Achat fournisseur' && _grandTotal > 0 && sup != null) {
      if (!_alreadyPaid) {
        debtId = 'sdebt_${DateTime.now().millisecondsSinceEpoch}';
        appState.addSupplierDebt(
          SupplierDebt(
            id: debtId,
            supplierName: sup.name,
            supplierPhone: sup.phone,
            invoiceRef: invoiceRef,
            totalAmount: _grandTotal,
            createdAt: now,
            dueDate: now.add(const Duration(days: 15)),
            orderRef: orderRef,
            storeName: _selectedStore,
          ),
        );
      } else {
        // Enregistrer la facture réglée avec son règlement récent
        final regRef = 'BS-REG-$dateStr-$seq';
        appState.addSupplierDebt(
          SupplierDebt(
            id: 'sdebt_${DateTime.now().millisecondsSinceEpoch}',
            supplierName: sup.name,
            supplierPhone: sup.phone,
            invoiceRef: invoiceRef,
            totalAmount: _grandTotal,
            paidAmount: _grandTotal,
            createdAt: now,
            dueDate: now,
            orderRef: orderRef,
            storeName: _selectedStore,
            payments: [
              DebtPayment(
                id: regRef,
                amount: _grandTotal,
                date: _supplyPaymentDate,
                paymentMethod: _supplyPaymentMethod,
                note: 'Règlement comptant approvisionnement',
              ),
            ],
          ),
        );

        // Déduire le paiement comptant du solde de la caisse
        final targetDesk = appState.cashDesks.firstWhereOrNull((c) =>
            c.storeName.trim().toLowerCase() == _selectedStore.trim().toLowerCase() ||
            c.name.trim().toLowerCase() == _supplyPaymentMethod.trim().toLowerCase()) ?? appState.cashDesks.firstOrNull;
        if (targetDesk != null) {
          targetDesk.balance = (targetDesk.balance - _grandTotal).clamp(0.0, double.infinity);
        }
      }
    }

    final itemsSummary = _items.map((i) => {
      'name': i.product.name,
      'quantity': i.quantity,
      'buyPrice': i.buyPrice,
      'total': i.quantity * i.buyPrice,
    }).toList();

    // Naviguer vers l'écran de succès de l'approvisionnement (Image 1)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SupplySuccessScreen(
          supplierName: _selectedSupplier ?? 'Fournisseur',
          orderRef: orderRef,
          receptionRef: receptionRef,
          invoiceRef: invoiceRef,
          totalAmount: _grandTotal,
          isAlreadyPaid: _alreadyPaid,
          debtId: debtId,
          items: itemsSummary,
          storeName: _selectedStore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final supplierList = appState.suppliers.map((s) => s.name).toList();
        final canSave = _items.isNotEmpty && _itemsWithoutCostCount == 0 && _grandTotal > 0;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
          appBar: StockAppBar.navy(
            title: 'Approvisionnement',
            onBack: () => Navigator.pop(context),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    // 1. TEXTE INTRODUCTIF
                    Text(
                      'Une seule étape pour enregistrer la commande et sa réception.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. SEGMENTED TABS: Achat fournisseur | Stock existant (Total background sur le segment actif)
                    Container(
                      height: 44,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedMode = 'Achat fournisseur'),
                              child: Container(
                                height: double.infinity,
                                color: _selectedMode == 'Achat fournisseur'
                                    ? (isDark ? AppTheme.primaryNavy : const Color(0xFFFED7AA))
                                    : Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_shipping_outlined,
                                      size: 16,
                                      color: _selectedMode == 'Achat fournisseur'
                                          ? (isDark ? AppTheme.accentGold : const Color(0xFF111827))
                                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Achat fournisseur',
                                      style: TextStyle(
                                        fontWeight: _selectedMode == 'Achat fournisseur'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                        color: _selectedMode == 'Achat fournisseur'
                                            ? (isDark ? AppTheme.accentGold : const Color(0xFF111827))
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1.0,
                            height: double.infinity,
                            color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedMode = 'Stock existant'),
                              child: Container(
                                height: double.infinity,
                                color: _selectedMode == 'Stock existant'
                                    ? (isDark ? AppTheme.primaryNavy : const Color(0xFFFED7AA))
                                    : Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 16,
                                      color: _selectedMode == 'Stock existant'
                                          ? (isDark ? AppTheme.accentGold : const Color(0xFF111827))
                                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Stock existant',
                                      style: TextStyle(
                                        fontWeight: _selectedMode == 'Stock existant'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                        color: _selectedMode == 'Stock existant'
                                            ? (isDark ? AppTheme.accentGold : const Color(0xFF111827))
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2.5 SÉLECTION DE LA BOUTIQUE DE DESTINATION
                    Row(
                      children: [
                        const Icon(Icons.storefront, size: 16, color: AppTheme.primaryNavy),
                        const SizedBox(width: 6),
                        Text(
                          'Boutique de destination *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: () {
                            final storeList = appState.availableStores.isNotEmpty
                                ? appState.availableStores
                                : (appState.outlets.isNotEmpty ? appState.outlets.map((o) => o.name).toList() : [appState.currentStore]);
                            return storeList.contains(_selectedStore) ? _selectedStore : storeList.first;
                          }(),
                          isExpanded: true,
                          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryNavy),
                          items: (appState.availableStores.isNotEmpty
                                  ? appState.availableStores
                                  : (appState.outlets.isNotEmpty ? appState.outlets.map((o) => o.name).toList() : [appState.currentStore]))
                              .map((sName) {
                            final outlet = appState.outlets.firstWhereOrNull((o) => o.name == sName);
                            final isDef = outlet?.isDefault ?? (sName == appState.currentStore);
                            return DropdownMenuItem<String>(
                              value: sName,
                              child: Row(
                                children: [
                                  Icon(Icons.storefront_outlined, size: 16, color: isDef ? AppTheme.accentGold : Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    sName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  if (isDef) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Par défaut', style: TextStyle(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStore = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. FOURNISSEUR DROPDOWN
                    if (_selectedMode == 'Achat fournisseur') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fournisseur *',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 15, color: AppTheme.primaryNavy),
                            label: const Text(
                              '+ Nouveau fournisseur',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy),
                            ),
                            onPressed: () {
                              final nameCtrl = TextEditingController();
                              final phoneCtrl = TextEditingController();
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Nouveau fournisseur', style: TextStyle(fontWeight: FontWeight.bold)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameCtrl,
                                        autofocus: true,
                                        decoration: const InputDecoration(labelText: 'Nom du fournisseur *', border: OutlineInputBorder()),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: phoneCtrl,
                                        keyboardType: TextInputType.phone,
                                        decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white),
                                      onPressed: () {
                                        final n = nameCtrl.text.trim();
                                        if (n.isNotEmpty) {
                                          appState.addSupplier(
                                            Supplier(
                                              id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
                                              name: n,
                                              phone: phoneCtrl.text.trim(),
                                              contactName: 'Général',
                                            ),
                                          );
                                          setState(() => _selectedSupplier = n);
                                        }
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Ajouter'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: supplierList.contains(_selectedSupplier) ? _selectedSupplier : null,
                            hint: Text(
                              'Choisir un fournisseur',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                            ),
                            isExpanded: true,
                            dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                            items: supplierList.map((s) {
                              return DropdownMenuItem<String>(
                                value: s,
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedSupplier = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // 4. SECTION ARTICLES (Exactement comme dans la capture)
                    Text(
                      'Articles (${_items.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bouton Scanner ou rechercher (Pilule blanche avec bordure nette)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : AppTheme.primaryNavy,
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        icon: const Icon(Icons.search, size: 18, color: AppTheme.accentGold),
                        label: const Text(
                          'Rechercher',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        onPressed: _showAddProductsModal,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Bouton Ajouter le stock bas
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        icon: const Icon(Icons.playlist_add_check, size: 18, color: Color(0xFF9CA3AF)),
                        label: const Text(
                          'Ajouter le stock bas',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        onPressed: _addLowStockProducts,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Liste des articles ajoutés (Reproduction fidèle de la capture)
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            'Aucun article ajouté',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ligne 1 : Nom du produit + Icône poubelle
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ProductImageWidget(
                                    imageUrl: item.product.imageUrl,
                                    size: 38,
                                    borderRadius: 8,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF64748B)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        item.dispose();
                                        _items.remove(item);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Ligne 2 : Quantité (- Qte +) et Coût unitaire côte à côte
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Champ Quantité avec boutons [-] et [+] + saisie manuelle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Quantité',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, size: 16),
                                                padding: EdgeInsets.zero,
                                                color: const Color(0xFF64748B),
                                                onPressed: () {
                                                  if (item.quantity > 1) {
                                                    setState(() {
                                                      item.quantity--;
                                                      item.quantityController.text = item.quantity.toString();
                                                    });
                                                  }
                                                },
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  controller: item.quantityController,
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                  ),
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.zero,
                                                  ),
                                                  onChanged: (val) {
                                                    final q = int.tryParse(val.trim());
                                                    if (q != null && q >= 1) {
                                                      setState(() => item.quantity = q);
                                                    }
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add, size: 16),
                                                padding: EdgeInsets.zero,
                                                color: AppTheme.primaryNavy,
                                                onPressed: () {
                                                  setState(() {
                                                    item.quantity++;
                                                    item.quantityController.text = item.quantity.toString();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Champ Coût unitaire (Prérempli si 2ème+ approvisionnement)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Coût unitaire',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 44,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: item.buyPrice <= 0
                                                  ? const Color(0xFFFCA5A5)
                                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                            ),
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller: item.priceController,
                                              keyboardType: TextInputType.number,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: 'Coût unitaire',
                                                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              onChanged: (val) {
                                                final p = double.tryParse(val.trim());
                                                setState(() => item.buyPrice = p ?? 0.0);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Ligne 3 : Pastille "Dernier prix (Fournisseur) · XXX F CFA" + Total ligne
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (item.hasPreviousSupply && item.lastPrice != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.history, size: 14, color: Color(0xFFD97706)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Dernier prix (${item.lastSupplier}) · ${AppTheme.formatFCFA(item.lastPrice!)}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Text(
                                        '1er approvisionnement',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1D4ED8),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    '= ${AppTheme.formatFCFA(item.total)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 10),
                    Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),

                    // 5. GESTION DES FRAIS
                    InkWell(
                      onTap: () => setState(() => _isFeesExpanded = !_isFeesExpanded),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Frais (${_fees.length} · ${AppTheme.formatFCFA(_feesTotal)})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            Icon(
                              _isFeesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isFeesExpanded) ...[
                      const SizedBox(height: 6),
                      ..._fees.asMap().entries.map((entry) {
                        final index = entry.key;
                        final fee = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              PopupMenuButton<String>(
                                initialValue: fee.type,
                                tooltip: 'Choisir le type de frais',
                                color: isDark ? AppTheme.darkSurface : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                onSelected: (val) {
                                  setState(() => fee.type = val);
                                },
                                itemBuilder: (ctx) {
                                  return _feeTypes.map((type) {
                                    final isSelected = fee.type == type;
                                    return PopupMenuItem<String>(
                                      value: type,
                                      child: Row(
                                        children: [
                                          if (isSelected) ...[
                                            const Icon(Icons.check, size: 18, color: AppTheme.accentGold),
                                            const SizedBox(width: 8),
                                          ] else ...[
                                            const SizedBox(width: 26),
                                          ],
                                          Text(
                                            type,
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isDark ? Colors.white : const Color(0xFF111827),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                },
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        fee.type,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: fee.amountController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Montant',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF6B7280)),
                                onPressed: () {
                                  setState(() {
                                    fee.amountController.dispose();
                                    _fees.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),

                      Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryNavy,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.add, size: 18, color: AppTheme.accentGold),
                          label: Text(
                            'Ajouter des frais',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              final used = _fees.map((f) => f.type).toSet();
                              final nextType = _feeTypes.firstWhere((t) => !used.contains(t), orElse: () => 'Autre');
                              _fees.add(SupplyFee(type: nextType));
                            });
                          },
                        ),
                      ),
                    ],

                    Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                    const SizedBox(height: 10),

                    // 6. SWITCHES TVA DÉDUCTIBLE & DÉJÀ PAYÉ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TVA déductible',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Votre régime ne suit pas la TVA — non applicable. Les coûts sont enregistrés tout compris.',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _tvaDeductible,
                          activeTrackColor: AppTheme.primaryNavy,
                          activeThumbColor: AppTheme.accentGold,
                          onChanged: (v) => setState(() => _tvaDeductible = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_selectedMode == 'Achat fournisseur') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Déjà payé',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'La facture fournisseur est réglée en totalité avec la réception.',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _alreadyPaid,
                            activeTrackColor: AppTheme.primaryNavy,
                            activeThumbColor: AppTheme.accentGold,
                            onChanged: (v) => setState(() => _alreadyPaid = v),
                          ),
                        ],
                      ),
                      if (_alreadyPaid) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Moyen de paiement',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: isDark ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSupplyPaymentCard(
                                title: 'Caisse ${appState.currentStore}',
                                icon: Icons.payments_outlined,
                                selected: _supplyPaymentMethod.startsWith('Caisse'),
                                onTap: () => setState(() => _supplyPaymentMethod = 'Caisse ${appState.currentStore}'),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSupplyPaymentCard(
                                title: 'Mobile Money',
                                icon: Icons.phone_android_rounded,
                                selected: _supplyPaymentMethod == 'Mobile Money',
                                onTap: () => setState(() => _supplyPaymentMethod = 'Mobile Money'),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSupplyPaymentCard(
                                title: 'Virement',
                                icon: Icons.account_balance_rounded,
                                selected: _supplyPaymentMethod == 'Virement',
                                onTap: () => setState(() => _supplyPaymentMethod = 'Virement'),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _supplyPaymentDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setState(() => _supplyPaymentDate = picked);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date du paiement',
                              labelStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                                color: isDark ? Colors.white70 : const Color(0xFF334155),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            child: Text(
                              '${_supplyPaymentDate.day.toString().padLeft(2, '0')}/${_supplyPaymentDate.month.toString().padLeft(2, '0')}/${_supplyPaymentDate.year}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                    ],

                    // 7. NOTES (OPTIONNEL)
                    Text(
                      'Notes (optionnel)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: TextField(
                        controller: _notesCtrl,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // 8. BARRE FIXE INFÉRIEURE : TOTAL & ENREGISTRER (Conforme Image)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  border: Border(
                    top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          AppTheme.formatFCFA(_grandTotal),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        if (_itemsWithoutCostCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '$_itemsWithoutCostCount article(s) sans coût unitaire',
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSave ? AppTheme.primaryNavy : const Color(0xFFCBD5E1),
                        foregroundColor: canSave ? AppTheme.accentGold : const Color(0xFF64748B),
                        elevation: canSave ? 2 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                      icon: Icon(
                        Icons.add_box_outlined,
                        size: 18,
                        color: canSave ? AppTheme.accentGold : const Color(0xFF94A3B8),
                      ),
                      label: Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: canSave ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                      onPressed: canSave ? _saveSupply : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupplyPaymentCard({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFFBEB) : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFD97706) : (isDark ? Colors.white70 : const Color(0xFF64748B)),
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: selected ? AppTheme.primaryNavy : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
