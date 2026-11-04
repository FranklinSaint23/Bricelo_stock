import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class SaleReceiptDialog extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onNewSale;

  const SaleReceiptDialog({
    super.key,
    required this.sale,
    this.onNewSale,
  });

  static Future<void> show(BuildContext context, Sale sale, {VoidCallback? onNewSale}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SaleReceiptDialog(sale: sale, onNewSale: onNewSale),
    );
  }

  String _formatDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy à $hh:$min';
  }

  String _buildPlainTextReceipt(AppState appState) {
    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('   ${appState.companyName.toUpperCase()}');
    buffer.writeln('   ${sale.storeName}');
    if (appState.userPhone.isNotEmpty) {
      buffer.writeln('   Tél: ${appState.userPhone}');
    }
    buffer.writeln('================================');
    buffer.writeln('REÇU N° : ${sale.ticketNumber}');
    buffer.writeln('Date    : ${_formatDateTime(sale.createdAt)}');
    buffer.writeln('Client  : ${sale.customerName}');
    if (sale.customerPhone.isNotEmpty) {
      buffer.writeln('Tél Cli : ${sale.customerPhone}');
    }
    buffer.writeln('Caissier: ${sale.cashierName}');
    buffer.writeln('--------------------------------');
    for (final item in sale.items) {
      buffer.writeln('${item.quantity}x ${item.productName}');
      buffer.writeln('   ${AppTheme.formatFCFA(item.unitPrice)} = ${AppTheme.formatFCFA(item.total)}');
    }
    buffer.writeln('--------------------------------');
    if (sale.discountTotal > 0) {
      buffer.writeln('Remise  : -${AppTheme.formatFCFA(sale.discountTotal)}');
    }
    buffer.writeln('TOTAL   : ${AppTheme.formatFCFA(sale.total)}');
    buffer.writeln('Paiement: ${sale.paymentMethod}');
    buffer.writeln('Reçu    : ${AppTheme.formatFCFA(sale.amountReceived)}');
    if (sale.paymentMethod == 'À Crédit') {
      final reste = (sale.total - sale.amountReceived).clamp(0, double.infinity);
      buffer.writeln('Reste dû: ${AppTheme.formatFCFA(reste)}');
    } else {
      buffer.writeln('Monnaie : ${AppTheme.formatFCFA(sale.changeReturned)}');
    }
    buffer.writeln('================================');
    buffer.writeln('   Merci de votre confiance !');
    buffer.writeln('      Propulsé par Bricelo');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isCredit = sale.paymentMethod == 'À Crédit';
    final remainingCredit = (sale.total - sale.amountReceived).clamp(0.0, double.infinity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. EN-TÊTE NAVY & GOLD DU REÇU
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentGold, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.accentGold,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      appState.companyName.isNotEmpty ? appState.companyName : sale.storeName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sale.storeName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (appState.userPhone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tél : ${appState.userPhone}',
                        style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'REÇU N° ${sale.ticketNumber}',
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. CORPS DU TICKET DE CAISSE
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Infos Date / Client / Caissier
                    _buildMetaRow('Date & Heure'.tr, _formatDateTime(sale.createdAt)),
                    const SizedBox(height: 6),
                    _buildMetaRow('Client'.tr, sale.customerName),
                    if (sale.customerPhone.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildMetaRow('Téléphone client'.tr, sale.customerPhone),
                    ],
                    const SizedBox(height: 6),
                    _buildMetaRow('Servi par'.tr, sale.cashierName),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),

                    // En-tête Tableau Articles
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'ARTICLE'.tr,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'QTÉ'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'TOTAL'.tr,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Lignes d'articles
                    ...sale.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppTheme.primaryNavy,
                                      ),
                                    ),
                                    Text(
                                      '${AppTheme.formatFCFA(item.unitPrice)} / u',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'x${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  AppTheme.formatFCFA(item.total),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),

                    if (sale.discountTotal > 0) ...[
                      _buildMetaRow('Remise accordée'.tr, '-${AppTheme.formatFCFA(sale.discountTotal)}'),
                      const SizedBox(height: 6),
                    ],

                    // TOTAL TTC ENCADRÉ
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL À PAYER'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              Text(
                                AppTheme.formatFCFA(sale.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildMetaRow('Mode de règlement'.tr, sale.paymentMethod, boldValue: true),
                          const SizedBox(height: 4),
                          _buildMetaRow('Montant reçu'.tr, AppTheme.formatFCFA(sale.amountReceived)),
                          const SizedBox(height: 4),
                          if (isCredit)
                            _buildMetaRow(
                              'Reste à payer (Dette)'.tr,
                              AppTheme.formatFCFA(remainingCredit),
                              valueColor: const Color(0xFFDC2626),
                              boldValue: true,
                            )
                          else
                            _buildMetaRow(
                              'Monnaie rendue'.tr,
                              AppTheme.formatFCFA(sale.changeReturned),
                              valueColor: const Color(0xFF16A34A),
                              boldValue: true,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Merci pour votre achat chez ${appState.companyName} !',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // BOUTONS D'ACTION : PARTAGER / IMPRIMER / NOUVELLE VENTE
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryNavy,
                              side: const BorderSide(color: AppTheme.primaryNavy, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: Text(
                              'Partager'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () {
                              final txt = _buildPlainTextReceipt(appState);
                              Clipboard.setData(ClipboardData(text: txt));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryNavy,
                                  content: Text('Reçu ${sale.ticketNumber} copié et prêt à être partagé sur WhatsApp !'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryNavy,
                              side: const BorderSide(color: AppTheme.primaryNavy, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.print_outlined, size: 18),
                            label: Text(
                              'Imprimer'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryNavy,
                                  content: Text('Impression thermique du ticket ${sale.ticketNumber} lancée...'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                        label: Text(
                          onNewSale != null ? 'Nouvelle vente'.tr : 'Fermer le reçu'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (onNewSale != null) onNewSale!();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {Color? valueColor, bool boldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: boldValue ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
