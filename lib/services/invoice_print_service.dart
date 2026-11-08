import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';

/// Convertisseur de nombres en lettres en français pour la facture
class FrenchNumberToWords {
  static const List<String> _units = [
    '', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', 'neuf',
    'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize', 'dix-sept', 'dix-huit', 'dix-neuf'
  ];

  static const List<String> _tens = [
    '', '', 'vingt', 'trente', 'quarante', 'cinquante', 'soixante', 'soixante', 'quatre-vingt', 'quatre-vingt'
  ];

  static String convert(int n) {
    if (n == 0) return 'Zéro Franc CFA';
    if (n < 0) return 'Moins ${convert(-n)}';

    String words = _convertChunk(n).trim();
    if (words.isNotEmpty) {
      words = words[0].toUpperCase() + words.substring(1);
    }
    return '$words Francs CFA';
  }

  static String _convertChunk(int n) {
    if (n >= 1000000000) {
      final billions = n ~/ 1000000000;
      final remainder = n % 1000000000;
      final bStr = billions == 1 ? 'un milliard' : '${_convertChunk(billions)} milliards';
      return remainder == 0 ? bStr : '$bStr ${_convertChunk(remainder)}';
    }
    if (n >= 1000000) {
      final millions = n ~/ 1000000;
      final remainder = n % 1000000;
      final mStr = millions == 1 ? 'un million' : '${_convertChunk(millions)} millions';
      return remainder == 0 ? mStr : '$mStr ${_convertChunk(remainder)}';
    }
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      final tStr = thousands == 1 ? 'mille' : '${_convertChunk(thousands)} mille';
      return remainder == 0 ? tStr : '$tStr ${_convertChunk(remainder)}';
    }
    if (n >= 100) {
      final hundreds = n ~/ 100;
      final remainder = n % 100;
      String hStr;
      if (hundreds == 1) {
        hStr = 'cent';
      } else {
        hStr = remainder == 0 ? '${_units[hundreds]} cents' : '${_units[hundreds]} cent';
      }
      return remainder == 0 ? hStr : '$hStr ${_convertChunk(remainder)}';
    }
    if (n >= 20) {
      final ten = n ~/ 10;
      final unit = n % 10;
      if (ten == 7) {
        if (unit == 1) return 'soixante et onze';
        return 'soixante-${_units[10 + unit]}';
      }
      if (ten == 8) {
        if (unit == 0) return 'quatre-vingts';
        return 'quatre-vingt-${_units[unit]}';
      }
      if (ten == 9) {
        return 'quatre-vingt-${_units[10 + unit]}';
      }
      if (unit == 1) {
        return '${_tens[ten]} et un';
      }
      return unit == 0 ? _tens[ten] : '${_tens[ten]}-${_units[unit]}';
    }
    return _units[n];
  }
}

class InvoicePrintService {
  InvoicePrintService._();

  static String _formatDateWithSeconds(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy à $hh:$min:$ss';
  }

