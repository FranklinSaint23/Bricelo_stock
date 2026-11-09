import 'dart:convert';
import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  String _activeFilter = "Aujourd'hui"; // "Aujourd'hui", "En attente", "Stock faible", "Terminé"

  Widget _buildShopLogoAvatar(AppState appState, double size) {
    if (appState.companyLogo.trim().isNotEmpty) {
      try {
        final clean = appState.companyLogo.contains(',')
            ? appState.companyLogo.split(',').last
            : appState.companyLogo;
        return Image.memory(
          base64Decode(clean),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildInitialsAvatar(appState, size),
        );
      } catch (_) {
        return _buildInitialsAvatar(appState, size);
      }
    }
    return _buildInitialsAvatar(appState, size);
  }

  Widget _buildInitialsAvatar(AppState appState, double size) {
    return Container(
      color: AppTheme.primaryNavy,
      width: size,
      height: size,
      child: Center(
        child: Text(
          appState.userInitials,
          style: TextStyle(
            color: AppTheme.accentGold,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;
        final totalSales = appState.todayRevenue;
        final salesCount = appState.todaySalesCount;
        final totalDebt = appState.totalCustomerDebt;

        if (isDesktop) {
          return _buildDesktopDashboard(context, appState, totalSales, salesCount, totalDebt);
        }

        return _buildMobileDashboard(context, appState, totalSales, salesCount, totalDebt);
      },
    );
  }

  // ==========================================
  // VERSION GRAND ÉCRAN WEB / DESKTOP (RÉACTIF)
  // ==========================================
  Widget _buildDesktopDashboard(
    BuildContext context,
    AppState appState,
    double totalSales,
    int salesCount,
    double totalDebt,
  ) {
    final isDark = appState.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAccountScreen()));
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentGold, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildShopLogoAvatar(appState, 52),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'Bonjour'.tr}, ${appState.displayUserName} 👋',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              AppTranslations.formattedCurrentDate,
                              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        appState.currentStore,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildWebKpiCard(
                    title: 'Chiffre du jour'.tr,
                    value: AppTheme.formatFCFA(totalSales),
                    subtitle: '$salesCount ${salesCount > 1 ? 'ventes'.tr : 'vente'.tr}',
                    icon: Icons.trending_up,
                    bgGradient: const LinearGradient(
                      colors: [Color(0xFF0D1B2E), Color(0xFF162540)],
                    ),
                    valueColor: Colors.white,
                    subtitleColor: AppTheme.accentGold,
                    iconColor: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWebKpiCard(
                    title: 'Encaissé'.tr,
                    value: AppTheme.formatFCFA(totalSales),
                    subtitle: 'Espèces & Mobile Money'.tr,
                    icon: Icons.account_balance_wallet_outlined,
                    bgColor: isDark ? AppTheme.darkSurface : Colors.white,
                    valueColor: const Color(0xFF16A34A),
                    subtitleColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    iconColor: const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen()));
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: _buildWebKpiCard(
                      title: 'À recouvrer (Dettes)'.tr,
                      value: AppTheme.formatFCFA(totalDebt),
                      subtitle: 'Voir les clients endettés >'.tr,
                      icon: Icons.people_outline,
                      bgColor: isDark ? AppTheme.darkSurface : Colors.white,
                      valueColor: const Color(0xFFD97706),
                      subtitleColor: const Color(0xFFD97706),
                      iconColor: const Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWebKpiCard(
                    title: 'Articles en stock'.tr,
                    value: '${appState.products.length}',
                    subtitle: appState.lowStockCount > 0 ? '${appState.lowStockCount} ${'bas'.tr}' : 'Stock optimal'.tr,
                    icon: Icons.inventory_2_outlined,
                    bgColor: isDark ? AppTheme.darkSurface : Colors.white,
                    valueColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    subtitleColor: appState.lowStockCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                    iconColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions Rapides'.tr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildWebActionTile(
                              title: 'Point de vente (POS)'.tr,
                              subtitle: 'Caisse rapide & encaissement'.tr,
                              icon: Icons.point_of_sale,
                              color: AppTheme.primaryNavy,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildWebActionTile(
                              title: 'Ajouter un produit'.tr,
                              subtitle: 'Nouveau produit au catalogue'.tr,
                              icon: Icons.add_box_outlined,
                              color: AppTheme.primaryNavy,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildWebActionTile(
                              title: 'Approvisionner'.tr,
                              subtitle: 'Réception de marchandises'.tr,
                              icon: Icons.move_to_inbox,
                              color: const Color(0xFF0284C7),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildWebActionTile(
                              title: 'Dépenses & Charges'.tr,
                              subtitle: 'Loyer, livraisons, salaires...'.tr,
                              icon: Icons.receipt_long_outlined,
                              color: const Color(0xFFB45309),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesAndExpensesScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history, color: AppTheme.primaryNavy, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ventes Récentes'.tr,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$salesCount ${salesCount > 1 ? 'ventes'.tr : 'vente'.tr}',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            if (appState.visibleSales.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 28),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFFCBD5E1)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Aucune vente enregistrée aujourd\'hui'.tr,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: appState.visibleSales.take(5).length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (context, idx) {
                                  final sale = appState.visibleSales[idx];
                                  return InkWell(
                                    onTap: () => SaleReceiptDialog.show(context, sale),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECFDF5),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${sale.ticketNumber} • ${sale.customerName}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                                ),
                                                Text(
                                                  sale.paymentMethod,
                                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            AppTheme.formatFCFA(sale.total),
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryNavy),
                                          ),
                                        ],
                                      ),
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
                const SizedBox(width: 24),
                Expanded(
                  flex: 35,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F172A), AppTheme.primaryNavy],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryNavy, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Assistant Bricelo'.tr,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        'Copilote IA de votre commerce'.tr,
                                        style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentGold,
                                  foregroundColor: AppTheme.primaryNavy,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: Text('Poser une question à Bricelo'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // CARTE ABONNEMENT PORTAIL WEB (Synchronisé avec l'app mobile en consommation)
                      if (appState.userRole.toLowerCase().contains('propriétaire') ||
                          appState.userRole.toLowerCase().contains('owner'))
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 1.5),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryNavy, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ABONNEMENT PORTAIL WEB',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Formule : ${appState.subscriptionPlan}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 15,
                                                  color: isDark ? Colors.white : AppTheme.primaryNavy,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDCFCE7),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Actif',
                                                style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Souscrivez ou changez votre formule ici sur le portail web. Votre abonnement est automatiquement synchronisé sur votre téléphone mobile via la base de données.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.35),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryNavy,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.upgrade_rounded, color: AppTheme.accentGold, size: 18),
                                  label: const Text(
                                    'Gérer mon abonnement / Formules',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),

                      // CARTE SUIVI SHIFTS, APPROBATIONS & ÉQUIPE (PORTAIL WEB)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.groups_rounded, color: AppTheme.primaryNavy, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      appState.isOwnerAccount
                                          ? 'Équipe, Shifts & Approbations'
                                          : 'Mon Suivi Shifts & Activités (${appState.assignedStoreForCurrentUser})',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                if (appState.isOwnerAccount && appState.pendingApprovalsCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.danger,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${appState.pendingApprovalsCount} en attente',
                                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (appState.isOwnerAccount) ...[
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.verified_user_rounded, color: Color(0xFFDC2626), size: 18),
                                ),
                                title: const Text('Approbations (Stock & Transferts)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                subtitle: Text(
                                  appState.pendingApprovalsCount > 0
                                      ? '${appState.pendingApprovalsCount} demande(s) d\'équipiers à valider'
                                      : 'Aucune demande en attente',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsScreen()));
                                },
                              ),
                              const Divider(height: 12),
                            ],
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.punch_clock_rounded, color: Color(0xFF059669), size: 18),
                              ),
                              title: Text(
                                appState.isOwnerAccount
                                    ? 'Suivi Shifts & Activités par Boutique'
                                    : 'Mon Suivi Shifts & Activités',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                              subtitle: Text(
                                appState.activeCashShift != null
                                    ? '${appState.activeCashShift!.cashDeskName} ${'ouvert'.tr} (${appState.activeCashShift!.formattedDurationHms})'
                                    : (appState.isOwnerAccount
                                        ? 'Caissiers, Magasiniers & Gérants'
                                        : 'Mes statistiques personnelles • ${appState.assignedStoreForCurrentUser}'),
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftsTrackingScreen()));
                              },
                            ),
                            if (appState.isOwnerAccount) ...[
                              const Divider(height: 12),
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.badge_rounded, color: AppTheme.primaryNavy, size: 18),
                                ),
                                title: const Text('Équipe & Groupes d\'accès', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                subtitle: Text(
                                  '${appState.teamMembers.length} collaborateur(s) invité(s)',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamScreen()));
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? bgColor,
    Gradient? bgGradient,
    required Color valueColor,
    required Color subtitleColor,
    required Color iconColor,
  }) {
    final isDark = AppState.instance.isDarkMode;
    final isDarkCard = bgGradient != null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? AppTheme.darkSurface : Colors.white),
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(14),
        border: isDarkCard ? null : Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDarkCard ? Colors.white70 : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDarkCard ? Colors.white12 : iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = AppState.instance.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDark ? AppTheme.accentGold : color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 13, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VERSION MOBILE — STYLE BRICELO (100% DYNAMIQUE)
  // ==========================================
  Widget _buildMobileDashboard(
    BuildContext context,
    AppState appState,
    double totalSales,
    int salesCount,
    double totalDebt,
  ) {
    final filteredSales = appState.visibleSales.where((s) {
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchTicket = s.ticketNumber.toLowerCase().contains(q);
        final matchClient = s.customerName.toLowerCase().contains(q);
        final matchItem = s.items.any((i) => i.productName.toLowerCase().contains(q));
        if (!matchTicket && !matchClient && !matchItem) return false;
      }
      if (_activeFilter == 'En attente') {
        return s.paymentMethod == 'À Crédit';
      }
      if (_activeFilter == 'Terminé') {
        return s.paymentMethod != 'À Crédit';
      }
      return true;
    }).toList();

    final isDark = appState.isDarkMode;
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final navyOrWhite = isDark ? Colors.white : AppTheme.primaryNavy;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bricelo Stock',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER : Logo de la boutique + Bonjour <Nom> + DATE DU JOUR en dessous + Assistant IA
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAccountScreen()));
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentGold, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildShopLogoAvatar(appState, 46),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'Bonjour'.tr}, ${appState.displayUserName} 👋',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                AppTranslations.formattedCurrentDate,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. BARRE DE RECHERCHE DYNAMIQUE
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(color: textPrimary, fontSize: 13),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une vente, un client ou produit...'.tr,
                    hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B), size: 20),
                    suffixIcon: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen()));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3052) : AppTheme.primaryNavy.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.qr_code_scanner_rounded, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 18),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. CARTE PRINCIPALE "AUJOURD'HUI" — BLEU NUIT BRICELO & OR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryNavy,
                      Color(0xFF162944),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            "Aujourd'hui".tr,
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Text(
                          '$salesCount ${salesCount > 1 ? 'ventes'.tr : 'vente'.tr}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppTheme.formatFCFA(totalSales),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chiffre du jour'.tr,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Encaissé'.tr,
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  AppTheme.formatFCFA(totalSales),
                                  style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 28, color: Colors.white12),
                          const SizedBox(width: 14),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen()));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'À recouvrer'.tr,
                                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios, color: AppTheme.accentGold, size: 10),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    AppTheme.formatFCFA(totalDebt),
                                    style: const TextStyle(
                                      color: AppTheme.accentGold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. FILTRES PILLS INTERACTIFS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusPill("Aujourd'hui", count: salesCount),
                    const SizedBox(width: 8),
                    _buildStatusPill('En attente', count: appState.heldCarts.length + appState.debts.where((d) => !d.isSettled).length),
                    const SizedBox(width: 8),
                    _buildStatusPill('Stock faible', count: appState.lowStockCount),
                    const SizedBox(width: 8),
                    _buildStatusPill('Terminé', count: appState.sales.where((s) => s.paymentMethod != 'À Crédit').length),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. GRILLE 2x2 ACTIONS RAPIDES — CARTES MODERNES BRICELO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actions Rapides'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: navyOrWhite,
                    ),
                  ),
                  Text(
                    '${appState.products.length} ${'articles'.tr}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildBriceloCategoryCard(
                      title: 'Nouvelle vente'.tr,
                      subtitle: 'Caisse & Reçu'.tr,
                      icon: Icons.point_of_sale_rounded,
                      cardBg: const Color(0xFFFFF8E7),
                      iconBg: AppTheme.accentGold,
                      iconColor: AppTheme.primaryNavy,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBriceloCategoryCard(
                      title: 'Ajouter un produit'.tr,
                      subtitle: '${appState.products.length} ${'articles'.tr}',
                      icon: Icons.add_box_rounded,
                      cardBg: const Color(0xFFEEF2F6),
                      iconBg: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      iconColor: isDark ? AppTheme.primaryNavy : Colors.white,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildBriceloCategoryCard(
                      title: 'Approvisionner'.tr,
                      subtitle: 'Entrées stock'.tr,
                      icon: Icons.move_to_inbox_rounded,
                      cardBg: const Color(0xFFEEF2F6),
                      iconBg: const Color(0xFF1E3A5F),
                      iconColor: AppTheme.accentGold,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBriceloCategoryCard(
                      title: 'Historique des ventes'.tr,
                      subtitle: '${appState.sales.length} ${appState.sales.length > 1 ? "ventes".tr : "vente".tr}',
                      icon: Icons.history_rounded,
                      cardBg: const Color(0xFFFFF8E7),
                      iconBg: const Color(0xFFE5A600),
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 6. SECTION ACTIVITÉ / VENTES RÉCENTES OU STOCK FAIBLE SELON LE FILTRE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeFilter == 'Stock faible' ? 'Alertes de Stock'.tr : 'Ventes Récentes'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: navyOrWhite,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
                    },
                    child: Text(
                      'Historique >'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.accentGold : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_activeFilter == 'Stock faible')
                appState.lowStockProducts.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Text(
                          'Tous vos stocks sont à niveau optimal'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                        ),
                      )
                    : Column(
                        children: appState.lowStockProducts.map((p) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? const Color(0xFF854D0E) : const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                                      Text('Stock restant : ${p.stock} ${p.unit}', style: const TextStyle(fontSize: 12, color: Color(0xFFD97706))),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                                  },
                                  child: Text('Réassort'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
              else if (filteredSales.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3052) : AppTheme.primaryNavy.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.rocket_launch_rounded, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.products.isEmpty
                                  ? 'Ajoutez vos premiers produits pour commencer'.tr
                                  : 'Aucune vente enregistrée aujourd\'hui'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appState.products.isEmpty
                                  ? 'Créez un produit puis encaissez au comptoir avec reçu.'.tr
                                  : 'Rendez-vous dans Vente pour encaisser votre premier client.'.tr,
                              style: TextStyle(color: textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: filteredSales.take(5).map((sale) {
                    return InkWell(
                      onTap: () => SaleReceiptDialog.show(context, sale),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3052) : AppTheme.primaryNavy.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.receipt_long_rounded, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${sale.ticketNumber} • ${sale.customerName}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${(sale.paymentMethod.startsWith("Caisse 1") || sale.paymentMethod == "Caisse 1" || sale.paymentMethod == "Caisse") ? "Caisse ${sale.storeName}" : sale.paymentMethod} • ${sale.items.length} article(s) • Voir reçu',
                                    style: TextStyle(color: textSecondary, fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AppTheme.formatFCFA(sale.total),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dashboard_assistant',
        backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
        foregroundColor: isDark ? AppTheme.primaryNavy : AppTheme.accentGold,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()));
        },
        child: const Icon(Icons.auto_awesome_rounded, size: 26),
      ),
    );
  }

  Widget _buildStatusPill(String label, {required int count}) {
    final isDark = AppState.instance.isDarkMode;
    final isSelected = _activeFilter == label;
    return InkWell(
      onTap: () => setState(() => _activeFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.accentGold : AppTheme.primaryNavy)
              : (isDark ? AppTheme.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTheme.accentGold : AppTheme.primaryNavy)
                : (isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.tr,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? AppTheme.primaryNavy : Colors.white)
                    : (isDark ? Colors.white : const Color(0xFF475569)),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppTheme.primaryNavy.withValues(alpha: 0.2) : AppTheme.accentGold)
                    : (isDark ? const Color(0xFF1E3052) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? AppTheme.primaryNavy : AppTheme.primaryNavy)
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBriceloCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardBg,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = AppState.instance.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF1E3052) : Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: iconBg.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isDark ? Colors.white : AppTheme.primaryNavy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
