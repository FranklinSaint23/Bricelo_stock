import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';

class SupplierDebtsScreen extends StatefulWidget {
  const SupplierDebtsScreen({super.key});

  @override
  State<SupplierDebtsScreen> createState() => _SupplierDebtsScreenState();
}

class _SupplierDebtsScreenState extends State<SupplierDebtsScreen> {
  final appState = AppState.instance;

  void _showPaymentModal(BuildContext context, SupplierDebt debt) {
    final amountController = TextEditingController(text: debt.remainingDebt.toStringAsFixed(0));
    final isDark = appState.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Régler la dette fournisseur',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.primaryNavy,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Fournisseur : ${debt.supplierName}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reste à payer : ${AppTheme.formatFCFA(debt.remainingDebt)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
                decoration: InputDecoration(
                  labelText: 'Montant versé (FCFA)',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
                  suffixText: 'FCFA',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accentGold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final entered = double.tryParse(amountController.text.trim()) ?? 0;
                    if (entered <= 0) return;
                    appState.recordSupplierPayment(debt.id, entered);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.primaryNavy,
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Paiement de ${AppTheme.formatFCFA(entered)} enregistré pour ${debt.supplierName}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirmer le versement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final totalDebt = appState.totalSupplierDebt;
        final isDark = appState.isDarkMode;
        final activeDebts = appState.supplierDebts.where((d) => !d.isSettled).toList();

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
          appBar: StockAppBar.navy(
            title: 'Dettes fournisseurs',
            onBack: () => Navigator.pop(context),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // 1. CARTE DU TOTAL DÛ AUX FOURNISSEURS
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFFFEDD5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.description_outlined, color: Color(0xFFC2410C), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Total dû aux fournisseurs',
                          style: TextStyle(
                            color: Color(0xFFC2410C),
                            fontSize: 13,
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
                        fontSize: 26,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. SOUS-TITRE PAR FOURNISSEUR
              Text(
                'Par fournisseur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),

              // 3. ÉTAT VIDE OU LISTE DES DETTES
              if (activeDebts.isEmpty) ...[
                Text(
                  'Aucune dette fournisseur.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  height: 1,
                ),
                const SizedBox(height: 12),

                // 4. NOTE EN BAS DE PAGE
                Text(
                  'Le montant affiché par fournisseur déduit les acomptes versés non encore imputés.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeDebts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final debt = activeDebts[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.business_outlined, color: AppTheme.accentGold, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  debt.supplierName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Réf: ${debt.invoiceRef.isNotEmpty ? debt.invoiceRef : 'Facture'} • Échéance: ${debt.dueDate.day}/${debt.dueDate.month}/${debt.dueDate.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppTheme.formatFCFA(debt.remainingDebt),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEA580C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _showPaymentModal(context, debt),
                            child: const Text('Régler', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  height: 1,
                ),
                const SizedBox(height: 12),
                Text(
                  'Le montant affiché par fournisseur déduit les acomptes versés non encore imputés.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
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
