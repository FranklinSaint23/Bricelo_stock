import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'inventory_screen.dart';
import 'debts_screen.dart';
import 'reports_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final appState = AppState.instance;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PosScreen(),
    InventoryScreen(),
    DebtsScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;

        if (isDesktop) {
          // Version Grand Écran / Portail Web (Patron & Vendeur)
          return Scaffold(
            body: Row(
              children: [
                // Barre latérale NavigationRail style Bricélo
                Container(
                  width: 260,
                  color: AppTheme.navy900,
                  child: Column(
                    children: [
                      // En-tête Bricélo Stock Prime
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.gold500,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory_2, color: AppTheme.navy900, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STOCK PRIME',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'by BRICÉLO Cameroun',
                                  style: TextStyle(color: AppTheme.gold400, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF1E3052), height: 1),

                      // Sélecteur de Boutique & Mode
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162540),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF264063)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('MAGASIN ACTIF', style: TextStyle(color: AppTheme.slate400, fontSize: 10, fontWeight: FontWeight.bold)),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.currentStore,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => appState.toggleBossMode(),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: appState.isBossMode ? AppTheme.gold500.withOpacity(0.15) : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: appState.isBossMode ? AppTheme.gold500.withOpacity(0.4) : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      appState.isBossMode ? Icons.admin_panel_settings : Icons.badge_outlined,
                                      size: 14,
                                      color: appState.isBossMode ? AppTheme.gold400 : AppTheme.slate400,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      appState.isBossMode ? 'Mode Patron (Tout visible)' : 'Mode Caissier (Marges masquées)',
                                      style: TextStyle(
                                        color: appState.isBossMode ? AppTheme.gold400 : AppTheme.slate400,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu Items
                      _buildWebMenuItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Tableau de bord', badgeCount: 0),
                      _buildWebMenuItem(1, Icons.point_of_sale_outlined, Icons.point_of_sale, 'Caisse (POS)', badgeCount: appState.cartCount),
                      _buildWebMenuItem(2, Icons.inventory_2_outlined, Icons.inventory_2, 'Stock & Produits', badgeCount: appState.lowStockCount + appState.outOfStockCount, isAlert: true),
                      _buildWebMenuItem(3, Icons.menu_book_outlined, Icons.menu_book, 'Carnet de Dettes', badgeCount: appState.debts.where((d) => !d.isSettled).length),
                      _buildWebMenuItem(4, Icons.bar_chart_outlined, Icons.bar_chart, 'Bilan & Z Caisse', badgeCount: 0),

                      const Spacer(),

                      // Panier en attente rapide si présent
                      if (appState.heldCarts.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E220D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.gold500.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.pause_circle_outline, color: AppTheme.gold400, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${appState.heldCarts.length} panier(s) en attente',
                                  style: const TextStyle(color: AppTheme.gold400, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  setState(() => _currentIndex = 1);
                                },
                                child: const Text('Voir', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                      // Badge Marketplace Bricélo
                      Container(
                        margin: const EdgeInsets.all(14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162540),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF264063)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Connecté à Bricélo.cm',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Stock synchronisé en temps réel avec la boutique en ligne.',
                              style: TextStyle(color: AppTheme.slate400, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu principal de l'écran
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        }

        // Version Mobile (Android / iOS)
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.gold500.withOpacity(0.2),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppTheme.navy900),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: appState.cartCount > 0,
                    label: Text('${appState.cartCount}'),
                    backgroundColor: AppTheme.gold500,
                    textColor: AppTheme.navy900,
                    child: const Icon(Icons.point_of_sale_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: appState.cartCount > 0,
                    label: Text('${appState.cartCount}'),
                    backgroundColor: AppTheme.gold500,
                    textColor: AppTheme.navy900,
                    child: const Icon(Icons.point_of_sale, color: AppTheme.navy900),
                  ),
                  label: 'Caisse',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: (appState.lowStockCount + appState.outOfStockCount) > 0,
                    label: Text('${appState.lowStockCount + appState.outOfStockCount}'),
                    backgroundColor: AppTheme.danger,
                    child: const Icon(Icons.inventory_2_outlined),
                  ),
                  selectedIcon: const Icon(Icons.inventory_2, color: AppTheme.navy900),
                  label: 'Stock',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: appState.debts.where((d) => !d.isSettled).isNotEmpty,
                    label: Text('${appState.debts.where((d) => !d.isSettled).length}'),
                    backgroundColor: AppTheme.warning,
                    child: const Icon(Icons.menu_book_outlined),
                  ),
                  selectedIcon: const Icon(Icons.menu_book, color: AppTheme.navy900),
                  label: 'Dettes',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart, color: AppTheme.navy900),
                  label: 'Bilan',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebMenuItem(int index, IconData icon, IconData activeIcon, String label, {int badgeCount = 0, bool isAlert = false}) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: AppTheme.gold500,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.navy900 : AppTheme.slate400,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.navy900 : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.navy900
                      : (isAlert ? AppTheme.danger : AppTheme.gold500),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isAlert ? Colors.white : AppTheme.navy900),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => setState(() => _currentIndex = index),
      ),
    );
  }
}
