import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/finance/supplier_payment_flow.dart';
import 'package:stock_prime/screens/inventory/supply_success_screen.dart';

class SupplierDebtsScreen extends StatefulWidget {
  const SupplierDebtsScreen({super.key});

  @override
  State<SupplierDebtsScreen> createState() => _SupplierDebtsScreenState();
}

class _SupplierDebtsScreenState extends State<SupplierDebtsScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'À régler'; // 'À régler' ou 'Réglées'

  void _showPaymentModal(BuildContext context, SupplierDebt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierPaymentScreen(
          supplierName: debt.supplierName,
          invoiceRef: debt.invoiceRef.isNotEmpty ? debt.invoiceRef : 'BS-FAF-${debt.id}',
          remainingDebt: debt.remainingDebt,
          debtId: debt.id,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final totalDue = appState.totalSupplierDebt;
        final isDark = appState.isDarkMode;
        final activeDebts = appState.supplierDebts.where((d) => !d.isSettled).toList();
        final settledDebts = appState.supplierDebts.where((d) => d.isSettled).toList();
        final totalSettled = settledDebts.fold(0.0, (sum, d) => sum + d.totalAmount);

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
          appBar: StockAppBar.navy(
            title: 'Dettes fournisseurs',
            onBack: () => Navigator.pop(context),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // 1. SEGMENTED TABS : À RÉGLER | RÉGLÉES
              SegmentedTabBar(
                tabs: const ['À régler', 'Réglées'],
                selectedTab: _selectedTab,
                activeColor: isDark ? AppTheme.primaryNavy : const Color(0xFFFFDFBA),
                activeTextColor: isDark ? AppTheme.accentGold : const Color(0xFF111827),
                inactiveTextColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151),
                borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                onTabSelected: (tab) => setState(() => _selectedTab = tab),
              ),
              const SizedBox(height: 16),

              // 2. CARTE RÉSUMÉ SELON ONGLET
              if (_selectedTab == 'À régler') ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E1C14) : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5),
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
                        AppTheme.formatFCFA(totalDue),
                        style: TextStyle(
                          color: isDark ? AppTheme.accentGold : const Color(0xFFEA580C),
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Factures en attente de règlement (${activeDebts.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),

                if (activeDebts.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: isDark ? AppTheme.accentGold : const Color(0xFFD97706),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune dette fournisseur en cours !',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toutes vos factures d\'achat sont soldées.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
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
                                    'Réf: ${debt.invoiceRef.isNotEmpty ? debt.invoiceRef : 'Facture'} • Échéance: ${_formatDate(debt.dueDate)}',
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
                ],
              ] else ...[
                // ONGLET FACTURES RÉGLÉES
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_outlined,
                              color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Total des factures réglées',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppTheme.formatFCFA(totalSettled),
                        style: TextStyle(
                          color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Factures soldées (${settledDebts.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),

                if (settledDebts.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 48,
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune facture réglée enregistrée.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: settledDebts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final debt = settledDebts[idx];
                      final lastPayment = debt.payments.isNotEmpty ? debt.payments.first : null;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupplierInvoiceDetailScreen(
                                supplierName: debt.supplierName,
                                invoiceRef: debt.invoiceRef,
                                orderRef: debt.orderRef ?? debt.invoiceRef.replaceAll('BS-FAF-', 'BS-ACH-'),
                                receptionRef: debt.orderRef != null
                                    ? debt.orderRef!.replaceAll('BS-ACH-', 'BS-REC-')
                                    : debt.invoiceRef.replaceAll('BS-FAF-', 'BS-REC-'),
                                totalAmount: debt.totalAmount,
                                isAlreadyPaid: true,
                                storeName: debt.storeName ?? appState.currentStore,
                                items: const [],
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    debt.supplierName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Réglée',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.accentGold : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    debt.invoiceRef,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    AppTheme.formatFCFA(debt.totalAmount),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                    ),
                                  ),
                                ],
                              ),
                              if (lastPayment != null) ...[
                                const SizedBox(height: 6),
                                Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 13,
                                      color: isDark ? AppTheme.accentGold : const Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Payé le ${_formatDate(lastPayment.date)} · ${lastPayment.paymentMethod}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
              const SizedBox(height: 20),
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
