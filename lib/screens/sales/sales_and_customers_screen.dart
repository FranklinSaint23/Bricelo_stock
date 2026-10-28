import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';

class SalesAndCustomersScreen extends StatelessWidget {
  const SalesAndCustomersScreen({super.key});

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
        title: const Text(
          'Ventes & clients',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Ventes',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(
                  icon: Icons.receipt_long,
                  title: 'Historique des ventes',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
                  },
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6)),
                _buildRow(
                  icon: Icons.description_outlined,
                  title: 'Devis',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotesScreen()));
                  },
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6)),
                _buildRow(
                  icon: Icons.bar_chart_outlined,
                  title: 'Analyse des ventes',
                  trailingIcon: Icons.lock_outline,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesAnalyticsScreen()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Clients',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(
                  icon: Icons.people_outline,
                  title: 'Clients',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
                  },
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6)),
                _buildRow(
                  icon: Icons.payments_outlined,
                  title: 'Recouvrement des dettes',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    IconData trailingIcon = Icons.chevron_right,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Icon(trailingIcon, size: 20, color: const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
