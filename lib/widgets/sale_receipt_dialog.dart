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

  String _formatDateTimeSeconds(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min:$ss';
  }

  String _buildPlainTextReceipt(AppState appState) {
    final company = appState.companyName.isNotEmpty ? appState.companyName : 'Franklin Athletics';
    final store = sale.storeName.isNotEmpty ? sale.storeName : 'Boutique principale';
    final buffer = StringBuffer();
    buffer.writeln(company);
    buffer.writeln(store);
    buffer.writeln(_formatDateTimeSeconds(sale.createdAt));
    buffer.writeln('--------------------------------');
    buffer.writeln('Article       Qte     P.U.  Total');
    buffer.writeln('--------------------------------');
    for (final item in sale.items) {
      final pName = item.productName.padRight(12).substring(0, 12);
      final qte = '${item.quantity}'.padLeft(3);
      final pu = '${item.unitPrice.toInt()} FCFA'.padLeft(8);
      final tot = '${item.total.toInt()} FCFA'.padLeft(8);
      buffer.writeln('$pName $qte  $pu $tot');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Sous-total              ${sale.subtotal.toInt()} FCFA');
    if (sale.discountTotal > 0) {
      buffer.writeln('Remise                 -${sale.discountTotal.toInt()} FCFA');
    }
    buffer.writeln('TOTAL                   ${sale.total.toInt()} FCFA');
    buffer.writeln('Paye                    ${sale.amountReceived.toInt()} FCFA');
    if (sale.changeReturned > 0) {
      buffer.writeln('Monnaie                 ${sale.changeReturned.toInt()} FCFA');
    }
    if (sale.paymentMethod == 'À Crédit') {
      final reste = (sale.total - sale.amountReceived).clamp(0, double.infinity);
      buffer.writeln('Reste a payer           ${reste.toInt()} FCFA');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('      Paiement: ${sale.paymentMethod}');
    buffer.writeln('    Ref: ${sale.ticketNumber}');
    buffer.writeln('--------------------------------');
    buffer.writeln('     Merci pour votre achat !');
    buffer.writeln('    Bricelo Stock · bricelo.com');
    return buffer.toString();
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashCount = (constraints.constrainWidth() / 8).floor();
          return Text(
            '-' * dashCount,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 2,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final company = appState.companyName.isNotEmpty ? appState.companyName : 'Franklin Athletics';
    final store = sale.storeName.isNotEmpty ? sale.storeName : 'Boutique principale';

    const headerStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      fontWeight: FontWeight.w900,
      color: Colors.black,
    );

    const rowStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    const boldRowStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      fontWeight: FontWeight.w900,
      color: Colors.black,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CARTE TICKET THERMIQUE EXACT COMME DANS LA PHOTO FOURNIE
            Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. NOM DE L'ENTREPRISE (Franklin Athletics)
                  Text(
                    company,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 2. NOM DE LA BOUTIQUE (Boutique principale)
                  Text(
                    store,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // 3. DATE ET HEURE (28/10/2026 02:47:39)
                  Text(
                    _formatDateTimeSeconds(sale.createdAt),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  // 4. LIGNE DE TIRETS
                  _buildDashedDivider(),

                  // 5. EN-TÊTE TABLEAU : Article | Qte | P.U. | Total
                  Row(
                    children: const [
                      Expanded(
                        flex: 5,
                        child: Text('Article', style: headerStyle),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Qte', textAlign: TextAlign.center, style: headerStyle),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('P.U.', textAlign: TextAlign.right, style: headerStyle),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Total', textAlign: TextAlign.right, style: headerStyle),
                      ),
                    ],
                  ),

                  // 6. LIGNE DE TIRETS
                  _buildDashedDivider(),

                  // 7. LIGNES D'ARTICLES
                  ...sale.items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              it.productName,
                              style: rowStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${it.quantity}',
                              textAlign: TextAlign.center,
                              style: rowStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${it.unitPrice.toInt()} FCFA',
                              textAlign: TextAlign.right,
                              style: rowStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${it.total.toInt()} FCFA',
                              textAlign: TextAlign.right,
                              style: rowStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 8. LIGNE DE TIRETS
                  _buildDashedDivider(),

                  // 9. SOUS-TOTAL / REMISE / TOTAL / PAYÉ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sous-total', style: rowStyle),
                      Text('${sale.subtotal.toInt()} FCFA', style: rowStyle),
                    ],
                  ),
                  if (sale.discountTotal > 0) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remise', style: rowStyle),
                        Text('-${sale.discountTotal.toInt()} FCFA', style: rowStyle),
                      ],
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: boldRowStyle),
                      Text('${sale.total.toInt()} FCFA', style: boldRowStyle),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Paye', style: rowStyle),
                      Text('${sale.amountReceived.toInt()} FCFA', style: rowStyle),
                    ],
                  ),
                  if (sale.changeReturned > 0) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monnaie', style: rowStyle),
                        Text('${sale.changeReturned.toInt()} FCFA', style: rowStyle),
                      ],
                    ),
                  ],
                  if (sale.paymentMethod == 'À Crédit') ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Reste a payer', style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                        Text('${(sale.total - sale.amountReceived).clamp(0, double.infinity).toInt()} FCFA', style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ],

                  // 10. LIGNE DE TIRETS
                  _buildDashedDivider(),

                  // 11. PAIEMENT & RÉFÉRENCE
                  Text(
                    'Paiement: ${sale.paymentMethod}',
                    textAlign: TextAlign.center,
                    style: rowStyle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ref: ${sale.ticketNumber}',
                    textAlign: TextAlign.center,
                    style: rowStyle,
                  ),

                  // 12. LIGNE DE TIRETS
                  _buildDashedDivider(),

                  // 13. MERCI POUR VOTRE ACHAT & BRANDING BRICELO
                  const Text(
                    'Merci pour votre achat !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bricelo Stock · bricelo.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // BARRE D'ACTIONS SOUS LE TICKET (IMPRIMER, PARTAGER, NOUVELLE VENTE)
            Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D), // Green
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.print_rounded, size: 18),
                          label: const Text('Imprimer le reçu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppTheme.primaryNavy,
                                content: Text('Impression thermique du reçu ${sale.ticketNumber} en cours...'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366), // WhatsApp
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () {
                            final txt = _buildPlainTextReceipt(appState);
                            Clipboard.setData(ClipboardData(text: txt));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reçu copié et prêt à être envoyé par WhatsApp !')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryNavy,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (onNewSale != null) onNewSale!();
                      },
                      child: Text(
                        onNewSale != null ? 'Nouvelle vente' : 'Fermer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
