import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ImportProductsScreen extends StatefulWidget {
  const ImportProductsScreen({super.key});

  @override
  State<ImportProductsScreen> createState() => _ImportProductsScreenState();
}

class _ImportProductsScreenState extends State<ImportProductsScreen> {
  final appState = AppState.instance;
  bool _isLoading = false;
  String? _selectedFileName;
  List<Product> _parsedProducts = [];
  final _pasteController = TextEditingController();

  Future<void> _pickAndParseFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls', 'txt', 'pdf', 'docx', 'doc'],
      );

      if (files.isEmpty) return;

      final file = files.first;
      setState(() {
        _isLoading = true;
        _selectedFileName = file.name;
        _parsedProducts = [];
      });

      String content = '';
      try {
        final bytes = await file.readAsBytes();
        try {
          content = utf8.decode(bytes, allowMalformed: true);
        } catch (_) {
          content = latin1.decode(bytes);
        }
      } catch (_) {
        if (file.path != null) {
          final f = File(file.path!);
          try {
            content = await f.readAsString(encoding: utf8);
          } catch (_) {
            content = await f.readAsString(encoding: latin1);
          }
        }
      }

      final products = _parseContentToProducts(content);

      setState(() {
        _isLoading = false;
        _parsedProducts = products;
      });

      if (products.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun format de produit détecté dans ce fichier. Vous pouvez aussi coller le texte directement.'),
              backgroundColor: Color(0xFFD97706),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lecture fichier: $e'), backgroundColor: const Color(0xFFDC2626)),
        );
      }
    }
  }

  void _parsePastedText() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;

    final products = _parseContentToProducts(text);
    setState(() {
      _selectedFileName = 'Texte / Tableau collé';
      _parsedProducts = products;
    });

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun produit détecté dans le texte collé. Vérifiez le format (Ex: Nom, Quantité, Prix).'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
    }
  }

  List<Product> _parseContentToProducts(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return [];

    final List<Product> result = [];
    int nameIdx = 0;
    int qtyIdx = 1;
    int priceIdx = 2;
    int buyPriceIdx = -1;
    int catIdx = -1;
    int barcodeIdx = -1;
    int unitIdx = -1;

    bool hasHeader = false;
    final firstLine = lines.first.toLowerCase();

    // Détecteur de séparateur (; ou , ou \t ou |)
    String separator = ';';
    if (firstLine.contains(';') && firstLine.split(';').length > 1) {
      separator = ';';
    } else if (firstLine.contains('\t')) {
      separator = '\t';
    } else if (firstLine.contains('|')) {
      separator = '|';
    } else if (firstLine.contains(',')) {
      separator = ',';
    }

    final headers = firstLine.split(separator).map((s) => s.trim().replaceAll('"', '').toLowerCase()).toList();

    if (headers.any((h) => h.contains('nom') || h.contains('designation') || h.contains('article') || h.contains('produit') || h.contains('name'))) {
      hasHeader = true;
      for (int i = 0; i < headers.length; i++) {
        final h = headers[i];
        if (h.contains('nom') || h.contains('designation') || h.contains('article') || h.contains('produit') || h == 'name') {
          nameIdx = i;
        } else if (h.contains('qte') || h.contains('quantite') || h.contains('stock') || h == 'qty') {
          qtyIdx = i;
        } else if (h.contains('pu') || h.contains('prix_vente') || h.contains('prix unitaire') || h.contains('prix') || h == 'price') {
          priceIdx = i;
        } else if (h.contains('cout') || h.contains('achat') || h.contains('cost') || h == 'buy_price') {
          buyPriceIdx = i;
        } else if (h.contains('cat') || h.contains('famille') || h == 'category') {
          catIdx = i;
        } else if (h.contains('code') || h.contains('barcode') || h.contains('barre')) {
          barcodeIdx = i;
        } else if (h.contains('unit') || h.contains('unite')) {
          unitIdx = i;
        }
      }
    }

    final startIndex = hasHeader ? 1 : 0;
    for (int i = startIndex; i < lines.length; i++) {
      final row = lines[i].split(separator).map((s) => s.trim().replaceAll('"', '')).toList();
      if (row.isEmpty) continue;

      String name = '';
      if (nameIdx < row.length) name = row[nameIdx].trim();
      if (name.isEmpty) continue;

      int qty = 1;
      if (qtyIdx < row.length) {
        final parsedQty = double.tryParse(row[qtyIdx].replaceAll(RegExp(r'[^0-9.]'), ''));
        if (parsedQty != null) qty = parsedQty.toInt();
      }

      double sellPrice = 0.0;
      if (priceIdx < row.length) {
        sellPrice = double.tryParse(row[priceIdx].replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      }

      double buyPrice = 0.0;
      if (buyPriceIdx >= 0 && buyPriceIdx < row.length) {
        buyPrice = double.tryParse(row[buyPriceIdx].replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      }

      String category = 'Général';
      if (catIdx >= 0 && catIdx < row.length && row[catIdx].isNotEmpty) {
        category = row[catIdx];
      }

      String barcode = '';
      if (barcodeIdx >= 0 && barcodeIdx < row.length) {
        barcode = row[barcodeIdx];
      }

      String unit = 'Pièce';
      if (unitIdx >= 0 && unitIdx < row.length && row[unitIdx].isNotEmpty) {
        unit = row[unitIdx];
      }

      result.add(Product(
        id: 'imp_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: name,
        category: category,
        sellPrice: sellPrice,
        buyPrice: buyPrice,
        stock: qty,
        unit: unit,
        barcode: barcode,
      ));
    }

    return result;
  }

  void _confirmImport() {
    if (_parsedProducts.isEmpty) return;

    for (final p in _parsedProducts) {
      // Si le produit existe déjà, incrémenter le stock
      final existing = appState.products.where((item) => item.name.trim().toLowerCase() == p.name.trim().toLowerCase()).firstOrNull;
      if (existing != null) {
        existing.stock += p.stock;
        if (p.sellPrice > 0) existing.sellPrice = p.sellPrice;
        if (p.buyPrice > 0) existing.buyPrice = p.buyPrice;
      } else {
        appState.addProduct(p);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF059669),
        content: Text('${_parsedProducts.length} produit(s) importé(s) dans votre stock avec succès !'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
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
        title: const Text(
          'Importer des produits',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. BANNIÈRE EXPLICATIVE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.upload_file_rounded, color: AppTheme.accentGold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Importation multi-formats',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                            Text(
                              'Excel (.xlsx, .xls), CSV, Word, PDF ou texte',
                              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Importez vos produits depuis un fichier ou copiez-collez simplement un tableau depuis Word / PDF. Les colonnes détectées sont : Nom du produit, Quantité, Prix unitaire, Coût, Catégorie.',
                    style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569), height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // Bouton Choisir un fichier
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.primaryNavy,
                        foregroundColor: AppTheme.accentGold,
                        side: BorderSide(color: isDark ? AppTheme.accentGold.withValues(alpha: 0.4) : Colors.transparent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.file_open_rounded, size: 20, color: AppTheme.accentGold),
                      label: Text(
                        _isLoading ? 'Lecture du fichier...' : 'Sélectionner un fichier (Excel, CSV, Word, PDF)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      onPressed: _isLoading ? null : _pickAndParseFile,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. OPTION COLLER DIRECTEMENT UN TABLEAU / TEXTE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ou coller un tableau copié',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Copiez un tableau de produits depuis Word, Excel ou WhatsApp et collez-le ici :',
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pasteController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Exemple :\nSavon; 20; 500\nLait en poudre; 10; 2500\nBiscotte; 15; 800",
                      hintStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.playlist_add_check, size: 18, color: Color(0xFF0F172A)),
                      label: const Text('Analyser le texte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: _parsePastedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. APERÇU DES PRODUITS DÉTECTÉS
            if (_parsedProducts.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Articles détectés (${_parsedProducts.length})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  if (_selectedFileName != null)
                    Flexible(
                      child: Text(
                        _selectedFileName!,
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _parsedProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final p = _parsedProducts[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF3C7),
                          child: Text('${idx + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : const Color(0xFFB45309))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                              Text('Catégorie: ${p.category}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${p.stock} ${p.unit}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                            Text(AppTheme.formatFCFA(p.sellPrice), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isDark ? AppTheme.accentGold : const Color(0xFFD97706))),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // BOUTON CONFIRMER L'IMPORTATION
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    'Importer ${_parsedProducts.length} produit(s) dans le stock',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: _confirmImport,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
