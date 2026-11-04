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
  int _currentIndex = 0;
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
          // Version Grand Écran Web Professionnelle Bricelo
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Row(
              children: [
                // 1. SIDEBAR WEB / DESKTOP (Largeur 260px)
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: Color(0xFF091320),
                    border: Border(right: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Column(
                    children: [
                      // En-tête Bricelo Stock avec Logo Officiel
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.storefront,
                                    color: AppTheme.primaryNavy,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BRICELO STOCK'.tr,
                                    style: const TextStyle(
                                      color: AppTheme.accentGold,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        'Market & Stock'.tr,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGold.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('CM', style: TextStyle(color: AppTheme.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sélecteur de Boutique Rapide
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131F33),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E3A5F)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_outlined, color: AppTheme.accentGold, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                appState.currentStore,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF1E293B), height: 16),

                      // Navigation principale
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          children: [
                            _buildWebSectionLabel('COMMERCE'),
                            _buildWebNavTile(0, Icons.dashboard_outlined, Icons.dashboard, 'Accueil'.tr, null),
                            _buildWebNavTile(
                              1,
                              Icons.point_of_sale_outlined,
                              Icons.point_of_sale,
                              'Point de vente'.tr,
                              appState.cart.isNotEmpty ? '${appState.cartCount}' : null,
                              badgeColor: const Color(0xFF10B981),
                            ),

                            const SizedBox(height: 12),
                            _buildWebSectionLabel('INVENTAIRE'),
                            _buildWebNavTile(
                              2,
                              Icons.inventory_2_outlined,
                              Icons.inventory_2,
                              'Produits'.tr,
                              '${appState.products.length}',
                            ),
                            _buildWebNavTile(
                              3,
                              Icons.warehouse_outlined,
                              Icons.warehouse,
                              'Stock'.tr,
                              appState.lowStockCount > 0 ? '${appState.lowStockCount} bas' : null,
                              badgeColor: const Color(0xFFF59E0B),
                            ),

                            const SizedBox(height: 12),
                            _buildWebSectionLabel('GESTION'),
                            _buildWebNavTile(4, Icons.more_horiz_outlined, Icons.more_horiz, 'Plus'.tr, null),

                            // Raccourci vers Assistant Bricelo
                            Container(
                              margin: const EdgeInsets.only(top: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1E3A5F),
                                    AppTheme.primaryNavy,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryNavy, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Assistant Bricelo'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        Text('Copilote IA connecté'.tr, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.accentGold, size: 12),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bas de Sidebar : Profil & Langue & Statut Cloud
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF060D17),
                          border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                        ),
                        child: Column(
                          children: [
                            // Profil Franklin
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      appState.userInitials,
                                      style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appState.displayCompanyName,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        appState.userRole,
                                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                // Basculeur Rapide de Langue
                                InkWell(
                                  onTap: () {
                                    final nextLang = appState.currentLanguage == 'fr' ? 'en' : 'fr';
                                    appState.setLanguage(nextLang);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      appState.currentLanguage.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.accentGold,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Badge Bricelo.cm
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_done, color: Color(0xFF10B981), size: 13),
                                const SizedBox(width: 6),
                                Text(
                                  'Connecté à Bricélo.cm'.tr,
                                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. CONTENU PRINCIPAL + TOPBAR D'ENTREPRISE
                Expanded(
                  child: Column(
                    children: [
                      // TOPBAR WEB (60px)
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        child: Row(
                          children: [
                            // Titre de l'écran actif
                            Text(
                              _getScreenTitle(_currentIndex),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Date du jour dynamique
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppTranslations.formattedCurrentDate,
                                    style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Bouton Action Rapide : + Vente POS
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              icon: const Icon(Icons.add_shopping_cart, size: 16),
                              label: Text('Nouvelle vente'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () => setState(() => _currentIndex = 1),
                            ),
                            const SizedBox(width: 10),

                            // Bouton Assistant Bricelo
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryNavy,
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              icon: const Icon(Icons.smart_toy_outlined, color: AppTheme.accentGold, size: 16),
                              label: Text('Assistant Bricelo'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()));
                              },
                            ),
                          ],
                        ),
                      ),

                      // Écran actif étendu
                      Expanded(child: _screens[_currentIndex]),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Version Mobile (100% Préservée)
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModernNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Accueil'.tr),
                    _buildModernNavItem(
                      1,
                      Icons.shopping_cart_outlined,
                      Icons.shopping_cart_rounded,
                      'Vente'.tr,
                      badge: appState.cart.isNotEmpty ? '' : null,
                    ),
                    _buildModernNavItem(2, Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Produits'.tr),
                    _buildModernNavItem(
                      3,
                      Icons.warehouse_outlined,
                      Icons.warehouse_rounded,
                      'Stock'.tr,
                      badge: appState.lowStockProducts.isNotEmpty ? '!' : null,
                      badgeColor: AppTheme.danger,
                    ),
                    _buildModernNavItem(4, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Plus'.tr),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getScreenTitle(int idx) {
    switch (idx) {
      case 0:
        return 'Tableau de bord'.tr;
      case 1:
        return 'Point de vente (Caisse)'.tr;
      case 2:
        return 'Gestion des Produits'.tr;
      case 3:
        return 'Gestion du Stock'.tr;
      default:
        return 'Menu & Paramètres'.tr;
    }
  }

  Widget _buildWebSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Text(
        title.tr,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildWebNavTile(int index, IconData icon, IconData activeIcon, String label, String? badge, {Color? badgeColor}) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentGold : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.primaryNavy : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryNavy : const Color(0xFFE2E8F0),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryNavy : (badgeColor ?? const Color(0xFF334155)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isSelected ? AppTheme.accentGold : Colors.white,
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

  Widget _buildModernNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected ? AppTheme.primaryNavy : const Color(0xFF94A3B8),
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: (badgeColor == AppTheme.danger) ? Colors.white : AppTheme.primaryNavy,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryNavy : const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            // Indicateur signature dot sous l item actif
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentGold : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
