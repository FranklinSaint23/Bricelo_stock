import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';

class PurchasesAndExpensesScreen extends StatelessWidget {
  const PurchasesAndExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
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
          'Achats & dépenses'.tr,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(Icons.domain_rounded, 'Fournisseurs'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.receipt_long_rounded, 'Bons d\'achat'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseOrdersScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.price_change_rounded, 'Dépenses'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.insights_rounded, 'Analyse des sorties'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesAnalyticsScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.request_quote_rounded, 'Coût d\'achat'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseCostsScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.credit_card_off_rounded, 'Dettes fournisseurs'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierDebtsScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String title, {
    required bool isLocked,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
              ),
            ),
            if (badgeText != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.goldBorder),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.gold600),
                ),
              ),
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              size: 20,
              color: isLocked ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6));
  }
}
