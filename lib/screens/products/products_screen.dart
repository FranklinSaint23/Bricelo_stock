import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'Tous';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  bool _isFabExpanded = false;

  final List<String> _tabs = ['Tous', 'Produits', 'Services', 'Packs'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final products = appState.products.where((p) {
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.barcode.contains(_searchQuery);
          return matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            title: const Text(
              'Produits',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catalogue actualisé !')),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // 1. RECHERCHE
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher un produit',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ),

                  // 2. FILTRES PILLS : Tous | Produits | Services | Packs
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _tabs.map((tab) {
                        final isSel = _selectedTab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedTab = tab),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? AppTheme.primaryNavy : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  color: isSel ? Colors.white : const Color(0xFF374151),
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // 3. BANNIÈRE QUOTA : Produits 0 / 25
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Produits',
                          style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${products.length} / 25',
                          style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // 4. CONTENU : LISTE OU ÉTAT VIDE
                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 70, color: Color(0xFFD1D5DB)),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Aucun produit pour l\'instant.',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF374151)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Ajoutez votre premier produit !',
                                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                                  ),
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryNavy,
                                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.description_outlined, size: 18),
                                    label: const Text('Importer une liste (Excel / CSV)', style: TextStyle(fontWeight: FontWeight.w600)),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportProductsScreen()));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: products.length,
                            separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
                            itemBuilder: (context, idx) {
                              final p = products[idx];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                                },
                                child: ListTile(
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy, size: 22),
                                  ),
                                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text('Stock : ${p.stock} ${p.unit} • Réf: ${p.barcode}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                  trailing: Text(
                                    AppTheme.formatFCFA(p.sellPrice),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),

              // SPEED DIAL OVERLAY QUAND LE FAB EST DÉPLIÉ (Screenshot 1)
              if (_isFabExpanded)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isFabExpanded = false),
                    child: Container(
                      color: Colors.white.withOpacity(0.85),
                      padding: const EdgeInsets.only(bottom: 90, right: 16),
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 1. Bouton "Importer des produits"
                          _buildSpeedDialItem(
                            label: 'Importer des produits',
                            icon: Icons.upload_file_outlined,
                            onTap: () {
                              setState(() => _isFabExpanded = false);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductsWizard()));
                            },
                          ),
                          const SizedBox(height: 14),
                          // 2. Bouton "Ajouter un produit"
                          _buildSpeedDialItem(
                            label: 'Ajouter un produit',
                            icon: Icons.add_box_outlined,
                            onTap: () {
                              setState(() => _isFabExpanded = false);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // FAB EN BAS À DROITE (Screenshot 1 & 2)
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: AppTheme.accentGold,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => setState(() => _isFabExpanded = !_isFabExpanded),
            child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, color: AppTheme.primaryNavy, size: 22),
          ),
        ],
      ),
    );
  }
}
