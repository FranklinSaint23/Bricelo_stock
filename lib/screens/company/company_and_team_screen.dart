import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';

class CompanyAndTeamScreen extends StatelessWidget {
  const CompanyAndTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final isWebPortal = kIsWeb || MediaQuery.of(context).size.width >= 800;
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);
        final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
        final dividerCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFF3F4F6);

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
            ),
            title: Text(
              'Entreprise & Équipe'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // SECTION 1: POUR COMMENCER
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Pour commencer'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      icon: Icons.business_center_rounded,
                      title: 'Profil de l\'entreprise'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyProfileScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.auto_awesome_motion_rounded,
                      title: 'Ma marque'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.credit_card_rounded,
                      title: 'Moyens de paiement'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.receipt_long_rounded,
                      title: 'Personnalisation des factures'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceCustomizationScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.restart_alt_rounded,
                      title: 'Repartir à zéro'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetDataScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 2: PARAMETRES
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Paramètres'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      icon: Icons.verified_user_rounded,
                      title: 'Approbations'.tr,
                      badge: appState.pendingApprovalsCount > 0 ? '${appState.pendingApprovalsCount}' : null,
                      badgeColor: const Color(0xFFDC2626),
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.group_rounded,
                      title: 'Équipe'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Groupes d\'accès'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessGroupsScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.storefront_rounded,
                      title: 'Boutiques & Entrepots'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OutletsScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.category_rounded,
                      title: 'Categories'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.history_toggle_off_rounded,
                      title: 'Historique d\'activité'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 3: CAISSE / SHIFTS
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Caisse / Shifts'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      icon: Icons.point_of_sale_rounded,
                      title: 'Caisses'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CashDesksScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      icon: Icons.punch_clock_rounded,
                      title: 'Suivi des shifts & Activités'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftsTrackingScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    required Color textPrimary,
    required bool isDark,
    String? badge,
    Color? badgeColor,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDark ? AppTheme.accentGold : const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, indent: 52, color: color);
  }
}
