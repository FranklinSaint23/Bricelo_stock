import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/inventory/stock_depreciation_screen.dart';

class DepreciationReportScreen extends StatefulWidget {
  const DepreciationReportScreen({super.key});

  @override
  State<DepreciationReportScreen> createState() => _DepreciationReportScreenState();
}

class _DepreciationReportScreenState extends State<DepreciationReportScreen> {
  String _selectedPeriod = 'Tous';
  final List<String> _periods = ['7j', '30j', '90j', '12m', 'Tous'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Rapport de dépréciations',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // BARRE DE FILTRES TEMPORELS + BOUTON CALENDRIER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                ..._periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPeriod = period),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFED7AA),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: const Color(0xFFEA580C), width: 1.2)
                              : null,
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                InkWell(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF9CA3AF), width: 1.2),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ÉTAT VIDE CONFORME AU SCREENSHOT
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ICÔNE CARTON AVEC CROIX
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: const [
                          Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 6,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Aucune dépréciation',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aucune perte de stock enregistrée sur cette période.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),

                    // BOUTON + Enregistrer une dépréciation (PÊCHE)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StockDepreciationScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFED7AA),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, size: 18, color: Color(0xFF111827)),
                            SizedBox(width: 8),
                            Text(
                              'Enregistrer une dépréciation',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
}
