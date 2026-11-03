import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.accentGold,
        unselectedItemColor: const Color(0xFF6B7280),
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
  }
}
