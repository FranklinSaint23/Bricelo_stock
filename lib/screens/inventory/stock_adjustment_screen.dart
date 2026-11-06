import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class StockAdjustmentScreen extends StatefulWidget {
  final Product? initialProduct;
  const StockAdjustmentScreen({super.key, this.initialProduct});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final appState = AppState.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newStockController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Product? _selectedProduct;
  late String _selectedStore;
  String _selectedReason = 'Inventaire physique';
  final List<String> _reasons = [
    'Inventaire physique',
    'Casse / Avarie',
    'Erreur de comptage',
    'Perte / Vol',
    'Don / Échantillon',
    'Autre motif',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStore = appState.currentStore;
    if (widget.initialProduct != null) {
      _selectProduct(widget.initialProduct!);
    }
  }

  void _selectProduct(Product p) {
    setState(() {
      _selectedProduct = p;
      final cur = p.stockForStore(_selectedStore);
      _newStockController.text = cur.toString();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newStockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final query = _searchController.text.trim().toLowerCase();

    final stores = appState.outlets.map((o) => o.name).toList();
    if (stores.isEmpty) stores.add(appState.currentStore);
    if (!stores.contains(_selectedStore)) {
      _selectedStore = stores.first;
    }

    final products = appState.products;
    final displayProducts = query.isEmpty
        ? products
        : products.where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.barcode.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query)).toList();

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
        title: const Text(
          'Ajustement de stock',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SÉLECTION DE LA BOUTIQUE
            Row(
              children: [
                const Icon(Icons.storefront, size: 16, color: AppTheme.primaryNavy),
                const SizedBox(width: 6),
                Text(
                  'Boutique concernée *',
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
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStore,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  items: stores.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedStore = val;
                        if (_selectedProduct != null) {
                          _newStockController.text = _selectedProduct!.stockForStore(val).toString();
                        }
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. CHAMP DE RECHERCHE DE PRODUIT
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit à ajuster...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF6B7280), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. SI AUCUN PRODUIT SÉLECTIONNÉ : LISTE RAPIDE DES PRODUITS
            if (_selectedProduct == null) ...[
              Text(
                'Sélectionnez un produit (${displayProducts.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              if (displayProducts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: const Text('Aucun produit trouvé', style: TextStyle(color: Color(0xFF94A3B8))),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final p = displayProducts[idx];
                    final stStock = p.stockForStore(_selectedStore);

                    return InkWell(
                      onTap: () => _selectProduct(p),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${p.category} • PU: ${p.sellPrice.toInt()} F',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: stStock > 0 ? AppTheme.accentGold.withValues(alpha: 0.15) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$stStock ${p.unit}(s)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: stStock > 0 ? const Color(0xFFB45309) : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ] else ...[
              // 4. FICHE D'AJUSTEMENT DU PRODUIT SÉLECTIONNÉ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accentGold, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedProduct!.name,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primaryNavy),
                              ),
                              Text(
                                '${_selectedProduct!.category} • Boutique : $_selectedStore',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                          onPressed: () => setState(() => _selectedProduct = null),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Stock actuel enregistré :', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        Text(
                          '${_selectedProduct!.stockForStore(_selectedStore)} ${_selectedProduct!.unit}(s)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // SAISIE NOUVEAU STOCK AVEC BOUTONS - / +
                    const Text('Nouveau stock réel *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final cur = int.tryParse(_newStockController.text.trim()) ?? 0;
                            if (cur > 0) {
                              setState(() => _newStockController.text = (cur - 1).toString());
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _newStockController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final cur = int.tryParse(_newStockController.text.trim()) ?? 0;
                            setState(() => _newStockController.text = (cur + 1).toString());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // CALCUL DE L'ÉCART
                    Builder(builder: (_) {
                      final cur = _selectedProduct!.stockForStore(_selectedStore);
                      final newQ = int.tryParse(_newStockController.text.trim()) ?? cur;
                      final diff = newQ - cur;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: diff == 0
                              ? const Color(0xFFF1F5F9)
                              : (diff > 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              diff == 0 ? 'Aucune variation' : (diff > 0 ? 'Entrée de stock :' : 'Sortie de stock :'),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: diff == 0 ? const Color(0xFF64748B) : (diff > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                              ),
                            ),
                            Text(
                              '${diff > 0 ? "+" : ""}$diff ${_selectedProduct!.unit}(s)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: diff == 0 ? const Color(0xFF64748B) : (diff > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 14),

                    // MOTIF DE L'AJUSTEMENT
                    const Text('Motif de l’ajustement *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReason,
                          isExpanded: true,
                          items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedReason = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BOUTON CONFIRMATION
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final newQty = int.tryParse(_newStockController.text.trim()) ?? _selectedProduct!.stockForStore(_selectedStore);
                          appState.adjustStock(
                            productId: _selectedProduct!.id,
                            newStock: newQty,
                            reason: _selectedReason,
                            storeName: _selectedStore,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Stock de « ${_selectedProduct!.name} » ajusté à $newQty dans $_selectedStore !'),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Valider l’ajustement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
