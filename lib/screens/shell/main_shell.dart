import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 2; // Default to 'Produits' to match the user's focus
  final appState = AppState.instance;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PosScreen(),
    ProductsScreen(),
    InventoryScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;

        if (isDesktop) {
          // Version Grand Écran Web (avec sidebar verte StockPlus)
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 250,
                  color: AppTheme.primaryNavy,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory_2, color: AppTheme.primaryNavy, size: 24),
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
                                Text('by BRICÉLO Cameroun', style: TextStyle(color: AppTheme.accentGold, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF1E3052), height: 1),
                      const SizedBox(height: 12),

                      _buildWebMenuItem(0, Icons.home_outlined, Icons.home, 'Accueil'),
                      _buildWebMenuItem(1, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Vente'),
                      _buildWebMenuItem(2, Icons.inventory_2_outlined, Icons.inventory_2, 'Produits'),
                      _buildWebMenuItem(3, Icons.warehouse_outlined, Icons.warehouse, 'Stock'),
                      _buildWebMenuItem(4, Icons.more_horiz, Icons.more_horiz, 'Plus'),

                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.all(14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162540),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_done, color: AppTheme.accentGold, size: 16),
                            SizedBox(width: 8),
                            Text('Connecté à Bricélo.cm', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        }

        // Version Mobile (Exacte reproduction des screenshots StockPlus)
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.primaryNavy,
              unselectedItemColor: const Color(0xFF6B7280),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: 'Vente',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Produits',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warehouse_outlined),
                  activeIcon: Icon(Icons.warehouse),
                  label: 'Stock',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  activeIcon: Icon(Icons.more_horiz),
                  label: 'Plus',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebMenuItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: AppTheme.accentGold,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.primaryNavy : Colors.white70,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryNavy : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        onTap: () => setState(() => _currentIndex = index),
      ),
    );
  }
}
