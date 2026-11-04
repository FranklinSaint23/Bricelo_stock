import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final appState = AppState.instance;
  bool _showLots = false;
  bool _showPriceHistory = false;

  Product get _currentProduct {
    return appState.products.firstWhere(
      (item) => item.id == widget.product.id,
      orElse: () => widget.product,
    );
  }

  void _showEditProductSheet(Product p) {
    final nameCtrl = TextEditingController(text: p.name);
    final sellCtrl = TextEditingController(text: p.sellPrice.toStringAsFixed(0));
    final buyCtrl = TextEditingController(text: p.buyPrice.toStringAsFixed(0));
    final stockCtrl = TextEditingController(text: p.stock.toString());
    final minStockCtrl = TextEditingController(text: p.minStockAlert.toString());
    final barcodeCtrl = TextEditingController(text: p.barcode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Modifier le produit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom du produit *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sellCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Prix de vente (FCFA)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: buyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Coût d\'achat (FCFA)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock actuel', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: minStockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Seuil alerte', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: barcodeCtrl,
                decoration: const InputDecoration(labelText: 'Code-barres / Réf', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final newName = nameCtrl.text.trim();
                    if (newName.isEmpty) return;
                    final updated = Product(
                      id: p.id,
                      name: newName,
                      category: p.category,
                      barcode: barcodeCtrl.text.trim(),
                      buyPrice: double.tryParse(buyCtrl.text.trim()) ?? p.buyPrice,
                      sellPrice: double.tryParse(sellCtrl.text.trim()) ?? p.sellPrice,
                      wholesalePrice: (double.tryParse(sellCtrl.text.trim()) ?? p.sellPrice) * 0.9,
                      stock: int.tryParse(stockCtrl.text.trim()) ?? p.stock,
                      minStockAlert: int.tryParse(minStockCtrl.text.trim()) ?? p.minStockAlert,
                      unit: p.unit,
                      productType: p.productType,
                    );
                    appState.updateProduct(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produit mis à jour avec succès !')),
                    );
                  },
                  child: const Text('Enregistrer les modifications', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final p = _currentProduct;
        final stores = appState.availableStores.isNotEmpty
            ? appState.availableStores
            : [appState.currentStore];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            leading: TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
              label: const Text('Produits', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            leadingWidth: 100,
            title: Text(
              p.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BARRE TOP : Prix de vente | Coût moyen | Marge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCol('Prix de vente', AppTheme.formatFCFA(p.sellPrice), AppTheme.primaryNavy),
                      Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                      _buildStatCol('Coût moyen', AppTheme.formatFCFA(p.buyPrice), const Color(0xFF111827)),
                      Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                      _buildStatCol('Marge', '+${p.marginPercent.toStringAsFixed(0)}%', AppTheme.success),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION STOCK PAR EMPLACEMENT DYNAMIQUE
                const Text(
                  'Stock par emplacement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Catégorie: ${p.category} | Unité: ${p.unit.toLowerCase()} | Seuil min: ${p.minStockAlert}',
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Emplacement', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Quantité', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 20),
                      for (int i = 0; i < stores.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(stores[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text(
                              i == 0 ? '${p.stock} ${p.unit}' : '0 ${p.unit}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showLots = !_showLots),
                    icon: Icon(_showLots ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.primaryNavy, size: 20),
                    label: const Text('Lots de stock', style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showPriceHistory = !_showPriceHistory),
                    icon: Icon(_showPriceHistory ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.primaryNavy, size: 20),
                    label: const Text('Historique des prix', style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),

                // LIGNE DE 3 BOUTONS D'ACTION : Modifier | Étiquette | Supprimer
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldLight,
                          foregroundColor: const Color(0xFF1F2937),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Modifier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () => _showEditProductSheet(p),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldLight,
                          foregroundColor: const Color(0xFF1F2937),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.qr_code, size: 16),
                        label: const Text('Étiquette', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Étiquette code-barres (${p.barcode}) prête pour impression !')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.danger,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                        label: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () {
                          appState.removeProduct(p.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Produit "${p.name}" supprimé.')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      ],
    );
  }
}
