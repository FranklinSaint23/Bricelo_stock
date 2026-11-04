import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

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

        if (isDesktop) {
          return _buildDesktopInventory(context);
        }

        return _buildMobileInventory(context);
      },
    );
  }

  // ==========================================
  // VERSION GRAND ÉCRAN WEB / DESKTOP (INVENTAIRE)
  // ==========================================
  Widget _buildDesktopInventory(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARTE VALEUR DU STOCK EN 3 COLONNES
            Row(
              children: [
                Expanded(
                  child: _buildWebValueCard('VALEUR DU STOCK (VENTE)'.tr, '0 F CFA', Icons.trending_up, AppTheme.accentGold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWebValueCard('COÛT D\'ACHAT'.tr, '0 F CFA', Icons.shopping_bag_outlined, const Color(0xFF0F172A)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWebValueCard('MARGE BRUTE'.tr, '—', Icons.pie_chart_outline, const Color(0xFFD97706)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. BARRE D'ACTIONS WEB (Approvisionner, Ajuster, Transférer, Dépréciation)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
              ),
              child: Row(
                children: [
                  // Sélecteur de Boutique Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        _buildStoreTabPill('Tous'),
                        _buildStoreTabPill('Boutique principale'),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // 4 Boutons d'action Web
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(Icons.move_to_inbox, size: 16),
                    label: Text('Approvisionner'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                    },
                  ),
                  const SizedBox(width: 8),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(Icons.tune, size: 16),
                    label: Text('Ajuster le stock'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Module d\'ajustement de stock ouvert !'.tr)),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text('Transférer'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Module de transfert inter-boutiques ouvert !'.tr)),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(Icons.remove_shopping_cart_outlined, size: 16),
                    label: Text('Pertes'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. STATUT DES ARTICLES & TABLEAU DU STOCK
            Row(
              children: [
                _buildWebBadge(Icons.inventory_2_outlined, '${appState.products.length} ${'articles'.tr}', const Color(0xFFF1F5F9), const Color(0xFF0F172A)),
                const SizedBox(width: 12),
                _buildWebBadge(Icons.warning_amber_rounded, '${appState.lowStockCount} ${'bas'.tr}', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                const SizedBox(width: 12),
                _buildWebBadge(Icons.cancel_outlined, '${appState.outOfStockCount} ${'rupture'.tr}', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
              ],
            ),
            const SizedBox(height: 24),

            // 4. ÉTAT DU STOCK PAR ARTICLE OU ÉTAT VIDE
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Détail des mouvements & Niveaux de Stock'.tr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        '${appState.products.length} ${'articles référencés'.tr}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  if (appState.products.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const Icon(Icons.warehouse_outlined, size: 64, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 14),
                            Text(
                              'Aucun stock enregistré pour l\'instant'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Le stock arrive de vos fournisseurs. Créez une commande ou ajoutez un produit.'.tr,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.move_to_inbox, size: 18),
                              label: Text('Approvisionner le stock'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appState.products.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, idx) {
                        final p = appState.products[idx];
                        final isLow = p.stock <= 5 && p.stock > 0;
                        final isOut = p.stock == 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      'Réf: ${p.barcode.isNotEmpty ? p.barcode : 'N/A'}',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${p.stock} ${p.unit}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              const SizedBox(width: 14),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                                },
                                child: Text('Réassort'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
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
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildWebValueCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebBadge(IconData icon, String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textCol),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  // ==========================================
  // VERSION MOBILE (100% PRÉSERVÉE)
  // ==========================================
  Widget _buildMobileInventory(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARTE VALEUR DU STOCK MODERNE
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: AppTheme.primaryNavy, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'VALEUR DU STOCK'.tr,
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStockValueCol('Vente'.tr, '0 F CFA'),
                          Container(width: 1, height: 30, color: const Color(0xFFE5E7EB)),
                          _buildStockValueCol('Coût'.tr, '0 F CFA'),
                          Container(width: 1, height: 30, color: const Color(0xFFE5E7EB)),
                          _buildStockValueCol('Marge'.tr, '—'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // BADGES D'ÉTAT DU STOCK
                Row(
                  children: [
                    _buildStatusBadge(
                      Icons.inventory_2_outlined,
                      '${appState.products.length} ${'articles'.tr}',
                      const Color(0xFFF3F4F6),
                      const Color(0xFF1F2937),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      Icons.warning_amber_rounded,
                      '${appState.lowStockCount} ${'bas'.tr}',
                      const Color(0xFFFEF3C7),
                      const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      Icons.cancel_outlined,
                      '${appState.outOfStockCount} ${'rupture'.tr}',
                      const Color(0xFFFEE2E2),
                      const Color(0xFFDC2626),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // SÉLECTEUR DE DÉPÔTS
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _selectedStoreTab = 'Tous'),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedStoreTab == 'Tous' ? AppTheme.goldLight : Colors.white,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          ),
                          child: Text(
                            'Tous'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _selectedStoreTab = 'Boutique principale'),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedStoreTab == 'Boutique principale' ? AppTheme.goldLight : Colors.white,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          ),
                          child: Text(
                            'Boutique principale'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION INVENTAIRE
                Text(
                  'Inventaire'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 40),

                // ÉTAT VIDE
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 70, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 14),
                      Text(
                        'Aucun stock pour cette boutique'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Le stock arrive de vos fournisseurs. Créez une commande pour en recevoir.'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldLight,
                          foregroundColor: const Color(0xFF1F2937),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.move_to_inbox, size: 18),
                        label: Text(
                          'Approvisionner'.tr,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // SPEED DIAL OVERLAY STOCK
          if (_isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isFabExpanded = false),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.88),
                  padding: const EdgeInsets.only(bottom: 90, right: 16),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 1. Approvisionner
                      _buildSpeedDialOption(
                        label: 'Approvisionner'.tr,
                        icon: Icons.move_to_inbox,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                        },
                      ),
                      const SizedBox(height: 14),
                      // 2. Ajuster le stock
                      _buildSpeedDialOption(
                        label: 'Ajuster le stock'.tr,
                        icon: Icons.tune,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Module d\'ajustement de stock ouvert !'.tr)),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      // 3. Transférer entre boutiques
                      _buildSpeedDialOption(
                        label: 'Transférer entre boutiques'.tr,
                        icon: Icons.swap_horiz,
                        onTap: () {
                          setState(() => _isFabExpanded = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Module de transfert inter-boutiques ouvert !'.tr)),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      // 4. Enregistrer une perte
                      _buildSpeedDialOption(
                        label: 'Enregistrer une perte'.tr,
                        icon: Icons.remove_shopping_cart_outlined,
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

  Widget _buildSpeedDialOption({required String label, required IconData icon, required VoidCallback onTap}) {
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

  Widget _buildStockValueCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
      ],
    );
  }

  Widget _buildStatusBadge(IconData icon, String label, Color bg, Color textCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: textCol),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
