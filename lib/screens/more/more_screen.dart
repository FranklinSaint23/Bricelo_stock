import 'package:stock_prime/screens/auth/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/auth/login_screen.dart';
import 'package:stock_prime/screens/company/company_and_team_screen.dart';
import 'package:stock_prime/screens/company/language_screen.dart';
import 'package:stock_prime/screens/company/preferences_screen.dart';
import 'package:stock_prime/screens/dashboard/bricelo_assistant_screen.dart';
import 'package:stock_prime/screens/finance/accounting_screen.dart';
import 'package:stock_prime/screens/finance/depreciation_report_screen.dart';
import 'package:stock_prime/screens/finance/promotion_and_shop_screen.dart';
import 'package:stock_prime/screens/finance/purchases_and_expenses_screen.dart';
import 'package:stock_prime/screens/inventory/stock_sub_menu_screen.dart';
import 'package:stock_prime/screens/sales/sales_and_customers_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final appState = AppState.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFEAF2FA);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

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
            // 1. CARTE PROFIL UTILISATEUR (Fidèle à l'Image 1)
            // ==========================================
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompanyAndTeamScreen()),
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
                    // Avatar circulaire avec photo
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
                              'DB',
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
                              Text(
                                'Franklin SAINT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Badge Rôle "Propriétaire" (Pastel bleu doux comme l'Image 1)
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

                    // Chevron droit
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
            // 2. BANNIÈRE E-MAIL NON VÉRIFIÉ (Navigation vers VerifyEmailScreen)
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
            // 3. GRILLE DES FONCTIONNALITÉS EN SQUIRCLES PASTELS (Fidèle à l'Image 2)
            // ==========================================
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
              child: Column(
                children: [
                  // Ligne 1 : Ventes, Stock, Achats, Boutique
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSquircleItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Ventes'.tr,
                        pastelColor: const Color(0xFFF3E8FF), // Pastel Violet / Lavande
                        iconColor: const Color(0xFF9333EA),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesAndCustomersScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.warehouse_outlined,
                        label: 'Stock'.tr,
                        pastelColor: const Color(0xFFE0F2FE), // Pastel Bleu Ciel
                        iconColor: const Color(0xFF0284C7),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockSubMenuScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Achats'.tr,
                        pastelColor: const Color(0xFFE6F4EA), // Pastel Menthe Doux
                        iconColor: const Color(0xFF137333),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesAndExpensesScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.storefront_outlined,
                        label: 'Boutique'.tr,
                        pastelColor: const Color(0xFFFCE7F3), // Pastel Rose / Framboise
                        iconColor: const Color(0xFFDB2777),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromotionAndShopScreen())),
                        textColor: textColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Ligne 2 : Comptabilité, Pertes, Assistant IA, Équipe
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSquircleItem(
                        icon: Icons.pie_chart_outline_rounded,
                        label: 'Comptabilité'.tr,
                        pastelColor: const Color(0xFFCCFBF1), // Pastel Turquoise
                        iconColor: const Color(0xFF0F766E),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountingScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.trending_down_rounded,
                        label: 'Pertes'.tr,
                        pastelColor: const Color(0xFFFFEDD5), // Pastel Pêche
                        iconColor: const Color(0xFFEA580C),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.smart_toy_outlined,
                        label: 'Bricelo IA'.tr,
                        pastelColor: const Color(0xFFFEF9C3), // Pastel Or Bricelo
                        iconColor: const Color(0xFFB45309),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BriceloAssistantScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.people_outline_rounded,
                        label: 'Équipe'.tr,
                        pastelColor: const Color(0xFFE0E7FF), // Pastel Indigo
                        iconColor: const Color(0xFF4F46E5),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyAndTeamScreen())),
                        textColor: textColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Ligne 3 : Préférences, Langue, Centre d'aide, Rapports
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSquircleItem(
                        icon: Icons.tune_rounded,
                        label: 'Préférences'.tr,
                        pastelColor: const Color(0xFFF1F5F9), // Pastel Ardoise
                        iconColor: const Color(0xFF475569),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.translate_rounded,
                        label: 'Langue'.tr,
                        pastelColor: const Color(0xFFEDE9FE), // Pastel Iris
                        iconColor: const Color(0xFF7C3AED),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Assistance'.tr,
                        pastelColor: const Color(0xFFE0F2FE), // Pastel Ciel
                        iconColor: const Color(0xFF0284C7),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              title: Row(
                                children: [
                                  const Icon(Icons.support_agent_rounded, color: AppTheme.primaryNavy),
                                  const SizedBox(width: 8),
                                  Text('Assistance Bricelo'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              content: Text(
                                'Support vendeur Bricelo disponible au Cameroun via WhatsApp.'.tr,
                                style: const TextStyle(fontSize: 13, height: 1.4),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Fermer'.tr, style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        textColor: textColor,
                      ),
                      _buildSquircleItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Clients'.tr,
                        pastelColor: const Color(0xFFDCFCE7), // Pastel Émeraude clair
                        iconColor: const Color(0xFF15803D),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesAndCustomersScreen())),
                        textColor: textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==========================================
            // 3. CARTE DU BAS : THÈME SOMBRE + DÉCONNEXION (Fidèle à l'Image 3)
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
                  // Ligne Thème Sombre avec Switch toggle (Image 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Squircle pastel bleu pour l'icône du thème
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
                        // Switch interactif qui inverse immédiatement le thème de toute l'application
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

                  // Séparateur fin
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 74,
                    color: isDark ? const Color(0xFF1E3352) : const Color(0xFFF1F5F9),
                  ),

                  // Ligne Se Déconnecter en rouge (Image 3)
                  InkWell(
                    onTap: () => _confirmLogout(context),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Squircle pastel rouge pour l'icône de déconnexion
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

  // Widget squircle pastel individuel avec label centré en dessous (Image 2)
  Widget _buildSquircleItem({
    required IconData icon,
    required String label,
    required Color pastelColor,
    required Color iconColor,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton Squircle Pastel
          Material(
            color: pastelColor,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: iconColor.withValues(alpha: 0.18),
              highlightColor: iconColor.withValues(alpha: 0.08),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Label centré sous le squircle
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
