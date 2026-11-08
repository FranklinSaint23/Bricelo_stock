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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nouveau devis pro-forma',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // NOM DU CLIENT (OBLIGATOIRE)
                  TextField(
                    controller: clientCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nom du client ou entreprise *',
                      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // TÉLÉPHONE CLIENT (OBLIGATOIRE)
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Téléphone du client *',
                      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
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
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_outlined, color: AppTheme.primaryNavy, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Valable jusqu\'au : ${DateFormat('dd/MM/yyyy').format(validUntil)}',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_month, color: AppTheme.accentGold, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Articles du devis *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 8),

                  // AJOUT D'UN ARTICLE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (appState.products.isNotEmpty) ...[
                          DropdownButtonFormField<Product>(
                            isExpanded: true,
                            value: selectedProduct,
                            hint: const Text('Sélectionner un produit du catalogue', style: TextStyle(fontSize: 13)),
                            decoration: InputDecoration(
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
                          decoration: InputDecoration(
                            labelText: 'Désignation de l\'article',
                            labelStyle: const TextStyle(fontSize: 12),
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
                                decoration: InputDecoration(
                                  labelText: 'Quantité',
                                  labelStyle: const TextStyle(fontSize: 12),
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
                                decoration: InputDecoration(
                                  labelText: 'Prix unitaire (FCFA)',
                                  labelStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: Colors.white,
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
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${it.quantity} x ${it.price.toInt()} F CFA', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Text('${it.total.toInt()} F CFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, fontSize: 13)),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              onPressed: () => setModalState(() => quoteItems.removeAt(entry.key)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('MONTANT TOTAL DU DEVIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
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
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentGold)),
                    Text(q.client, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.primaryNavy)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'Jusqu\'au ${DateFormat('dd/MM/yyyy').format(q.validUntil)}',
                    style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (q.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Tél : ${q.phone}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text('Articles inclus :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            ...q.items.map((it) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('${it.name} (×${it.quantity})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    Text('${it.total.toInt()} F CFA', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL DU DEVIS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryNavy)),
                Text('${q.total.toInt()} F CFA', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryNavy)),
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

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: StockAppBar.forestGreen(
            title: 'Devis & Pro-formas',
            onBack: () => Navigator.pop(context),
          ),
          body: Column(
            children: [
              // BARRE DE RECHERCHE DEVIS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher par client, n° devis, téléphone...',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                            const Icon(Icons.description_outlined, size: 64, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 14),
                            const Text(
                              'Aucun devis enregistré',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Touchez le bouton ci-dessous pour créer un devis.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: _showNewQuoteModal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D1B2E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Créer un devis'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quotes.length,
                        itemBuilder: (context, idx) {
                          final q = quotes[idx];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFEFF6FF),
                                child: Icon(Icons.description_outlined, color: AppTheme.primaryNavy),
                              ),
                              title: Text(q.client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(
                                'Réf: ${q.id} • Valable jusqu\'au ${DateFormat('dd/MM/yyyy').format(q.validUntil)}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${q.total.toInt()} F CFA',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryNavy),
                                  ),
                                  Text(
                                    '${q.items.length} article(s)',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
            label: const Text(
              'Nouveau devis',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: _showNewQuoteModal,
          ),
        );
      },
    );
  }
}
