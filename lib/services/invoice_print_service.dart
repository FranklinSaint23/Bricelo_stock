import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';

class InvoicePrintService {
  InvoicePrintService._();

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  // ==========================================
  // 1. REÇU DE VENTE / TICKET DE CAISSE (PDF)
  // ==========================================
  static Future<Uint8List> generateSaleReceiptPdf(Sale sale) async {
    final pdf = pw.Document();
    final appState = AppState.instance;
    final companyName = appState.companyName.isNotEmpty ? appState.companyName : 'Bricelo Stock';
    final storeName = sale.storeName.isNotEmpty ? sale.storeName : appState.currentStore;

    // Format ticket de caisse rouleau 80mm
    const pageFormat = PdfPageFormat.roll80;

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                storeName,
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                _formatDate(sale.createdAt),
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              // En-tête tableau articles
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('Article', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Qté', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('P.U.', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Lignes articles
              ...sale.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(item.productName, style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text('${item.unitPrice.toInt()} F', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text('${item.total.toInt()} F', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Sous-total & Remises
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Sous-total :', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('${sale.subtotal.toInt()} F CFA', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              if (sale.discountTotal > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Remise :', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('-${sale.discountTotal.toInt()} F CFA', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text('${sale.total.toInt()} F CFA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Payé (${sale.paymentMethod}) :', style: const pw.TextStyle(fontSize: 8.5)),
                  pw.Text('${sale.amountReceived.toInt()} F CFA', style: const pw.TextStyle(fontSize: 8.5)),
                ],
              ),
              if (sale.changeReturned > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Monnaie rendue :', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Text('${sale.changeReturned.toInt()} F CFA', style: const pw.TextStyle(fontSize: 8.5)),
                  ],
                ),
              ],
              if (sale.paymentMethod == 'À Crédit' && sale.total > sale.amountReceived) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Reste dû :', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Text('${(sale.total - sale.amountReceived).toInt()} F CFA', style: const pw.TextStyle(fontSize: 8.5)),
                  ],
                ),
              ],

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              pw.Text('Réf : ${sale.ticketNumber}', style: const pw.TextStyle(fontSize: 8)),
              if (sale.customerName.isNotEmpty && sale.customerName != 'Client Comptoir')
                pw.Text('Client : ${sale.customerName}', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 6),
              pw.Text('Merci pour votre visite !', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 8.5)),
              pw.Text('Bricelo Stock · bricelo.com', style: const pw.TextStyle(fontSize: 7.5)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // ACTIONS RÉELLES : IMPRESSION ET PARTAGE VENTE
  // ==========================================
  static Future<void> printSale(Sale sale) async {
    final pdfBytes = await generateSaleReceiptPdf(sale);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: sale.ticketNumber,
    );
  }

  static Future<void> shareSale(Sale sale) async {
    final pdfBytes = await generateSaleReceiptPdf(sale);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${sale.ticketNumber}.pdf',
    );
  }

  // ==========================================
  // 2. BON D'ACHAT / COMMANDE FOURNISSEUR (PDF A4)
  // ==========================================
  static Future<Uint8List> generatePurchaseOrderPdf(PurchaseOrder order) async {
    final pdf = pw.Document();
    final appState = AppState.instance;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        appState.companyName.isNotEmpty ? appState.companyName : 'BRICELO STOCK',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(order.destinationStore, style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('BON D\'ACHAT', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text(order.reference, style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Date : ${_formatDate(order.createdAt)}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('FOURNISSEUR : ${order.supplierName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('STATUT : ${order.status}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text('Articles demandés', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
              pw.SizedBox(height: 8),

              pw.TableHelper.fromTextArray(
                headers: ['Produit', 'Qté demandée', 'Qté reçue', 'P.U. (F CFA)', 'Total (F CFA)'],
                data: order.items.map((i) {
                  return [
                    i.productName,
                    '${i.quantityRequested}',
                    '${i.quantityReceived}',
                    '${i.unitPrice.toInt()}',
                    '${i.totalPrice.toInt()}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellHeight: 24,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TOTAL : ${order.totalAmount.toInt()} F CFA',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printPurchaseOrder(PurchaseOrder order) async {
    final pdfBytes = await generatePurchaseOrderPdf(order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: order.reference,
    );
  }

  static Future<void> sharePurchaseOrder(PurchaseOrder order) async {
    final pdfBytes = await generatePurchaseOrderPdf(order);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${order.reference}.pdf',
    );
  }
}

