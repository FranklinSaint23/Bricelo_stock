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
  final String category;
  final Color pastelLight;
  final Color pastelDark;
  final Color iconLight;
  final Color iconDark;
  final void Function(BuildContext context) onTap;
  final Widget? badge;
  final List<String> keywords;

  const _OriginalMenuItem({
    required this.icon,
    required this.title,
    required this.category,
    required this.pastelLight,
    required this.pastelDark,
    required this.iconLight,
    required this.iconDark,
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
      // 1. Ventes & clients (Icons.receipt_long_outlined -> SalesAndCustomersScreen)
      _OriginalMenuItem(
        icon: Icons.receipt_long_outlined,
        title: 'Ventes & clients'.tr,
        category: 'ACTIVITÉS',
        pastelLight: const Color(0xFFEFF6FF),
        pastelDark: const Color(0xFF1E3A5F),
        iconLight: const Color(0xFF2563EB),
        iconDark: const Color(0xFF60A5FA),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const SalesAndCustomersScreen())),
        keywords: ['vente', 'ventes', 'client', 'clients', 'devis', 'facture', 'pos', 'commande'],
      ),
      // 2. Promotion & boutique (Icons.campaign_outlined -> PromotionAndShopScreen)
      _OriginalMenuItem(
        icon: Icons.campaign_outlined,
        title: 'Promotion & boutique'.tr,
        category: 'ACTIVITÉS',
        pastelLight: const Color(0xFFFFEDD5),
        pastelDark: const Color(0xFF432010),
        iconLight: const Color(0xFFEA580C),
        iconDark: const Color(0xFFFB923C),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PromotionAndShopScreen())),
        keywords: ['promotion', 'boutique', 'shop', 'remise', 'catalogue', 'promo', 'commande', 'commandes en ligne', 'boutique en ligne', 'studio video', 'studio vidéo', 'video', 'vidéo'],
      ),
      // 3. Stock (Icons.warehouse_outlined -> StockSubMenuScreen)
      _OriginalMenuItem(
        icon: Icons.warehouse_outlined,
        title: 'Stock'.tr,
        category: 'ACTIVITÉS',
        pastelLight: const Color(0xFFFEF3C7),
        pastelDark: const Color(0xFF3D2E14),
        iconLight: const Color(0xFFD97706),
        iconDark: const Color(0xFFFBBF24),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const StockSubMenuScreen())),
        keywords: ['stock', 'stocks', 'article', 'articles', 'produit', 'produits', 'inventaire'],
      ),
      // 4. Achats & dépenses (Icons.shopping_cart_outlined -> PurchasesAndExpensesScreen)
      _OriginalMenuItem(
        icon: Icons.shopping_cart_outlined,
        title: 'Achats & dépenses'.tr,
        category: 'ACTIVITÉS',
        pastelLight: const Color(0xFFF3E8FF),
        pastelDark: const Color(0xFF341A4E),
        iconLight: const Color(0xFF9333EA),
        iconDark: const Color(0xFFC084FC),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PurchasesAndExpensesScreen())),
        keywords: ['achat', 'achats', 'dépense', 'depense', 'dépenses', 'fournisseur', 'fournisseurs', 'charge', 'bon d\'achat', 'bons d\'achat', 'dette fournisseur', 'dettes fournisseurs'],
      ),

      // 5. Pertes & dépréciations (Icons.trending_down_outlined -> DepreciationReportScreen)
      _OriginalMenuItem(
        icon: Icons.trending_down_outlined,
        title: 'Pertes & dépréciations'.tr,
        category: 'SUIVI',
        pastelLight: const Color(0xFFFEE2E2),
        pastelDark: const Color(0xFF451A1A),
        iconLight: const Color(0xFFDC2626),
        iconDark: const Color(0xFFF87171),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const DepreciationReportScreen())),
        keywords: ['perte', 'pertes', 'dépréciation', 'depreciation', 'casse', 'avarie', 'rapport'],
      ),
      // 6. Comptabilité & trésorerie (Icons.menu_book_outlined -> AccountingScreen)
      _OriginalMenuItem(
        icon: Icons.menu_book_outlined,
        title: 'Comptabilité & trésorerie'.tr,
        category: 'SUIVI',
        pastelLight: const Color(0xFFDCFCE7),
        pastelDark: const Color(0xFF143823),
        iconLight: const Color(0xFF16A34A),
        iconDark: const Color(0xFF4ADE80),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AccountingScreen())),
        keywords: ['comptabilité', 'comptabilite', 'trésorerie', 'tresorerie', 'banque', 'caisse', 'finance', 'bilan'],
      ),

      // 7. Entreprise & équipe (Icons.badge_outlined -> CompanyAndTeamScreen, badge À compléter)
      _OriginalMenuItem(
        icon: Icons.badge_outlined,
        title: 'Entreprise & équipe'.tr,
        category: 'ADMINISTRATION',
        pastelLight: const Color(0xFFE0E7FF),
        pastelDark: const Color(0xFF1F2253),
        iconLight: const Color(0xFF4F46E5),
        iconDark: const Color(0xFF818CF8),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CompanyAndTeamScreen())),
        badge: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.badgeOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'À compléter'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
          ),
        ),
        keywords: ['entreprise', 'équipe', 'equipe', 'employé', 'employe', 'utilisateur', 'rôle', 'role', 'société'],
      ),
      // 8. Préférences (Icons.settings_outlined -> PreferencesScreen)
      _OriginalMenuItem(
        icon: Icons.settings_outlined,
        title: 'Préférences'.tr,
        category: 'ADMINISTRATION',
        pastelLight: const Color(0xFFF1F5F9),
        pastelDark: const Color(0xFF1E293B),
        iconLight: const Color(0xFF475569),
        iconDark: const Color(0xFF94A3B8),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PreferencesScreen())),
        keywords: ['préférence', 'preference', 'préférences', 'preferences', 'paramètre', 'parametre', 'configuration'],
      ),
      // 9. Langue de l'application (Icons.language_outlined -> LanguageScreen)
      _OriginalMenuItem(
        icon: Icons.language_outlined,
        title: 'Langue de l\'application'.tr,
        category: 'ADMINISTRATION',
        pastelLight: const Color(0xFFCCFBF1),
        pastelDark: const Color(0xFF133835),
        iconLight: const Color(0xFF0D9488),
        iconDark: const Color(0xFF2DD4BF),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LanguageScreen())),
        keywords: ['langue', 'langues', 'application', 'français', 'francais', 'anglais', 'english', 'swahili'],
      ),

      // 10. Assistant Bricelo (Icons.smart_toy_outlined -> BriceloAssistantScreen)
      _OriginalMenuItem(
        icon: Icons.smart_toy_outlined,
        title: 'Assistant Bricelo'.tr,
        category: 'ASSISTANCE',
        pastelLight: const Color(0xFFFDF4FF),
        pastelDark: const Color(0xFF3F1545),
        iconLight: const Color(0xFFC026D3),
        iconDark: const Color(0xFFE879F9),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen())),
        keywords: ['assistant', 'bricelo', 'ia', 'ai', 'robot', 'aide', 'conseil'],
      ),
      // 11. Centre d'aide (Icons.help_outline -> _showHelpDialog)
      _OriginalMenuItem(
        icon: Icons.help_outline,
        title: 'Centre d\'aide'.tr,
        category: 'ASSISTANCE',
        pastelLight: const Color(0xFFFEF9C3),
        pastelDark: const Color(0xFF3B3310),
        iconLight: const Color(0xFFCA8A04),
        iconDark: const Color(0xFFFACC15),
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
        keywords: ['centre', 'aide', 'support', 'contact', 'faq', 'guide', 'tutoriel'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFEAF2FA);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final allItems = _getOriginalItems();
    final isSearching = _query.isNotEmpty;
    final filteredItems = isSearching
        ? allItems.where((item) {
            final q = _query.toLowerCase();
            final matchTitle = item.title.toLowerCase().contains(q);
            final matchCat = item.category.toLowerCase().contains(q);
            final matchKw = item.keywords.any((k) => k.toLowerCase().contains(q));
            return matchTitle || matchCat || matchKw;
          }).toList()
        : allItems;

    // Regroupement par catégorie
    final activitiesItems = allItems.where((item) => item.category == 'ACTIVITÉS').toList();
    final trackingItems = allItems.where((item) => item.category == 'SUIVI').toList();
    final adminItems = allItems.where((item) => item.category == 'ADMINISTRATION').toList();
    final assistanceItems = allItems.where((item) => item.category == 'ASSISTANCE').toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Plus d\'options'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            // ==========================================
            // 0. BARRE DE RECHERCHE RAPIDE (Tout au-dessus)
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
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
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyAccountScreen()),
                );
              },
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cardBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar circulaire avec photo (assets/images/hum.jpg)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 1.5),
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
                          child: const Center(
                            child: Text(
                              'FS',
                              style: TextStyle(
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

                    // Nom + Badge "Propriétaire" + Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Franklin SAINT',
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
                                  color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Propriétaire'.tr,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'franklin@gmail.com',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 12,
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
            const SizedBox(height: 16),

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
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D1616) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
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

            // ==========================================
            // 3. FONCTIONNALITÉS REGROUPÉES PAR CATÉGORIES (Fidèle à l'image du client)
            // ==========================================
            if (isSearching)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cardBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildSearchResults(filteredItems, isDark, textColor),
              )
            else ...[
              // CATÉGORIE 1 : ACTIVITÉS (Ventes & clients, Promotion & boutique, Stock, Achats & dépenses)
              _buildCategoryCard(
                title: 'ACTIVITÉS'.tr,
                items: activitiesItems,
                cardBg: cardBg,
                cardBorder: cardBorder,
                isDark: isDark,
                textColor: textColor,
              ),
              const SizedBox(height: 16),

              // CATÉGORIE 2 : SUIVI (Pertes & dépréciations, Comptabilité & trésorerie)
              _buildCategoryCard(
                title: 'SUIVI'.tr,
                items: trackingItems,
                cardBg: cardBg,
                cardBorder: cardBorder,
                isDark: isDark,
                textColor: textColor,
              ),
              const SizedBox(height: 16),

              // CATÉGORIE 3 : ADMINISTRATION (Entreprise & équipe, Préférences, Langue de l'application)
              _buildCategoryCard(
                title: 'ADMINISTRATION'.tr,
                items: adminItems,
                cardBg: cardBg,
                cardBorder: cardBorder,
                isDark: isDark,
                textColor: textColor,
              ),
              const SizedBox(height: 16),

              // CATÉGORIE 4 : ASSISTANCE (Assistant Bricelo, Centre d'aide)
              _buildCategoryCard(
                title: 'ASSISTANCE'.tr,
                items: assistanceItems,
                cardBg: cardBg,
                cardBorder: cardBorder,
                isDark: isDark,
                textColor: textColor,
              ),
            ],
            const SizedBox(height: 16),

            // ==========================================
            // 4. CARTE DU BAS : THÈME SOMBRE + DÉCONNEXION (Fidèle à l'Image 3)
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
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
                            color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                            color: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7),
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
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF451A1A) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(14),
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

  // Widget de catégorie respectant le style de l'image de référence
  Widget _buildCategoryCard({
    required String title,
    required List<_OriginalMenuItem> items,
    required Color cardBg,
    required Color cardBorder,
    required bool isDark,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la catégorie en majuscule grise élégante
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Grille responsive 4 colonnes via Expanded : zÃ©ro dÃ©bordement quel que soit l'Ã©cran
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: i < items.length
                      ? _buildSquircleWidget(items[i], isDark, textColor)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Squircle pastel individuel adaptatif sans largeur fixe pour Ã©viter tout dÃ©bordement
  Widget _buildSquircleWidget(_OriginalMenuItem item, bool isDark, Color textColor) {
    final pastelColor = isDark ? item.pastelDark : item.pastelLight;
    final iconColor = isDark ? item.iconDark : item.iconLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: pastelColor,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => item.onTap(context),
                borderRadius: BorderRadius.circular(18),
                splashColor: iconColor.withValues(alpha: 0.18),
                highlightColor: iconColor.withValues(alpha: 0.08),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            if (item.badge != null)
              Positioned(
                top: -5,
                right: -8,
                child: item.badge!,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            item.title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Affichage des résultats lors d'une recherche
  Widget _buildSearchResults(List<_OriginalMenuItem> matches, bool isDark, Color textColor) {
    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 38,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 8),
              Text(
                'Aucune option trouvée pour "$_query"'.tr,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            '${matches.length} résultat(s) trouvé(s)'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
            ),
          ),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: matches.map((item) => SizedBox(width: 68, child: _buildSquircleWidget(item, isDark, textColor))).toList(),
        ),
      ],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
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
