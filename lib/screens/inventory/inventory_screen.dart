import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final appState = AppState.instance;
  String _selectedStoreTab = 'Tous';
  bool _isFabExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;
        final availableStores = ['Tous', ...appState.outlets.map((o) => o.name)];
        if (!availableStores.contains(_selectedStoreTab)) {
          _selectedStoreTab = 'Tous';
        }

        if (isDesktop) {
          return _buildDesktopInventory(context, availableStores);
        }

        return _buildMobileInventory(context, availableStores);
      },
    );
  }

  // ==========================================
  // VERSION GRAND ÉCRAN WEB / DESKTOP (INVENTAIRE)
  // ==========================================
  Widget _buildDesktopInventory(BuildContext context, List<String> availableStores) {
    final isDark = appState.isDarkMode;
    final products = appState.products;

    final filteredProducts = _selectedStoreTab == 'Tous'
        ? products
        : products.where((p) => p.stockForStore(_selectedStoreTab) > 0 || p.stockByStore.containsKey(_selectedStoreTab)).toList();

    double totalVente = 0;
    double totalAchat = 0;
    for (final p in products) {
      final qty = p.stockForStore(_selectedStoreTab);
      totalVente += p.sellPrice * qty;
      totalAchat += p.buyPrice * qty;
    }
    final marge = totalVente - totalAchat;
    final margePct = totalAchat > 0 ? (marge / totalAchat) * 100 : 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09121E) : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARTE VALEUR DU STOCK EN 3 COLONNES
            Row(
              children: [
                Expanded(
                  child: _buildWebValueCard(
                    'VALEUR DU STOCK (VENTE)'.tr,
                    AppTheme.formatFCFA(totalVente),
                    Icons.trending_up,
                    AppTheme.accentGold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWebValueCard(
                    'COÛT D\'ACHAT'.tr,
                    AppTheme.formatFCFA(totalAchat),
                    Icons.shopping_bag_outlined,
                    isDark ? Colors.white70 : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWebValueCard(
                    'MARGE BRUTE'.tr,
                    '${AppTheme.formatFCFA(marge)} (${margePct.toStringAsFixed(1)}%)',
                    Icons.pie_chart_outline,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. BARRE D'ACTIONS WEB
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132238) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
              ),
              child: Row(
                children: [
                  // Sélecteur de Boutique Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A1322) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: availableStores.map((st) => _buildStoreTabPill(st)).toList(),
                    ),
                  ),
                  const Spacer(),

                  // Actions Web
                  _buildWebActionButton(Icons.add_shopping_cart, 'Approvisionner'.tr, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                  }),
                  const SizedBox(width: 10),
                  _buildWebActionButton(Icons.tune, 'Ajuster'.tr, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()));
                  }),
                  const SizedBox(width: 10),
                  _buildWebActionButton(Icons.swap_horiz, 'Transférer'.tr, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockTransfersScreen()));
                  }),
                  const SizedBox(width: 10),
                  _buildWebActionButton(Icons.trending_down, 'Dépréciation'.tr, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. TABLEAU OU LISTE DES ARTICLES
            _buildProductsList(filteredProducts, isDark),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VERSION MOBILE (INVENTAIRE)
  // ==========================================
  Widget _buildMobileInventory(BuildContext context, List<String> availableStores) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    final products = appState.products;
    final filteredProducts = _selectedStoreTab == 'Tous'
        ? products
        : products.where((p) => p.stockForStore(_selectedStoreTab) > 0 || p.stockByStore.containsKey(_selectedStoreTab)).toList();

    double totalVente = 0;
    double totalAchat = 0;
    for (final p in products) {
      final qty = p.stockForStore(_selectedStoreTab);
      totalVente += p.sellPrice * qty;
      totalAchat += p.buyPrice * qty;
    }
    final marge = totalVente - totalAchat;
    final margePct = totalAchat > 0 ? (marge / totalAchat) * 100 : 0;

    int lowStock = 0;
    int outOfStock = 0;
    for (final p in filteredProducts) {
      final s = p.stockForStore(_selectedStoreTab);
      if (s <= 0) {
        outOfStock++;
      } else if (s <= p.minStockAlert) {
        lowStock++;
      }
    }

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CARTE VALEUR DU STOCK MOBILE (100% Dynamique)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.trending_up_rounded, color: AppTheme.accentGold, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'VALEUR DU STOCK'.tr,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.4 : 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _selectedStoreTab,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStockValueCol('Vente'.tr, AppTheme.formatFCFA(totalVente), isDark, textColor),
                          Container(width: 1, height: 32, color: cardBorder),
                          _buildStockValueCol('Coût'.tr, AppTheme.formatFCFA(totalAchat), isDark, textColor),
                          Container(width: 1, height: 32, color: cardBorder),
                          _buildStockValueCol('Marge'.tr, '${AppTheme.formatFCFA(marge)} (${margePct.toStringAsFixed(0)}%)', isDark, const Color(0xFF10B981)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. BADGES D'ÉTAT DU STOCK
                Row(
                  children: [
                    _buildStatusBadge(
                      Icons.inventory_2_outlined,
                      '${filteredProducts.length} ${'articles'.tr}',
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      Icons.warning_amber_rounded,
                      '$lowStock ${'bas'.tr}',
                      const Color(0xFFFEF3C7),
                      const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      Icons.cancel_outlined,
                      '$outOfStock ${'rupture'.tr}',
                      const Color(0xFFFEE2E2),
                      const Color(0xFFDC2626),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. SÉLECTEUR DYNAMIQUE DE BOUTIQUES / DÉPÔTS (Onglets à défilement)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: availableStores.map((st) {
                      final isSel = _selectedStoreTab == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedStoreTab = st),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppTheme.primaryNavy
                                  : (isDark ? const Color(0xFF132238) : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? AppTheme.accentGold : cardBorder,
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (st != 'Tous')
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      size: 14,
                                      color: isSel ? AppTheme.accentGold : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                Text(
                                  st.tr,
                                  style: TextStyle(
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12.5,
                                    color: isSel ? Colors.white : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. LISTE DYNAMIQUE DES ARTICLES EN INVENTAIRE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inventaire'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                    ),
                    Text(
                      '${filteredProducts.length} référence(s)'.tr,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildProductsList(filteredProducts, isDark),
              ],
            ),
          ),

          // BOUTONS FLOTTANTS (FAB) D'ACTIONS RAPIDES
          _buildFloatingActions(context),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> products, bool isDark) {
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 54, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'Aucun article dans cette sélection'.tr,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 6),
            Text(
              'Approvisionnez votre stock ou ajoutez de nouveaux produits pour commencer.'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
              },
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: AppTheme.accentGold),
              label: Text('Approvisionner maintenant'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        final currentQty = p.stockForStore(_selectedStoreTab);
        final isOut = currentQty <= 0;
        final isLow = currentQty <= p.minStockAlert && !isOut;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
            },
            child: Row(
              children: [
                // Avatar ou Icône
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.4 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.accentGold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Détails produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${p.category} • ${AppTheme.formatFCFA(p.sellPrice)} / ${p.unit}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                // Badge Stock & Réassort
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOut
                            ? const Color(0xFFFEE2E2)
                            : isLow
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$currentQty ${p.unit}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isOut
                              ? const Color(0xFFDC2626)
                              : isLow
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                      },
                      child: Text(
                        'Réassort'.tr,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                        ),
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

  Widget _buildStockValueCol(String label, String value, bool isDark, Color valColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: valColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(IconData icon, String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textCol),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStoreTabPill(String tabName) {
    final isSel = _selectedStoreTab == tabName;
    return InkWell(
      onTap: () => setState(() => _selectedStoreTab = tabName),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSel ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(
          tabName.tr,
          style: TextStyle(
            color: isSel ? AppTheme.primaryNavy : const Color(0xFF64748B),
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildWebValueCard(String title, String value, IconData icon, Color iconColor) {
    final isDark = appState.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132238) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebActionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabExpanded) ...[
            _buildFabMini(Icons.add_shopping_cart, 'Approvisionner'.tr, () {
              setState(() => _isFabExpanded = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
            }),
            const SizedBox(height: 10),
            _buildFabMini(Icons.tune, 'Ajuster'.tr, () {
              setState(() => _isFabExpanded = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()));
            }),
            const SizedBox(height: 10),
            _buildFabMini(Icons.swap_horiz, 'Transférer'.tr, () {
              setState(() => _isFabExpanded = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StockTransfersScreen()));
            }),
            const SizedBox(height: 10),
            _buildFabMini(Icons.trending_down, 'Dépréciation'.tr, () {
              setState(() => _isFabExpanded = false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
            }),
            const SizedBox(height: 10),
          ],
          FloatingActionButton.extended(
            heroTag: 'fab_inventory_main',
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: AppTheme.accentGold,
            elevation: 4,
            onPressed: () => setState(() => _isFabExpanded = !_isFabExpanded),
            icon: Icon(_isFabExpanded ? Icons.close : Icons.add_rounded),
            label: Text(
              _isFabExpanded ? 'Fermer'.tr : 'Actions Stock'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabMini(IconData icon, String label, VoidCallback onTap) {
    return FloatingActionButton.extended(
      heroTag: 'fab_mini_$label',
      onPressed: onTap,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primaryNavy,
      elevation: 3,
      icon: Icon(icon, size: 18, color: AppTheme.primaryNavy),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
