import 'package:stock_prime/screens/company/help_center_screen.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/auth/login_screen.dart';
import 'package:stock_prime/screens/auth/verify_email_screen.dart';
import 'package:stock_prime/screens/auth/my_account_screen.dart';
import 'package:stock_prime/screens/sales/sales_and_customers_screen.dart';
import 'package:stock_prime/screens/finance/promotion_and_shop_screen.dart';
import 'package:stock_prime/screens/inventory/stock_sub_menu_screen.dart';
import 'package:stock_prime/screens/finance/purchases_and_expenses_screen.dart';
import 'package:stock_prime/screens/finance/depreciation_report_screen.dart';
import 'package:stock_prime/screens/finance/accounting_screen.dart';
import 'package:stock_prime/screens/finance/global_stats_screen.dart';
import 'package:stock_prime/screens/finance/activity_reports_screen.dart';
import 'package:stock_prime/screens/company/company_and_team_screen.dart';
import 'package:stock_prime/screens/company/preferences_screen.dart';
import 'package:stock_prime/screens/company/language_screen.dart';
import 'package:stock_prime/screens/dashboard/bricelo_assistant_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _OriginalMenuItem {
  final IconData icon;
  final String title;
  final void Function(BuildContext context) onTap;
  final Widget? badge;
  final List<String> keywords;

  const _OriginalMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.keywords = const [],
  });
}

