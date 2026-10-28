import 'depreciation_report_screen.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import 'supply_screen.dart';

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
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            title: const Text(
              'Stock',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
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
                    color: Colors.white.withOpacity(0.2),
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
                    // CARTE VALEUR DU STOCK
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.trending_up, color: AppTheme.primaryNavy, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'VALEUR DU STOCK',
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStockValueCol('Vente', '0 F CFA'),
                              Container(width: 1, height: 30, color: const Color(0xFFE5E7EB)),
                              _buildStockValueCol('Coût', '0 F CFA'),
                              Container(width: 1, height: 30, color: const Color(0xFFE5E7EB)),
                              _buildStockValueCol('Marge', '—'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // BADGES D'ÉTAT DU STOCK
                    Row(
                      children: [
                        _buildStatusBadge(Icons.inventory_2_outlined, '${appState.products.length} articles', const Color(0xFFF3F4F6), const Color(0xFF1F2937)),
                        const SizedBox(width: 8),
                        _buildStatusBadge(Icons.warning_amber_rounded, '${appState.lowStockCount} bas', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        _buildStatusBadge(Icons.cancel_outlined, '${appState.outOfStockCount} rupture', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
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
                              child: const Text('Tous', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
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
                              child: const Text('Boutique principale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION INVENTAIRE
                    const Text(
                      'Inventaire',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 40),

                    // ÉTAT VIDE
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 70, color: Color(0xFF9CA3AF)),
                          const SizedBox(height: 14),
                          const Text(
                            'Aucun stock pour cette boutique',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Le stock arrive de vos fournisseurs. Créez une commande pour en recevoir.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
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
                            label: const Text('Approvisionner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

              // SPEED DIAL OVERLAY STOCK (Screenshot 2: 4 Actions)
              if (_isFabExpanded)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isFabExpanded = false),
                    child: Container(
                      color: Colors.white.withOpacity(0.88),
                      padding: const EdgeInsets.only(bottom: 90, right: 16),
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 1. Approvisionner
                          _buildSpeedDialOption(
                            label: 'Approvisionner',
                            icon: Icons.move_to_inbox,
                            onTap: () {
                              setState(() => _isFabExpanded = false);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                            },
                          ),
                          const SizedBox(height: 14),
                          // 2. Ajuster le stock
                          _buildSpeedDialOption(
                            label: 'Ajuster le stock',
                            icon: Icons.tune,
                            onTap: () {
                              setState(() => _isFabExpanded = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Module d\'ajustement de stock ouvert !')),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          // 3. Transférer entre boutiques
                          _buildSpeedDialOption(
                            label: 'Transférer entre boutiques',
                            icon: Icons.swap_horiz,
                            onTap: () {
                              setState(() => _isFabExpanded = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Module de transfert inter-boutiques ouvert !')),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                                                    // 4. Enregistrer une perte
                          _buildSpeedDialOption(
                            label: 'Enregistrer une perte',
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

          // FAB EN BAS À DROITE (Screenshot 2)
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
