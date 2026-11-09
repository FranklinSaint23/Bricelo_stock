import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_prime/services/bricelo_ai_service.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/product_image_widget.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final appState = AppState.instance;
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController(
    text: '690${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
  );
  final _minStockCtrl = TextEditingController(text: '5');
  final _initialStockCtrl = TextEditingController(text: '10');

  String _selectedType = 'Produit'; // 'Produit', 'Service', 'Pack'
  String _selectedUnit = 'Pièce';
  bool _expiryTracking = false;
  bool _serialImeiTracking = false;
  String? _selectedCategory;
  bool _showAdvancedOptions = false;
  String? _pickedImagePath;
  bool _isGeneratingDesc = false;

  final List<String> _units = ['Pièce', 'Kg', 'Litre', 'Carton', 'Paquet', 'Sac', 'Mètre'];

  Future<void> _generateAiDescription() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord saisir le nom du produit.')),
      );
      return;
    }

    setState(() => _isGeneratingDesc = true);
    final desc = await BriceloAIService.instance.generateProductDescription(
      productName: name,
      category: _selectedCategory,
    );
    if (mounted) {
      setState(() => _isGeneratingDesc = false);
      if (desc != null && desc.isNotEmpty) {
        _descCtrl.text = desc;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Description générée par Bricelo IA !'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de générer la description actuellement.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (appState.categories.isNotEmpty) {
      _selectedCategory = appState.categories.first.name;
    } else {
      _selectedCategory = 'Non catégorisé';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _buyPriceCtrl.dispose();
    _barcodeCtrl.dispose();
    _minStockCtrl.dispose();
    _initialStockCtrl.dispose();
    super.dispose();
  }

  List<String> get _availableCategories {
    final cats = <String>{'Non catégorisé'};
    for (final c in appState.categories) {
      if (c.name.trim().isNotEmpty) cats.add(c.name.trim());
    }
    for (final p in appState.products) {
      if (p.category.trim().isNotEmpty) cats.add(p.category.trim());
    }
    return cats.toList();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _pickedImagePath = base64Image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur sélection image: $e')),
        );
      }
    }
  }

  void _showPhotoPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: appState.isDarkMode ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = appState.isDarkMode;
        final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

        return SafeArea(
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
                    color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Photo du produit'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark ? AppTheme.accentGold.withValues(alpha: 0.2) : AppTheme.goldLight,
                    child: Icon(Icons.camera_alt, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                  ),
                  title: Text('Prendre une photo'.tr, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Utiliser l\'appareil photo'.tr, style: TextStyle(color: textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark ? AppTheme.accentGold.withValues(alpha: 0.2) : AppTheme.goldLight,
                    child: Icon(Icons.photo_library, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                  ),
                  title: Text('Choisir dans la galerie'.tr, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Importer une image existante'.tr, style: TextStyle(color: textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_pickedImagePath != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFEE2E2),
                      child: Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: Text('Supprimer la photo'.tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _pickedImagePath = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuickAddCategoryDialog() {
    final ctrl = TextEditingController();
    final isDark = appState.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Nouvelle catégorie'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
          decoration: InputDecoration(
            labelText: '${'Nom de la catégorie'.tr} *',
            labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
              foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
            ),
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                appState.addCategory(
                  CategoryItem(
                    id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                  ),
                );
                setState(() => _selectedCategory = name);
              }
              Navigator.pop(ctx);
            },
            child: Text('Ajouter'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? AppTheme.darkScaffold : Colors.white;
        final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);

        final categories = _availableCategories;
        if (_selectedCategory == null || !categories.contains(_selectedCategory)) {
          _selectedCategory = categories.first;
        }

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
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
              'Nouveau produit'.tr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ZONE PHOTO
                GestureDetector(
                  onTap: () => _showPhotoPicker(context),
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedImagePath != null && _pickedImagePath!.isNotEmpty
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ProductImageWidget(
                                imageUrl: _pickedImagePath,
                                size: double.infinity,
                                borderRadius: 0,
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Changer'.tr,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image_outlined, size: 36, color: textSecondary),
                                const SizedBox(height: 6),
                                Text('Aucune photo'.tr, style: TextStyle(color: textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      side: BorderSide(color: cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    icon: Icon(
                      _pickedImagePath != null ? Icons.edit_outlined : Icons.camera_alt_outlined,
                      size: 18,
                      color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                    ),
                    label: Text(
                      (_pickedImagePath != null ? 'Modifier la photo' : 'Ajouter une photo').tr,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    onPressed: () => _showPhotoPicker(context),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. NOM DU PRODUIT *
                TextField(
                  controller: _nameCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: '${'Nom du produit'.tr} *',
                    labelStyle: TextStyle(color: textSecondary),
                    hintText: 'Ex: Perceuse Bosch 750W, Sac de Riz 25kg...'.tr,
                    hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. TYPE (Segmented buttons)
                Text('Type'.tr, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: cardBorder),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      _buildTypeSegment('Produit', Icons.inventory_2_outlined, isFirst: true, isDark: isDark),
                      _buildTypeSegment('Service', Icons.build_outlined, isDark: isDark),
                      _buildTypeSegment('Pack', Icons.layers_outlined, isLast: true, isDark: isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (_selectedType == 'Produit'
                      ? 'Article en stock : inventaire, coût de revient, réapprovisionnement.'
                      : (_selectedType == 'Service'
                          ? 'Prestation sans gestion de stock physique.'
                          : 'Lot de plusieurs produits vendus ensemble.')).tr,
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 16),

                // 4. PRIX DE VENTE & PRIX D'ACHAT
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: '${'Prix de vente (FCFA)'.tr} *',
                          labelStyle: TextStyle(color: textSecondary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _buyPriceCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Coût d\'achat (FCFA)'.tr,
                          labelStyle: TextStyle(color: textSecondary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. STOCK INITIAL & SEUIL D'ALERTE (Si Produit ou Pack)
                if (_selectedType != 'Service') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _initialStockCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Stock initial en boutique'.tr,
                            labelStyle: TextStyle(color: textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Unité'.tr,
                            labelStyle: TextStyle(color: textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                          ),
                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u.tr, style: TextStyle(fontSize: 14, color: textPrimary)))).toList(),
                          onChanged: (v) => setState(() => _selectedUnit = v ?? 'Pièce'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // 6. CATÉGORIE DYNAMIQUE (+ BOUTON AJOUT RAPIDE)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Catégorie'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(Icons.add_circle_outline, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                      label: Text(
                        '+ Nouvelle catégorie'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                      ),
                      onPressed: _showQuickAddCategoryDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down, color: textSecondary),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.tr, style: TextStyle(fontSize: 14, color: textPrimary)))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 14),

                // 7. DESCRIPTION (FACULTATIF) + BOUTON MAGIQUE IA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Description (facultatif)'.tr,
                      style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      onTap: _isGeneratingDesc ? null : _generateAiDescription,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.accentGold.withValues(alpha: 0.2) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isGeneratingDesc) ...[
                              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.8, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
                              const SizedBox(width: 6),
                              Text('Rédaction...'.tr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
                            ] else ...[
                              Icon(Icons.auto_awesome, size: 13, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                              const SizedBox(width: 4),
                              Text('Rédiger avec Bricelo IA'.tr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Description (facultatif)'.tr,
                    hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                  ),
                ),
                const SizedBox(height: 12),

                // 8. OPTIONS AVANCÉES ACCORDION
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
                    icon: Icon(
                      _showAdvancedOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      size: 20,
                    ),
                    label: Text(
                      'Options avancées (Code-barres, Seuil d\'alerte, Péremption)'.tr,
                      style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),

                if (_showAdvancedOptions) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _barcodeCtrl,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Code-barres / SKU'.tr,
                            labelStyle: TextStyle(color: textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _minStockCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Seuil stock bas'.tr,
                            labelStyle: TextStyle(color: textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cardBorder)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Suivi de péremption'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                    subtitle: Text('Produits périssables (alimentaire, pharmacie...)'.tr, style: TextStyle(fontSize: 11, color: textSecondary)),
                    value: _expiryTracking,
                    activeThumbColor: isDark ? Colors.white : AppTheme.primaryNavy,
                    activeTrackColor: AppTheme.accentGold,
                    onChanged: (v) => setState(() => _expiryTracking = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Suivi par n° de série / IMEI'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                    subtitle: Text('Téléphones, appareils électroniques...'.tr, style: TextStyle(fontSize: 11, color: textSecondary)),
                    value: _serialImeiTracking,
                    activeThumbColor: isDark ? Colors.white : AppTheme.primaryNavy,
                    activeTrackColor: AppTheme.accentGold,
                    onChanged: (v) => setState(() => _serialImeiTracking = v),
                  ),
                ],

                const SizedBox(height: 24),

                // 9. BOUTONS CRÉER & ANNULER
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(Icons.check_circle_outline, color: isDark ? AppTheme.primaryNavy : AppTheme.accentGold),
                    label: Text('Créer le produit'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      final name = _nameCtrl.text.trim();
                      final sellPrice = double.tryParse(_priceCtrl.text.trim()) ?? 0;
                      final buyPrice = double.tryParse(_buyPriceCtrl.text.trim()) ?? (sellPrice * 0.7);
                      final stock = _selectedType == 'Service' ? 999 : (int.tryParse(_initialStockCtrl.text.trim()) ?? 0);
                      final minStock = int.tryParse(_minStockCtrl.text.trim()) ?? 5;
                      final category = _selectedCategory ?? 'Non catégorisé';

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez entrer le nom du produit !'.tr)),
                        );
                        return;
                      }
                      if (sellPrice <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez entrer un prix de vente valide !'.tr)),
                        );
                        return;
                      }

                      final created = Product(
                        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        category: category,
                        barcode: _barcodeCtrl.text.trim(),
                        buyPrice: buyPrice,
                        sellPrice: sellPrice,
                        wholesalePrice: sellPrice * 0.9,
                        stock: stock,
                        minStockAlert: minStock,
                        unit: _selectedUnit,
                        productType: _selectedType,
                        imageUrl: _pickedImagePath,
                      );

                      appState.addProduct(created);
                      Navigator.pop(context, created);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produit "$name" créé avec succès !'.tr)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler'.tr, style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSegment(String type, IconData icon, {bool isFirst = false, bool isLast = false, required bool isDark}) {
    final isSel = _selectedType == type;
    final activeBg = isDark ? AppTheme.accentGold.withValues(alpha: 0.25) : AppTheme.goldLight;
    final inactiveBg = isDark ? AppTheme.darkSurface : Colors.white;
    final activeText = isDark ? AppTheme.accentGold : const Color(0xFF1F2937);
    final inactiveText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.horizontal(
          left: isFirst ? const Radius.circular(24) : Radius.zero,
          right: isLast ? const Radius.circular(24) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? activeBg : inactiveBg,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(24) : Radius.zero,
              right: isLast ? const Radius.circular(24) : Radius.zero,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSel ? activeText : inactiveText),
              const SizedBox(width: 6),
              Text(
                type.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSel ? activeText : inactiveText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
