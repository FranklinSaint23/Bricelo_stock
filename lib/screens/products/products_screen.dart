import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/product_image_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'Tous';
  String _selectedCategory = 'Toutes';
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

          bool matchesCat = true;
          if (_selectedCategory != 'Toutes') {
            matchesCat = p.category == _selectedCategory;
          }

          return matchesSearch && matchesTab && matchesCat;
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
    final isDark = appState.isDarkMode;
    final canAddProduct = appState.isOwnerAccount || appState.hasPermission('Création de produits');
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
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
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cardBorder),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom, code-barres...'.tr,
                        hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B), size: 20),
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
                        backgroundColor: cardBg,
                        labelStyle: TextStyle(
                          color: isSel ? AppTheme.accentGold : (isDark ? Colors.white : const Color(0xFF475569)),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSel ? AppTheme.primaryNavy : cardBorder),
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
                if (canAddProduct) ...[
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
                      if (appState.isDiscoveredPlan && appState.isProductQuotaReached) {
                        _showProductQuotaDialog(context);
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                    },
                  ),
                ],
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 12),
                            Text('Aucun produit pour l\'instant.'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
                            const SizedBox(height: 4),
                            Text('Cliquez sur « Ajouter un produit » pour démarrer.'.tr, style: TextStyle(color: textSecondary, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: products.length + 1,
                        separatorBuilder: (context, index) => Divider(height: 1, color: cardBorder),
                        itemBuilder: (context, idx) {
                          if (idx == 0) {
                            // En-tête du Tableau
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              color: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text('PRODUIT'.tr, style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('CODE-BARRES'.tr, style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('PRIX DE VENTE'.tr, style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('STOCK'.tr, style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 11))),
                                  Expanded(flex: 2, child: Text('STATUT'.tr, style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 11))),
                                  SizedBox(width: 80, child: Text('ACTIONS'.tr, style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 11))),
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
                                        ProductImageWidget(
                                          imageUrl: p.imageUrl,
                                          size: 38,
                                          borderRadius: 8,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
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
                                      style: TextStyle(color: textSecondary, fontSize: 12),
                                    ),
                                  ),
                                  // Prix de vente
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      AppTheme.formatFCFA(p.sellPrice),
                                      style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontSize: 13),
                                    ),
                                  ),
                                  // Stock
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${p.stock} ${p.unit}',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 12),
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
    final isDark = appState.isDarkMode;
    final canAddProduct = appState.isOwnerAccount || appState.hasPermission('Création de produits');
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
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
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit'.tr,
                      hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: isDark ? AppTheme.accentGold : const Color(0xFF6B7280), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),

              // 2. FILTRES PILLS : Tous | Produits | Services | Packs
              Container(
                height: 44,
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.accentGold : cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSel ? AppTheme.accentGold : cardBorder),
                          ),
                          child: Text(
                            tab.tr,
                            style: TextStyle(
                              color: isSel ? AppTheme.primaryNavy : (isDark ? Colors.white : const Color(0xFF374151)),
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 2.bis FILTRES CATÉGORIES : Toutes | Catégorie 1 | + Nouvelle catégorie
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    InkWell(
                      onTap: () => setState(() => _selectedCategory = 'Toutes'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedCategory == 'Toutes' ? AppTheme.accentGold : cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _selectedCategory == 'Toutes' ? AppTheme.accentGold : cardBorder),
                        ),
                        child: Text(
                          'Toutes'.tr,
                          style: TextStyle(
                            color: _selectedCategory == 'Toutes' ? AppTheme.primaryNavy : (isDark ? Colors.white : const Color(0xFF374151)),
                            fontWeight: _selectedCategory == 'Toutes' ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...appState.categories.map((c) {
                      final isSel = _selectedCategory == c.name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCategory = c.name),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.accentGold : cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? AppTheme.accentGold : cardBorder),
                            ),
                            child: Text(
                              c.name,
                              style: TextStyle(
                                color: isSel ? AppTheme.primaryNavy : (isDark ? Colors.white : const Color(0xFF374151)),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    InkWell(
                      onTap: () {
                        final catCtrl = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: cardBg,
                            title: Text('Nouvelle catégorie'.tr, style: TextStyle(color: textPrimary)),
                            content: TextField(
                              controller: catCtrl,
                              autofocus: true,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Nom de la catégorie'.tr,
                                labelStyle: TextStyle(color: textSecondary),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Annuler'.tr)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy),
                                onPressed: () {
                                  final name = catCtrl.text.trim();
                                  if (name.isNotEmpty) {
                                    appState.addCategory(CategoryItem(
                                      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                                      name: name,
                                    ));
                                    setState(() => _selectedCategory = name);
                                    Navigator.pop(ctx);
                                  }
                                },
                                child: Text('Ajouter'.tr, style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16, color: isDark ? AppTheme.accentGold : const Color(0xFF374151)),
                            const SizedBox(width: 4),
                            Text(
                              'Nouvelle catégorie'.tr,
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF374151), fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. BANNIÈRE QUOTA AVEC PROGRESSION (Produits X / 25)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162540) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Produits'.tr,
                          style: TextStyle(color: isDark ? AppTheme.accentGold : const Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${products.length} / 25',
                          style: TextStyle(color: isDark ? AppTheme.accentGold : const Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (products.length / 25).clamp(0.04, 1.0),
                        backgroundColor: isDark ? const Color(0xFF1E3052) : const Color(0xFFDBEAFE),
                        valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppTheme.accentGold : const Color(0xFF2563EB)),
                        minHeight: 4,
                      ),
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
                              Icon(Icons.inventory_2_outlined, size: 70, color: textSecondary),
                              const SizedBox(height: 14),
                              Text(
                                'Aucun produit pour l\'instant.'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ajoutez votre premier produit !'.tr,
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                  side: BorderSide(color: cardBorder),
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

                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ProductImageWidget(
                                    imageUrl: p.imageUrl,
                                    size: 56,
                                    borderRadius: 12,
                                    placeholderIcon: Icons.inventory_2_rounded,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                            color: textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          AppTheme.formatFCFA(p.sellPrice),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14.5,
                                            color: isDark ? AppTheme.accentGold : const Color(0xFFD97706),
                                          ),
                                        ),
                                        Text(
                                          '${'Coût'.tr}: ${AppTheme.formatFCFA(p.buyPrice)}',
                                          style: TextStyle(fontSize: 12, color: textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        p.category.isNotEmpty ? p.category : 'Général'.tr,
                                        style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '${'Stock'.tr}: ${p.stock}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                                      ),
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
                  color: (isDark ? AppTheme.darkScaffold : Colors.white).withValues(alpha: 0.88),
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
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
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
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          if (appState.isDiscoveredPlan && appState.isProductQuotaReached) {
                            _showProductQuotaDialog(context);
                            return;
                          }
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

      // FAB EN BAS À DROITE (Uniquement pour ceux autorisés à créer des produits)
      floatingActionButton: canAddProduct
          ? FloatingActionButton(
              backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
              foregroundColor: AppTheme.accentGold,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cardBorder)),
              onPressed: () => setState(() => _isFabExpanded = !_isFabExpanded),
              child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 28),
            )
          : null,
    );
  }

  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12), blurRadius: 8, offset: const Offset(0, 3))],
              border: Border.all(color: cardBorder),
            ),
            child: Icon(icon, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 22),
          ),
        ],
      ),
    );
  }

  void _showProductQuotaDialog(BuildContext context) {
    final isDark = appState.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF382305) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_rounded, color: AppTheme.accentGold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Plafond Découverte atteint',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Votre catalogue en formule Découverte est limité à 25 articles (${appState.products.length}/25).\n\n'
          'Pour enregistrer un nombre illimité de produits, ajouter des variantes et gérer des dépôts multiples, passez à la Formule Pro sur le portail web.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Compris',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
