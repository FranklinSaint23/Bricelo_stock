import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/inventory/stock_depreciation_screen.dart';

class DepreciationReportScreen extends StatefulWidget {
  const DepreciationReportScreen({super.key});

  @override
  State<DepreciationReportScreen> createState() => _DepreciationReportScreenState();
}

class _DepreciationReportScreenState extends State<DepreciationReportScreen> {
  final appState = AppState.instance;

  String _selectedPeriod = 'Ce mois';
  final List<String> _periods = [
    'Aujourd\'hui',
    'Hier',
    'Cette semaine',
    'Semaine passée',
    'Ce mois',
    'Le mois passé',
    'Cette année',
    'L\'année dernière',
    'Personnalisé',
  ];

  DateTimeRange? _customDateRange;

  bool _matchesPeriod(DateTime date) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case 'Aujourd\'hui':
        return date.isAfter(startOfToday.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfToday.add(const Duration(seconds: 1)));
      case 'Hier':
        final start = startOfToday.subtract(const Duration(days: 1));
        final end = DateTime(start.year, start.month, start.day, 23, 59, 59);
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      case 'Cette semaine':
        final start = startOfToday.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfToday.add(const Duration(seconds: 1)));
      case 'Semaine passée':
        final startThisWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
        final startLastWeek = startThisWeek.subtract(const Duration(days: 7));
        final endLastWeek = startThisWeek.subtract(const Duration(seconds: 1));
        return date.isAfter(startLastWeek.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endLastWeek.add(const Duration(seconds: 1)));
      case 'Ce mois':
        final start = DateTime(now.year, now.month, 1);
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfToday.add(const Duration(seconds: 1)));
      case 'Le mois passé':
        final firstDayPrevMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayPrevMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return date.isAfter(firstDayPrevMonth.subtract(const Duration(seconds: 1))) &&
            date.isBefore(lastDayPrevMonth.add(const Duration(seconds: 1)));
      case 'Cette année':
        final start = DateTime(now.year, 1, 1);
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfToday.add(const Duration(seconds: 1)));
      case 'L\'année dernière':
        final start = DateTime(now.year - 1, 1, 1);
        final end = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      case 'Personnalisé':
        if (_customDateRange == null) return true;
        final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
        final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      default:
        return true;
    }
  }

  Future<void> _shareReportPdf(List<StockDepreciation> items, double totalLoss, int totalQty) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      appState.displayCompanyName,
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text('Rapport des dépréciations & pertes de stock', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Période: $_selectedPeriod', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Édité le: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          // BANNIÈRE KPI
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.red50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.red200),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Perte totale', style: const pw.TextStyle(fontSize: 10, color: PdfColors.red800)),
                    pw.SizedBox(height: 4),
                    pw.Text('${totalLoss.toStringAsFixed(0)} F CFA', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Articles dépréciés', style: const pw.TextStyle(fontSize: 10, color: PdfColors.red800)),
                    pw.SizedBox(height: 4),
                    pw.Text('$totalQty pièce(s)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Nombre de déclarations', style: const pw.TextStyle(fontSize: 10, color: PdfColors.red800)),
                    pw.SizedBox(height: 4),
                    pw.Text('${items.length}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          // TABLEAU
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Produit', 'Motif', 'Boutique', 'Qté', 'Coût Unitaire', 'Perte Totale'],
            data: items.map((dep) => [
              '${dep.date.day.toString().padLeft(2, '0')}/${dep.date.month.toString().padLeft(2, '0')}/${dep.date.year}',
              dep.productName,
              dep.reason,
              dep.storeName,
              '${dep.quantity}',
              '${dep.unitCost.toStringAsFixed(0)} F CFA',
              '${dep.totalLoss.toStringAsFixed(0)} F CFA',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Rapport_Depreciations_${_selectedPeriod.replaceAll(" ", "_")}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final filteredDepreciations = appState.stockDepreciations.where((d) => _matchesPeriod(d.date)).toList();

        final totalLoss = filteredDepreciations.fold<double>(0.0, (sum, d) => sum + d.totalLoss);
        final totalQty = filteredDepreciations.fold<int>(0, (sum, d) => sum + d.quantity);

        // Motif dominant
        final Map<String, int> reasonCounts = {};
        for (final d in filteredDepreciations) {
          reasonCounts[d.reason] = (reasonCounts[d.reason] ?? 0) + 1;
        }
        String topReason = 'Aucun';
        int maxCount = 0;
        reasonCounts.forEach((reason, count) {
          if (count > maxCount) {
            maxCount = count;
            topReason = reason;
          }
        });

        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
        final titleCol = isDark ? Colors.white : const Color(0xFF111827);
        final subtitleCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB),
          appBar: StockAppBar.forestGreen(
            title: 'Rapport de dépréciations',
            onBack: () => Navigator.pop(context),
            actions: [
              if (filteredDepreciations.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Partager le rapport PDF',
                  onPressed: () => _shareReportPdf(filteredDepreciations, totalLoss, totalQty),
                ),
            ],
          ),
          body: Column(
            children: [
              // 1. BARRE DE FILTRES TEMPORELS HORIZONTALE
              Container(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _periods.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final period = _periods[index];
                      final isSelected = _selectedPeriod == period;

                      return InkWell(
                        onTap: () async {
                          if (period == 'Personnalisé') {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: _customDateRange ??
                                  DateTimeRange(
                                    start: DateTime.now().subtract(const Duration(days: 7)),
                                    end: DateTime.now(),
                                  ),
                            );
                            if (picked != null) {
                              setState(() {
                                _customDateRange = picked;
                                _selectedPeriod = period;
                              });
                            }
                          } else {
                            setState(() => _selectedPeriod = period);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEA580C)
                                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(color: const Color(0xFFEA580C), width: 1.2)
                                : Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                period,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
                                ),
                              ),
                              if (period == 'Personnalisé' && _customDateRange != null && isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.date_range, size: 14, color: Colors.white),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2. CONTENU PRINCIPAL
              Expanded(
                child: filteredDepreciations.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ICÔNE CARTON AVEC CROIX
                              SizedBox(
                                width: 68,
                                height: 68,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                        size: 56,
                                        color: subtitleCol,
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      bottom: 6,
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: subtitleCol,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Aucune dépréciation',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: titleCol,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucune perte de stock enregistrée pour la période « $_selectedPeriod ».',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleCol,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 22),

                              // BOUTON + Enregistrer une dépréciation
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StockDepreciationScreen()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFFEA580C) : const Color(0xFFFED7AA),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add, size: 18, color: isDark ? Colors.white : const Color(0xFF111827)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Enregistrer une dépréciation',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // RÉSUMÉ KPI CARDS
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Perte totale',
                                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${totalLoss.toStringAsFixed(0)} F CFA',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: cardBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Qté dépréciée',
                                        style: TextStyle(fontSize: 12, color: subtitleCol),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$totalQty pièce(s)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: titleCol,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.pie_chart_outline, color: Color(0xFFEA580C), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Motif principal :',
                                  style: TextStyle(fontSize: 13, color: subtitleCol),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  topReason,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: titleCol,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$maxCount cas',
                                  style: TextStyle(fontSize: 12, color: subtitleCol),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Détail des pertes (${filteredDepreciations.length})',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: titleCol),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StockDepreciationScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Ajouter'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // LISTE DES ARTICLES DÉPRÉCIÉS
                          ...filteredDepreciations.map((dep) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dep.productName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: titleCol,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${dep.date.day.toString().padLeft(2, '0')}/${dep.date.month.toString().padLeft(2, '0')}/${dep.date.year} à ${dep.date.hour.toString().padLeft(2, '0')}:${dep.date.minute.toString().padLeft(2, '0')} • ${dep.storeName}',
                                              style: TextStyle(fontSize: 12, color: subtitleCol),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '-${dep.quantity} pcs',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFDC2626),
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '${dep.totalLoss.toStringAsFixed(0)} F CFA',
                                            style: TextStyle(fontSize: 12, color: subtitleCol),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF7C2D12).withValues(alpha: 0.4) : const Color(0xFFFFF7ED),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: isDark ? const Color(0xFFEA580C) : const Color(0xFFFED7AA)),
                                        ),
                                        child: Text(
                                          dep.reason,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                                          ),
                                        ),
                                      ),
                                      if (dep.notes.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            dep.notes,
                                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: subtitleCol),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
              ),
            ],
          ),
          bottomNavigationBar: StockBottomBar(
            currentIndex: 4,
            onTap: (_) => Navigator.pop(context),
          ),
        );
      },
    );
  }
}
