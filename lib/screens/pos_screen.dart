import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final appState = AppState.instance;
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'Tous',
    'Électronique',
    'Électroménager',
    'Bricolage & Électricité',
    'Maison & Confort',
    'Mode & Voyage',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 900;
        final filteredProducts = appState.products.where((p) {
          final matchesCat = _selectedCategory == 'Tous' || p.category == _selectedCategory;
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.barcode.contains(_searchQuery);
          return matchesCat && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Caisse Tactile & Vente Directe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            actions: [
              // Bouton Scanner Code-barres
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: AppTheme.gold500),
                tooltip: 'Scanner un code-barres',
                onPressed: () => _showBarcodeScannerDialog(context),
              ),
              // Bouton Paniers en attente
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.pause_circle_outline, color: Colors.white),
                    tooltip: 'Paniers mis en attente',
                    onPressed: () => _showHeldCartsModal(context),
                  ),
                  if (appState.heldCarts.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppTheme.gold500, shape: BoxShape.circle),
                        child: Text(
                          '${appState.heldCarts.length}',
                          style: const TextStyle(color: AppTheme.navy900, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: isDesktop
              ? Row(
                  children: [
                    // CATALOGUE & RECHERCHE (Gauche)
                    Expanded(
                      flex: 6,
                      child: _buildProductsCatalog(filteredProducts),
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                    // PANIER & ENCAISSEMENT (Droite)
                    Expanded(
                      flex: 4,
                      child: _buildCartPanel(context),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    _buildProductsCatalog(filteredProducts),
                    if (appState.cart.isNotEmpty)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: _buildMobileCartFloatingBar(context),
                      ),
                  ],
                ),
        );
      },
    );
  }

  // --- CATALOGUE DES PRODUITS ---
  Widget _buildProductsCatalog(List<Product> products) {
    return Column(
      children: [
        // Barre de recherche & Code-barres
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Rechercher article, code-barres ou EAN...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.slate400),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.slate500),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchCtrl.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: AppTheme.surfaceRaised,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),
        ),

        // Filtres par Catégorie (Pills horizontales)
        Container(
          height: 48,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            itemCount: _categories.length,
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              final isSel = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                  selected: isSel,
                  selectedColor: AppTheme.navy900,
                  labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.slate700),
                  backgroundColor: AppTheme.surfaceRaised,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Grille des Produits
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.slate400),
                      const SizedBox(height: 12),
                      Text('Aucun produit trouvé pour "$_searchQuery"', style: const TextStyle(color: AppTheme.slate500)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, idx) {
                    final p = products[idx];
                    return _buildProductCard(p);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product p) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: p.isOutOfStock ? null : () => appState.addToCart(p),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de Stock & Catégorie
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.isOutOfStock
                          ? AppTheme.danger
                          : (p.isLowStock ? AppTheme.warning : AppTheme.success),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p.isOutOfStock ? 'RUPTURE' : 'Stock : ${p.stock}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.touch_app, size: 14, color: AppTheme.slate400),
                ],
              ),
              const Spacer(),
              // Nom du Produit
              Text(
                p.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.navy900),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Réf: ${p.barcode}',
                style: const TextStyle(fontSize: 10, color: AppTheme.slate500),
              ),
              const SizedBox(height: 6),
              // Prix de Vente
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTheme.formatFCFA(p.sellPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.navy900),
                      ),
                      Text(
                        'Gros: ${AppTheme.formatFCFA(p.wholesalePrice)}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.warning, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: p.isOutOfStock ? Colors.grey.shade300 : AppTheme.gold500,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.add,
                      color: p.isOutOfStock ? Colors.grey : AppTheme.navy900,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- PANNEAU DU PANIER (Desktop) ---
  Widget _buildCartPanel(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête Panier
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppTheme.navy900,
              border: Border(bottom: BorderSide(color: Color(0xFF1E3052))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: AppTheme.gold500, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Panier (${appState.cartCount})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                if (appState.cart.isNotEmpty)
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.pause, size: 14, color: AppTheme.gold400),
                        label: const Text('Attente', style: TextStyle(color: AppTheme.gold400, fontSize: 11)),
                        onPressed: () => _promptHoldCart(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep, color: AppTheme.slate400, size: 20),
                        tooltip: 'Vider le panier',
                        onPressed: () => appState.clearCart(),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Liste des articles du panier
          Expanded(
            child: appState.cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: AppTheme.slate400),
                        SizedBox(height: 10),
                        Text('Le panier est vide', style: TextStyle(color: AppTheme.slate500, fontWeight: FontWeight.bold)),
                        Text('Cliquez sur un article pour l\'ajouter', style: TextStyle(color: AppTheme.slate400, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: appState.cart.length,
                    separatorBuilder: (_, index) => const Divider(height: 12),
                    itemBuilder: (context, idx) {
                      final item = appState.cart[idx];
                      return _buildCartItemTile(context, item);
                    },
                  ),
          ),

          // Total & Bouton d'encaissement
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceRaised,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sous-total :', style: TextStyle(color: AppTheme.slate600, fontSize: 12)),
                    Text(AppTheme.formatFCFA(appState.cartSubtotal), style: const TextStyle(color: AppTheme.slate800, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL À PAYER :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.navy900)),
                    Text(
                      AppTheme.formatFCFA(appState.cartTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.navy900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navy900,
                      foregroundColor: AppTheme.gold500,
                    ),
                    icon: const Icon(Icons.payments, size: 20),
                    label: Text(
                      'ENCAISSER  (${AppTheme.formatFCFA(appState.cartTotal)})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: appState.cart.isEmpty ? null : () => _showPaymentModal(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(BuildContext context, CartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 2,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppTheme.slate400),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => appState.removeFromCart(item),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Sélecteur Quantité (+ / -)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => appState.updateCartQuantity(item, -1),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(Icons.remove, size: 14),
                    ),
                  ),
                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  InkWell(
                    onTap: () => appState.updateCartQuantity(item, 1),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(Icons.add, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Toggle Prix de Gros
            InkWell(
              onTap: () => appState.toggleCartItemWholesale(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isWholesale ? AppTheme.warning.withOpacity(0.15) : AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: item.isWholesale ? AppTheme.warning : Colors.transparent),
                ),
                child: Text(
                  item.isWholesale ? 'PRIX GROS' : 'Détail',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item.isWholesale ? AppTheme.warning : AppTheme.slate600,
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Montant Total Item
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppTheme.formatFCFA(item.total),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.navy900),
                ),
                if (item.discount > 0)
                  Text(
                    '-${item.discount.toStringAsFixed(0)} FCFA remise',
                    style: const TextStyle(fontSize: 10, color: AppTheme.danger),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- MOBILE CART FLOATING BAR ---
  Widget _buildMobileCartFloatingBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.navy900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: AppTheme.gold500, shape: BoxShape.circle),
            child: Text(
              '${appState.cartCount}',
              style: const TextStyle(color: AppTheme.navy900, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Panier en cours', style: TextStyle(color: AppTheme.slate400, fontSize: 11)),
              Text(
                AppTheme.formatFCFA(appState.cartTotal),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold500,
              foregroundColor: AppTheme.navy900,
            ),
            onPressed: () => _showMobileCartBottomSheet(context),
            child: const Text('VOIR & PAYER'),
          ),
        ],
      ),
    );
  }

  void _showMobileCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _buildCartPanel(context),
      ),
    );
  }

  // --- MODAL DE PAIEMENT (Cash / OM / MoMo / Crédit) ---
  void _showPaymentModal(BuildContext context) {
    String selectedMethod = 'Espèces';
    final total = appState.cartTotal;
    final cashGivenCtrl = TextEditingController(text: total.toStringAsFixed(0));
    final customerNameCtrl = TextEditingController(text: 'Client Comptoir');
    final customerPhoneCtrl = TextEditingController(text: '+237 6 ');
    double change = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final received = double.tryParse(cashGivenCtrl.text) ?? total;
            change = received > total ? received - total : 0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mode d\'Encaissement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy900)),
                        Text(
                          AppTheme.formatFCFA(total),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navy900),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Choix du mode
                    Row(
                      children: [
                        _buildMethodTile(ctx, 'Espèces', Icons.money, AppTheme.success, selectedMethod == 'Espèces', () {
                          setModalState(() => selectedMethod = 'Espèces');
                        }),
                        const SizedBox(width: 8),
                        _buildMethodTile(ctx, 'Orange Money', Icons.phone_android, AppTheme.orangeMoney, selectedMethod == 'Orange Money', () {
                          setModalState(() => selectedMethod = 'Orange Money');
                        }),
                        const SizedBox(width: 8),
                        _buildMethodTile(ctx, 'MTN MoMo', Icons.phonelink_ring, const Color(0xFFCC9900), selectedMethod == 'MTN MoMo', () {
                          setModalState(() => selectedMethod = 'MTN MoMo');
                        }),
                        const SizedBox(width: 8),
                        _buildMethodTile(ctx, 'À Crédit', Icons.menu_book, AppTheme.danger, selectedMethod == 'À Crédit', () {
                          setModalState(() => selectedMethod = 'À Crédit');
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Détails Spécifiques au mode sélectionné
                    if (selectedMethod == 'Espèces') ...[
                      const Text('Montant reçu du client :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: cashGivenCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixText: 'FCFA',
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 8),
                      // Raccourcis billets courants au Cameroun
                      Wrap(
                        spacing: 8,
                        children: [total, 5000.0, 10000.0, 20000.0, 50000.0].map((amt) {
                          if (amt < total && amt != total) return const SizedBox.shrink();
                          return ActionChip(
                            label: Text(AppTheme.formatFCFA(amt), style: const TextStyle(fontSize: 11)),
                            onPressed: () {
                              setModalState(() {
                                cashGivenCtrl.text = amt.toStringAsFixed(0);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: change > 0 ? const Color(0xFFDCFCE7) : AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Monnaie à rendre :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              AppTheme.formatFCFA(change),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: change > 0 ? AppTheme.success : AppTheme.navy900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (selectedMethod == 'Orange Money' || selectedMethod == 'MTN MoMo') ...[
                      TextField(
                        controller: customerPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Numéro ${selectedMethod}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'ID / Référence de Transaction (Optionnel)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                    ],

                    if (selectedMethod == 'À Crédit') ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: AppTheme.danger, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cette vente sera inscrite dans le Cahier de Dettes du client.',
                                style: TextStyle(color: AppTheme.danger, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: customerNameCtrl,
                        decoration: const InputDecoration(labelText: 'Nom du client créancier *', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: customerPhoneCtrl,
                        decoration: const InputDecoration(labelText: 'Téléphone WhatsApp pour relance *', border: OutlineInputBorder()),
                      ),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navy900,
                          foregroundColor: AppTheme.gold500,
                        ),
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text('VALIDER L\'ENCAISSEMENT & TICKET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: () {
                          final sale = appState.finalizeSale(
                            paymentMethod: selectedMethod,
                            amountReceived: received,
                            changeReturned: change,
                            customerName: customerNameCtrl.text,
                            customerPhone: customerPhoneCtrl.text,
                          );
                          Navigator.pop(ctx);
                          _showThermalReceiptDialog(context, sale);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMethodTile(BuildContext ctx, String label, IconData icon, Color color, bool isSel, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? color.withOpacity(0.15) : AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSel ? color : Colors.transparent, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? color : AppTheme.slate600, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSel ? color : AppTheme.slate700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TICKET DE CAISSE THERMIQUE ESC/POS (58mm / 80mm) ---
  void _showThermalReceiptDialog(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Container(
          width: 320,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Entête Thermique
              const Text('★ BRICÉLO STOCK PRIME ★', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
              Text(sale.storeName, style: const TextStyle(fontSize: 10, color: AppTheme.slate600)),
              const Text('Tél: +237 6 99 00 00 00 • Douala, Cameroun', style: TextStyle(fontSize: 9, color: AppTheme.slate500)),
              const Divider(thickness: 1, color: Colors.black45),

              // Métadonnées
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ticket : ${sale.ticketNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(
                    '${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Client : ${sale.customerName}', style: const TextStyle(fontSize: 10)),
                  Text('Caisse : ${sale.cashierName}', style: const TextStyle(fontSize: 10)),
                ],
              ),
              const Divider(thickness: 1, color: Colors.black45),

              // Liste Articles
              ...sale.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          AppTheme.formatFCFA(item.total),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  )),

              const Divider(thickness: 1, color: Colors.black45),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(AppTheme.formatFCFA(sale.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Règlement (${sale.paymentMethod}) :', style: const TextStyle(fontSize: 10)),
                  Text(AppTheme.formatFCFA(sale.amountReceived), style: const TextStyle(fontSize: 10)),
                ],
              ),
              if (sale.changeReturned > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monnaie rendue :', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(AppTheme.formatFCFA(sale.changeReturned), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),

              const Divider(thickness: 1, color: Colors.black45),
              const Text('Merci de votre visite chez BRICÉLO !', style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic)),
              const Text('Les marchandises vendues ne sont ni reprises ni échangées.', style: TextStyle(fontSize: 8, color: AppTheme.slate500)),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.share, size: 16),
            label: const Text('WhatsApp'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket formaté prêt à l\'envoi WhatsApp !')),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Imprimer Ticket (58mm)'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impression ticket thermique lancée !')),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- DIALOGUE PANIERS EN ATTENTE ---
  void _showHeldCartsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.pause_circle_outline, color: AppTheme.gold500),
            const SizedBox(width: 8),
            Text('Paniers en attente (${appState.heldCarts.length})'),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: appState.heldCarts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun panier en attente.', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: appState.heldCarts.length,
                  itemBuilder: (ctx, idx) {
                    final h = appState.heldCarts[idx];
                    return ListTile(
                      title: Text(h.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${h.items.length} article(s) • Total : ${AppTheme.formatFCFA(h.total)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: AppTheme.success),
                            tooltip: 'Reprendre',
                            onPressed: () {
                              appState.resumeHeldCart(h);
                              Navigator.pop(ctx);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.danger),
                            tooltip: 'Supprimer',
                            onPressed: () {
                              appState.discardHeldCart(h);
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _promptHoldCart(BuildContext context) {
    final ctrl = TextEditingController(text: 'Client en attente');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mettre le panier en attente', style: TextStyle(fontSize: 15)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nom ou repère du client', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              appState.holdCurrentCart(customerName: ctrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Panier mis en attente avec succès !')),
              );
            },
            child: const Text('Mettre en attente'),
          ),
        ],
      ),
    );
  }

  // --- SCANNER CODE-BARRES VIRTUEL ---
  void _showBarcodeScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppTheme.gold500),
            SizedBox(width: 8),
            Text('Scanner Code-Barres', style: TextStyle(fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 90,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.gold500, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Text('Visez le code-barres de l\'article', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Articles détectables instantanément :', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: appState.products.take(4).map((p) {
                return ActionChip(
                  label: Text(p.name.split(' ').first, style: const TextStyle(fontSize: 10)),
                  onPressed: () {
                    appState.addToCart(p);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bip ! ${p.name} scanné et ajouté au panier.')),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }
}
