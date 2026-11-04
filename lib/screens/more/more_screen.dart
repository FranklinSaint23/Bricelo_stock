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

class _MoreMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String category;
  final void Function(BuildContext context) onTap;
  final bool isSpecial;
  final List<String> keywords;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.onTap,
    this.isSpecial = false,
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

  List<_MoreMenuItem> _getAllItems() {
    return [
      // 1. ACTIVITÉS & OPÉRATIONS
      _MoreMenuItem(
        icon: Icons.receipt_long_rounded,
        title: 'Ventes & clients'.tr,
        subtitle: 'Factures, devis & caisse'.tr,
        category: 'Activités & Ventes'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const SalesAndCustomersScreen())),
        keywords: ['vente', 'ventes', 'client', 'clients', 'devis', 'facture', 'pos', 'commande'],
      ),
      _MoreMenuItem(
        icon: Icons.campaign_rounded,
        title: 'Promotion & boutique'.tr,
        subtitle: 'Boutique en ligne & offres'.tr,
        category: 'Activités & Ventes'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PromotionAndShopScreen())),
        keywords: ['promotion', 'boutique', 'shop', 'remise', 'catalogue', 'promo', 'commande', 'ligne'],
      ),
      _MoreMenuItem(
        icon: Icons.warehouse_rounded,
        title: 'Gestion du Stock'.tr,
        subtitle: 'Articles & inventaire'.tr,
        category: 'Activités & Ventes'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const StockSubMenuScreen())),
        keywords: ['stock', 'stocks', 'article', 'articles', 'produit', 'produits', 'inventaire'],
      ),
      _MoreMenuItem(
        icon: Icons.shopping_cart_rounded,
        title: 'Achats & dépenses'.tr,
        subtitle: 'Fournisseurs & charges'.tr,
        category: 'Activités & Ventes'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PurchasesAndExpensesScreen())),
        keywords: ['achat', 'achats', 'dépense', 'dépenses', 'fournisseur', 'fournisseurs', 'charge'],
      ),

      // 2. FINANCE & COMPTABILITÉ
      _MoreMenuItem(
        icon: Icons.menu_book_rounded,
        title: 'Comptabilité & trésorerie'.tr,
        subtitle: 'Journaux, bilans & caisse'.tr,
        category: 'Finance & Suivi'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AccountingScreen())),
        keywords: ['comptabilité', 'journal', 'bilan', 'trésorerie', 'caisse', 'finance', 'compte'],
      ),
      _MoreMenuItem(
        icon: Icons.trending_down_rounded,
        title: 'Pertes & dépréciations'.tr,
        subtitle: 'Suivi des amortissements'.tr,
        category: 'Finance & Suivi'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const DepreciationReportScreen())),
        keywords: ['perte', 'pertes', 'dépréciation', 'dépréciations', 'amortissement'],
      ),

      // 3. ORGANISATION & ÉQUIPE
      _MoreMenuItem(
        icon: Icons.badge_rounded,
        title: 'Entreprise & équipe'.tr,
        subtitle: 'Collaborateurs & boutiques'.tr,
        category: 'Organisation & Équipe'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CompanyAndTeamScreen())),
        keywords: ['entreprise', 'équipe', 'collaborateur', 'collaborateurs', 'boutique', 'boutiques', 'rôle'],
      ),
      _MoreMenuItem(
        icon: Icons.person_rounded,
        title: 'Mon compte'.tr,
        subtitle: 'Profil, sécurité & accès'.tr,
        category: 'Organisation & Équipe'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const MyAccountScreen())),
        keywords: ['compte', 'profil', 'sécurité', 'mot de passe', 'utilisateur'],
      ),

      // 4. INTELLIGENCE & ASSISTANCE
      _MoreMenuItem(
        icon: Icons.smart_toy_rounded,
        title: 'Assistant IA Bricelo'.tr,
        subtitle: 'Conseils & analyses instantanés'.tr,
        category: 'Assistance & IA'.tr,
        isSpecial: true,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen())),
        keywords: ['assistant', 'ia', 'bricelo', 'aide', 'robot', 'analyse', 'conseil'],
      ),
      _MoreMenuItem(
        icon: Icons.help_outline_rounded,
        title: "Centre d'aide".tr,
        subtitle: 'Guides, FAQ & support'.tr,
        category: 'Assistance & IA'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
        keywords: ['aide', 'faq', 'support', 'guide', 'contact', 'assistance'],
      ),

      // 5. PARAMÈTRES & SYSTÈME
      _MoreMenuItem(
        icon: Icons.tune_rounded,
        title: 'Préférences'.tr,
        subtitle: 'Boutique, reçus & alertes'.tr,
        category: 'Paramètres & Système'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PreferencesScreen())),
        keywords: ['préférence', 'préférences', 'paramètre', 'paramètres', 'configuration', 'reçu', 'alerte'],
      ),
      _MoreMenuItem(
        icon: Icons.language_rounded,
        title: "Langue de l'application".tr,
        subtitle: 'Français / English'.tr,
        category: 'Paramètres & Système'.tr,
        onTap: (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LanguageScreen())),
        keywords: ['langue', 'langues', 'language', 'anglais', 'français', 'traduction'],
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

    final allItems = _getAllItems();
    final isSearching = _query.isNotEmpty;
    final filteredItems = isSearching
        ? allItems.where((item) {
            final q = _query.toLowerCase();
            final matchTitle = item.title.toLowerCase().contains(q);
            final matchSub = item.subtitle.toLowerCase().contains(q);
            final matchCat = item.category.toLowerCase().contains(q);
            final matchKw = item.keywords.any((k) => k.toLowerCase().contains(q));
            return matchTitle || matchSub || matchCat || matchKw;
          }).toList()
        : allItems;

    // Regroupement par catégories ordonnées
    final categories = [
      'Activités & Ventes'.tr,
      'Finance & Suivi'.tr,
      'Organisation & Équipe'.tr,
      'Assistance & IA'.tr,
      'Paramètres & Système'.tr,
    ];

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 0. BARRE DE RECHERCHE RAPIDE (Style Pilule)
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
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
                  hintText: 'Rechercher dans le menu...'.tr,
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
            // 1. CARTE PROFIL UTILISATEUR
            // ==========================================
            if (!isSearching) ...[
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
                        color: const Color(0xFF0D1B2E).withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentGold, width: 2),
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
                              'franklin@gmail.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Alerte e-mail non vérifié
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.mail_outline_rounded, color: Color(0xFFDC2626), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-mail non vérifié'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B)),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Sécurisez votre compte'.tr,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
                        );
                      },
                      child: Text('À vérifier'.tr, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],

            // ==========================================
            // 2. CONTENU PRINCIPAL (Grille 2 colonnes par catégorie)
            // ==========================================
            if (isSearching) ...[
              _buildSearchResults(filteredItems, isDark, cardBg, cardBorder, textColor),
            ] else ...[
              for (final cat in categories) ...[
                Builder(
                  builder: (context) {
                    final catItems = allItems.where((i) => i.category == cat).toList();
                    if (catItems.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de catégorie soigné avec barre dorée Bricelo
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 22, bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Grille 2 colonnes conforme à l'image demandée
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: catItems.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                          ),
                          itemBuilder: (context, index) {
                            return _buildFeatureCard(
                              item: catItems[index],
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              isDark: isDark,
                              textColor: textColor,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],

            const SizedBox(height: 32),

            // ==========================================
            // 3. BOUTON DE DÉCONNEXION
            // ==========================================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.6), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmLogout(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Se déconnecter'.tr,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // CARTE FORMAT GRILLE (Exactement selon le layout de l'image de référence)
  // Couleurs 100% Bricelo : fond blanc/sombre, squircle marine/ardoise/or, texte marine
  // =========================================================================
  Widget _buildFeatureCard({
    required _MoreMenuItem item,
    required Color cardBg,
    required Color cardBorder,
    required bool isDark,
    required Color textColor,
  }) {
    // Teintes sobres Bricelo (pas de multicolore arc-en-ciel)
    final iconBoxBg = item.isSpecial
        ? (isDark ? const Color(0xFF2E2413) : const Color(0xFFFFFBEB))
        : (isDark ? const Color(0xFF0F1A28) : const Color(0xFFF1F5F9));

    final iconColor = item.isSpecial
        ? AppTheme.accentGold
        : (isDark ? const Color(0xFF93C5FD) : AppTheme.primaryNavy);

    final iconBorderColor = item.isSpecial
        ? AppTheme.accentGold.withValues(alpha: 0.5)
        : (isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0));

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isSpecial ? AppTheme.accentGold.withValues(alpha: 0.6) : cardBorder,
          width: item.isSpecial ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B2E).withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => item.onTap(context),
          borderRadius: BorderRadius.circular(24),
          splashColor: iconColor.withValues(alpha: 0.12),
          highlightColor: iconColor.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Squircle Icône centré au sommet (comme sur l'image)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBoxBg,
                        borderRadius: BorderRadius.circular(16),
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
                    if (item.isSpecial)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_rounded, size: 10, color: AppTheme.primaryNavy),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Titre principal en gras centré
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
                const SizedBox(height: 3),

                // Sous-titre descriptif / compteur (style '4 Task' de l'image)
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // RÉSULTATS DE RECHERCHE
  // =========================================================================
  Widget _buildSearchResults(
    List<_MoreMenuItem> matches,
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
  ) {
    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 44,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 10),
              Text(
                'Aucune option trouvée pour "$_query"'.tr,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 14,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${matches.length} résultat(s) trouvé(s)'.tr,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            return _buildFeatureCard(
              item: matches[index],
              cardBg: cardBg,
              cardBorder: cardBorder,
              isDark: isDark,
              textColor: textColor,
            );
          },
        ),
      ],
    );
  }

  // =========================================================================
  // BOÎTE DE DIALOGUE DE DÉCONNEXION
  // =========================================================================
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