class _MoreScreenState extends State<MoreScreen> {
  final appState = AppState.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Exactement les 11 fonctionnalités d'origine avec leurs noms complets, icônes et liens originaux
  List<_OriginalMenuItem> _getOriginalItems() {
    return [
      // 1. Ventes & clients
      _OriginalMenuItem(
        icon: Icons.point_of_sale_rounded,
        title: 'Ventes & clients'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const SalesAndCustomersScreen())),
        keywords: ['vente', 'ventes', 'client', 'clients', 'devis', 'facture', 'pos', 'commande'],
      ),
      // 2. Promotion & boutique
      _OriginalMenuItem(
        icon: Icons.local_offer_rounded,
        title: 'Promotion & boutique'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PromotionAndShopScreen())),
        keywords: ['promotion', 'boutique', 'shop', 'remise', 'catalogue', 'promo', 'commande', 'commandes en ligne', 'boutique en ligne', 'studio video', 'studio vidéo', 'video', 'vidéo'],
      ),
      // 3. Stock
      _OriginalMenuItem(
        icon: Icons.inventory_2_rounded,
        title: 'Stock'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const StockSubMenuScreen())),
        keywords: ['stock', 'stocks', 'article', 'articles', 'produit', 'produits', 'inventaire'],
      ),
      // 4. Achats & dépenses
      _OriginalMenuItem(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Achats & dépenses'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PurchasesAndExpensesScreen())),
        keywords: ['achat', 'achats', 'dépense', 'depense', 'dépenses', 'fournisseur', 'fournisseurs', 'charge', 'bon d\'achat', 'bons d\'achat', 'dette fournisseur', 'dettes fournisseurs'],
      ),
      // 5. Comptabilité & trésorerie
      _OriginalMenuItem(
        icon: Icons.calculate_rounded,
        title: 'Comptabilité & trésorerie'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AccountingScreen())),
        keywords: ['comptabilité', 'comptabilite', 'trésorerie', 'tresorerie', 'banque', 'caisse', 'finance', 'bilan'],
      ),
      // 6. Statistiques (globales)
      _OriginalMenuItem(
        icon: Icons.bar_chart_rounded,
        title: 'Statistiques (globales)'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const GlobalStatsScreen())),
        keywords: ['statistique', 'statistiques', 'stat', 'stats', 'globale', 'globales', 'analyse', 'graphique', 'chiffre'],
      ),
      // 7. Rapports
      _OriginalMenuItem(
        icon: Icons.assessment_rounded,
        title: 'Rapports'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ActivityReportsScreen())),
        keywords: ['rapport', 'rapports', 'activité', 'activite', 'période', 'periode', 'bilan', 'export', 'pdf'],
      ),
      // 8. Entreprise & équipe
      _OriginalMenuItem(
        icon: Icons.corporate_fare_rounded,
        title: 'Entreprise & équipe'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CompanyAndTeamScreen())),
        keywords: ['entreprise', 'équipe', 'equipe', 'employé', 'employe', 'utilisateur', 'rôle', 'role', 'société'],
      ),
      // 8. Préférences
      _OriginalMenuItem(
        icon: Icons.tune_rounded,
        title: 'Préférences'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PreferencesScreen())),
        keywords: ['préférence', 'preference', 'préférences', 'preferences', 'paramètre', 'parametre', 'configuration'],
      ),
      // 9. Langue de l'application
      _OriginalMenuItem(
        icon: Icons.translate_rounded,
        title: "Langue de l'application".tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LanguageScreen())),
        keywords: ['langue', 'langues', 'application', 'français', 'francais', 'anglais', 'english', 'swahili'],
      ),
      // 10. Assistant Bricelo
      _OriginalMenuItem(
        icon: Icons.auto_awesome_rounded,
        title: 'Assistant Bricelo'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen())),
        keywords: ['assistant', 'bricelo', 'ia', 'ai', 'robot', 'aide', 'conseil'],
      ),
      // 11. Centre d'aide
      _OriginalMenuItem(
        icon: Icons.support_agent_rounded,
        title: "Centre d'aide".tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
        keywords: ['centre', 'aide', 'support', 'contact', 'faq', 'guide', 'tutoriel'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2E);

    final allItems = _getOriginalItems();
    final isSearching = _query.isNotEmpty;
    final filteredItems = isSearching
        ? allItems.where((item) {
            final q = _query.toLowerCase();
            final matchTitle = item.title.toLowerCase().contains(q);
            final matchKw = item.keywords.any((k) => k.toLowerCase().contains(q));
            return matchTitle || matchKw;
          }).toList()
        : allItems;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Plus d'options".tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            // ==========================================
            // 0. BARRE DE RECHERCHE RAPIDE
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D1B2E).withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: textColor, fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Rechercher dans le menu'.tr,
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                              _query = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
              ),
            ),
            const SizedBox(height: 16),

            // ==========================================
            // 1. CARTE PROFIL UTILISATEUR (Mon compte)
            // ==========================================
            if (!isSearching) ...[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyAccountScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D1B2E).withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.6), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/hum.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.primaryNavy,
                            child: Center(
                              child: Text(
                                appState.userInitials,
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    appState.displayUserName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.4 : 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 1),
                                  ),
                                  child: Text(
                                    'Propriétaire'.tr,
                                    style: TextStyle(
                                      color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appState.userEmail.isNotEmpty ? appState.userEmail : appState.displayCompanyName,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 12.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ==========================================
              // 2. BANNIÈRE E-MAIL NON VÉRIFIÉ
              // ==========================================
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D1616) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF5A2323) : const Color(0xFFFECACA), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mail_outline_rounded, color: AppTheme.danger, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'E-mail non vérifié'.tr,
                              style: const TextStyle(
                                color: AppTheme.danger,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sécurisez votre compte — touchez pour vérifier'.tr,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'À vérifier'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ==========================================
            // 3. LES 11 FONCTIONNALITÉS D'ORIGINE RANGÉES SANS CATÉGORIES
            //    (Design 2 colonnes aux couleurs Bricelo uniquement)
            // ==========================================
            if (isSearching && filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 42,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Aucune option trouvée pour "$_query"'.tr,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 13.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.22,
                ),
                itemBuilder: (context, index) {
                  return _buildFeatureCard(
                    item: filteredItems[index],
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    isDark: isDark,
                    textColor: textColor,
                  );
                },
              ),

            const SizedBox(height: 18),

            // ==========================================
            // 4. CARTE DU BAS : THÈME SOMBRE + SE DÉCONNECTER
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D1B2E).withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Ligne Thème Sombre
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F1A28) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                            color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Thème sombre'.tr,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: isDark,
                          onChanged: (val) {
                            appState.toggleDarkMode(val);
                          },
                          activeThumbColor: AppTheme.accentGold,
                          activeTrackColor: AppTheme.primaryNavy,
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 74,
                    color: isDark ? const Color(0xFF1E3352) : const Color(0xFFF1F5F9),
                  ),

                  // Ligne Se Déconnecter
                  InkWell(
                    onTap: () => _confirmLogout(context),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF451A1A) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFDC2626),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Se déconnecter'.tr,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                            size: 22,
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
    );
  }

  Widget _buildFeatureCard({
    required _OriginalMenuItem item,
    required Color cardBg,
    required Color cardBorder,
    required bool isDark,
    required Color textColor,
  }) {
    final iconBoxBg = isDark ? const Color(0xFF0F1A28) : const Color(0xFFF1F5F9);
    final iconColor = isDark ? AppTheme.accentGold : AppTheme.primaryNavy;
    final iconBorderColor = isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B2E).withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => item.onTap(context),
          borderRadius: BorderRadius.circular(13),
          splashColor: iconColor.withValues(alpha: 0.12),
          highlightColor: iconColor.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBoxBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: iconBorderColor, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          item.icon,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                    ),
                    if (item.badge != null)
                      Positioned(
                        top: -6,
                        right: -18,
                        child: item.badge!,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Se déconnecter'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr, style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await appState.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Se déconnecter'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
