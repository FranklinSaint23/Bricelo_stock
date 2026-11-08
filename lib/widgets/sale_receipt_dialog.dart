import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/services/invoice_print_service.dart';
import 'package:stock_prime/theme/app_theme.dart';

// =========================================================================
// PEINTRE VECTORIEL POUR LA SIGNATURE MANUSCRITE "BRICELO"
// =========================================================================
class BriceloSignaturePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const BriceloSignaturePainter({
    this.color = const Color(0xFF1E3A8A),
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Échelle basée sur un canevas de référence 160x55
    final scaleX = size.width / 160.0;
    final scaleY = size.height / 55.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Lettre 'B' majuscule avec sa boucle
    final pathB = Path()
      ..moveTo(14, 38)
      ..cubicTo(12, 25, 20, 8, 28, 8)
      ..cubicTo(36, 8, 40, 18, 34, 27)
      ..cubicTo(32, 30, 27, 33, 21, 33)
      ..cubicTo(30, 33, 40, 33, 42, 43)
      ..cubicTo(44, 49, 34, 49, 24, 47)
      ..cubicTo(17, 45, 14, 39, 20, 35);
    canvas.drawPath(pathB, strokePaint);

    // Lettres cursives r - i - c - e - l - o
    final pathRest = Path()
      ..moveTo(34, 32)
      ..cubicTo(40, 28, 46, 26, 50, 28)
      ..cubicTo(54, 30, 51, 36, 48, 40)
      ..moveTo(52, 36)
      ..cubicTo(56, 28, 60, 28, 64, 28)
      ..cubicTo(68, 28, 66, 40, 66, 40)
      ..moveTo(70, 32)
      ..cubicTo(76, 28, 82, 30, 88, 32)
      ..cubicTo(94, 34, 92, 40, 86, 42)
      ..moveTo(90, 36)
      ..cubicTo(96, 30, 102, 32, 108, 34)
      ..cubicTo(114, 36, 110, 42, 106, 42)
      ..moveTo(110, 32)
      ..cubicTo(114, 20, 118, 10, 122, 8)
      ..cubicTo(126, 6, 124, 30, 122, 40)
      ..moveTo(126, 34)
      ..cubicTo(132, 28, 140, 30, 146, 32)
      ..cubicTo(152, 34, 150, 42, 142, 42)
      ..cubicTo(134, 42, 136, 34, 144, 34);
    canvas.drawPath(pathRest, strokePaint);

    // Point sur le 'i'
    canvas.drawCircle(const Offset(64, 20), 1.6, fillPaint);

    // Paraphe de soulignement élancé avec boucle
    final pathUnderline = Path()
      ..moveTo(20, 48)
      ..quadraticBezierTo(80, 51, 148, 43)
      ..quadraticBezierTo(158, 41, 144, 49)
      ..quadraticBezierTo(88, 54, 36, 52)
      ..close();
    canvas.drawPath(pathUnderline, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// MODAL D'APERÇU & IMPRESSION DE LA FACTURE A6 CONFORME AU MODÈLE
// =========================================================================
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
    return '$dd/$mm/$yyyy à $hh:$min:$ss';
  }

  String _buildPlainTextReceipt(AppState appState) {
    final buffer = StringBuffer();
    buffer.writeln('FACTURE N° ${sale.formattedInvoiceNumber}');
    buffer.writeln('Réf: ${sale.historyReference}');
    buffer.writeln(_formatDateTimeSeconds(sale.createdAt));
    if (sale.customerName.isNotEmpty && sale.customerName != 'Client Comptoir') {
      buffer.writeln('Client: ${sale.customerName}');
    }
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
    buffer.writeln('TOTAL : ${sale.total.toInt()} F CFA');
    buffer.writeln('Arrêté à : ${FrenchNumberToWords.convert(sale.total.round())} Francs CFA');
    buffer.writeln('Signature : Bricelo (Caisse)');
    buffer.writeln('--------------------------------');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final formatter = NumberFormat('#,###', 'fr_FR');
    const inkBlue = Color(0xFF1E3A8A);
    const accentRed = Color(0xFFDC2626);
    final totalInWords = FrenchNumberToWords.convert(sale.total.round());

    // Décodage du logo si présent
    Uint8List? logoBytes;
    if (appState.companyLogo.isNotEmpty) {
      try {
        final clean = appState.companyLogo.contains(',') ? appState.companyLogo.split(',').last : appState.companyLogo;
        logoBytes = base64Decode(clean);
      } catch (_) {}
    }

    const minTableRows = 4;
    final emptyRowsCount = (minTableRows - sale.items.length).clamp(0, minTableRows);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TITRE MODAL
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_rounded, color: AppTheme.accentGold, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Aperçu de la Facture (Format A6)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),

            // FEUILLE DE FACTURE BORDEREAU A6 CONFORME AU MODÈLE
            Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. RECTANGLE AVEC DOUBLE BORDURE BLEUE EN-TÊTE
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: inkBlue, width: 2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: inkBlue, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // LOGO RECTANGULAIRE STRICT S'ÉTIRANT PEU IMPORTE LA TAILLE
                          Container(
                            width: 105,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B4F9C),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: logoBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: Image.memory(
                                      logoBytes,
                                      fit: BoxFit.fill, // S'étire nettement pour remplir le cadre
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.home_work_outlined, color: Colors.white, size: 22),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'BRICELO',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5, letterSpacing: 0.5),
                                              ),
                                              Text(
                                                'CONFORT',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 7.5, letterSpacing: 0.5),
                                              ),
                                              Text(
                                                'Juste le confort !',
                                                style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 4.8),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),

                          // LIGNES D'INFOS MODIFIABLES
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: appState.invoiceHeaderLines.map((line) {
                                final isFirst = line == appState.invoiceHeaderLines.first;
                                final isPhone = line.label.toLowerCase().contains('tél') || line.value.toLowerCase().contains('tél');

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0.8),
                                  child: Text(
                                    line.value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isFirst ? 7.2 : (isPhone ? 8.8 : 6.4),
                                      color: inkBlue,
                                      height: 1.1,
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

                  const SizedBox(height: 6),

                  // 2. LIGNE DATE
                  Row(
                    children: [
                      const Text(
                        'Date: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue),
                      ),
                      Text(
                        _formatDateTimeSeconds(sale.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue),
                      ),
                      const Expanded(
                        child: Text(
                          ' ............................................................................................................',
                          style: TextStyle(fontSize: 8, color: inkBlue),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // 3. PILULE FACTURE + NUMÉRO TAMPON ROUGE
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: inkBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'FACTURE:',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sale.formattedInvoiceNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: accentRed,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          ' •',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: accentRed),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  // 4. LIGNE CLIENT & TÉL
                  Row(
                    children: [
                      const Text(
                        'Client: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue),
                      ),
                      if (sale.customerName.isNotEmpty && sale.customerName != 'Client Comptoir') ...[
                        Text(
                          sale.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue),
                        ),
                        const SizedBox(width: 3),
                      ],
                      const Expanded(
                        flex: 3,
                        child: Text(
                          ' .....................................................................',
                          style: TextStyle(fontSize: 8, color: inkBlue),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Tél: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue),
                      ),
                      if (sale.customerPhone.isNotEmpty) ...[
                        Text(
                          sale.customerPhone,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue),
                        ),
                        const SizedBox(width: 3),
                      ],
                      const Expanded(
                        flex: 2,
                        child: Text(
                          ' .....................................................................',
                          style: TextStyle(fontSize: 8, color: inkBlue),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 5. TABLEAU DES ARTICLES (Qtés | Désignations | P.U | P.Total)
                  Table(
                    border: TableBorder.all(color: inkBlue, width: 0.8),
                    columnWidths: const {
                      0: FixedColumnWidth(34),
                      1: FlexColumnWidth(3),
                      2: FixedColumnWidth(60),
                      3: FixedColumnWidth(70),
                    },
                    children: [
                      // En-tête
                      TableRow(
                        decoration: const BoxDecoration(color: Colors.white),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Text('Qtés', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                            child: Text('Désignations', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Text('P.U', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Text('P.Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.5, color: inkBlue)),
                          ),
                        ],
                      ),

                      // Articles
                      ...sale.items.map((it) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Text('${it.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: inkBlue)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                              child: Text(it.productName, style: const TextStyle(fontSize: 8, color: inkBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                              child: Text(formatter.format(it.unitPrice.round()), textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: inkBlue)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                              child: Text(formatter.format(it.total.round()), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: inkBlue)),
                            ),
                          ],
                        );
                      }),

                      // Lignes de remplissage
                      ...List.generate(emptyRowsCount, (_) {
                        return const TableRow(
                          children: [
                            SizedBox(height: 14),
                            SizedBox(height: 14),
                            SizedBox(height: 14),
                            SizedBox(height: 14),
                          ],
                        );
                      }),
                    ],
                  ),

                  // 6. TOTAL AVEC LA CAPSULE BLEUE
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: inkBlue, width: 0.8),
                        right: BorderSide(color: inkBlue, width: 0.8),
                        bottom: BorderSide(color: inkBlue, width: 0.8),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'TOTAL',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: inkBlue, letterSpacing: 1),
                          ),
                        ),
                        Container(
                          width: 140,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF60A5FA), // Capsule bleue conforme
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${formatter.format(sale.total.round())} F CFA',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9.5, color: Color(0xFF0D1B2E)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 7. ARRÊTÉ LA PRÉSENTE FACTURE À LA SOMME DE (LETTRES)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Arrêté la présente facture à la somme de: ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: inkBlue),
                            ),
                            TextSpan(
                              text: '$totalInWords Francs CFA',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: inkBlue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        '................................................................................................................................................................................................',
                        style: TextStyle(fontSize: 7.5, color: inkBlue),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 8. SIGNATURES (CLIENT & CAISSE AVEC SIGNATURE BRICELO DESSINÉE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text(
                          'Le Client:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: inkBlue),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Caisse',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: inkBlue),
                            ),
                            const SizedBox(height: 2),
                            // Signature manuscrite vectorielle Bricelo
                            SizedBox(
                              width: 75,
                              height: 26,
                              child: CustomPaint(
                                painter: const BriceloSignaturePainter(color: inkBlue, strokeWidth: 1.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // BOUTONS D'ACTION (IMPRIMER FACTURE A6 / PARTAGER A6 / WHATSAPP / FERMER)
            Container(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            foregroundColor: AppTheme.primaryNavy,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.print_rounded, size: 18, color: AppTheme.primaryNavy),
                          label: const Text('Imprimer (A6)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () async {
                            try {
                              await InvoicePrintService.printSale(sale);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur impression : $e')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.share_rounded, size: 18, color: AppTheme.accentGold),
                          label: const Text('Partager PDF (A6)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () async {
                            try {
                              await InvoicePrintService.shareSale(sale);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur partage : $e')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // WhatsApp
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                      label: const Text('Envoyer texte WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      onPressed: () {
                        final txt = _buildPlainTextReceipt(appState);
                        Clipboard.setData(ClipboardData(text: txt));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Facture copiée ! Collez-la dans WhatsApp pour l\'envoyer au client.')),
                        );
                      },
                    ),
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
