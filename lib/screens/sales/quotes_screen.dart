import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final appState = AppState.instance;
  final List<Map<String, dynamic>> _quotes = [
    {
      'id': 'DEV-2026-001',
      'client': 'Hôtel Hilton Yaoundé',
      'phone': '+237 690 00 00 00',
      'validUntil': '30/11/2026',
      'items': [
        {'name': 'Matelas Orthopédique Royal', 'quantity': 5, 'price': 85000.0, 'total': 425000.0},
        {'name': 'Oreiller Ergonomique', 'quantity': 10, 'price': 12000.0, 'total': 120000.0},
      ],
      'total': 545000.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  void _showNewQuoteModal() {
    final clientCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    DateTime validUntil = DateTime.now().add(const Duration(days: 15));
    final List<Map<String, dynamic>> quoteItems = [];
    Product? selectedProduct;
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          double totalDevis = quoteItems.fold<double>(0.0, (sum, it) => sum + (it['total'] as double));

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
                  const SizedBox(height: 12),

                  // SÉLECTION CLIENT
                  TextField(
                    controller: clientCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nom du client ou entreprise *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Téléphone client',
                      prefixIcon: const Icon(Icons.phone_outlined),
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
                  const Text('Articles du devis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 8),

                  // AJOUT D'UN ARTICLE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      children: [
                        DropdownButtonFormField<Product>(
                          isExpanded: true,
                          value: selectedProduct,
                          hint: const Text('Sélectionner un produit existant'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: appState.products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (${p.sellPrice.toInt()} F CFA)'))).toList(),
                          onChanged: (p) {
                            if (p != null) {
                              setModalState(() {
                                selectedProduct = p;
                                priceCtrl.text = p.sellPrice.toInt().toString();
                              });
                            }
                          },
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                final pName = selectedProduct?.name ?? 'Article devis';
                                final qty = int.tryParse(qtyCtrl.text) ?? 1;
                                final pu = double.tryParse(priceCtrl.text) ?? 0.0;
                                if (pu <= 0) return;
                                setModalState(() {
                                  quoteItems.add({'name': pName, 'quantity': qty, 'price': pu, 'total': qty * pu});
                                  selectedProduct = null;
                                  qtyCtrl.text = '1';
                                  priceCtrl.clear();
                                });
                              },
                              child: const Text('Ajouter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // LISTE DES ARTICLES AJOUTÉS
                  if (quoteItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...quoteItems.asMap().entries.map((entry) {
                      final it = entry.value;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${it['name']} (×${it['quantity']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${(it['price'] as double).toInt()} FCFA / unité'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(it['total'] as double).toInt()} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                              onPressed: () => setModalState(() => quoteItems.removeAt(entry.key)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('MONTANT TOTAL DU DEVIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                          Text('${totalDevis.toInt()} F CFA', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.accentGold)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: AppTheme.primaryNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final client = clientCtrl.text.trim();
                        if (client.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez indiquer le nom du client.')));
                          return;
                        }
                        if (quoteItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez ajouter au moins un article au devis.')));
                          return;
                        }

                        final newQuote = {
                          'id': 'DEV-${DateTime.now().year}-${(_quotes.length + 1).toString().padLeft(3, '0')}',
                          'client': client,
                          'phone': phoneCtrl.text.trim(),
                          'validUntil': DateFormat('dd/MM/yyyy').format(validUntil),
                          'items': List.from(quoteItems),
                          'total': totalDevis,
                          'createdAt': DateTime.now(),
                        };

                        setState(() => _quotes.insert(0, newQuote));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Devis pour "$client" créé avec succès.')),
                        );
                      },
                      child: const Text('Créer le devis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  void _showQuoteDetails(Map<String, dynamic> q) {
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
                    Text(q['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentGold)),
                    Text(q['client'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.primaryNavy)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                  child: Text('Jusqu\'au ${q['validUntil']}', style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text('Articles inclus :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            ...(q['items'] as List<dynamic>? ?? []).map((it) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('${it['name']} (×${it['quantity']})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    Text('${(it['total'] as num).toInt()} FCFA', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
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
                Text(AppTheme.formatFCFA(q['total'] as num), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryNavy)),
              ],
            ),
            const SizedBox(height: 20),
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
                    icon: const Icon(Icons.share_rounded, size: 18, color: AppTheme.accentGold),
                    label: const Text('Partager devis', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Devis ${q['id']} copié et prêt à être envoyé par WhatsApp.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'Supprimer ce devis',
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () {
                    setState(() => _quotes.removeWhere((e) => e['id'] == q['id']));
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
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
        title: const Text(
          'Devis & Pro-formas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: _quotes.isEmpty
          ? const Center(
              child: Text(
                'Aucun devis pour le moment.\nTouchez "+" pour créer un devis.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _quotes.length,
              itemBuilder: (context, idx) {
                final q = _quotes[idx];
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
                    title: Text(q['client'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Réf: ${q['id']} • Valable jusqu\'au ${q['validUntil']}', style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      AppTheme.formatFCFA(q['total'] as num),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryNavy),
                    ),
                    onTap: () => _showQuoteDetails(q),
                  ),
                );
              },
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
  }
}
