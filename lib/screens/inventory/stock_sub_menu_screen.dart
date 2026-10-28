import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/screens.dart';

class StockSubMenuScreen extends StatelessWidget {
  const StockSubMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: StockAppBar.forestGreen(
        title: 'Stock',
        onBack: () => Navigator.pop(context),
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockDepreciationScreen()));
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.sync_alt,
                  title: 'Transferts de stock',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockTransfersScreen()));
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
      bottomNavigationBar: StockBottomBar(
        currentIndex: 4,
        onTap: (_) => Navigator.pop(context),
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
