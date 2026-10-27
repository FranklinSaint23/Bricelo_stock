import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final appState = AppState.instance;
  String _filter = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final products = appState.products.where((p) {
          bool matchesFilter = true;
          if (_filter == 'Stock Faible') matchesFilter = p.isLowStock;
          if (_filter == 'Rupture') matchesFilter = p.isOutOfStock;
          if (_filter == 'Bricélo.cm') matchesFilter = p.isSyncedToBricelo;

          final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.barcode.contains(_searchQuery);
          return matchesFilter && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Gestion des Stocks & Produits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.gold500,
              indicatorWeight: 3,
              labelColor: AppTheme.gold500,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2, size: 18),
                      const SizedBox(width: 8),
                      Text('Catalogue (${appState.products.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 18),
                      const SizedBox(width: 8),
                      Text('Mouvements (${appState.stockMovements.length})'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.gold500, size: 26),
                tooltip: 'Ajouter un produit',
                onPressed: () => _showAddProductDialog(context),
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ONGLET 1 : CATALOGUE
              _buildCatalogueTab(products),
              // ONGLET 2 : MOUVEMENTS DE STOCK
              _buildMovementsTab(),
            ],
          ),
        );
      },
    );
  }

  // --- ONGLET 1 : CATALOGUE ---
  Widget _buildCatalogueTab(List<Product> products) {
    return Column(
      children: [
        // Filtres & Recherche
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Rechercher un article ou code-barres...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  isDense: true,
                  filled: true,
                  fillColor: AppTheme.surfaceRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tous', 'Stock Faible', 'Rupture', 'Bricélo.cm'].map((f) {
                    final isSel = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(f, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selected: isSel,
                        selectedColor: AppTheme.navy900,
                        labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.slate700),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Liste des cartes produits
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text('Aucun produit correspondant.', style: TextStyle(color: AppTheme.slate500)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, idx) {
                    final p = products[idx];
                    return _buildProductListItem(p);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductListItem(Product p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.navy900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Réf: ${p.barcode} • Catégorie: ${p.category} • Fournisseur: ${p.supplierName ?? "Marché"}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.isOutOfStock
                        ? AppTheme.danger
                        : (p.isLowStock ? AppTheme.warning : AppTheme.success),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.isOutOfStock ? 'RUPTURE' : 'Stock : ${p.stock}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),

            // Ligne Financière : Vente / Gros / Achat / Marge
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildPriceCol('Prix Détail', AppTheme.formatFCFA(p.sellPrice), AppTheme.navy900),
                _buildPriceCol('Prix Gros', AppTheme.formatFCFA(p.wholesalePrice), AppTheme.warning),
                if (appState.isBossMode) ...[
                  _buildPriceCol('Prix Achat', AppTheme.formatFCFA(p.buyPrice), AppTheme.slate600),
                  _buildPriceCol(
                    'Marge Nette',
                    '${AppTheme.formatFCFA(p.margin)} (+${p.marginPercent.toStringAsFixed(0)}%)',
                    AppTheme.success,
                  ),
                ] else
                  _buildPriceCol('Marge', '*** (Caissier)', AppTheme.slate400),
              ],
            ),
            const SizedBox(height: 12),

            // Actions : Réassort (+), Ajustement / Perte, Synchro Bricélo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      p.isSyncedToBricelo ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: p.isSyncedToBricelo ? AppTheme.success : AppTheme.slate400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      p.isSyncedToBricelo ? 'Synchro Bricélo.cm' : 'Stock Local',
                      style: TextStyle(
                        fontSize: 11,
                        color: p.isSyncedToBricelo ? AppTheme.success : AppTheme.slate500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.tune, size: 14),
                      label: const Text('Ajuster / Perte', style: TextStyle(fontSize: 11)),
                      onPressed: () => _showAdjustmentDialog(context, p),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navy900,
                        foregroundColor: AppTheme.gold500,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('+ Réassort', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _showRestockDialog(context, p),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.slate500)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // --- ONGLET 2 : JOURNAL DES MOUVEMENTS DE STOCK ---
  Widget _buildMovementsTab() {
    final movements = appState.stockMovements;
    if (movements.isEmpty) {
      return const Center(child: Text('Aucun mouvement de stock pour le moment.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: movements.length,
      separatorBuilder: (_, index) => const Divider(height: 12),
      itemBuilder: (context, idx) {
        final m = movements[idx];
        final isPositive = m.type.contains('+');
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive ? AppTheme.success.withOpacity(0.12) : AppTheme.danger.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPositive ? Icons.arrow_downward : Icons.arrow_upward,
              color: isPositive ? AppTheme.success : AppTheme.danger,
              size: 20,
            ),
          ),
          title: Text(m.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(
            '${m.type} • ${m.quantity} article(s) • Nouveau stock : ${m.newStock} • ${m.reason}',
            style: const TextStyle(fontSize: 11, color: AppTheme.slate600),
          ),
          trailing: Text(
            '${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11, color: AppTheme.slate400),
          ),
        );
      },
    );
  }

  // --- MODALS DE RÉASSORT & AJUSTEMENT ---
  void _showRestockDialog(BuildContext context, Product product) {
    final qtyCtrl = TextEditingController(text: '10');
    final costCtrl = TextEditingController(text: product.buyPrice.toStringAsFixed(0));
    final supplierCtrl = TextEditingController(text: product.supplierName ?? 'Grossiste Akwa');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Réapprovisionnement : ${product.name}', style: const TextStyle(fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock actuel : ${product.stock} ${product.unit}(s)', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité reçue *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix d\'achat unitaire (FCFA)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierCtrl,
              decoration: const InputDecoration(labelText: 'Fournisseur / Grossiste', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text) ?? 10;
              final cost = double.tryParse(costCtrl.text) ?? product.buyPrice;
              appState.restockProduct(
                productId: product.id,
                quantity: qty,
                buyCost: cost,
                supplier: supplierCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock mis à jour (+ $qty) pour ${product.name} !')),
              );
            },
            child: const Text('Enregistrer l\'Entrée'),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentDialog(BuildContext context, Product product) {
    final stockCtrl = TextEditingController(text: product.stock.toString());
    String reason = 'Avarie / Cassé';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Ajustement de Stock : ${product.name}', style: const TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nouveau stock réel compté', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: reason,
                decoration: const InputDecoration(labelText: 'Motif de l\'ajustement', border: OutlineInputBorder()),
                items: [
                  'Avarie / Cassé',
                  'Perte / Vol suspecté',
                  'Consommation / Usage boutique',
                  'Erreur inventaire comptage',
                ].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setDialogState(() => reason = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final newStock = int.tryParse(stockCtrl.text) ?? product.stock;
                appState.adjustStock(
                  productId: product.id,
                  newStock: newStock,
                  reason: reason,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock ajusté à $newStock ${product.unit}(s).')),
                );
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController(text: '690${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}');
    final buyCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    final wholesaleCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '12');
    String category = 'Électronique';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter un Nouveau Produit', style: TextStyle(fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom de l\'article *', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                  items: ['Électronique', 'Électroménager', 'Bricolage & Électricité', 'Maison & Confort', 'Mode & Voyage']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 8),
                TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'Code-barres / EAN', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: buyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix d\'achat (PAMP en FCFA) *', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: sellCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix de vente détail (FCFA) *', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: wholesaleCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix de vente gros (FCFA)', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock initial en magasin', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final sell = double.tryParse(sellCtrl.text) ?? 0;
                final buy = double.tryParse(buyCtrl.text) ?? 0;
                final wholesale = double.tryParse(wholesaleCtrl.text) ?? (sell * 0.88);
                final stock = int.tryParse(stockCtrl.text) ?? 0;
                if (nameCtrl.text.isEmpty || sell <= 0) return;

                appState.addProduct(Product(
                  id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  category: category,
                  barcode: barcodeCtrl.text,
                  buyPrice: buy,
                  sellPrice: sell,
                  wholesalePrice: wholesale,
                  stock: stock,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Produit ${nameCtrl.text} créé avec succès !')),
                );
              },
              child: const Text('Enregistrer le Produit'),
            ),
          ],
        ),
      ),
    );
  }
}
