import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _showLots = false;
  bool _showPriceHistory = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

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
        title: const Text('Détail produit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARRE TOP : Prix de vente | Cout moyen | Marge (Screenshot 3)
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
                  _buildStatCol('Cout moyen', AppTheme.formatFCFA(p.buyPrice), const Color(0xFF111827)),
                  Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                  _buildStatCol('Marge', '+${p.marginPercent.toStringAsFixed(0)}%', AppTheme.success),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION STOCK PAR EMPLACEMENT
            const Text(
              'Stock par emplacement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 2),
            Text(
              'Unite: ${p.unit.toLowerCase()} | Seuil min: ${p.minStockAlert}',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            const SizedBox(height: 14),

            // Tableau des emplacements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Emplacement', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Quantite', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Boutique principale (Akwa)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('${p.stock}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Dépôt Bonamoussadi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('24', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ACCORDÉONS : Lots de stock & Historique des prix
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
            const SizedBox(height: 10),

            // SECTION VARIANTES (Screenshot 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Variantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.goldLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14),
                      SizedBox(width: 4),
                      Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Aucune variante', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            const SizedBox(height: 36),

            // LIGNE DE 3 BOUTONS D'ACTION : Modifier | Etiquet... | Suppri... (Screenshot 3)
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Modification du produit ouverte !')),
                      );
                    },
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
                    label: const Text('Etiquet...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Impression code-barres / étiquette thermique !')),
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
                    label: const Text('Suppri...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Produit archivé !')),
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
