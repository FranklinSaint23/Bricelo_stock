import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/screens/pos/shift_dialog_helper.dart';

class _DynamicNavTab {
  final String id;
  final Widget screen;
  final String label;
  final String webTitle;
  final IconData icon;
  final IconData activeIcon;
  final String? badge;
  final Color? badgeColor;

  const _DynamicNavTab({
    required this.id,
    required this.screen,
    required this.label,
    required this.webTitle,
    required this.icon,
    required this.activeIcon,
    this.badge,
    this.badgeColor,
  });
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final appState = AppState.instance;

  List<_DynamicNavTab> _buildDynamicTabs({required bool isDesktop}) {
    final isOwner = appState.userRole.toLowerCase().contains('propriétaire') ||
        appState.userRole.toLowerCase().contains('owner');
    final canFinance = isOwner || appState.hasPermission('Comptabilité & Finances');
    final canPos = isOwner || appState.hasPermission('Point de vente (POS)');
    final canShifts = isOwner || appState.hasPermission('Gestion des shifts (Caisse)');
    final canStockAndPrice = isOwner || appState.hasPermission('Gestion du stock & Prix');
    final canRestockRequest = isOwner || appState.hasPermission('Demandes d\'approvisionnement & Transferts');
    final canApprove = isOwner || appState.hasPermission('Validation des approbations');
    final canTeam = isOwner || appState.hasPermission('Gestion des collaborateurs');

    final List<_DynamicNavTab> tabs = [];

    if (canFinance) {
      tabs.add(_DynamicNavTab(
        id: 'dashboard',
        screen: const DashboardScreen(),
        label: 'Accueil'.tr,
        webTitle: 'Tableau de bord'.tr,
        icon: Icons.space_dashboard_outlined,
        activeIcon: Icons.space_dashboard_rounded,
      ));
    }

    if (canPos) {
      tabs.add(_DynamicNavTab(
        id: 'pos',
        screen: const PosScreen(),
        label: 'Vente'.tr,
        webTitle: 'Point de vente (Caisse)'.tr,
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale_rounded,
        badge: appState.cart.isNotEmpty ? '${appState.cartCount}' : null,
        badgeColor: const Color(0xFF10B981),
      ));
    }

    // Sur Mobile : accès direct aux shifts pour les rôles invités (ex: Caissier)
    // Sur Portail Web (isDesktop) : accès direct à Suivi Shifts & Activités pour le Propriétaire et les rôles autorisés
    if ((!isOwner && canShifts && !canFinance) || (isDesktop && (isOwner || canShifts || canRestockRequest))) {
      tabs.add(_DynamicNavTab(
        id: 'shifts',
        screen: const ShiftsTrackingScreen(initialTabIndex: 0),
        label: isDesktop ? 'Shifts & Activités' : 'Shifts',
        webTitle: 'Suivi des Shifts & Activités Équipe',
        icon: Icons.punch_clock_outlined,
        activeIcon: Icons.punch_clock_rounded,
      ));
    }

    if (canStockAndPrice) {
      tabs.add(_DynamicNavTab(
        id: 'products',
        screen: const ProductsScreen(),
        label: 'Produits'.tr,
        webTitle: 'Gestion des Produits'.tr,
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
      ));
    }

    if (canStockAndPrice || canRestockRequest) {
      tabs.add(_DynamicNavTab(
        id: 'stock',
        screen: const InventoryScreen(),
        label: 'Stock'.tr,
        webTitle: 'Gestion du Stock'.tr,
        icon: Icons.all_inbox_outlined,
        activeIcon: Icons.all_inbox_rounded,
        badge: appState.lowStockProducts.isNotEmpty ? '!' : null,
        badgeColor: AppTheme.danger,
      ));
    }

    // Sections additionnelles dédiées au Portail Web (Sidebar Grand Écran)
    if (isDesktop) {
      if (canApprove) {
        tabs.add(_DynamicNavTab(
          id: 'approvals',
          screen: const ApprovalsScreen(),
          label: 'Approbations',
          webTitle: 'Centre d\'Approbations & Validations',
          icon: Icons.verified_user_outlined,
          activeIcon: Icons.verified_user_rounded,
          badge: appState.pendingApprovalsCount > 0 ? '${appState.pendingApprovalsCount}' : null,
          badgeColor: AppTheme.danger,
        ));
      }

      if (canTeam) {
        tabs.add(_DynamicNavTab(
          id: 'team',
          screen: const TeamScreen(),
          label: 'Équipe & Rôles',
          webTitle: 'Gestion de l\'Équipe & Rôles',
          icon: Icons.group_outlined,
          activeIcon: Icons.group_rounded,
        ));
      }

      if (isOwner) {
        tabs.add(_DynamicNavTab(
          id: 'subscription',
          screen: const SubscriptionScreen(showAppBar: false),
          label: 'Abonnement',
          webTitle: 'Portail Web • Formules & Abonnement',
          icon: Icons.workspace_premium_outlined,
          activeIcon: Icons.workspace_premium_rounded,
          badge: appState.subscriptionPlan,
          badgeColor: const Color(0xFF059669),
        ));
      }
    }

    tabs.add(_DynamicNavTab(
      id: 'more',
      screen: const MoreScreen(),
      label: isOwner ? 'Plus'.tr : 'Mon Compte',
      webTitle: 'Menu & Paramètres'.tr,
      icon: Icons.widgets_outlined,
      activeIcon: Icons.widgets_rounded,
      badge: (canApprove && appState.pendingApprovalsCount > 0)
          ? '${appState.pendingApprovalsCount}'
          : null,
      badgeColor: AppTheme.danger,
    ));

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;
        final isDark = appState.isDarkMode;
        final tabs = _buildDynamicTabs(isDesktop: isDesktop);
        final safeIndex = _currentIndex.clamp(0, tabs.length - 1);
        final posIndex = tabs.indexWhere((t) => t.id == 'pos');
        final subIndex = tabs.indexWhere((t) => t.id == 'subscription');
        final isOwner = appState.userRole.toLowerCase().contains('propriétaire') ||
            appState.userRole.toLowerCase().contains('owner');
        final activeShift = appState.activeCashShift;
        final now = DateTime.now();
        final isPast17h30 = now.hour > 17 || (now.hour == 17 && now.minute >= 30);

        if (isDesktop) {
          // Version Grand Écran Web Professionnelle Bricelo
          return Scaffold(
            backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
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

                      // Sélecteur de Boutique Rapide (Interactif sur le Portail Web)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                              child: (isOwner && appState.availableStores.length > 1)
                                  ? DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: const Color(0xFF0F172A),
                                        isDense: true,
                                        isExpanded: true,
                                        value: appState.availableStores.contains(appState.currentStore)
                                            ? appState.currentStore
                                            : appState.availableStores.first,
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.accentGold, size: 16),
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        items: appState.availableStores
                                            .map((st) => DropdownMenuItem<String>(
                                                  value: st,
                                                  child: Text(st, overflow: TextOverflow.ellipsis),
                                                ))
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            appState.setCurrentStore(val);
                                          }
                                        },
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        appState.currentStore,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 6),
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

                      // Navigation principale dynamique selon le rôle et les permissions
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          children: [
                            _buildWebSectionLabel('NAVIGATION (${appState.userRole.toUpperCase()})'),
                            for (int i = 0; i < tabs.length; i++)
                              _buildWebNavTile(
                                i,
                                tabs[i].icon,
                                tabs[i].activeIcon,
                                tabs[i].label,
                                tabs[i].badge,
                                badgeColor: tabs[i].badgeColor,
                              ),

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
                                    child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryNavy, size: 18),
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

                      // Bas de Sidebar : Profil & Langue & Déconnexion & Statut Cloud
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF060D17),
                          border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                        ),
                        child: Column(
                          children: [
                            // Profil Utilisateur (cliquable vers Mon Compte)
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAccountScreen()));
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
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
                                                appState.displayUserName,
                                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                appState.userAssignedCashDesk != null && appState.userAssignedCashDesk!.isNotEmpty
                                                    ? '${appState.userRole} • ${appState.userAssignedCashDesk}'
                                                    : appState.userRole,
                                                style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Basculeur Rapide de Langue
                                InkWell(
                                  onTap: () {
                                    final nextLang = appState.currentLanguage == 'fr' ? 'en' : 'fr';
                                    appState.setLanguage(nextLang);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      appState.currentLanguage.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.accentGold,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Bouton Déconnexion rapide sur le Portail Web
                                Tooltip(
                                  message: 'Déconnexion',
                                  child: InkWell(
                                    onTap: () async {
                                      await appState.logout();
                                      if (!context.mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                        (route) => false,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                                      ),
                                      child: const Icon(Icons.logout_rounded, color: Color(0xFFFCA5A5), size: 14),
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
                                Icon(
                                  appState.isDeviceOffline ? Icons.cloud_off_rounded : Icons.cloud_done,
                                  color: appState.isDeviceOffline ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                                  size: 13,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appState.isDeviceOffline
                                      ? 'Mode hors-ligne (${appState.pendingSyncQueue.length} en attente)'
                                      : 'Synchronisé avec Bricélo Cloud'.tr,
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
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0))),
                        ),
                        child: Row(
                          children: [
                            // Titre de l'écran actif
                            Text(
                              tabs[safeIndex].webTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Date du jour dynamique
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppTranslations.formattedCurrentDate,
                                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Statut du Shift de Caisse Actif (avec chronomètre & bouton Clôturer) sur le Portail Web
                            if (activeShift != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${activeShift.cashDeskName} ouvert • ${activeShift.formattedDuration}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => ShiftDialogHelper.showCloseShiftDialog(context, activeShift),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Clôturer',
                                          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],

                            // Badge Abonnement Portail Web (cliquable pour le Propriétaire)
                            if (isOwner && subIndex != -1) ...[
                              InkWell(
                                onTap: () => setState(() => _currentIndex = subIndex),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.6)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryNavy, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Formule : ${appState.subscriptionPlan}',
                                        style: const TextStyle(
                                          color: AppTheme.primaryNavy,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF16A34A),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Actif',
                                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],

                            // Bouton Action Rapide : + Vente POS (uniquement si autorisé)
                            if (posIndex != -1) ...[
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
                                onPressed: () => setState(() => _currentIndex = posIndex),
                              ),
                              const SizedBox(width: 10),
                            ],

                            // Bouton Assistant Bricelo
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                side: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 16),
                              label: Text('Assistant Bricelo'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()));
                              },
                            ),
                          ],
                        ),
                      ),

                      // Alerte 17h30 sur le Portail Web si un shift de caisse est toujours ouvert après 17h30
                      if (activeShift != null && isPast17h30)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          color: const Color(0xFFFEF2F2),
                          child: Row(
                            children: [
                              const Icon(Icons.alarm_on_rounded, color: Color(0xFFDC2626), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '⚠️ Alerte 17h30 : La caisse "${activeShift.cashDeskName}" (${activeShift.cashierName}) est toujours ouverte. Pensez à clôturer la caisse.',
                                  style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: () => ShiftDialogHelper.showCloseShiftDialog(context, activeShift),
                                child: const Text('Clôturer la caisse', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                      if (appState.showReconnectedSyncBanner)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: const Color(0xFF0D9488),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Connexion rétablie • Synchronisation en cours...',
                                style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                      // Écran actif étendu
                      Expanded(child: tabs[safeIndex].screen),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Version Mobile (Dynamique selon le rôle et les droits accordés)
        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
          body: Column(
            children: [
              if (appState.showReconnectedSyncBanner)
                SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: const Color(0xFF0D9488),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Synchronisation en cours...',
                            style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (appState.userRole != 'Propriétaire')
                SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppTheme.accentGold, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${appState.displayUserName} • ${appState.userRole}',
                                style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (appState.userAssignedCashDesk != null && appState.userAssignedCashDesk!.isNotEmpty)
                                Text(
                                  'Caisse : ${appState.userAssignedCashDesk}',
                                  style: const TextStyle(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        // Bouton Déconnexion rapide pour l'équipier
                        InkWell(
                          onTap: () async {
                            await appState.logout();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'Déconnexion',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(child: tabs[safeIndex].screen),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
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
                    for (int i = 0; i < tabs.length; i++)
                      _buildModernNavItem(
                        i,
                        tabs[i].icon,
                        tabs[i].activeIcon,
                        tabs[i].label,
                        isDark: isDark,
                        isSelectedOverride: safeIndex == i,
                        badge: tabs[i].badge,
                        badgeColor: tabs[i].badgeColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
    bool isDark = false,
    bool? isSelectedOverride,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = isSelectedOverride ?? (_currentIndex == index);
    final activeColor = isDark ? AppTheme.accentGold : AppTheme.primaryNavy;
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentGold.withValues(alpha: isDark ? 0.22 : 0.16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 23,
                    color: isSelected ? activeColor : const Color(0xFF94A3B8),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    right: -2,
                    top: -2,
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
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            // Indicateur signature premium (barre or arrondie avec halo diffus)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: isSelected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentGold : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
