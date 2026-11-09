import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class PromotionAndShopScreen extends StatelessWidget {
  const PromotionAndShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);
        final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
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
              'Promotion & boutique'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      Icons.local_offer_outlined,
                      'Promotions'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PromotionsScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      Icons.campaign_outlined,
                      'Catalogues à partager'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogShareScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      Icons.storefront_outlined,
                      'Boutique en ligne'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineShopScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      Icons.shopping_cart_outlined,
                      'Commandes en ligne'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineOrdersScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      Icons.assignment_outlined,
                      'Commande externe'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExternalOrderScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      Icons.movie_creation_outlined,
                      'Studio vidéo'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoStudioScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      Icons.chat_bubble_outline,
                      'Catalogue WhatsApp & Facebook'.tr,
                      isLocked: false,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogShareScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(
    IconData icon,
    String title, {
    required bool isLocked,
    required Color textPrimary,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
