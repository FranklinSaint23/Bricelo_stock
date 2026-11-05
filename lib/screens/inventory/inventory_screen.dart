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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: Text(
          'Stock'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
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

                // 3. SÉLECTEUR DYNAMIQUE DE BOUTIQUES / DÉPÔTS (Pilule délimitée)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: availableStores.map((st) {
                      final isSel = _selectedStoreTab == st;
                      return InkWell(
                        onTap: () => setState(() => _selectedStoreTab = st),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFED7AA) : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            st,
                            style: TextStyle(
                              color: isSel ? const Color(0xFF9A3412) : const Color(0xFF1E293B),
                              fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 13,
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

          // OVERLAY SPEED DIAL QUAND LE FAB EST DÉPLIÉ
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
                      _buildSpeedDialItem(
                        label: 'Approvisionner'.tr,
                        icon: Icons.add_shopping_cart,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildSpeedDialItem(
                        label: 'Ajuster'.tr,
                        icon: Icons.tune,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()));
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildSpeedDialItem(
                        label: 'Transférer'.tr,
                        icon: Icons.swap_horiz,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StockTransfersScreen()));
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildSpeedDialItem(
                        label: 'Dépréciation'.tr,
                        icon: Icons.trending_down,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_inventory_main',
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.accentGold,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => setState(() => _isFabExpanded = !_isFabExpanded),
        child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 28),
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

    final storeTitle = _selectedStoreTab == 'Tous' ? appState.currentStore : _selectedStoreTab;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            storeTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            final currentQty = p.stockForStore(_selectedStoreTab);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.inventory_2_rounded, color: AppTheme.accentGold, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            '${p.category.isNotEmpty ? p.category : "Général"} | ${AppTheme.formatFCFA(p.sellPrice)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currentQty',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF15803D)),
                        ),
                        Text(
                          p.unit.isNotEmpty ? p.unit : 'piece',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
