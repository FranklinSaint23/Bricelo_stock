import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class GlobalStatsPdfService {
  static String _formatFCFA(double amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(amount.round()).replaceAll(' ', ' ')} F CFA';
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

    final dateRangeStr = '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year} au ${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    final generatedAtStr = _formatDateTimeWithSeconds(now);

    // Charte graphique Bricelo officielle
    final primaryNavy = PdfColor.fromInt(0xFF0D1B2E); // Bleu Marine Bricelo
    final accentGold = PdfColor.fromInt(0xFFD97706); // Gold Bricelo
    final darkText = PdfColor.fromInt(0xFF0F172A); // Texte foncé
    final grayMuted = PdfColor.fromInt(0xFF64748B); // Gris labels
    final graySub = PdfColor.fromInt(0xFF94A3B8); // Gris sous-titres
    final chevronColor = PdfColor.fromInt(0xFFFBBF24); // Gold chevron
    final greenSuccess = PdfColor.fromInt(0xFF059669); // Vert succès
    final redAlert = PdfColor.fromInt(0xFFDC2626); // Rouge alerte
    final cardBg = PdfColor.fromInt(0xFFF8FAFC); // Fond carte clair
    final cardBorder = PdfColor.fromInt(0xFFE2E8F0); // Bordure carte

    // Widget pour une carte métrique principale
    pw.Widget buildMetricCard({
      required String label,
      required String value,
      String? subtitle,
      String? badge,
      PdfColor? valueColor,
      double valueSize = 15,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: cardBg,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: cardBorder, width: 0.8),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        label.toUpperCase(),
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 8.5,
                          color: grayMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (badge != null && badge.isNotEmpty) ...[
                        pw.SizedBox(width: 6),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFFFEF3C7),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            badge,
                            style: pw.TextStyle(font: fontBold, fontSize: 8, color: accentGold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    value,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: valueSize,
                      color: valueColor ?? primaryNavy,
                    ),
                  ),
                  if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      subtitle,
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 8,
                        color: grayMuted,
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
                fontSize: 14,
                color: chevronColor,
              ),
            ),
          ],
        ),
      );
    }

    // Widget pour une section détaillée
    pw.Widget buildSectionBlock({
      required String title,
      required String subtitle,
      required List<pw.Widget> children,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.all(11),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: cardBorder, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(font: fontBold, fontSize: 10.5, color: primaryNavy),
                ),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayMuted),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 0.5, color: cardBorder),
            pw.SizedBox(height: 4),
            ...children,
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        build: (pw.Context ctx) {
          return [
            // 1. BANNIÈRE EN-TÊTE BLEU MARINE BRICELO & GOLD
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: pw.BoxDecoration(
                color: primaryNavy,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    companyName.isNotEmpty ? companyName : (storeName != 'Tous' ? storeName : 'Bricelo Confort'),
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 16,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'RAPPORT DES STATISTIQUES GLOBALES DU SYSTÈME',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 8.5,
                      color: accentGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // 2. MÉTADONNÉES DU RAPPORT AVEC SECONDES & BOUTIQUE
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: cardBg,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: cardBorder, width: 0.6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('GÉNÉRÉ PAR', style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: grayMuted)),
                      pw.SizedBox(height: 2),
                      pw.Text(userName.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 10, color: darkText)),
                      if (userEmail.isNotEmpty)
                        pw.Text(userEmail, style: pw.TextStyle(font: fontRegular, fontSize: 8, color: grayMuted)),
                      pw.SizedBox(height: 3),
                      pw.Text('Édité le : $generatedAtStr', style: pw.TextStyle(font: fontBold, fontSize: 8, color: primaryNavy)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('PÉRIODE', style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: grayMuted)),
                      pw.SizedBox(height: 2),
                      pw.Text(periodName, style: pw.TextStyle(font: fontBold, fontSize: 10, color: accentGold)),
                      pw.Text(dateRangeStr, style: pw.TextStyle(font: fontRegular, fontSize: 8, color: grayMuted)),
                      pw.SizedBox(height: 3),
                      pw.Text('Boutique : ${storeName == "Tous" ? "Toutes les boutiques" : storeName}', style: pw.TextStyle(font: fontBold, fontSize: 8, color: primaryNavy)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // 3. CARTES FINANCIÈRES MAJEURES (Ventes totales, Bénéfice brut, Bénéfice net)
            buildMetricCard(
              label: 'Ventes totales',
              value: _formatFCFA(totalRevenue),
              subtitle: peakRevenueText.isNotEmpty ? peakRevenueText : 'Aucun pic de vente sur la période',
              valueColor: primaryNavy,
              valueSize: 16,
            ),
            pw.SizedBox(height: 6),

            pw.Row(
              children: [
                pw.Expanded(
                  child: buildMetricCard(
                    label: 'Bénéfice brut',
                    value: _formatFCFA(grossMargin),
                    badge: '${marginRate.toStringAsFixed(1)}% marge',
                    subtitle: peakGrossText.isNotEmpty ? peakGrossText : null,
                    valueColor: accentGold,
                    valueSize: 13,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: buildMetricCard(
                    label: 'Bénéfice net',
                    value: _formatFCFA(netProfit),
                    badge: 'Net',
                    subtitle: peakNetText.isNotEmpty ? peakNetText : (totalExpenses > 0 ? 'Dépenses : ${_formatFCFA(totalExpenses)}' : 'Aucune dépense'),
                    valueColor: netProfit >= 0 ? greenSuccess : redAlert,
                    valueSize: 13,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            // INDICATEURS SECONDAIRES
            pw.Row(
              children: [
                pw.Expanded(
                  child: buildMetricCard(
                    label: 'Nombre de ventes',
                    value: '$totalSalesCount transaction(s)',
                    valueSize: 11,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: buildMetricCard(
                    label: 'Remises accordées',
                    value: _formatFCFA(totalDiscounts),
                    valueColor: redAlert,
                    valueSize: 11,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            pw.Row(
              children: [
                pw.Expanded(
                  child: buildMetricCard(
                    label: 'Panier moyen',
                    value: _formatFCFA(averageBasket),
                    valueSize: 11,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: buildMetricCard(
                    label: 'Charges & Dépenses',
                    value: _formatFCFA(totalExpenses),
                    valueColor: redAlert,
                    valueSize: 11,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // 4. BOUTIQUE LA PLUS PRODUCTIVE (Si Toutes sélectionné)
            if (storeName == 'Tous' && storeProductivity.isNotEmpty)
              buildSectionBlock(
                title: 'Boutique la plus productive',
                subtitle: 'Classement par chiffre d\'affaires',
                children: storeProductivity.map((sp) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          sp.storeName,
                          style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: darkText),
                        ),
                        pw.Text(
                          '${_formatFCFA(sp.revenue)} (${sp.count} ventes • ${sp.percent.toStringAsFixed(1)}%)',
                          style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: primaryNavy),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            // 5. MEILLEURS PRODUITS LES PLUS VENDUS (Top actions)
            buildSectionBlock(
              title: 'Meilleurs produits vendus',
              subtitle: '${topProducts.length} référence(s) vendue(s)',
              children: topProducts.isEmpty
                  ? [pw.Text('Aucune vente enregistrée sur la période', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayMuted))]
                  : topProducts.take(8).map((p) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 3),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                p.name,
                                style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: darkText),
                                maxLines: 1,
                              ),
                            ),
                            pw.Text(
                              '${p.quantity} unité(s) vendue(s) • ${_formatFCFA(p.revenue)}',
                              style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: primaryNavy),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
            ),

            // 6. MEILLEURS CLIENTS
            buildSectionBlock(
              title: 'Meilleurs clients',
              subtitle: '${topCustomers.length} client(s) actif(s)',
              children: topCustomers.isEmpty
                  ? [pw.Text('Aucun client enregistré sur la période', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayMuted))]
                  : topCustomers.take(5).map((c) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 3),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(c.name, style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: darkText)),
                                  pw.Text('${c.ordersCount} visite(s) • Préféré : ${c.favProduct}', style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: grayMuted)),
                                ],
                              ),
                            ),
                            pw.Text(_formatFCFA(c.totalSpent), style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: greenSuccess)),
                          ],
                        ),
                      );
                    }).toList(),
            ),

            // 7. MEILLEURS FOURNISSEURS
            buildSectionBlock(
              title: 'Meilleurs fournisseurs',
              subtitle: '${topSuppliers.length} fournisseur(s) répertorié(s)',
              children: topSuppliers.isEmpty
                  ? [pw.Text('Aucun approvisionnement enregistré', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayMuted))]
                  : topSuppliers.take(5).map((s) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 3),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(s.name, style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: darkText)),
                                  pw.Text('Fournit principalement : ${s.mainProduct} (${s.supplyCount} comm.)', style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: grayMuted)),
                                ],
                              ),
                            ),
                            pw.Text(_formatFCFA(s.totalSpent), style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: primaryNavy)),
                          ],
                        ),
                      );
                    }).toList(),
            ),

            // 8. MODES DE PAIEMENT
            buildSectionBlock(
              title: 'Modes de paiement',
              subtitle: 'Classés du plus utilisé au moins utilisé',
              children: paymentMethods.isEmpty
                  ? [pw.Text('Aucun paiement enregistré', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: grayMuted))]
                  : paymentMethods.map((pm) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('${pm.method} (${pm.count} ventes)', style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: darkText)),
                            pw.Text('${_formatFCFA(pm.amount)} (${pm.percent.toStringAsFixed(1)}%)', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: primaryNavy)),
                          ],
                        ),
                      );
                    }).toList(),
            ),

            // 9. ÉQUIPE & PERFORMANCE DES CAISSIERS
            buildSectionBlock(
              title: 'Équipe & Caissiers de la boutique',
              subtitle: 'Performance des ventes par équipier',
              children: teamMembers.isEmpty
                  ? [pw.Text('$userName ($companyName) • Propriétaire', style: pw.TextStyle(font: fontBold, fontSize: 8.5))]
                  : teamMembers.map((tm) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('${tm.name} (${tm.role})', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: darkText)),
                            pw.Text('${_formatFCFA(tm.revenue)} (${tm.count} ventes)', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: primaryNavy)),
                          ],
                        ),
                      );
                    }).toList(),
            ),

            // 10. GESTION DES STOCKS (FAIBLES & ÉLEVÉS)
            buildSectionBlock(
              title: 'Niveaux de stock critiques & Tops stocks',
              subtitle: 'Surveillance des ruptures et des surstocks',
              children: [
                pw.Text('STOCKS LES PLUS FAIBLES (URGENCES)', style: pw.TextStyle(font: fontBold, fontSize: 8, color: redAlert)),
                pw.SizedBox(height: 3),
                ...lowestStocks.take(5).map((p) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(p.name, style: pw.TextStyle(font: fontRegular, fontSize: 8, color: darkText)),
                        pw.Text(
                          p.stock <= 0 ? 'Épuisé (0)' : '${p.stock} ${p.unit}(s)',
                          style: pw.TextStyle(font: fontBold, fontSize: 8, color: p.stock <= 0 ? redAlert : accentGold),
                        ),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 5),
                pw.Divider(thickness: 0.4, color: cardBorder),
                pw.SizedBox(height: 3),
                pw.Text('STOCKS LES PLUS ÉLEVÉS', style: pw.TextStyle(font: fontBold, fontSize: 8, color: greenSuccess)),
                pw.SizedBox(height: 3),
                ...highestStocks.take(5).map((p) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(p.name, style: pw.TextStyle(font: fontRegular, fontSize: 8, color: darkText)),
                        pw.Text('${p.stock} ${p.unit}(s)', style: pw.TextStyle(font: fontBold, fontSize: 8, color: greenSuccess)),
                      ],
                    ),
                  );
                }),
              ],
            ),

            // 11. RÉSULTATS DES INVENTAIRES PHYSIQUES
            buildSectionBlock(
              title: 'Résultats des inventaires physiques',
              subtitle: 'Audits de stock clôturés sur la période',
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Inventaires clôturés :', style: pw.TextStyle(font: fontRegular, fontSize: 8.5)),
                    pw.Text('$totalInventoriesCount session(s)', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: darkText)),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Unités comptées / théoriques :', style: pw.TextStyle(font: fontRegular, fontSize: 8.5)),
                    pw.Text('$totalCountedUnits / $totalTheoreticalUnits unités', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: darkText)),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Écart total constaté :', style: pw.TextStyle(font: fontRegular, fontSize: 8.5)),
                    pw.Text(
                      _formatFCFA(totalDiscrepancyValue),
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 8.5,
                        color: totalDiscrepancyValue == 0 ? greenSuccess : redAlert,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Rapport officiel certifié conforme • Bricelo Stock',
                style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: graySub),
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
