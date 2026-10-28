import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.book_outlined, 'title': 'Journal & activation'},
      {'icon': Icons.balance_outlined, 'title': 'Balance'},
      {'icon': Icons.people_outline, 'title': 'Clients à crédit'},
      {'icon': Icons.bar_chart_outlined, 'title': 'Compte de résultat'},
      {'icon': Icons.description_outlined, 'title': 'Bilan'},
      {'icon': Icons.receipt_outlined, 'title': 'TVA'},
      {'icon': Icons.badge_outlined, 'title': 'Paie'},
      {'icon': Icons.apartment_outlined, 'title': 'Immobilisations'},
      {'icon': Icons.event_available_outlined, 'title': 'Clôture'},
      {'icon': Icons.photo_library_outlined, 'title': 'Médiathèque'},
    ];

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
          'Comptabilité & trésorerie',
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
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6)),
                  _buildLockedRow(items[i]['icon'] as IconData, items[i]['title'] as String),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedRow(IconData icon, String title) {
    return InkWell(
      onTap: () {},
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
            const Icon(Icons.lock_outline, size: 20, color: Color(0xFF374151)),
          ],
        ),
      ),
    );
  }
}
