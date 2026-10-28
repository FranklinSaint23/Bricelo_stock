import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';

class SupplierDebtsScreen extends StatelessWidget {
  const SupplierDebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final totalDebt = appState.totalSupplierDebt;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: StockAppBar.forestGreen(
            title: 'Dettes fournisseurs',
            onBack: () => Navigator.pop(context),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // 1. CARTE DU TOTAL DÛ AUX FOURNISSEURS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.description_outlined, color: Color(0xFFC2410C), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Total dû aux fournisseurs',
                          style: TextStyle(
                            color: Color(0xFFC2410C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppTheme.formatFCFA(totalDebt),
                      style: const TextStyle(
                        color: Color(0xFFEA580C),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. SOUS-TITRE PAR FOURNISSEUR
              const Text(
                'Par fournisseur',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),

              // 3. ÉTAT VIDE
              const Text(
                'Aucune dette fournisseur.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 12),

              // 4. NOTE EN BAS DE PAGE
              const Text(
                'Le montant affiché par fournisseur déduit les acomptes versés non encore imputés.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, height: 1.3),
              ),
            ],
          ),
          bottomNavigationBar: StockBottomBar(
            currentIndex: 4,
            onTap: (_) => Navigator.pop(context),
          ),
        );
      },
    );
  }
}
