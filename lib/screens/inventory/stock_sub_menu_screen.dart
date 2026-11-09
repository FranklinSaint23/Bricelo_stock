import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/services/product_export_service.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/widgets/dialogs/upgrade_dialog.dart';

class StockSubMenuScreen extends StatelessWidget {
  const StockSubMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final isDiscovered = appState.isDiscoveredPlan;
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
              'Stock'.tr,
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
                      context: context,
                      icon: Icons.move_to_inbox_rounded,
                      title: 'Approvisionnement'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: false,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      context: context,
                      icon: Icons.remove_circle_outline_rounded,
                      title: 'Dépréciation de stock'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: isDiscovered,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockDepreciationScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      context: context,
                      icon: Icons.insert_chart_outlined_rounded,
                      title: 'Rapport de dépréciations'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: isDiscovered,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      context: context,
                      icon: Icons.fact_check_rounded,
                      title: 'Inventaires'.tr,
                      isLocked: isDiscovered,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PhysicalInventoryScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      context: context,
                      icon: Icons.tune_rounded,
                      title: 'Ajustement de stock'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: false,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      context: context,
                      icon: Icons.swap_horiz_rounded,
                      title: 'Transferts de stock'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: isDiscovered,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockTransfersScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    // 1. IMPORTER DES PRODUITS (Excel, Word, PDF, CSV)
                    _buildRow(
                      context: context,
                      icon: Icons.upload_file_rounded,
                      title: 'Importer des produits'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: isDiscovered,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportProductsScreen()));
                      },
                    ),
                    _buildDivider(dividerCol),
                    // 2. EXPORTER LA LISTE DES PRODUITS (Excel universel)
                    _buildRow(
                      context: context,
                      icon: Icons.download_rounded,
                      title: 'Exporter la liste des produits'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: isDiscovered,
                      onTap: () => ProductExportService.exportProductsToExcelCsv(context),
                    ),
                    _buildDivider(dividerCol),
                    _buildRow(
                      context: context,
                      icon: Icons.event_busy_rounded,
                      title: 'Suivi de péremption'.tr,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      isLocked: isDiscovered,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiryTrackingScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: StockBottomBar(
              currentIndex: 4,
              onTap: (_) => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color textPrimary,
    required bool isDark,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        if (isLocked) {
          showUpgradeDialog(context, title);
        } else if (onTap != null) {
          onTap();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDark ? AppTheme.accentGold : const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
            Icon(
              isLocked ? Icons.lock_rounded : Icons.chevron_right,
              size: isLocked ? 19 : 20,
              color: isLocked
                  ? const Color(0xFFD97706)
                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
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
