import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class GlobalStatsPdfService {
  static String _formatFCFA(double amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return 'Fr.${formatter.format(amount.round()).replaceAll(' ', ' ')}';
  }

  static String _formatDateTimeWithSeconds(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy à $hh:$min:$ss';
  }

  static Future<void> generateAndSharePdf({
    required String companyName,
    required String userName,
    required String userEmail,
    required String storeName,
    required String periodName,
    required DateTime startDate,
    required DateTime endDate,
    required double totalRevenue,
    required String peakRevenueText,
    required double grossMargin,
    required double marginRate,
    required String peakGrossText,
    required double netProfit,
    required String peakNetText,
    required double totalExpenses,
    required int totalSalesCount,
    required double totalDiscounts,
    required double averageBasket,
    required List<({String name, int quantity, double revenue})> topProducts,
    required List<({String name, double totalSpent, int ordersCount, String favProduct})> topCustomers,
    required List<({String name, double totalSpent, int supplyCount, String mainProduct})> topSuppliers,
    required List<({String method, double amount, int count, double percent})> paymentMethods,
    required List<({String name, String role, int count, double revenue})> teamMembers,
    required List<({String name, int stock, String unit})> lowestStocks,
    required List<({String name, int stock, String unit})> highestStocks,
    required int totalInventoriesCount,
    required double totalDiscrepancyValue,
    required int totalCountedUnits,
    required int totalTheoreticalUnits,
    required List<({String storeName, double revenue, int count, double percent})> storeProductivity,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontRegular = await PdfGoogleFonts.openSansRegular();

    final dateRangeStr = '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year} - ${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    final generatedAtStr = _formatDateTimeWithSeconds(now);

    // Couleurs officielles conformes au screenshot
    final primaryBlue = PdfColor.fromInt(0xFF2563EB); // Bleu royal header
    final darkNavy = PdfColor.fromInt(0xFF1E3A8A); // Bleu chiffres
    final grayLabel = PdfColor.fromInt(0xFF6B7280); // Gris labels
    final graySub = PdfColor.fromInt(0xFF9CA3AF); // Gris sous-titres
    final chevronColor = PdfColor.fromInt(0xFF93C5FD); // Bleu chevron
    final redAlert = PdfColor.fromInt(0xFFDC2626); // Rouge stock faible

    pw.Widget buildItemRow({
      required String label,
      required String value,
      String? subtitle,
      PdfColor? valueColor,
      bool isValueBold = true,
      double valueSize = 16,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    label.toUpperCase(),
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 9,
                      color: grayLabel,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    value,
                    style: pw.TextStyle(
                      font: isValueBold ? fontBold : fontRegular,
                      fontSize: valueSize,
                      color: valueColor ?? darkNavy,
                    ),
                  ),
                  if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      subtitle,
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 8.5,
                        color: graySub,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.Text(
              '>',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: chevronColor,
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context ctx) {
          // Top product string
          final bestProductStr = topProducts.isNotEmpty
              ? '${topProducts.first.name} : ${topProducts.first.quantity}'
              : 'Aucune vente enregistrée';
          final otherProductsStr = topProducts.length > 1
              ? topProducts.skip(1).take(3).map((p) => '${p.name} (${p.quantity})').join(' • ')
              : null;

          // Top client string
          final bestClientStr = topCustomers.isNotEmpty
              ? '${topCustomers.first.name} : ${_formatFCFA(topCustomers.first.totalSpent)}'
              : 'Aucun lien de vente vers aucun client !';
          final clientSub = topCustomers.isNotEmpty
              ? '${topCustomers.first.ordersCount} visite(s) • Préféré : ${topCustomers.first.favProduct}'
              : null;

          // Modes de paiement
          final paymentsStr = paymentMethods.isNotEmpty
              ? paymentMethods.take(3).map((pm) => '${pm.method} : ${_formatFCFA(pm.amount)} (${pm.percent.toStringAsFixed(0)}%)').join(' • ')
              : 'Aucun paiement enregistré';

          // Vendeurs
          final bestCashierStr = teamMembers.isNotEmpty ? teamMembers.first.name : userName;
          final cashierSubStr = teamMembers.length > 1
              ? '${teamMembers.length - 1} plus de caissier !'
              : '1 caissier actif';

          // Stock faible
          final lowestStr = lowestStocks.isNotEmpty
              ? '${lowestStocks.first.name} = ${lowestStocks.first.stock}.0'
              : 'Aucun stock critique';
          final lowestSubStr = lowestStocks.length > 1
              ? '${lowestStocks.length} plus d\'articles sont faibles'
              : 'Stocks sous contrôle';

          // Fournisseur
          final bestSupStr = topSuppliers.isNotEmpty
              ? '${topSuppliers.first.name} : ${_formatFCFA(topSuppliers.first.totalSpent)}'
              : 'Direct / Aucun fournisseur';
          final bestSupSub = topSuppliers.isNotEmpty
              ? 'Fournit principalement : ${topSuppliers.first.mainProduct}'
              : null;

          // Stock élevé
          final highestStr = highestStocks.isNotEmpty
              ? '${highestStocks.first.name} = ${highestStocks.first.stock} ${highestStocks.first.unit}(s)'
              : 'Aucun produit en stock';

          // Boutique productive
          final topStoreStr = storeProductivity.isNotEmpty
              ? '${storeProductivity.first.storeName} : ${_formatFCFA(storeProductivity.first.revenue)}'
              : storeName;
          final topStoreSub = storeProductivity.isNotEmpty
              ? '${storeProductivity.first.count} vente(s) • ${storeProductivity.first.percent.toStringAsFixed(0)}% du total'
              : null;

          // Inventaire
          final invStr = totalInventoriesCount > 0
              ? '$totalInventoriesCount session(s) d\'inventaire'
              : 'Aucun inventaire réalisé';
          final invSub = totalInventoriesCount > 0
              ? 'Écart total : ${_formatFCFA(totalDiscrepancyValue)} ($totalCountedUnits/$totalTheoreticalUnits unités)'
              : null;

          return [
            // 1. BANNIÈRE EN-TÊTE BLEUE
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: pw.BoxDecoration(
                color: primaryBlue,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Center(
                child: pw.Text(
                  companyName.isNotEmpty ? companyName : (storeName != 'Tous' ? storeName : 'Bricelo Confort'),
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 16,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 14),

            // 2. SOUS-EN-TÊTE MÉTADONNÉES (Généré par + Date avec secondes)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Généré par', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayLabel)),
                    pw.SizedBox(height: 2),
                    pw.Text(userName.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 11, color: darkNavy)),
                    if (userEmail.isNotEmpty)
                      pw.Text(userEmail, style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: graySub)),
                    pw.SizedBox(height: 3),
                    pw.Text('Généré le : $generatedAtStr', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: grayLabel)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Date', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayLabel)),
                    pw.SizedBox(height: 2),
                    pw.Text(dateRangeStr, style: pw.TextStyle(font: fontBold, fontSize: 10, color: darkNavy)),
                    pw.SizedBox(height: 2),
                    pw.Text('Période : $periodName', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayLabel)),
                    pw.Text('Boutique : ${storeName == "Tous" ? "Toutes les boutiques" : storeName}', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: primaryBlue)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.8, color: PdfColors.grey300),
            pw.SizedBox(height: 4),

            // 3. SECTIONS OFFICIELLES DU FORMALISME DEMANDÉ
            buildItemRow(
              label: 'Ventes totales',
              value: _formatFCFA(totalRevenue),
              subtitle: peakRevenueText.isNotEmpty ? peakRevenueText : null,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Bénéfices',
              value: _formatFCFA(grossMargin),
              subtitle: peakGrossText.isNotEmpty ? '$peakGrossText • ${marginRate.toStringAsFixed(1)}% de marge' : '${marginRate.toStringAsFixed(1)}% de marge',
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Bénéfices (Ventes - Dépenses)',
              value: totalExpenses > 0 ? _formatFCFA(netProfit) : 'Aucune dépense',
              subtitle: totalExpenses > 0 ? '$peakNetText • Total dépenses: ${_formatFCFA(totalExpenses)}' : 'Bénéfice net égal au bénéfice brut',
              valueColor: netProfit >= 0 ? darkNavy : redAlert,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Meilleures actions',
              value: bestProductStr,
              subtitle: otherProductsStr,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Ventes',
              value: '$totalSalesCount',
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Impôt',
              value: 'Fr.0',
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Remise',
              value: _formatFCFA(totalDiscounts),
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Valeur moyenne des ventes',
              value: _formatFCFA(averageBasket),
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Meilleur client',
              value: bestClientStr,
              subtitle: clientSub,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Modes de paiement',
              value: paymentsStr,
              valueSize: 13,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Vendu par',
              value: bestCashierStr,
              subtitle: cashierSubStr,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Stock faible',
              value: lowestStr,
              subtitle: lowestSubStr,
              valueColor: redAlert,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Stocks les plus élevés',
              value: highestStr,
            ),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),

            buildItemRow(
              label: 'Meilleur fournisseur',
              value: bestSupStr,
              subtitle: bestSupSub,
            ),

            if (storeName == 'Tous' && storeProductivity.isNotEmpty) ...[
              pw.Divider(thickness: 0.5, color: PdfColors.grey200),
              buildItemRow(
                label: 'Boutique la plus productive',
                value: topStoreStr,
                subtitle: topStoreSub,
              ),
            ],

            pw.Divider(thickness: 0.5, color: PdfColors.grey200),
            buildItemRow(
              label: 'Résultats des inventaires',
              value: invStr,
              subtitle: invSub,
            ),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'Rapport certifié conforme • Bricelo Stock',
                style: pw.TextStyle(font: fontRegular, fontSize: 8, color: graySub),
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final cleanStore = storeName.replaceAll(' ', '_');
    final filename = 'Statistiques_${cleanStore}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