  // =========================================================================
  // NOUVELLE FACTURE PRO CONFORME AU MODÈLE (BRICELO CONFORT)
  // =========================================================================
  static Future<Uint8List> generateInvoicePdf(Sale sale) async {
    final pdf = pw.Document();
    final appState = AppState.instance;

    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontItalic = await PdfGoogleFonts.openSansItalic();

    // Couleurs officielles Bricelo et du bordereau
    final primaryNavy = PdfColor.fromInt(0xFF0D1B2E); // Bleu Marine Bricelo
    final inkBlue = PdfColor.fromInt(0xFF1E3A8A);     // Bleu encre Facture
    final accentRed = PdfColor.fromInt(0xFFDC2626);   // Rouge tampon numéro facture

    final formatter = NumberFormat('#,###', 'fr_FR');
    final totalInWords = FrenchNumberToWords.convert(sale.total.round());
    final dateFormatted = _formatDateWithSeconds(sale.createdAt);

    // Extraction du logo entreprise si défini
    Uint8List? logoBytes;
    if (appState.companyLogo.isNotEmpty) {
      try {
        final clean = appState.companyLogo.contains(',') ? appState.companyLogo.split(',').last : appState.companyLogo;
        logoBytes = base64Decode(clean);
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 26),
        build: (pw.Context context) {
          final borderBold = pw.BorderSide(color: inkBlue, width: 1.3);
          final borderThin = pw.BorderSide(color: inkBlue, width: 0.8);

          const minTableRows = 8;
          final emptyRowsCount = (minTableRows - sale.items.length).clamp(0, minTableRows);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. RECTANGLE EN HAUT AVEC DOUBLE BORDURE BLEUE
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: inkBlue, width: 2),
                ),
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: inkBlue, width: 1),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // LOGO RECTANGLE EXACT (FORMAT RECTANGULAIRE STRICT)
                      pw.Container(
                        width: 140,
                        height: 65, // Exactement rectangle
                        decoration: pw.BoxDecoration(
                          color: primaryNavy,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                        child: logoBytes != null
                            ? pw.ClipRRect(
                                horizontalRadius: 2,
                                verticalRadius: 2,
                                child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
                              )
                            : _buildDefaultLogo(fontBold, fontItalic),
                      ),
                      pw.SizedBox(width: 12),

                      // INFORMATIONS DE LA BOUTIQUE (MODIFIABLES DANS PERSONNALISATION FACTURE)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: appState.invoiceHeaderLines.map((line) {
                            final isFirst = line == appState.invoiceHeaderLines.first;
                            final isPhone = line.label.toLowerCase().contains('tél') || line.value.toLowerCase().contains('tél');

                            return pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
                              child: pw.Text(
                                line.value,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: isFirst ? 9.5 : (isPhone ? 11 : 8.5),
                                  color: inkBlue,
                                  letterSpacing: isFirst ? 0.3 : 0,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 12),

              // 2. LIGNE DATE (DATE + HEURE JUSQU'AUX SECONDES)
              pw.Row(
                children: [
                  pw.Text(
                    'Date: ',
                    style: pw.TextStyle(font: fontBold, fontSize: 11, color: inkBlue),
                  ),
                  pw.Text(
                    dateFormatted,
                    style: pw.TextStyle(font: fontBold, fontSize: 11, color: inkBlue),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      ' ........................................................................................................................................................................',
                      style: pw.TextStyle(font: fontRegular, fontSize: 10, color: inkBlue),
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              // 3. PILULE FACTURE + NUMÉRO EN ROUGE
              pw.Center(
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4.5),
                      decoration: pw.BoxDecoration(
                        color: inkBlue,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        'FACTURE:',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 14.5,
                          color: PdfColors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      sale.formattedInvoiceNumber,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 22,
                        color: accentRed, // Rouge tampon comme sur l'image
                        letterSpacing: 2.0,
                      ),
                    ),
                    pw.Text(
                      ' •',
                      style: pw.TextStyle(font: fontBold, fontSize: 15, color: accentRed),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // 4. LIGNE CLIENT ET TÉLÉPHONE
              pw.Row(
                children: [
                  pw.Text(
                    'Client: ',
                    style: pw.TextStyle(font: fontBold, fontSize: 11.5, color: inkBlue),
                  ),
                  if (sale.customerName.isNotEmpty && sale.customerName != 'Client Comptoir') ...[
                    pw.Text(
                      sale.customerName,
                      style: pw.TextStyle(font: fontBold, fontSize: 11, color: inkBlue),
                    ),
                    pw.SizedBox(width: 4),
                  ],
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      ' .....................................................................................................',
                      style: pw.TextStyle(font: fontRegular, fontSize: 10, color: inkBlue),
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'Tél: ',
                    style: pw.TextStyle(font: fontBold, fontSize: 11.5, color: inkBlue),
                  ),
                  if (sale.customerPhone.isNotEmpty) ...[
                    pw.Text(
                      sale.customerPhone,
                      style: pw.TextStyle(font: fontBold, fontSize: 11, color: inkBlue),
                    ),
                    pw.SizedBox(width: 4),
                  ],
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      ' .....................................................................................................',
                      style: pw.TextStyle(font: fontRegular, fontSize: 10, color: inkBlue),
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // 5. TABLEAU DES ARTICLES (Qtés | Désignations | P.U | P.Total)
              pw.Table(
                border: pw.TableBorder(
                  top: borderBold,
                  left: borderBold,
                  right: borderBold,
                  bottom: borderBold,
                  verticalInside: borderThin,
                  horizontalInside: borderThin,
                ),
                columnWidths: const {
                  0: pw.FixedColumnWidth(55),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FixedColumnWidth(95),
                  3: pw.FixedColumnWidth(110),
                },
                children: [
                  // En-tête des colonnes
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5.5),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Qtés', style: pw.TextStyle(font: fontBold, fontSize: 11.5, color: inkBlue)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5.5, horizontal: 8),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Désignations', style: pw.TextStyle(font: fontBold, fontSize: 11.5, color: inkBlue)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5.5),
                        alignment: pw.Alignment.center,
                        child: pw.Text('P.U', style: pw.TextStyle(font: fontBold, fontSize: 11.5, color: inkBlue)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5.5),
                        alignment: pw.Alignment.center,
                        child: pw.Text('P.Total', style: pw.TextStyle(font: fontBold, fontSize: 11.5, color: inkBlue)),
                      ),
                    ],
                  ),

                  // Lignes des produits
                  ...sale.items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 5),
                          alignment: pw.Alignment.center,
                          child: pw.Text('${item.quantity}', style: pw.TextStyle(font: fontBold, fontSize: 10, color: inkBlue)),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(item.productName, style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: inkBlue)),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(formatter.format(item.unitPrice.round()), style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: inkBlue)),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(formatter.format(item.total.round()), style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: inkBlue)),
                        ),
                      ],
                    );
                  }),

                  // Lignes vides de remplissage du bordereau
                  ...List.generate(emptyRowsCount, (_) {
                    return pw.TableRow(
                      children: [
                        pw.Container(height: 22),
                        pw.Container(height: 22),
                        pw.Container(height: 22),
                        pw.Container(height: 22),
                      ],
                    );
                  }),
                ],
              ),

              // 6. LIGNE TOTAL FUSIONNÉE AVEC LA PILULE BLEUE
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: borderBold,
                    right: borderBold,
                    bottom: borderBold,
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'TOTAL',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: fontBold, fontSize: 14, color: inkBlue, letterSpacing: 1.5),
                      ),
                    ),
                    pw.Container(
                      width: 205,
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF60A5FA), // Pilule bleue exacte comme sur l'image
                        borderRadius: pw.BorderRadius.circular(16),
                      ),
                      child: pw.Text(
                        '${formatter.format(sale.total.round())} F CFA',
                        style: pw.TextStyle(font: fontBold, fontSize: 12, color: primaryNavy),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // 7. ARRÊTÉ LA PRÉSENTE FACTURE À LA SOMME DE (EN LETTRES)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Arrêté la présente facture à la somme de: ',
                          style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: inkBlue),
                        ),
                        pw.TextSpan(
                          text: totalInWords,
                          style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: inkBlue),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '........................................................................................................................................................................................................................................',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: inkBlue),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                  ),
                ],
              ),

              pw.SizedBox(height: 22),

              // 8. SIGNATURES (LE CLIENT & CAISSE AVEC SIGNATURE BRICELO PAR DÉFAUT)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Le Client:
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 12),
                    child: pw.Text(
                      'Le Client:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11.5, color: inkBlue),
                    ),
                  ),

                  // Caisse avec signature Bricelo systématique
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 24),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Caisse',
                          style: pw.TextStyle(font: fontBold, fontSize: 12, color: inkBlue),
                        ),
                        pw.SizedBox(height: 4),
                        // Signature par défaut Bricelo stylisée
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColor.fromInt(0xFF93C5FD), width: 0.8),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Column(
                            children: [
                              pw.Text(
                                'Bricelo',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 16,
                                  color: inkBlue,
                                  fontStyle: pw.FontStyle.italic,
                                ),
                              ),
                              pw.Text(
                                '(Signature certifiée)',
                                style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.grey700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDefaultLogo(pw.Font fontBold, pw.Font fontItalic) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      color: PdfColor.fromInt(0xFF0D1B2E),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'BRICELO',
            style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.white, letterSpacing: 1),
          ),
          pw.Text(
            'CONFORT',
            style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: PdfColor.fromInt(0xFFFBBF24), letterSpacing: 1.2),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Juste le confort, tout simplement !',
            style: pw.TextStyle(font: fontItalic, fontSize: 6.5, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTIONS RÉELLES : IMPRESSION ET PARTAGE VENTE
  // ==========================================
  static Future<Uint8List> generateSaleReceiptPdf(Sale sale) => generateInvoicePdf(sale);

  static Future<void> printSale(Sale sale) async {
    final pdfBytes = await generateInvoicePdf(sale);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Facture_${sale.formattedInvoiceNumber}',
    );
  }

  static Future<void> shareSale(Sale sale) async {
    final pdfBytes = await generateInvoicePdf(sale);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Facture_${sale.formattedInvoiceNumber}.pdf',
    );
  }

  // ==========================================
  // BON D'ACHAT / COMMANDE FOURNISSEUR (PDF A4)
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
                      pw.Text('Date : ${_formatDateWithSeconds(order.createdAt)}', style: const pw.TextStyle(fontSize: 10)),
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
