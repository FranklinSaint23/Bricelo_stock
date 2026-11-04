import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BANDEAU DE BIENVENUE & DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, Franklin'.tr,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Voici le point d\'activité en temps réel de votre boutique Bricelo.'.tr,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
                // Badge Statut Boutique
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
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
                        'Boutique principale (Akwa)'.tr,
                        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. GRILLE DES 4 KPI CARTES EN HAUT
            Row(
              children: [
                // Carte 1 : Chiffre d'affaires du jour (Navy & Gold)
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

                // Carte 2 : Encaissé aujourd'hui (Vert)
                Expanded(
                  child: _buildWebKpiCard(
                    title: 'Encaissé'.tr,
                    value: AppTheme.formatFCFA(totalSales),
                    subtitle: 'Espèces & Mobile Money'.tr,
                    icon: Icons.account_balance_wallet_outlined,
                    bgColor: Colors.white,
                    valueColor: const Color(0xFF16A34A),
                    subtitleColor: const Color(0xFF64748B),
                    iconColor: const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 16),

                // Carte 3 : À recouvrer / Dettes clients
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
                      bgColor: Colors.white,
                      valueColor: const Color(0xFFD97706),
                      subtitleColor: const Color(0xFFD97706),
                      iconColor: const Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Carte 4 : Stock & Produits référencés
                Expanded(
                  child: _buildWebKpiCard(
                    title: 'Articles en stock'.tr,
                    value: '${appState.products.length}',
                    subtitle: appState.lowStockCount > 0 ? '${appState.lowStockCount} ${'bas'.tr}' : 'Stock optimal'.tr,
                    icon: Icons.inventory_2_outlined,
                    bgColor: Colors.white,
                    valueColor: const Color(0xFF0F172A),
                    subtitleColor: appState.lowStockCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                    iconColor: AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. SECTION PRINCIPALE 2 COLONNES (Actions & Ventes / Assistant & Alertes)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COLONNE GAUCHE (65%) : ACTIONS RAPIDES & VENTES DU JOUR
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

                      // Grille de 4 Cartes d'actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildWebActionTile(
                              title: 'Point de vente (POS)'.tr,
                              subtitle: 'Caisse rapide & encaissement'.tr,
                              icon: Icons.point_of_sale,
                              color: AppTheme.primaryNavy,
                              onTap: () {
                                final shell = context.findAncestorStateOfType<State>();
                                // Switch to tab 1 if inside MainShell
                                if (shell != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MainShell()),
                                  );
                                }
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

                      // Carte Résumé des Ventes Récentes
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

                            if (salesCount == 0)
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
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ouvrez le point de vente pour enregistrer vos premiers encaissements.'.tr,
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: appState.sales.take(5).length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (context, idx) {
                                  final sale = appState.sales[idx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sale.customerName.isNotEmpty ? sale.customerName : 'Client Comptant'.tr,
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

                // COLONNE DROITE (35%) : ASSISTANT BRICELO IA & ALERTES STOCK
                Expanded(
                  flex: 35,
                  child: Column(
                    children: [
                      // Widget Assistant Bricelo Intégré Desktop
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F172A), AppTheme.primaryNavy],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryNavy, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Assistant Bricelo'.tr,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                      ),
                                      Text(
                                        'Copilote IA de votre commerce'.tr,
                                        style: const TextStyle(color: AppTheme.accentGold, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Posez une question sur vos ventes, votre stock ou la configuration de votre boutique.'.tr,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                            ),
                            const SizedBox(height: 14),

                            // Bouton Ouvrir Chat Complet
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentGold,
                                  foregroundColor: AppTheme.primaryNavy,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: Text(
                                  'Poser une question à Bricelo'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Boîte Alertes Stock Bas
                      Container(
                        padding: const EdgeInsets.all(18),
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
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Alertes de Stock'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (appState.lowStockCount == 0 && appState.outOfStockCount == 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                                    const SizedBox(width: 8),
                                    Text('Tous vos stocks sont à niveau optimal'.tr, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                  ],
                                ),
                              )
                            else
                              Column(
                                children: [
                                  if (appState.lowStockCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Color(0xFFD97706), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${appState.lowStockCount} ${'articles ont un stock faible (< 5 unités)'.tr}',
                                              style: const TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (appState.outOfStockCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${appState.outOfStockCount} ${'articles en rupture de stock'.tr}',
                                              style: const TextStyle(color: Color(0xFF991B1B), fontSize: 11, fontWeight: FontWeight.bold),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(14),
        border: bgColor != null ? Border.all(color: const Color(0xFFE2E8F0)) : null,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
                  color: bgGradient != null ? Colors.white70 : const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.w600),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF94A3B8), size: 12),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VERSION MOBILE (100% PRÉSERVÉE)
  // ==========================================
  Widget _buildMobileDashboard(
    BuildContext context,
    AppState appState,
    double totalSales,
    int salesCount,
    double totalDebt,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. EN-TETE MODERNE (Avatar, Salutation, Selecteur Boutique, Cloche)
                  Row(
                    children: [
                      // Avatar circulaire stylise
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryNavy,
                          border: Border.all(color: AppTheme.accentGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'FA',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Salutation et Boutique active
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, Franklin 👋'.tr,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const OutletsScreen()));
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'Boutique principale (Akwa)'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bouton Notifications avec Badge
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 22),
                            if (appState.lowStockProducts.isNotEmpty)
                              Positioned(
                                top: 9,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2. BARRE DE RECHERCHE PILULE (Inspiree de la maquette)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Rechercher une vente, un produit...'.tr,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Color(0xFF64748B), size: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. ONGLETS FILTRES HORIZONTAUX (Pills)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('Aujourd\'hui'.tr, isSelected: true),
                        const SizedBox(width: 8),
                        _buildFilterPill('En attente'.tr, isSelected: false),
                        const SizedBox(width: 8),
                        _buildFilterPill('Stock faible'.tr, isSelected: false, count: appState.lowStockProducts.length),
                        const SizedBox(width: 8),
                        _buildFilterPill('Terminé'.tr, isSelected: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. CARTE RESUME DU JOUR (Bleu Nuit Bricelo + Or)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0D1B2E), Color(0xFF162540)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D1B2E).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recettes du jour'.tr,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$salesCount ${salesCount > 1 ? 'ventes'.tr : 'vente'.tr}',
                                style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTheme.formatFCFA(totalSales),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Deux sous-capsules : Encaisse & A recouvrer
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('Encaissé'.tr, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppTheme.formatFCFA(totalSales),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen()));
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.accentGold,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text('À recouvrer'.tr, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                            ],
                                          ),
                                          const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 10),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppTheme.formatFCFA(totalDebt),
                                        style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5. RACCOURCIS D\'ACTIONS RAPIDES (Boutiques, Caisse, Produit)
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          icon: Icons.point_of_sale_rounded,
                          label: 'Nouvelle Vente'.tr,
                          color: const Color(0xFF0F172A),
                          textColor: Colors.white,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          icon: Icons.add_box_rounded,
                          label: '+ Produit'.tr,
                          color: Colors.white,
                          textColor: const Color(0xFF0F172A),
                          isOutlined: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          icon: Icons.local_shipping_rounded,
                          label: 'Appro'.tr,
                          color: Colors.white,
                          textColor: const Color(0xFF0F172A),
                          isOutlined: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 6. TITRE SECTION : OPERATIONS DU JOUR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Opérations récentes'.tr,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
                        },
                        child: Row(
                          children: [
                            Text(
                              'Voir tout'.tr,
                              style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.accentGold),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 7. LISTE DE CARTES OPERATIONS (Design fidAle A  la maquette !)
                  if (appState.sales.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF64748B), size: 26),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune opération aujourd\'hui'.tr,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vos ventes et mouvements de stock apparaîtront ici.'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appState.sales.take(4).length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final sale = appState.sales[idx];
                        final customer = sale.customerName.isNotEmpty ? sale.customerName : 'Client Comptant'.tr;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
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
                                  Expanded(
                                    child: Text(
                                      customer,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    AppTheme.formatFCFA(sale.total),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${sale.items.length} ${sale.items.length > 1 ? 'articles' : 'article'} • ${sale.paymentMethod}',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Aujourd\'hui • Caisse 1',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  // Badge pastel de statut (vert pastel ou ambre)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFA7F3D0)),
                                    ),
                                    child: Text(
                                      'Encaissé'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFF059669),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // BOUTON FLOTTANT ASSISTANT IA BRICELO (Coins arrondis pilule)
            Positioned(
              right: 16,
              bottom: 16,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()));
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryNavy, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Assistant IA'.tr,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title, {required bool isSelected, int? count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF475569),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (count != null && count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentGold : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryNavy : const Color(0xFF1E293B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: isOutlined ? Border.all(color: const Color(0xFFCBD5E1)) : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}
