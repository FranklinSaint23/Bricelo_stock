import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';

class StockDepreciationScreen extends StatefulWidget {
  final Product? initialProduct;
  final String? initialReason;

  const StockDepreciationScreen({
    super.key,
    this.initialProduct,
    this.initialReason,
  });

  @override
  State<StockDepreciationScreen> createState() => _StockDepreciationScreenState();
}

class _StockDepreciationScreenState extends State<StockDepreciationScreen> {
  final appState = AppState.instance;

  Product? _selectedProduct;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _notesController = TextEditingController();

  final List<String> _reasons = [
    'Péremption',
    'Casse / Dommage',
    'Vol / Disparition',
    'Défaut fabricant',
    'Autre',
  ];
  late String _selectedReason;
  late String _selectedStore;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.initialProduct;
    _selectedReason = widget.initialReason ?? 'Péremption';
    _selectedStore = appState.currentStore.isNotEmpty ? appState.currentStore : 'Principal';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _quantity => int.tryParse(_qtyController.text) ?? 1;

  double get _unitCost {
    if (_selectedProduct == null) return 0.0;
    return _selectedProduct!.buyPrice > 0 ? _selectedProduct!.buyPrice : (_selectedProduct!.sellPrice * 0.7);
  }

  double get _totalLoss => _quantity * _unitCost;

  void _submitDepreciation() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un produit à déprécier'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final qty = _quantity;
    final currentStock = _selectedProduct!.stockForStore(_selectedStore);

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La quantité doit être supérieure à 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (qty > currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La quantité dépasse le stock disponible ($currentStock)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    appState.recordStockDepreciation(
      productId: _selectedProduct!.id,
      quantity: qty,
      reason: _selectedReason,
      notes: _notesController.text.trim(),
      storeName: _selectedStore,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dépréciation enregistrée : -$qty ${_selectedProduct!.name}'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );

    setState(() {
      _selectedProduct = null;
      _qtyController.text = '1';
      _notesController.clear();
      _searchController.clear();
    });
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filter = _searchController.text.trim().toLowerCase();
            final filtered = appState.products.where((p) {
              return p.name.toLowerCase().contains(filter) ||
                  p.category.toLowerCase().contains(filter) ||
                  p.barcode.toLowerCase().contains(filter);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sélectionner un produit',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setModalState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher par nom, catégorie, code...',
                        prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun produit trouvé',
                              style: TextStyle(color: Color(0xFF6B7280)),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            itemBuilder: (_, idx) {
                              final p = filtered[idx];
                              final storeStock = p.stockForStore(_selectedStore);
                              final cost = p.buyPrice > 0 ? p.buyPrice : (p.sellPrice * 0.7);

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF374151)),
                                ),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  'Stock: $storeStock ${p.unit} • Coût: ${cost.toStringAsFixed(0)} F CFA',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: storeStock <= 0 ? Colors.red : const Color(0xFF6B7280),
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
                                onTap: () {
                                  setState(() {
                                    _selectedProduct = p;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final recentDepreciations = appState.stockDepreciations;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: StockAppBar.forestGreen(
            title: 'Dépréciation de stock',
            onBack: () => Navigator.pop(context),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. CARTE DE SAISIE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enregistrer une dépréciation / perte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Déduisez du stock les articles avariés, périmés, cassés ou perdus.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),

                    // SÉLECTION DU PRODUIT
                    const Text(
                      'Produit concerné *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showProductPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedProduct != null ? const Color(0xFFF0FDF4) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedProduct != null ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedProduct != null ? Icons.check_circle : Icons.search,
                              color: _selectedProduct != null ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _selectedProduct != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedProduct!.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                                        ),
                                        Text(
                                          'Stock dispo: ${_selectedProduct!.stockForStore(_selectedStore)} ${_selectedProduct!.unit} • Coût: ${_unitCost.toStringAsFixed(0)} F CFA',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Choisir un produit dans le stock...',
                                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                                    ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MOTIF DE DÉPRÉCIATION
                    const Text(
                      'Motif de la perte *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReason,
                          isExpanded: true,
                          items: _reasons.map((r) {
                            return DropdownMenuItem<String>(
                              value: r,
                              child: Row(
                                children: [
                                  Icon(
                                    r == 'Péremption'
                                        ? Icons.event_busy
                                        : r == 'Casse / Dommage'
                                            ? Icons.broken_image_outlined
                                            : r == 'Vol / Disparition'
                                                ? Icons.warning_amber_rounded
                                                : Icons.inventory_2_outlined,
                                    size: 18,
                                    color: const Color(0xFFEA580C),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(r, style: const TextStyle(fontSize: 14, color: Color(0xFF111827))),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedReason = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QUANTITÉ À DÉPRÉCIER
                    const Text(
                      'Quantité dépréciée *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final current = _quantity;
                            if (current > 1) {
                              _qtyController.text = (current - 1).toString();
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF6B7280)),
                        ),
                        Expanded(
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                            ),
                            child: TextField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final current = _quantity;
                            _qtyController.text = (current + 1).toString();
                            setState(() {});
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF16A34A)),
                        ),
                        if (_selectedProduct != null)
                          TextButton(
                            onPressed: () {
                              final maxStock = _selectedProduct!.stockForStore(_selectedStore);
                              if (maxStock > 0) {
                                _qtyController.text = maxStock.toString();
                                setState(() {});
                              }
                            },
                            child: const Text('Max', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // BOUTIQUE CONCERNÉE
                    if (appState.availableStores.length > 1) ...[
                      const Text(
                        'Boutique',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStore,
                            isExpanded: true,
                            items: appState.availableStores.map((s) {
                              return DropdownMenuItem<String>(
                                value: s,
                                child: Text(s, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStore = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // NOTE / DÉTAIL FACULTATIF
                    const Text(
                      'Observations (optionnel)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Colis tombé lors du déchargement, flacon brisé...',
                          hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // BANNIÈRE RÉSUMÉ DE PERTE FINANCIÈRE
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_down, color: Color(0xFFDC2626), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Perte financière estimée',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                                ),
                                Text(
                                  '${_totalLoss.toStringAsFixed(0)} F CFA',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$_quantity unit.',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // BOUTON VALIDER
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitDepreciation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1B2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Valider la dépréciation',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. SECTION HISTORIQUE RÉCENT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historique récent des pertes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  Text(
                    '${recentDepreciations.length} enregistrée(s)',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (recentDepreciations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune perte enregistrée pour le moment',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  ),
                )
              else
                ...recentDepreciations.map((dep) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove_shopping_cart_outlined, color: Color(0xFFDC2626), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dep.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${dep.date.day.toString().padLeft(2, '0')}/${dep.date.month.toString().padLeft(2, '0')}/${dep.date.year} • Motif: ${dep.reason}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                              if (dep.notes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    dep.notes,
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF4B5563)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '-${dep.quantity} pcs',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 14),
                            ),
                            Text(
                              '${dep.totalLoss.toStringAsFixed(0)} F CFA',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
          bottomNavigationBar: StockBottomBar(
            currentIndex: 1, // Inventaire tab
            onTap: (_) => Navigator.pop(context),
          ),
        );
      },
    );
  }
}
