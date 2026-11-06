import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stock_prime/models/models.dart';

class InventoryPdfService {
  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year} à ${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';
  }

  // 1. TÉLÉCHARGER L'INVENTAIRE DU JOUR EN PDF
  static Future<void> downloadDailyInventoryPdf(String storeName, List<Product> products) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontRegular = await PdfGoogleFonts.openSansRegular();

    double totalAchat = 0;
    double totalVente = 0;
    int totalPieces = 0;

    for (final p in products) {
      final q = p.stockForStore(storeName);
      totalPieces += q;
      totalAchat += q * p.buyPrice;
      totalVente += q * p.sellPrice;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return [
            // EN-TÊTE
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BRICELO STOCK', style: pw.TextStyle(font: fontBold, fontSize: 20, color: PdfColors.blueGrey900)),
                    pw.Text('Gestion de stock professionnelle', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVENTAIRE DU JOUR', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColor.fromInt(0xFFB45309))),
                    pw.Text('Boutique : $storeName', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    pw.Text('Édité le : ${_formatDate(now)}', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
            pw.SizedBox(height: 8),

            // RÉSUMÉ CHIFFRÉ
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Références', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('${products.length}', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Total Pièces', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('$totalPieces', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Valeur Coût Achat', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('${totalAchat.toInt()} F CFA', style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromInt(0xFF0F172A))),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Valeur Vente', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('${totalVente.toInt()} F CFA', style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromInt(0xFF059669))),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // TABLEAU DES ARTICLES
            pw.TableHelper.fromTextArray(
              headers: ['Réf / Barcode', 'Désignation', 'Fournisseur', 'Stock Théorique', 'Compté Réel', 'P. Achat', 'P. Vente', 'Valeur Achat'],
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0D1B2E)),
              cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
              },
              data: products.map((p) {
                final qty = p.stockForStore(storeName);
                final val = qty * p.buyPrice;
                return [
                  p.barcode.isNotEmpty ? p.barcode : p.id.split('_').last,
                  p.name,
                  p.supplierName ?? 'Direct',
                  '$qty ${p.unit}',
                  '[    ]', // Espace pour comptage physique
                  '${p.buyPrice.toInt()} F',
                  '${p.sellPrice.toInt()} F',
                  '${val.toInt()} F',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),
            // SIGNATURES
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Visa Agent d\'inventaire :', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                    pw.SizedBox(height: 30),
                    pw.Text('Date : ..............................', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Visa Direction / Gérant :', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                    pw.SizedBox(height: 30),
                    pw.Text('Signature & Cachet', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'inventaire_${storeName.replaceAll(' ', '_')}_${now.year}${now.month}${now.day}.pdf');
  }

  // 2. TÉLÉCHARGER LE RAPPORT D'UNE SESSION D'INVENTAIRE PASSÉE
  static Future<void> downloadSessionInventoryPdf(InventorySession session) async {
    final pdf = pw.Document();

    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontRegular = await PdfGoogleFonts.openSansRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return [
            // EN-TÊTE
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BRICELO STOCK', style: pw.TextStyle(font: fontBold, fontSize: 20, color: PdfColors.blueGrey900)),
                    pw.Text('Procès-Verbal d\'Inventaire Physique', style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromInt(0xFF0F172A))),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(session.reference, style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromInt(0xFFB45309))),
                    pw.Text('Boutique : ${session.storeName}', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.Text('Responsable : ${session.conductedBy}', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
            pw.SizedBox(height: 6),

            // HORODATAGE PRÉCIS D'ENREGISTREMENT
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber50,
                border: pw.Border.all(color: PdfColors.amber200),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Début inventaire : ${_formatDate(session.startedAt)}', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColor.fromInt(0xFF78350F))),
                  pw.Text('Clôture & Validation : ${_formatDate(session.completedAt)}', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColor.fromInt(0xFF78350F))),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // RÉSUMÉ STATISTIQUE
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Articles comptés', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      pw.Text('${session.totalArticlesCounted}', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Écarts constatés', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      pw.Text('${session.articlesWithDiscrepancy}', style: pw.TextStyle(font: fontBold, fontSize: 12, color: session.articlesWithDiscrepancy > 0 ? PdfColors.red700 : PdfColors.green700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Valeur Stock Compté', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      pw.Text('${session.totalCountedValue.toInt()} F CFA', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Impact Écart Net', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      pw.Text('${session.totalDiscrepancyValue.toInt()} F CFA', style: pw.TextStyle(font: fontBold, fontSize: 12, color: session.totalDiscrepancyValue < 0 ? PdfColors.red700 : PdfColors.green700)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // TABLEAU EXHAUSTIF DES ARTICLES
            pw.TableHelper.fromTextArray(
              headers: ['Article', 'Fournisseur', 'Clients Récents', 'P. Achat', 'P. Vente', 'Théorique', 'Compté', 'Écart', 'Impact'],
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0D1B2E)),
              cellStyle: pw.TextStyle(font: fontRegular, fontSize: 7.5),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.centerRight,
              },
              data: session.items.map((i) {
                final diff = i.difference;
                final diffStr = diff > 0 ? '+$diff' : '$diff';
                final buyersStr = i.recentBuyers.isNotEmpty ? i.recentBuyers.take(2).join(', ') : 'Aucun';
                return [
                  i.productName,
                  i.supplierName.isNotEmpty ? i.supplierName : 'Direct',
                  buyersStr,
                  '${i.buyPrice.toInt()} F',
                  '${i.sellPrice.toInt()} F',
                  '${i.theoreticalStock}',
                  '${i.countedStock}',
                  diffStr,
                  '${i.discrepancyValue.toInt()} F',
                ];
              }).toList(),
            ),

            if (session.note.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text('Observations : ${session.note}', style: pw.TextStyle(font: fontRegular, fontSize: 9, fontStyle: pw.FontStyle.italic)),
            ],

            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Signature Agent d\'Inventaire :', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                    pw.SizedBox(height: 35),
                    pw.Text('Nom : ${session.conductedBy}', style: pw.TextStyle(font: fontRegular, fontSize: 8.5)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Approbation Direction / Gérant :', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                    pw.SizedBox(height: 35),
                    pw.Text('Cachet & Signature', style: pw.TextStyle(font: fontRegular, fontSize: 8.5)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: '${session.reference}_${session.storeName.replaceAll(' ', '_')}.pdf');
  }
}
