import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/products/new_product_screen.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newStockController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Product? _selectedProduct;
  String _selectedReason = 'Inventaire physique';
  final List<String> _reasons = [
    'Inventaire physique',
    'Casse / Avarie',
    'Erreur de comptage',
    'Perte / Vol',
    'Autre motif',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _newStockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final query = _searchController.text.trim().toLowerCase();
    final matchingProducts = query.isEmpty
        ? <Product>[]
        : appState.products.where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.barcode.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Ajustement de stock',
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LIBELLÉ: Produit *
            RichText(
              text: const TextSpan(
                text: 'Produit ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
                children: [
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // CHAMP DE RECHERCHE AVEC LOUPE À DROITE (1:1 SCREENSHOT 1)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF6B7280), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _selectedProduct = null);
                          },
                        )
                      : const Icon(Icons.search, color: Color(0xFF374151), size: 22),
                ),
              ),
            ),

            // RÉSULTATS DE RECHERCHE EN DIRECT
            if (_searchController.text.isNotEmpty && _selectedProduct == null) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: matchingProducts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                'Aucun produit trouvé',
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NewProductScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add, color: Color(0xFF1B5E20), size: 18),
                                label: const Text(
                                  'Ajouter un produit',
                                  style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: matchingProducts.map((p) {
                          return ListTile(
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('Stock actuel : ${p.stock} ${p.unit}'),
                            trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                            onTap: () {
                              setState(() {
                                _selectedProduct = p;
                                _newStockController.text = p.stock.toString();
                              });
                            },
                          );
                        }).toList(),
                      ),
              ),
            ],

            // FORMULAIRE D'AJUSTEMENT SI PRODUIT SÉLECTIONNÉ
            if (_selectedProduct != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedProduct!.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Catégorie : ${_selectedProduct!.category}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFED7AA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Actuel : ${_selectedProduct!.stock}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C2D12), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFE5E7EB)),
                    const Text(
                      'Nouveau stock physique compté *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newStockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 25',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Motif de l’ajustement',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReason,
                          isExpanded: true,
                          items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedReason = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final newQty = int.tryParse(_newStockController.text.trim()) ?? _selectedProduct!.stock;
                          appState.adjustStock(
                            productId: _selectedProduct!.id,
                            newStock: newQty,
                            reason: _selectedReason,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Stock de ${_selectedProduct!.name} ajusté à $newQty unités.'),
                              backgroundColor: const Color(0xFF1B5E20),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Valider l’ajustement',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
