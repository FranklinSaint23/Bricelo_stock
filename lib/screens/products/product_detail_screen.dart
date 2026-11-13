import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/product_image_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final appState = AppState.instance;
  bool _showLots = false;
  bool _showPriceHistory = false;
  final List<Map<String, dynamic>> _variants = [];

  Product get _currentProduct {
    return appState.products.firstWhere(
      (item) => item.id == widget.product.id,
      orElse: () => widget.product,
    );
  }

  Future<void> _pickAndChangeProductPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        final p = _currentProduct;
        p.imageUrl = base64Image;
        appState.updateProduct(p);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF059669),
              content: Text('Photo du produit mise à jour avec succès !'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du changement de photo: $e')),
        );
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    final isDark = appState.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Modifier la photo du produit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? const Color(0xFF162540) : const Color(0xFFE2E8F0),
                  child: Icon(Icons.camera_alt, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                ),
                title: Text('Prendre une photo', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndChangeProductPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? const Color(0xFF162540) : const Color(0xFFE2E8F0),
                  child: Icon(Icons.photo_library, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                ),
                title: Text('Choisir dans la galerie', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndChangeProductPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddVariantDialog(BuildContext context) {
    final isDark = appState.isDarkMode;
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: _currentProduct.sellPrice.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ajouter une variante',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skuCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'SKU',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: barcodeCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Code-barres',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Prix de vente',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : AppTheme.primaryNavy,
              side: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.primaryNavy,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _variants.add({
                    'name': nameCtrl.text.trim(),
                    'sku': skuCtrl.text.trim(),
                    'barcode': barcodeCtrl.text.trim(),
                    'price': double.tryParse(priceCtrl.text.trim()) ?? _currentProduct.sellPrice,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Variante "${nameCtrl.text.trim()}" ajoutée')),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showLabelsDialog(BuildContext context, Product p) {
    final isDark = appState.isDarkMode;
    int copies = 1;
    String format = '50x30 mm';
    bool showPrice = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Générer des étiquettes',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
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
                const SizedBox(height: 12),
                Text(
                  'Format d\'étiquette',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['50x30 mm', '70x40 mm', 'Planche A4'].map((fmt) {
                    final isSel = format == fmt;
                    return ChoiceChip(
                      label: Text(fmt),
                      selected: isSel,
                      selectedColor: AppTheme.accentGold,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : null,
                      labelStyle: TextStyle(
                        color: isSel
                            ? AppTheme.primaryNavy
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setMState(() => format = fmt),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nombre d\'exemplaires',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: isDark ? Colors.white70 : Colors.black87),
                          onPressed: () {
                            if (copies > 1) setMState(() => copies--);
                          },
                        ),
                        Text(
                          '$copies',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: isDark ? Colors.white70 : Colors.black87),
                          onPressed: () => setMState(() => copies++),
                        ),
                      ],
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Afficher le prix de vente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  value: showPrice,
                  onChanged: (v) => setMState(() => showPrice = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.print_rounded, size: 18, color: AppTheme.primaryNavy),
                    label: Text('Imprimer $copies étiquette(s)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Impression de $copies étiquette(s) ($format) lancée !')),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProductSheet(Product p) {
    final isDark = appState.isDarkMode;
    final nameCtrl = TextEditingController(text: p.name);
    final sellCtrl = TextEditingController(text: p.sellPrice.toStringAsFixed(0));
    final buyCtrl = TextEditingController(text: p.buyPrice.toStringAsFixed(0));
    final stockCtrl = TextEditingController(text: p.stock.toString());
    final minStockCtrl = TextEditingController(text: p.minStockAlert.toString());
    final barcodeCtrl = TextEditingController(text: p.barcode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modifier le produit',
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
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nom du produit *',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sellCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Prix de vente (FCFA)',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        filled: isDark,
                        fillColor: isDark ? const Color(0xFF162540) : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: buyCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Coût d\'achat (FCFA)',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        filled: isDark,
                        fillColor: isDark ? const Color(0xFF162540) : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Stock actuel',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        filled: isDark,
                        fillColor: isDark ? const Color(0xFF162540) : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: minStockCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Seuil alerte',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        filled: isDark,
                        fillColor: isDark ? const Color(0xFF162540) : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: barcodeCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Code-barres / Réf',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final newName = nameCtrl.text.trim();
                    if (newName.isEmpty) return;
                    final updated = Product(
                      id: p.id,
                      name: newName,
                      category: p.category,
                      barcode: barcodeCtrl.text.trim(),
                      buyPrice: double.tryParse(buyCtrl.text.trim()) ?? p.buyPrice,
                      sellPrice: double.tryParse(sellCtrl.text.trim()) ?? p.sellPrice,
                      wholesalePrice: (double.tryParse(sellCtrl.text.trim()) ?? p.sellPrice) * 0.9,
                      stock: int.tryParse(stockCtrl.text.trim()) ?? p.stock,
                      minStockAlert: int.tryParse(minStockCtrl.text.trim()) ?? p.minStockAlert,
                      unit: p.unit,
                      productType: p.productType,
                      imageUrl: p.imageUrl,
                      supplierName: p.supplierName,
                      stockByStore: p.stockByStore,
                    );
                    appState.updateProduct(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produit mis à jour avec succès !')),
                    );
                  },
                  child: const Text('Enregistrer les modifications', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC);
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
        final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final pillBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        final pillText = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

        final p = _currentProduct;
        final stores = appState.availableStores.isNotEmpty ? appState.availableStores : [appState.currentStore];
        final totalStockValuation = p.sellPrice * p.stock;
        final totalCostValuation = p.buyPrice * p.stock;
        final potentialMargin = totalStockValuation - totalCostValuation;

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Détail du produit'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: Colors.red),
                          title: const Text('Supprimer ce produit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.pop(ctx);
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Confirmer la suppression',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  'Êtes-vous sûr de vouloir supprimer définitivement « ${p.name} » ?\nCette action retirera le produit du catalogue.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx),
                                    child: Text(
                                      'Annuler',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(dialogCtx);
                                      appState.removeProduct(p.id);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('« ${p.name} » a été supprimé.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    child: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO PHOTO DU PRODUIT
                GestureDetector(
                  onTap: () => _showPhotoOptions(context),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFF0D1B2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ProductImageWidget(
                          imageUrl: p.imageUrl,
                          size: double.infinity,
                          borderRadius: 16,
                          placeholderIcon: Icons.inventory_2_rounded,
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.darkSurface.withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
                              foregroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: Icon(Icons.camera_alt_outlined, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                            label: Text('Changer photo'.tr, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            onPressed: () => _showPhotoOptions(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // NOM ET BADGE CATÉGORIE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (p.category.isNotEmpty ? p.category : 'Général').tr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: pillText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. CARD TARIFICATION (Vente | Coût moyen | Marge)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCol('Prix de vente'.tr, AppTheme.formatFCFA(p.sellPrice), textPrimary, isDark: isDark),
                      Container(width: 1, height: 32, color: cardBorder),
                      _buildMetricCol('Coût moyen'.tr, AppTheme.formatFCFA(p.buyPrice), textSecondary, isDark: isDark),
                      Container(width: 1, height: 32, color: cardBorder),
                      _buildMetricCol(
                        'Marge'.tr,
                        '${p.marginPercent.toStringAsFixed(1)}%',
                        AppTheme.accentGold,
                        subtitle: '+${AppTheme.formatFCFA(p.sellPrice - p.buyPrice)}',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. CARD VALEUR DU STOCK
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'VALEUR DU STOCK'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textSecondary, letterSpacing: 0.5),
                          ),
                          Text(
                            '${p.stock} ${p.unit.tr}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.accentGold),
                          ),
                        ],
                      ),
                      Divider(height: 20, color: cardBorder),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetricCol('Valeur vente'.tr, AppTheme.formatFCFA(totalStockValuation), textPrimary, isDark: isDark),
                          _buildMetricCol('Coût total'.tr, AppTheme.formatFCFA(totalCostValuation), textSecondary, isDark: isDark),
                          _buildMetricCol('Marge potentielle'.tr, '+${AppTheme.formatFCFA(potentialMargin)}', AppTheme.accentGold, isDark: isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4. DISPONIBLE DANS (STOCK PAR BOUTIQUE)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Disponible dans'.tr,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textPrimary),
                          ),
                          Text(
                            '${p.stock} ${p.unit.tr}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('${'Unité'.tr}: ${p.unit.tr}', style: TextStyle(fontSize: 11, color: pillText)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('${'Seuil minimum'.tr}: ${p.minStockAlert}', style: TextStyle(fontSize: 11, color: pillText)),
                          ),
                        ],
                      ),
                      Divider(height: 20, color: cardBorder),
                      ...stores.map((st) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(st, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: textPrimary)),
                                Row(
                                  children: [
                                    Text(
                                      '${'Quantité'.tr}: ${p.stockForStore(st)}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.accentGold),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: textSecondary),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 5. VARIANTES SECTION (+ AJOUTER MODAL)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Variantes'.tr,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textPrimary),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                            icon: const Icon(Icons.add_circle_outline, size: 16),
                            label: Text('Ajouter une variante'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                            onPressed: () => _showAddVariantDialog(context),
                          ),
                        ],
                      ),
                      if (_variants.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Aucune variante définie. Créez des déclinaisons (taille, couleur, arôme...).'.tr,
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        )
                      else
                        ..._variants.map((v) => Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(v['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                                  Text(AppTheme.formatFCFA(v['price']), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accentGold)),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 6. LOTS & HISTORIQUE DES PRIX
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: _showLots ? AppTheme.accentGold : (isDark ? Colors.white : AppTheme.primaryNavy),
                        ),
                        onPressed: () => setState(() {
                          _showLots = !_showLots;
                          if (_showLots) _showPriceHistory = false;
                        }),
                        icon: Icon(_showLots ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18),
                        label: Text('Lots de stock'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: _showPriceHistory ? AppTheme.accentGold : (isDark ? Colors.white : AppTheme.primaryNavy),
                        ),
                        onPressed: () => setState(() {
                          _showPriceHistory = !_showPriceHistory;
                          if (_showPriceHistory) _showLots = false;
                        }),
                        icon: Icon(_showPriceHistory ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18),
                        label: Text('Historique des prix'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

                // VUE DÉTAILLÉE : LOTS DE STOCK
                if (_showLots) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Lots & Réceptions de stock',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${p.stock} ${p.unit}(s) en stock',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Répartition par boutique
                        ...appState.outlets.map((outlet) {
                          final stQty = p.stockForStore(outlet.name);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(outlet.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  '$stQty ${p.unit}(s)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: stQty > 0 ? const Color(0xFF0F172A) : const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 18),
                        // Lots d'approvisionnement récents
                        const Text(
                          'Mouvements de réceptions récents',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (_) {
                            final movs = appState.stockMovements
                                .where((m) => m.productId == p.id || m.productName.toLowerCase() == p.name.toLowerCase())
                                .take(5)
                                .toList();
                            if (movs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Lot initial créé lors de l\'enregistrement (Fournisseur : ${p.supplierName ?? "Non spécifié"}).',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                                ),
                              );
                            }
                            return Column(
                              children: movs.map((m) {
                                final isAdd = m.type.contains('+');
                                final dtStr = '${m.date.day.toString().padLeft(2, "0")}/${m.date.month.toString().padLeft(2, "0")}/${m.date.year}';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(isAdd ? Icons.add_circle : Icons.remove_circle, size: 16, color: isAdd ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${m.type} • ${m.reason}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        '$dtStr • ${m.quantity} ${p.unit}(s)',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isAdd ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // VUE DÉTAILLÉE : HISTORIQUE DES PRIX
                if (_showPriceHistory) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grille tarifaire & Marges',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Prix de vente détail', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            Text(
                              AppTheme.formatFCFA(p.sellPrice),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Prix de gros', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            Text(
                              AppTheme.formatFCFA(p.wholesalePrice),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Dernier coût d\'achat', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            Text(
                              AppTheme.formatFCFA(p.buyPrice),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFFD97706)),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Marge brute unitaire', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            Text(
                              '${AppTheme.formatFCFA(p.margin)} (${p.marginPercent.toStringAsFixed(1)}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // BARRE FIXE EN BAS : MODIFIER & ÉTIQUETTES
          bottomSheet: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                border: Border(top: BorderSide(color: cardBorder)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: AppTheme.primaryNavy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryNavy),
                        label: Text('Modifier'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: () => _showEditProductSheet(p),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : AppTheme.primaryNavy,
                          side: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                        label: Text('Étiquettes'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: () => _showLabelsDialog(context, p),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCol(String label, String value, Color color, {String? subtitle, bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: color)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color)),
        ],
      ],
    );
  }
}
