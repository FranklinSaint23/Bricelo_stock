import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final appState = AppState.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- PARTAGE DU DEVIS EN PDF ---
  Future<void> _shareQuotePdf(Quote quote) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // EN-TÊTE DE L'ENTREPRISE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        appState.displayCompanyName.toUpperCase(),
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                      ),
                      if (appState.companyAddress.isNotEmpty)
                        pw.Text(appState.companyAddress, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (appState.userPhone.isNotEmpty)
                        pw.Text('Tél : ${appState.userPhone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (appState.taxNumber.isNotEmpty)
                        pw.Text('N° Contribuable : ${appState.taxNumber}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blueGrey900,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('DEVIS PRO-FORMA', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        pw.Text('Réf : ${quote.id}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.amber)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // INFOS CLIENT & DATES
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CLIENT :', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.SizedBox(height: 2),
                      pw.Text(quote.client, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                      if (quote.phone.isNotEmpty)
                        pw.Text('Tél : ${quote.phone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date d\'émission : ${DateFormat('dd/MM/yyyy').format(quote.createdAt)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 2),
                      pw.Text('Date de validité : ${DateFormat('dd/MM/yyyy').format(quote.validUntil)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // TABLEAU DES ARTICLES
              pw.TableHelper.fromTextArray(
                headers: ['Désignation', 'Quantité', 'Prix Unitaire', 'Total'],
                data: quote.items.map((it) {
                  return [
                    it.name,
                    '${it.quantity}',
                    '${it.price.toInt()} F CFA',
                    '${it.total.toInt()} F CFA',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 16),

              // BANNIÈRE TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text('TOTAL DU DEVIS : ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey900)),
                        pw.Text('${quote.total.toInt()} F CFA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.blueGrey900)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // MENTION LÉGALE & SIGNATURE
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Validité : Jusqu\'au ${DateFormat('dd/MM/yyyy').format(quote.validUntil)}', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text('Passé ce délai, les prix et disponibilités peuvent être révisés.', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Bon pour accord (Signature et Cachet) :', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                        pw.SizedBox(height: 36),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Devis_${quote.id}_${quote.client.replaceAll(" ", "_")}.pdf',
    );
  }

  // --- PARTAGE VIA TEXTE / WHATSAPP ---
  void _shareQuoteText(Quote quote) {
    final buffer = StringBuffer();
    buffer.writeln('📋 *DEVIS PRO-FORMA - ${appState.displayCompanyName.toUpperCase()}*');
    buffer.writeln('Réf : *${quote.id}*');
    buffer.writeln('Client : *${quote.client}*');
    buffer.writeln('Validité : jusqu\'au ${DateFormat('dd/MM/yyyy').format(quote.validUntil)}');
    buffer.writeln('');
    buffer.writeln('*Articles :*');
    for (final it in quote.items) {
      buffer.writeln('• ${it.name} (x${it.quantity}) : ${it.total.toInt()} F CFA');
    }
    buffer.writeln('');
    buffer.writeln('💰 *MONTANT TOTAL : ${quote.total.toInt()} F CFA*');
    buffer.writeln('');
    buffer.writeln('Pour valider ce devis, contactez-nous au ${appState.userPhone}. Merci de votre confiance !');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texte du devis copié dans le presse-papier ! Prêt à être collé dans WhatsApp.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  // --- MODAL NOUVEAU DEVIS ---
  void _showNewQuoteModal() {
    final isDark = appState.isDarkMode;
    final clientCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    DateTime validUntil = DateTime.now().add(const Duration(days: 15));
    final List<QuoteItem> quoteItems = [];
    Product? selectedProduct;
    final customNameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          double totalDevis = quoteItems.fold<double>(0.0, (sum, it) => sum + it.total);

          void tryAddPendingItem() {
            final pName = selectedProduct?.name ?? customNameCtrl.text.trim();
            final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
            final pu = double.tryParse(priceCtrl.text.trim()) ?? (selectedProduct?.sellPrice ?? 0.0);

            if (pName.isNotEmpty && qty > 0 && pu > 0) {
              quoteItems.add(
                QuoteItem(
                  name: pName,
                  quantity: qty,
                  price: pu,
                  total: qty * pu,
                ),
              );
              selectedProduct = null;
              customNameCtrl.clear();
              qtyCtrl.text = '1';
              priceCtrl.clear();
            }
          }

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nouveau devis pro-forma',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : AppTheme.primaryNavy,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // NOM DU CLIENT (OBLIGATOIRE)
                  TextField(
                    controller: clientCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Nom du client ou entreprise *',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                      prefixIcon: Icon(Icons.person_outline, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: isDark,
                      fillColor: isDark ? const Color(0xFF162540) : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // TÉLÉPHONE CLIENT (OBLIGATOIRE)
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Téléphone du client *',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                      prefixIcon: Icon(Icons.phone_outlined, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: isDark,
                      fillColor: isDark ? const Color(0xFF162540) : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // DATE DE VALIDITÉ
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: validUntil,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => validUntil = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF162540) : null,
                        border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_outlined, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Valable jusqu\'au : ${DateFormat('dd/MM/yyyy').format(validUntil)}',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_month, color: AppTheme.accentGold, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Articles du devis *',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // AJOUT D'UN ARTICLE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (appState.products.isNotEmpty) ...[
                          DropdownButtonFormField<Product>(
                            isExpanded: true,
                            value: selectedProduct,
                            dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            hint: Text('Sélectionner un produit du catalogue', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                            decoration: InputDecoration(
                              filled: isDark,
                              fillColor: isDark ? const Color(0xFF162540) : null,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: appState.products.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text('${p.name} (${p.sellPrice.toInt()} F CFA)', style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (p) {
                              if (p != null) {
                                setModalState(() {
                                  selectedProduct = p;
                                  customNameCtrl.text = p.name;
                                  priceCtrl.text = p.sellPrice.toInt().toString();
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                        ],

                        TextField(
                          controller: customNameCtrl,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Désignation de l\'article',
                            labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            filled: isDark,
                            fillColor: isDark ? const Color(0xFF162540) : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: qtyCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Quantité',
                                  labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  filled: isDark,
                                  fillColor: isDark ? const Color(0xFF162540) : null,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Prix unitaire (FCFA)',
                                  labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  filled: isDark,
                                  fillColor: isDark ? const Color(0xFF162540) : null,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () {
                                final pName = selectedProduct?.name ?? customNameCtrl.text.trim();
                                final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
                                final pu = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

                                if (pName.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez saisir ou sélectionner un produit.')),
                                  );
                                  return;
                                }
                                if (pu <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez renseigner un prix unitaire valide.')),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  quoteItems.add(QuoteItem(name: pName, quantity: qty, price: pu, total: qty * pu));
                                  selectedProduct = null;
                                  customNameCtrl.clear();
                                  qtyCtrl.text = '1';
                                  priceCtrl.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // LISTE DES ARTICLES DU DEVIS
                  if (quoteItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...quoteItems.asMap().entries.map((entry) {
                      final it = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                                  Text('${it.quantity} x ${it.price.toInt()} F CFA', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Text('${it.total.toInt()} F CFA', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontSize: 13)),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              onPressed: () => setModalState(() => quoteItems.removeAt(entry.key)),
                            ),
                          ],
                        ),
                      );
                    }),
                    Divider(height: 12, color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('MONTANT TOTAL DU DEVIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppTheme.primaryNavy)),
                          Text('${totalDevis.toInt()} F CFA', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFD97706))),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // BOUTON CRÉER LE DEVIS AVEC VALIDATION STRICTE
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                        foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: () {
                        // 1. Si un article est en cours de saisie, l'ajouter
                        tryAddPendingItem();
                        totalDevis = quoteItems.fold<double>(0.0, (sum, it) => sum + it.total);

                        final client = clientCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();

                        // 2. Contrôle strict de tous les champs
                        final List<String> missingFields = [];
                        if (client.isEmpty) missingFields.add('Nom du client');
                        if (phone.isEmpty) missingFields.add('Téléphone');
                        if (quoteItems.isEmpty) missingFields.add('Au moins un article');

                        if (missingFields.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFDC2626),
                              duration: const Duration(seconds: 4),
                              content: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Veuillez remplir tous les champs obligatoires : ${missingFields.join(", ")}.',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          return;
                        }

                        // 3. Création du devis
                        final newQuote = Quote(
                          id: 'DEV-${DateTime.now().year}-${(appState.quotes.length + 1).toString().padLeft(3, '0')}',
                          client: client,
                          phone: phone,
                          validUntil: validUntil,
                          items: List.from(quoteItems),
                          total: totalDevis,
                          createdAt: DateTime.now(),
                        );

                        appState.addQuote(newQuote);
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF16A34A),
                            content: Text('Devis ${newQuote.id} pour "$client" créé avec succès.'),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 18, color: AppTheme.accentGold),
                          SizedBox(width: 8),
                          Text('Créer le devis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- MODAL DÉTAILS DU DEVIS ---
  void _showQuoteDetails(Quote q) {
    final isDark = appState.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentGold)),
                    Text(
                      q.client,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: isDark ? Colors.white : AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Jusqu\'au ${DateFormat('dd/MM/yyyy').format(q.validUntil)}',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (q.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Tél : ${q.phone}',
                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ],
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            Text(
              'Articles inclus :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            ...q.items.map((it) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${it.name} (×${it.quantity})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '${it.total.toInt()} F CFA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL DU DEVIS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppTheme.primaryNavy,
                  ),
                ),
                Text(
                  '${q.total.toInt()} F CFA',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BOUTONS DE PARTAGE (PDF & TEXTE/WHATSAPP) & SUPPRESSION
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 18, color: AppTheme.accentGold),
                    label: const Text('Partager PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _shareQuotePdf(q);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFF16A34A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _shareQuoteText(q);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Supprimer ce devis',
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () {
                    appState.deleteQuote(q.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devis supprimé.')));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final query = _searchCtrl.text.trim().toLowerCase();
        final quotes = appState.quotes.where((q) {
          if (query.isEmpty) return true;
          return q.client.toLowerCase().contains(query) ||
              q.id.toLowerCase().contains(query) ||
              q.phone.toLowerCase().contains(query);
        }).toList();

        final isDark = appState.isDarkMode;
        final pageBg = isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC);
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFD1D5DB);
        final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
            ),
            title: Text(
              'Devis & Pro-formas'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              // BARRE DE RECHERCHE DEVIS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cardBorder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par client, n° devis, téléphone...'.tr,
                      hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                      prefixIcon: Icon(Icons.search, size: 20, color: isDark ? AppTheme.accentGold : const Color(0xFF6B7280)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              // LISTE DYNAMIQUE DES DEVIS
              Expanded(
                child: quotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined, size: 64, color: textSecondary),
                            const SizedBox(height: 14),
                            Text(
                              'Aucun devis enregistré'.tr,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Touchez "+ Nouveau devis" pour créer un devis.'.tr,
                              style: TextStyle(fontSize: 13, color: textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quotes.length,
                        itemBuilder: (context, idx) {
                          final q = quotes[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cardBorder),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 4, offset: const Offset(0, 1)),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: isDark ? const Color(0xFF1E3052) : const Color(0xFFEFF6FF),
                                child: Icon(Icons.description_outlined, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                              ),
                              title: Text(q.client, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                              subtitle: Text(
                                '${'Réf'.tr}: ${q.id} • ${'Valable jusqu\'au'.tr} ${DateFormat('dd/MM/yyyy').format(q.validUntil)}',
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${q.total.toInt()} F CFA',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                                  ),
                                  Text(
                                    '${q.items.length} ${'article(s)'.tr}',
                                    style: TextStyle(fontSize: 11, color: textSecondary),
                                  ),
                                ],
                              ),
                              onTap: () => _showQuoteDetails(q),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accentGold,
            foregroundColor: AppTheme.primaryNavy,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              'Nouveau devis'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: _showNewQuoteModal,
          ),
        );
      },
    );
  }
}
