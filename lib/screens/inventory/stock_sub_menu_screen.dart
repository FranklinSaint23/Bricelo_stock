import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';

class StockSubMenuScreen extends StatelessWidget {
  const StockSubMenuScreen({super.key});

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
          'Stock',
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
                _buildRow(
                  icon: Icons.archive_outlined,
                  title: 'Approvisionnement',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Dépréciation de stock',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.bar_chart_outlined,
                  title: 'Rapport de dépréciations',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.assignment_outlined,
                  title: 'Inventaires',
                  isLocked: true,
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.tune_outlined,
                  title: 'Ajustement de stock',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ajustement physique de stock')),
                    );
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.sync_alt,
                  title: 'Transferts de stock',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfert entre boutiques')),
                    );
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.qr_code_scanner,
                  title: 'Trouver une unité',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FindUnitScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.event_note_outlined,
                  title: 'Suivi de péremption',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiryTrackingScreen()));
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
    bool isLocked = false,
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
