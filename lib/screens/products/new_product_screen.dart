import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final List<String> _units = ['Pièce', 'Kg', 'Litre', 'Carton', 'Paquet', 'Sac', 'Mètre'];

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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Photo du produit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.goldLight,
                  child: Icon(Icons.camera_alt, color: AppTheme.primaryNavy),
                ),
                title: const Text('Prendre une photo'),
                subtitle: const Text('Utiliser l\'appareil photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.goldLight,
                  child: Icon(Icons.photo_library, color: AppTheme.primaryNavy),
                ),
                title: const Text('Choisir dans la galerie'),
                subtitle: const Text('Importer une image existante'),
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
                  title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _pickedImagePath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickAddCategoryDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nouvelle catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nom de la catégorie *',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
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
            child: const Text('Ajouter'),
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
        final categories = _availableCategories;
        if (_selectedCategory == null || !categories.contains(_selectedCategory)) {
          _selectedCategory = categories.first;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.circleNavy,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 16),
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
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
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
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Changer',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image_outlined, size: 36, color: Color(0xFF9CA3AF)),
                                SizedBox(height: 6),
                                Text('Aucune photo', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    icon: Icon(
                      _pickedImagePath != null ? Icons.edit_outlined : Icons.camera_alt_outlined,
                      size: 18,
                      color: AppTheme.primaryNavy,
                    ),
                    label: Text(
                      _pickedImagePath != null ? 'Modifier la photo' : 'Ajouter une photo',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    onPressed: () => _showPhotoPicker(context),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. NOM DU PRODUIT *
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom du produit *',
                    hintText: 'Ex: Perceuse Bosch 750W, Sac de Riz 25kg...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. TYPE (Segmented buttons)
                const Text('Type', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      _buildTypeSegment('Produit', Icons.inventory_2_outlined, isFirst: true),
                      _buildTypeSegment('Service', Icons.build_outlined),
                      _buildTypeSegment('Pack', Icons.layers_outlined, isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedType == 'Produit'
                      ? 'Article en stock : inventaire, coût de revient, réapprovisionnement.'
                      : (_selectedType == 'Service'
                          ? 'Prestation sans gestion de stock physique.'
                          : 'Lot de plusieurs produits vendus ensemble.'),
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                ),
                const SizedBox(height: 16),

                // 4. PRIX DE VENTE & PRIX D'ACHAT
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Prix de vente (FCFA) *',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _buyPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Coût d\'achat (FCFA)',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          decoration: InputDecoration(
                            labelText: 'Stock initial en boutique',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: InputDecoration(
                            labelText: 'Unité',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 14)))).toList(),
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
                    const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primaryNavy),
                      label: const Text(
                        '+ Nouvelle catégorie',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy),
                      ),
                      onPressed: _showQuickAddCategoryDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 14),

                // 7. DESCRIPTION (FACULTATIF)
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Description (facultatif)',
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                  ),
                ),
                const SizedBox(height: 12),

                // 8. OPTIONS AVANCÉES ACCORDION
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
                    icon: Icon(
                      _showAdvancedOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppTheme.primaryNavy,
                      size: 20,
                    ),
                    label: const Text(
                      'Options avancées (Code-barres, Seuil d\'alerte, Péremption)',
                      style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13),
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
                          decoration: InputDecoration(
                            labelText: 'Code-barres / SKU',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _minStockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Seuil stock bas',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Suivi de péremption', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Produits périssables (alimentaire, pharmacie...)', style: TextStyle(fontSize: 11)),
                    value: _expiryTracking,
                    activeThumbColor: AppTheme.primaryNavy,
                    onChanged: (v) => setState(() => _expiryTracking = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Suivi par n° de série / IMEI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Téléphones, appareils électroniques...', style: TextStyle(fontSize: 11)),
                    value: _serialImeiTracking,
                    activeThumbColor: AppTheme.primaryNavy,
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
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, color: AppTheme.accentGold),
                    label: const Text('Créer le produit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      final name = _nameCtrl.text.trim();
                      final sellPrice = double.tryParse(_priceCtrl.text.trim()) ?? 0;
                      final buyPrice = double.tryParse(_buyPriceCtrl.text.trim()) ?? (sellPrice * 0.7);
                      final stock = _selectedType == 'Service' ? 999 : (int.tryParse(_initialStockCtrl.text.trim()) ?? 0);
                      final minStock = int.tryParse(_minStockCtrl.text.trim()) ?? 5;
                      final category = _selectedCategory ?? 'Non catégorisé';

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez entrer le nom du produit !')),
                        );
                        return;
                      }
                      if (sellPrice <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez entrer un prix de vente valide !')),
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
                        SnackBar(content: Text('Produit "$name" créé avec succès !')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler', style: TextStyle(color: AppTheme.primaryNavy, fontSize: 14)),
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

  Widget _buildTypeSegment(String type, IconData icon, {bool isFirst = false, bool isLast = false}) {
    final isSel = _selectedType == type;
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
            color: isSel ? AppTheme.goldLight : Colors.white,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(24) : Radius.zero,
              right: isLast ? const Radius.circular(24) : Radius.zero,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1F2937)),
              const SizedBox(width: 6),
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
