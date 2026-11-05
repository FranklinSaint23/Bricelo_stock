import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/inventory/supply_screen.dart';
import 'package:stock_prime/screens/finance/supplier_payment_flow.dart';

// ==========================================
// 1. ÉCRAN APPROVISIONNEMENT ENREGISTRÉ (Image 1)
// ==========================================
class SupplySuccessScreen extends StatelessWidget {
  final String supplierName;
  final String orderRef;
  final String receptionRef;
  final String invoiceRef;
  final double totalAmount;
  final bool isAlreadyPaid;
  final String? debtId;
  final List<Map<String, dynamic>> items;
  final String storeName;

  const SupplySuccessScreen({
    super.key,
    required this.supplierName,
    required this.orderRef,
    required this.receptionRef,
    required this.invoiceRef,
    required this.totalAmount,
    required this.isAlreadyPaid,
    this.debtId,
    this.items = const [],
    this.storeName = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Approvisionnement',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // CERCLE DE SUCCÈS
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7), // Or doux
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: AppTheme.accentGold, size: 54),
                ),
              ),
              const SizedBox(height: 20),

              // TITRE
              const Text(
                'Approvisionnement enregistré',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // RÉFÉRENCES CMD & REC
              Text(
                '$orderRef · $receptionRef',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              // MONTANT TOTAL
              Text(
                AppTheme.formatFCFA(totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),

              // STATUT FACTURE
              Text(
                isAlreadyPaid
                    ? 'Facture fournisseur réglée.'
                    : 'Facture fournisseur créée — reste à payer.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 2),

              // 1. BOUTON "PAYER MAINTENANT" (si non payé)
              if (!isAlreadyPaid && totalAmount > 0) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryNavy,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    icon: const Icon(Icons.payments_rounded, size: 18, color: AppTheme.primaryNavy),
                    label: const Text(
                      'Payer maintenant',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupplierPaymentScreen(
                            supplierName: supplierName,
                            invoiceRef: invoiceRef,
                            remainingDebt: totalAmount,
                            debtId: debtId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 2. BOUTON "VOIR LE DÉTAIL"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryNavy,
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text(
                    'Voir le détail',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SupplierInvoiceDetailScreen(
                          supplierName: supplierName,
                          invoiceRef: invoiceRef,
                          orderRef: orderRef,
                          receptionRef: receptionRef,
                          totalAmount: totalAmount,
                          isAlreadyPaid: isAlreadyPaid,
                          debtId: debtId,
                          items: items,
                          storeName: storeName,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // 3. BOUTON "+ NOUVEL APPROVISIONNEMENT"
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.accentGold),
                label: const Text(
                  'Nouvel approvisionnement',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplyScreen()));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. ÉCRAN FACTURE FOURNISSEUR (Image 2)
// ==========================================
class SupplierInvoiceDetailScreen extends StatelessWidget {
  final String supplierName;
  final String invoiceRef;
  final String orderRef;
  final String receptionRef;
  final double totalAmount;
  final bool isAlreadyPaid;
  final String? debtId;
  final List<Map<String, dynamic>> items;
  final String storeName;

  const SupplierInvoiceDetailScreen({
    super.key,
    required this.supplierName,
    required this.invoiceRef,
    required this.orderRef,
    required this.receptionRef,
    required this.totalAmount,
    required this.isAlreadyPaid,
    this.debtId,
    this.items = const [],
    this.storeName = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Facture fournisseur',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARTE PRINCIPALE FACTURE FOURNISSEUR (Conforme Image 2)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplierName,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoiceRef,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  _buildLine('Montant HT', AppTheme.formatFCFA(totalAmount)),
                  const SizedBox(height: 8),
                  _buildLine('Total TTC', AppTheme.formatFCFA(totalAmount), isBold: true),
                  const SizedBox(height: 8),
                  _buildLine('Paiement enregistré.', AppTheme.formatFCFA(isAlreadyPaid ? totalAmount : 0)),
                  const SizedBox(height: 8),
                  _buildLine(
                    'Reste à payer',
                    AppTheme.formatFCFA(isAlreadyPaid ? 0 : totalAmount),
                    isBold: true,
                    valueColor: isAlreadyPaid ? AppTheme.primaryNavy : const Color(0xFFD97706),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // DÉTAIL DES ARTICLES APPROVISIONNÉS (SI DISPONIBLES)
            if (items.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Articles approvisionnés',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF334155)),
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((it) {
                final qty = it['quantity'] ?? 1;
                final buy = it['buyPrice'] ?? 0.0;
                final tot = it['total'] ?? (qty * buy);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$qty x ${AppTheme.formatFCFA(buy)}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Text(
                        AppTheme.formatFCFA(tot),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.primaryNavy),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
      bottomNavigationBar: (!isAlreadyPaid && totalAmount > 0)
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryNavy,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    icon: const Icon(Icons.payments_rounded, size: 18, color: AppTheme.primaryNavy),
                    label: const Text(
                      'Payer',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupplierPaymentScreen(
                            supplierName: supplierName,
                            invoiceRef: invoiceRef,
                            remainingDebt: totalAmount,
                            debtId: debtId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLine(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF475569),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14.5 : 13.5,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
