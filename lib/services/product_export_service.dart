import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stock_prime/services/app_state.dart';

class ProductExportService {
  static Future<void> exportProductsToExcelCsv(BuildContext context) async {
    final appState = AppState.instance;
    final products = appState.products;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun produit à exporter.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    try {
      // Entêtes standards pour réimportation universelle
      final buffer = StringBuffer();

      // UTF-8 BOM pour ouverture directe et parfaite dans Excel sur PC, Mac et Mobile
      buffer.write('\uFEFF');

      // Entêtes
      buffer.writeln('nom_produit;qte;PU;cout_achat;categorie;code_barres;unite;type;seuil_alerte');

      for (final p in products) {
        final safeName = p.name.replaceAll(';', ',').replaceAll('\n', ' ');
        final safeCategory = p.category.replaceAll(';', ',').replaceAll('\n', ' ');
        final safeBarcode = p.barcode.replaceAll(';', ',');
        final safeUnit = p.unit.replaceAll(';', ',');

        buffer.writeln(
          '$safeName;${p.stock};${p.sellPrice.toInt()};${p.buyPrice.toInt()};$safeCategory;$safeBarcode;$safeUnit;${p.productType};${p.minStockAlert}',
        );
      }

      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, "0")}${now.day.toString().padLeft(2, "0")}_${now.hour.toString().padLeft(2, "0")}${now.minute.toString().padLeft(2, "0")}';
      final fileName = 'produits_bricelo_stock_$dateStr.csv';
      final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));

      XFile xFile;
      try {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        xFile = XFile(file.path, mimeType: 'text/csv', name: fileName);
      } catch (_) {
        xFile = XFile.fromData(bytes, mimeType: 'text/csv', name: fileName);
      }

      await Share.shareXFiles(
        [xFile],
        subject: 'Exportation de la liste des produits Bricelo Stock',
        text: 'Voici la liste complète de vos ${products.length} produits (Format Excel / CSV universel).',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF059669),
            content: Text('${products.length} produits exportés avec succès.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'exportation: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }
}
