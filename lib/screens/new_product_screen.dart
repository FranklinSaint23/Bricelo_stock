import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController(text: '690${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}');
  final _minStockCtrl = TextEditingController(text: '5');
  final _initialStockCtrl = TextEditingController(text: '10');

  String _selectedType = 'Produit'; // 'Produit', 'Service', 'Pack'
  bool _expiryTracking = false;
  bool _serialImeiTracking = false;
  String _selectedCategory = 'Électronique';
  bool _showAdvancedOptions = false;

  final List<String> _categories = [
    'Électronique',
    'Électroménager',
    'Bricolage & Électricité',
    'Maison & Confort',
    'Mode & Voyage',
    'Alimentation & Boissons',
  ];

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

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Nouveau',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Text(
                  'Aucune photo',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
                icon: const Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.primaryNavy),
                label: const Text('Ajouter une photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sélecteur de photo / Caméra activé !')),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 2. NOM DU PRODUIT *
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Nom du produit *',
                hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
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
                  _buildTypeSegment('Pack', Icons.lock_outline, isLast: true),
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
            const SizedBox(height: 18),

            // 4. SUIVI DE PÉREMPTION (Switch)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Suivi de péremption', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text(
                        'Activez pour les produits périssables (alimentaire, cosmétiques, médicaments...).',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _expiryTracking,
                  activeColor: AppTheme.primaryNavy,
                  onChanged: (v) => setState(() => _expiryTracking = v),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. SUIVI PAR N° DE SÉRIE / IMEI (Switch)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Suivi par n° de série / IMEI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text(
                        'Activez pour les articles suivis un par un (téléphones, appareils, véhicules...).',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _serialImeiTracking,
                  activeColor: AppTheme.primaryNavy,
                  onChanged: (v) => setState(() => _serialImeiTracking = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 6. PRIX DE VENTE *
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Prix de vente *',
                hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              ),
            ),
            const SizedBox(height: 14),

            // 7. CATÉGORIE DROPDOWN
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 14),

            // 8. DESCRIPTION (FACULTATIF)
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
            const SizedBox(height: 4),
            const Text(
              'Visible par vos clients sur la boutique en ligne, les catalogues et Google (50 caractères minimum).',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
            const SizedBox(height: 16),

            // 9. OPTIONS AVANCÉES ACCORDION
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
                icon: Icon(
                  _showAdvancedOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppTheme.primaryNavy,
                  size: 20,
                ),
                label: const Text(
                  'Options avancées',
                  style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            if (_showAdvancedOptions) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _buyPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix d\'achat (PAMP en F CFA)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _barcodeCtrl,
                decoration: InputDecoration(
                  labelText: 'Code-barres / Référence SKU',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _initialStockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stock initial',
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
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 12),

            // 10. VARIANTES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Variantes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.goldLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Module d\'ajout de variante (taille, couleur...) ouvert !')),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 14, color: Color(0xFF1F2937)),
                            SizedBox(width: 4),
                            Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1F2937))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Aucune variante ajoutée (optionnel).',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),

            const SizedBox(height: 28),

            // 11. BOUTONS CRÉER & ANNULER
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  final sellPrice = double.tryParse(_priceCtrl.text) ?? 0;
                  final buyPrice = double.tryParse(_buyPriceCtrl.text) ?? (sellPrice * 0.7);
                  final stock = int.tryParse(_initialStockCtrl.text) ?? 10;
                  final minStock = int.tryParse(_minStockCtrl.text) ?? 5;

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez entrer le nom du produit !')),
                    );
                    return;
                  }

                  AppState.instance.addProduct(Product(
                    id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    category: _selectedCategory,
                    barcode: _barcodeCtrl.text,
                    buyPrice: buyPrice,
                    sellPrice: sellPrice > 0 ? sellPrice : 5000,
                    wholesalePrice: sellPrice > 0 ? (sellPrice * 0.9) : 4500,
                    stock: stock,
                    minStockAlert: minStock,
                  ));

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Produit "$name" créé avec succès !')),
                  );
                },
                child: const Text('Créer le produit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
