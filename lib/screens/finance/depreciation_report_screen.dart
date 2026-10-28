import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class DepreciationReportScreen extends StatefulWidget {
  const DepreciationReportScreen({super.key});

  @override
  State<DepreciationReportScreen> createState() => _DepreciationReportScreenState();
}

class _DepreciationReportScreenState extends State<DepreciationReportScreen> {
  String _selectedFilter = '30j';

  final List<String> _filters = ['7j', '30j', '90j', '12m', 'Tout'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('Plus', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        leadingWidth: 70,
        title: const Text(
          'Rapport depreciations',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PILULES DE PERIODE
            Row(
              children: [
                for (final f in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = f),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedFilter == f ? const Color(0xFFFEF3C7) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedFilter == f ? const Color(0xFFF5B000) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedFilter == f) ...[
                              const Icon(Icons.check, size: 14, color: Color(0xFF92400E)),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              f,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedFilter == f ? FontWeight.bold : FontWeight.w500,
                                color: _selectedFilter == f ? const Color(0xFF92400E) : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _selectedFilter = 'Personnalise'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedFilter == 'Personnalise' ? const Color(0xFFFEF3C7) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedFilter == 'Personnalise' ? const Color(0xFFF5B000) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  'Personnalise',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: _selectedFilter == 'Personnalise' ? FontWeight.bold : FontWeight.w500,
                    color: _selectedFilter == 'Personnalise' ? const Color(0xFF92400E) : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4 CARTES KPI (2x2)
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Quantite totale',
                    value: '15',
                    titleColor: const Color(0xFFC2410C),
                    valueColor: const Color(0xFFEA580C),
                    bgColor: const Color(0xFFFFF7ED),
                    borderColor: const Color(0xFFFFEDD5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Perte totale',
                    value: '26 000 F',
                    titleColor: const Color(0xFFB91C1C),
                    valueColor: const Color(0xFFDC2626),
                    bgColor: const Color(0xFFFEF2F2),
                    borderColor: const Color(0xFFFEE2E2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Nb de depreciations',
                    value: '2',
                    titleColor: const Color(0xFF1D4ED8),
                    valueColor: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFDBEAFE),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Perte moyenne',
                    value: '13 000 F',
                    titleColor: const Color(0xFF7E22CE),
                    valueColor: const Color(0xFF9333EA),
                    bgColor: const Color(0xFFFAF5FF),
                    borderColor: const Color(0xFFF3E8FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECTION PAR RAISON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Par raison',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9333EA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Perte',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                      ),
                      const Spacer(),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '26 000 F',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                          ),
                          Text(
                            '15 unites',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION PRODUITS LES PLUS DEPRECIES
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produits les plus deprecies',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),
                  _buildDepreciatedItem(
                    index: 1,
                    name: 'Lait',
                    units: '5 unites',
                    amount: '18 750 F',
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildDepreciatedItem(
                    index: 2,
                    name: 'Assieted',
                    units: '10 unites',
                    amount: '7 250 F',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color titleColor,
    required Color valueColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDepreciatedItem({
    required int index,
    required String name,
    required String units,
    required String amount,
  }) {
    return Row(
      children: [
        Text(
          index.toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 2),
            Text(
              units,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFDC2626)),
        ),
      ],
    );
  }
}
