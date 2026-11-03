import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';

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

  SupplyItem({
    required this.product,
    this.quantity = 1,
    required this.buyPrice,
  });

  double get total => quantity * buyPrice;
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
  bool _tvaDeductible = false;
  bool _alreadyPaid = false;
  final _notesCtrl = TextEditingController();

  // Liste des articles ajoutés
  final List<SupplyItem> _items = [];

  // Liste des frais (Images 1 & 2)
  bool _isFeesExpanded = true;
  final List<SupplyFee> _fees = [
    SupplyFee(type: 'Transport', initialAmount: '0'),
  ];

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
    } else {
      _selectedSupplier = 'Grossiste Ets NANA & Fils (Akwa)';
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final f in _fees) {
      f.amountController.dispose();
    }
    super.dispose();
  }

  double get _itemsTotal => _items.fold(0.0, (sum, i) => sum + i.total);
  double get _feesTotal => _fees.fold(0.0, (sum, f) => sum + f.amount);
  double get _grandTotal => _itemsTotal + _feesTotal;

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
                          icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
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
                                final alreadyAdded = _items.any((i) => i.product.id == p.id);

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: alreadyAdded
                                          ? AppTheme.accentGold
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
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
                                              'Prix d\'achat: ${AppTheme.formatFCFA(p.buyPrice)} • Stock actuel: ${p.stock}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: alreadyAdded ? const Color(0xFFE2E8F0) : AppTheme.primaryNavy,
                                          foregroundColor: alreadyAdded ? const Color(0xFF475569) : Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (!alreadyAdded) {
                                              _items.add(SupplyItem(product: p, quantity: 1, buyPrice: p.buyPrice));
                                            }
                                          });
                                          setModalState(() {});
                                        },
                                        child: Text(alreadyAdded ? 'Ajouté' : '+ Ajouter'),
                                      ),
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
        _items.add(SupplyItem(product: p, quantity: 5, buyPrice: p.buyPrice));
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

    // Mettre à jour le stock des articles avec traçabilité
    for (final item in _items) {
      appState.restockProduct(
        productId: item.product.id,
        quantity: item.quantity,
        buyCost: item.buyPrice,
        supplier: _selectedSupplier ?? 'Fournisseur',
      );
    }

    // Si dette fournisseur
    if (_selectedMode == 'Achat fournisseur' && !_alreadyPaid && _grandTotal > 0 && _selectedSupplier != null) {
      appState.addSupplierDebt(
        SupplierDebt(
          id: 'sdebt_${DateTime.now().millisecondsSinceEpoch}',
          supplierName: _selectedSupplier!,
          supplierPhone: '',
          invoiceRef: 'APPR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          totalAmount: _grandTotal,
          createdAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 15)),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryNavy,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Approvisionnement de ${AppTheme.formatFCFA(_grandTotal)} validé avec succès !',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        final supplierList = appState.suppliers.isNotEmpty
            ? appState.suppliers.map((s) => s.name).toList()
            : [
                'Grossiste Ets NANA & Fils (Akwa)',
                'Société Camerounaise d\'Importation (SCI)',
                'Oraimo Store Officiel Douala',
                'Usine Mousse Bassa',
                'Grossiste Marché Central Yaoundé',
              ];

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

                    // 2. SEGMENTED TABS: Achat fournisseur | Stock existant (Image 1)
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280),
                          width: 0.9,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedMode = 'Achat fournisseur'),
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedMode == 'Achat fournisseur'
                                      ? (isDark ? AppTheme.primaryNavy : const Color(0xFFFFDFBA))
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                                ),
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
                            width: 0.9,
                            color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedMode = 'Stock existant'),
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedMode == 'Stock existant'
                                      ? (isDark ? AppTheme.primaryNavy : const Color(0xFFFFDFBA))
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                                ),
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
                    const SizedBox(height: 18),

                    // 3. FOURNISSEUR DROPDOWN (Si Achat fournisseur)
                    if (_selectedMode == 'Achat fournisseur') ...[
                      Text(
                        'Fournisseur *',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
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

                    // 4. SECTION ARTICLES (Image 1)
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
                          'Scanner ou rechercher',
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

                    // Liste des articles ajoutés ou État vide (Image 1)
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
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : const Color(0xFF111827),
                                      ),
                                    ),
                                    Text(
                                      'Prix unitaire: ${AppTheme.formatFCFA(item.buyPrice)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    color: const Color(0xFFEF4444),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                        } else {
                                          _items.remove(item);
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    color: AppTheme.accentGold,
                                    onPressed: () => setState(() => item.quantity++),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 14),
                    Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),

                    // =========================================================
                    // 5. GESTION DES FRAIS CONFORME AUX IMAGES 1 & 2
                    // =========================================================
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
                              // Sélecteur de type de frais (Popup menu conforme Image 2)
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
                                  height: 48,
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
                                          fontSize: 14,
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

                              // Champ montant du frais (Image 1 & 2)
                              Expanded(
                                child: Container(
                                  height: 48,
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ),
                              ),

                              // Bouton suppression corbeille (Image 1 & 2)
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

                      // Bouton + Ajouter des frais (Image 1 & 2)
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
                              fontSize: 14,
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

              // 8. BARRE FIXE INFÉRIEURE : TOTAL & ENREGISTRER (Images 1 & 2)
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
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _grandTotal > 0 ? AppTheme.primaryNavy : const Color(0xFFCBD5E1),
                        foregroundColor: _grandTotal > 0 ? Colors.white : const Color(0xFF475569),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                      icon: Icon(
                        Icons.add_box_outlined,
                        size: 18,
                        color: _grandTotal > 0 ? AppTheme.accentGold : const Color(0xFF94A3B8),
                      ),
                      label: const Text(
                        'Enregistrer',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: _saveSupply,
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
}
