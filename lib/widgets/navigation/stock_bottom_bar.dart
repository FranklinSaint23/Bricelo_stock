import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class StockBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StockBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final barBg = isDark ? AppTheme.darkSurface : Colors.white;
        final borderCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);
        final unselectedCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

        return Container(
          decoration: BoxDecoration(
            color: barBg,
            border: Border(
              top: BorderSide(color: borderCol, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: barBg,
            selectedItemColor: AppTheme.accentGold,
            unselectedItemColor: unselectedCol,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'Accueil'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_cart_outlined),
                activeIcon: const Icon(Icons.shopping_cart),
                label: 'Vente'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_outlined),
                activeIcon: const Icon(Icons.inventory_2),
                label: 'Produits'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.warehouse_outlined),
                activeIcon: const Icon(Icons.warehouse),
                label: 'Stock'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.more_horiz),
                activeIcon: const Icon(Icons.more_horiz),
                label: 'Plus'.tr,
              ),
            ],
          ),
        );
      },
    );
  }
}
