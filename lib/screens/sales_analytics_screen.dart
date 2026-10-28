import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  String _selectedPeriod = '7 jours'; // 'Aujour...', '7 jours', '30 jours', 'Perso...'

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        leading: TextButton.icon(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
          label: const Text('Plus', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 80,
        title: const Text('Analyse des ventes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SÉLECTEUR DE BOUTIQUE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.storefront, color: AppTheme.primaryNavy, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Toutes les boutiques', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. SÉLECTEUR DE PÉRIODE (Screenshot 4)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildPeriodSegment('Aujour...'),
                  _buildPeriodSegment('7 jours'),
                  _buildPeriodSegment('30 jours'),
                  _buildPeriodSegment('Perso...'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. GRILLE DE 4 CARTES KPI (Screenshot 4)
            Row(
              children: [
                Expanded(child: _buildKpiBox('Chiffre d\'affaires', '720 845 F', AppTheme.primaryNavy)),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiBox('Nombre de ventes', '15', const Color(0xFF111827))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildKpiBox('Panier moyen', '48 056 F', const Color(0xFF111827))),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiBox('Bénéfice net', '77 520 F', AppTheme.success)),
              ],
            ),
            const SizedBox(height: 20),

            // 4. GRAPHIQUE ÉVOLUTION DU CHIFFRE D'AFFAIRES (Screenshot 4)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evolution du chiffre d\'affaires',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 24),

                  // Histogramme vertical stylisé Bricélo
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Axe Y
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('400K', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                            Text('300K', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                            Text('200K', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                            Text('100K', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                            Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Barres
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar('02-16', 30),
                              _buildBar('02-19', 10),
                              _buildBar('02-20', 160, isPeak: true),
                              _buildBar('02-21', 110),
                              _buildBar('02-22', 0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. PRODUITS LES PLUS VENDUS
            const Text(
              'Produits les plus vendus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: appState.products.take(3).map((p) {
                  return ListTile(
                    leading: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('Réf: ${p.barcode}', style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      AppTheme.formatFCFA(p.sellPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSegment(String period) {
    final isSel = _selectedPeriod == period;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? AppTheme.goldLight : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              period,
              style: TextStyle(
                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

  Widget _buildBar(String date, double height, {bool isPeak = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 38,
          height: height,
          decoration: BoxDecoration(
            color: isPeak ? AppTheme.primaryNavy : const Color(0xFF1E3052),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 6),
        Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
      ],
    );
  }
}
