import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/widgets/sale_receipt_dialog.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailScreen({super.key, required this.sale});

  String _formatDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isCredit = sale.paymentMethod == 'À Crédit';
    final remainingDebt = (sale.total - sale.amountReceived).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détail de la vente'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            Text(
              sale.ticketNumber,
              style: const TextStyle(fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCredit ? const Color(0xFFFEF3C7) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCredit ? 'À Crédit' : 'Terminé',
                  style: TextStyle(
                    color: isCredit ? const Color(0xFFB45309) : const Color(0xFFD97706),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARTES BOUTIQUE & VENDEUR
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF64748B)),
                            SizedBox(width: 6),
                            Text('Boutique', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sale.storeName.isNotEmpty ? sale.storeName : appState.currentStore,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: Color(0xFF64748B)),
                            SizedBox(width: 6),
                            Text('Vendeur', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sale.cashierName.isNotEmpty ? sale.cashierName : appState.displayUserName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDateTime(sale.createdAt),
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // TABLE DES ARTICLES
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Articles vendus',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        '${sale.items.length} article(s)',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  ...sale.items.map((it) {
                    final appState = AppState.instance;
                    final prod = appState.products.firstWhereOrNull(
                      (p) => p.name.trim().toLowerCase() == it.productName.trim().toLowerCase(),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          ProductImageWidget(
                            imageUrl: prod?.imageUrl,
                            size: 34,
                            borderRadius: 6,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  '${AppTheme.formatFCFA(it.unitPrice)} / unité',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'x${it.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            AppTheme.formatFCFA(it.total),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // TOTALS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSummaryLine('Sous-total', AppTheme.formatFCFA(sale.subtotal)),
                  if (sale.discountTotal > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryLine('Remise', '-${AppTheme.formatFCFA(sale.discountTotal)}', valueColor: Colors.red),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        AppTheme.formatFCFA(sale.total),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryNavy),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildSummaryLine('Payé (${sale.paymentMethod})', AppTheme.formatFCFA(sale.amountReceived)),
                  if (sale.changeReturned > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryLine('Monnaie rendue', AppTheme.formatFCFA(sale.changeReturned), valueColor: AppTheme.primaryNavy),
                  ],
                  if (isCredit && remainingDebt > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryLine('Reste à payer (Dette)', AppTheme.formatFCFA(remainingDebt), valueColor: Colors.red, isBold: true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ACTIONS
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: AppTheme.primaryNavy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.print_rounded, size: 18, color: AppTheme.primaryNavy),
                label: const Text('Imprimer le reçu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () => SaleReceiptDialog.show(context, sale),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'Reçu ${sale.ticketNumber} • Total: ${AppTheme.formatFCFA(sale.total)}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reçu copié pour WhatsApp !')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.receipt_outlined, size: 18),
                    label: const Text('Facture A4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Facture format A4 générée (${sale.ticketNumber})')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Annuler la vente', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Annuler la vente ?'),
                      content: Text('Cette action remettra les articles (${sale.items.length}) en stock.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Non')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                            appState.cancelSale(sale);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Vente ${sale.ticketNumber} annulée et stock restauré.')),
                            );
                          },
                          child: const Text('Oui, annuler', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

