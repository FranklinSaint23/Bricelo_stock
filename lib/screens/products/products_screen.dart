import 'package:stock_prime/models/models.dart';
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
        final isDesktop = MediaQuery.of(context).size.width >= 800;
        final products = appState.products.where((p) {
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.barcode.contains(_searchQuery) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase());
          bool matchesTab = true;
          if (_selectedTab == 'Produits') matchesTab = p.productType == 'Produit';
          if (_selectedTab == 'Services') matchesTab = p.productType == 'Service';
          if (_selectedTab == 'Packs') matchesTab = p.productType == 'Pack';
          return matchesSearch && matchesTab;
        }).toList();

        if (isDesktop) {
          return _buildDesktopProducts(context, products);
        }

        return _buildMobileProducts(context, products);
      },
    );
  }

  // ==========================================
  // VERSION GRAND ÉCRAN WEB / DESKTOP (TABLEAU)
  // ==========================================
  Widget _buildDesktopProducts(BuildContext context, List<Product> products) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre d'outils Web (Recherche + Filtres + Actions)
            Row(
              children: [
                // Champ Recherche
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom, code-barres...'.tr,
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Filtres Catégories
                Row(
                  children: _tabs.map((tab) {
                    final isSel = _selectedTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(tab.tr),
                        selected: isSel,
                        selectedColor: AppTheme.primaryNavy,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSel ? AppTheme.accentGold : const Color(0xFF475569),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSel ? AppTheme.primaryNavy : const Color(0xFFE2E8F0)),
                        ),
                        onSelected: (_) => setState(() => _selectedTab = tab),
                      ),
                    );
                  }).toList(),
                ),

                const Spacer(),

                // Bouton Importer CSV
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryNavy,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: Text('Importer'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportProductsScreen()));
                  },
                ),
                const SizedBox(width: 10),

                // Bouton Nouveau Produit
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.add, color: AppTheme.accentGold, size: 18),
                  label: Text('Ajouter un produit'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Compteur de Produits
            Row(
              children: [
                Text(
                  '${products.length} ${'articles au total'.tr}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${products.length} / 25 Gratuit',
                    style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tableau de Produits
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                ),
                child: products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 12),
                            Text('Aucun produit pour l\'instant.'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155))),
                            const SizedBox(height: 4),
                            Text('Cliquez sur « Ajouter un produit » pour démarrer.'.tr, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: products.length + 1,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, idx) {
                          if (idx == 0) {
                            // En-tête du Tableau
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              color: const Color(0xFFF8FAFC),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text('PRODUIT'.tr, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('CODE-BARRES'.tr, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('PRIX DE VENTE'.tr, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('STOCK'.tr, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('STATUT'.tr, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11))),
                                  const SizedBox(width: 80, child: Text('ACTIONS', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11))),
                                ],
                              ),
                            );
                          }

                          final p = products[idx - 1];
                          final isLow = p.stock <= 5 && p.stock > 0;
                          final isOut = p.stock == 0;

                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  // Produit (Icon + Name)
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Code-barres
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      p.barcode.isNotEmpty ? p.barcode : '—',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                    ),
                                  ),
                                  // Prix de vente
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      AppTheme.formatFCFA(p.sellPrice),
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryNavy, fontSize: 13),
                                    ),
                                  ),
                                  // Stock
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${p.stock} ${p.unit}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 12),
                                    ),
                                  ),
                                  // Statut
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isOut
                                            ? const Color(0xFFFEE2E2)
                                            : isLow
                                                ? const Color(0xFFFEF3C7)
                                                : const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isOut
                                            ? 'Rupture'.tr
                                            : isLow
                                                ? 'Stock bas'.tr
                                                : 'En stock'.tr,
                                        style: TextStyle(
                                          color: isOut
                                              ? const Color(0xFFDC2626)
                                              : isLow
                                                  ? const Color(0xFFD97706)
                                                  : const Color(0xFF059669),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Actions
                                  SizedBox(
                                    width: 80,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VERSION MOBILE (100% PRÉSERVÉE)
  // ==========================================
  Widget _buildMobileProducts(BuildContext context, List<Product> products) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: Text(
          'Produits'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                appState.syncFromSupabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Catalogue synchronisé !'.tr)),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit'.tr,
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            tab.tr,
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
                    Text(
                      'Produits'.tr,
                      style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.bold),
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
                              Text(
                                'Aucun produit pour l\'instant.'.tr,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF374151)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ajoutez votre premier produit !'.tr,
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
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
                                label: Text(
                                  'Importer une liste (Excel / CSV)'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
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
                        separatorBuilder: (_, index) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final p = products[idx];
                          final isOutOfStock = p.stock <= 0;
                          final isLowStock = p.stock > 0 && p.stock <= 5;
                          final stockColor = isOutOfStock
                              ? const Color(0xFFDC2626)
                              : (isLowStock ? const Color(0xFFD97706) : const Color(0xFF059669));
                          final stockBg = isOutOfStock
                              ? const Color(0xFFFEF2F2)
                              : (isLowStock ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
                          final stockBorder = isOutOfStock
                              ? const Color(0xFFFECACA)
                              : (isLowStock ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0));
                          final stockText = isOutOfStock
                              ? 'Épuisé'.tr
                              : (isLowStock ? '${p.stock} restants' : '${p.stock} ${p.unit}');

                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFF1F5F9)),
                                    ),
                                    child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Text(
                                              'Réf: ${p.barcode}',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: stockBg,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: stockBorder),
                                              ),
                                              child: Text(
                                                stockText,
                                                style: TextStyle(
                                                  color: stockColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        AppTheme.formatFCFA(p.sellPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: AppTheme.primaryNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF94A3B8)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // SPEED DIAL OVERLAY QUAND LE FAB EST DÉPLIÉ
          if (_isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isFabExpanded = false),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.85),
                  padding: const EdgeInsets.only(bottom: 90, right: 16),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 1. Bouton "Importer des produits"
                      _buildSpeedDialItem(
                        label: 'Importer des produits'.tr,
                        icon: Icons.upload_file_outlined,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductsWizard()));
                        },
                      ),
                      const SizedBox(height: 14),
                      // 2. Bouton "Ajouter un produit"
                      _buildSpeedDialItem(
                        label: 'Ajouter un produit'.tr,
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

      // FAB EN BAS À DROITE
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.accentGold,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => setState(() => _isFabExpanded = !_isFabExpanded),
        child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 28),
      ),
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
