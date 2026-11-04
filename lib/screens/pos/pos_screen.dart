import 'package:stock_prime/models/models.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final appState = AppState.instance;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  final List<String> _categories = ['Tous', 'Téléphones', 'Vêtements', 'Électronique', 'Alimentation'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;
        final products = appState.products.where((p) {
          final q = _searchQuery.toLowerCase();
          return p.name.toLowerCase().contains(q) || p.barcode.contains(q);
        }).toList();

        if (isDesktop) {
          return _buildDesktopLayout(context, products);
        }

        return _buildMobileLayout(context, products);
      },
    );
  }

  // ==========================================
  // VERSION GRAND ÉCRAN WEB / DESKTOP (2 COLONNES)
  // ==========================================
  Widget _buildDesktopLayout(BuildContext context, List<Product> products) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // COLONNE GAUCHE (65%) : CATALOGUE & RECHERCHE
          Expanded(
            flex: 65,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de Recherche & Filtres Rapides
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              hintText: 'Rechercher un article par nom ou code-barres...'.tr,
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bouton Scanner Code-barres
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryNavy,
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        icon: const Icon(Icons.qr_code_scanner, color: AppTheme.accentGold, size: 18),
                        label: Text('Scanner'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Scanner code-barres activé'.tr)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Catégories Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat.tr),
                            selected: isSel,
                            selectedColor: AppTheme.primaryNavy,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSel ? AppTheme.accentGold : const Color(0xFF475569),
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: isSel ? AppTheme.primaryNavy : const Color(0xFFE2E8F0)),
                            ),
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Grille de Produits Web
                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF2E5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFFEA580C), size: 40),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Rien à vendre pour l’instant'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Ajoutez un produit et son stock pour démarrer vos ventes.'.tr,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryNavy,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.add_box, size: 18),
                                  label: Text('Ajouter mon premier produit'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                                  },
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              childAspectRatio: 0.82,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final p = products[index];
                              final cartItem = appState.cart.cast<CartItem?>().firstWhere(
                                    (ci) => ci?.product.id == p.id,
                                    orElse: () => null,
                                  );

                              return InkWell(
                                onTap: () => appState.addToCart(p),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cartItem != null ? AppTheme.accentGold : const Color(0xFFE2E8F0),
                                      width: cartItem != null ? 2 : 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Image / Icon box
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.inventory_2_outlined,
                                                    color: cartItem != null ? AppTheme.accentGold : const Color(0xFF94A3B8),
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            // Nom du produit
                                            Text(
                                              p.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            // Badge Stock
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: p.stock > 5 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    '${p.stock} ${'articles'.tr}',
                                                    style: TextStyle(
                                                      color: p.stock > 5 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // Prix en vert
                                            Text(
                                              AppTheme.formatFCFA(p.sellPrice),
                                              style: const TextStyle(
                                                color: AppTheme.primaryNavy,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Badge quantité dans le panier
                                      if (cartItem != null)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentGold,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                            ),
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // COLONNE DROITE (35%) : CAISSE / PANIER EN DIRECT
          Container(
            width: 380,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                // En-tête Caisse
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long, color: AppTheme.primaryNavy, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Caisse / Ticket'.tr,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${appState.cartCount} ${'articles'.tr}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (appState.cart.isNotEmpty)
                        TextButton(
                          onPressed: () => appState.clearCart(),
                          child: Text(
                            'Vider'.tr,
                            style: const TextStyle(color: Color(0xFFF87171), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),

                // Liste des articles du panier
                Expanded(
                  child: appState.cart.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shopping_cart_outlined, size: 60, color: Color(0xFFCBD5E1)),
                                const SizedBox(height: 12),
                                Text(
                                  'Panier vide'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF475569)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cliquez sur un produit à gauche pour l\'ajouter à la caisse.'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: appState.cart.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, idx) {
                            final ci = appState.cart[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ci.product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${AppTheme.formatFCFA(ci.product.sellPrice)} / u',
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quantité - / +
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => appState.removeFromCart(ci),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.remove, size: 14, color: Color(0xFF475569)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '${ci.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => appState.updateCartQuantity(ci, 1),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryNavy,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.add, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // Total ligne
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      AppTheme.formatFCFA(ci.product.sellPrice * ci.quantity),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Récapitulatif & Modes de Règlement
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sous-total'.tr, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          Text(AppTheme.formatFCFA(appState.cartTotal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Remise'.tr, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          const Text('0 F CFA', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL'.tr,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            AppTheme.formatFCFA(appState.cartTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Boutons d'encaissement direct
                      Row(
                        children: [
                          // Espèces (Cash)
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentGold,
                                foregroundColor: AppTheme.primaryNavy,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.money, size: 16),
                              label: Text('Espèces'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              onPressed: appState.cart.isEmpty
                                  ? null
                                  : () {
                                      appState.finalizeSale(
                                        paymentMethod: 'Espèces',
                                        amountReceived: appState.cartTotal,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Vente enregistrée en espèces !'.tr)),
                                      );
                                    },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Orange Money
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6600),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: appState.cart.isEmpty
                                  ? null
                                  : () {
                                      appState.finalizeSale(
                                        paymentMethod: 'Orange Money',
                                        amountReceived: appState.cartTotal,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Vente enregistrée Orange Money !'.tr)),
                                      );
                                    },
                              child: const Text('OM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // MTN MoMo
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFCC00),
                                foregroundColor: const Color(0xFF1F2937),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: appState.cart.isEmpty
                                  ? null
                                  : () {
                                      appState.finalizeSale(
                                        paymentMethod: 'MTN MoMo',
                                        amountReceived: appState.cartTotal,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Vente enregistrée MTN MoMo !'.tr)),
                                      );
                                    },
                              child: const Text('MoMo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VERSION MOBILE (100% PRÉSERVÉE)
  // ==========================================
  Widget _buildMobileLayout(BuildContext context, List<Product> products) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: Text(
          'Point de vente'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Scanner code-barres activé'.tr)),
                        );
                      },
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Catalogue rafraîchi'.tr)),
                        );
                      },
                      child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. CHAMP DE RECHERCHE
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...'.tr,
                  hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4B5563), size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),

          // 2. SÉLECTEUR DE BOUTIQUE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF374151)),
                    const SizedBox(width: 6),
                    Text(
                      'Boutique principale'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. CONTENU : LISTE OU ÉTAT VIDE
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF2E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      color: Color(0xFFEA580C),
                                      size: 34,
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(
                                        Icons.add,
                                        color: Color(0xFFEA580C),
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Rien à vendre pour l’instant'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF111827),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Ajoutez un produit et son stock pour démarrer vos ventes.'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NewProductScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_box, color: Colors.white, size: 20),
                              label: Text(
                                'Ajouter mon premier produit'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: products.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final cartItem = appState.cart.cast<CartItem?>().firstWhere(
                            (ci) => ci?.product.id == p.id,
                            orElse: () => null,
                          );
                      final isOutOfStock = p.stock <= 0;
                      final isLowStock = p.stock > 0 && p.stock <= 5;
                      final stockColor = isOutOfStock
                          ? const Color(0xFFDC2626)
                          : (isLowStock ? const Color(0xFFD97706) : const Color(0xFF059669));
                      final stockBg = isOutOfStock
                          ? const Color(0xFFFEF2F2)
                          : (isLowStock ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
                      final stockBorder = isOutOfStock
                          ? const Color(0xFFFECACA)
                          : (isLowStock ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0));

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        AppTheme.formatFCFA(p.sellPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.primaryNavy,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: stockBg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: stockBorder),
                                        ),
                                        child: Text(
                                          isOutOfStock ? 'Épuisé'.tr : '${p.stock} en stock',
                                          style: TextStyle(
                                            color: stockColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (cartItem == null)
                              InkWell(
                                onTap: isOutOfStock ? null : () => appState.addToCart(p),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isOutOfStock ? const Color(0xFFE2E8F0) : AppTheme.primaryNavy,
                                    shape: BoxShape.circle,
                                    boxShadow: isOutOfStock
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Icon(Icons.add_rounded, color: isOutOfStock ? const Color(0xFF94A3B8) : Colors.white, size: 20),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => appState.updateCartQuantity(cartItem, -1),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.remove_rounded, size: 14, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${cartItem.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => appState.updateCartQuantity(cartItem, 1),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryNavy,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 4. BARRE DU PANIER LORSQUE NON VIDE
          if (appState.cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: InkWell(
                onTap: () => _showPaymentDialog(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              const Icon(Icons.shopping_cart, color: Colors.white, size: 22),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF97316),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${appState.cartCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Payer'.tr,
                            style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        AppTheme.formatFCFA(appState.cartTotal),
                        style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Encaissement Rapide'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(
                    AppTheme.formatFCFA(appState.cartTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.money, color: Color(0xFF16A34A)),
                title: Text('Espèces (Cash)'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Avec calcul automatique de monnaie à rendre'.tr),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  appState.finalizeSale(
                    paymentMethod: 'Espèces',
                    amountReceived: appState.cartTotal,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vente enregistrée en espèces !'.tr)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android, color: Color(0xFFFF6600)),
                title: Text('Orange Money Cameroun'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  appState.finalizeSale(
                    paymentMethod: 'Orange Money',
                    amountReceived: appState.cartTotal,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vente enregistrée Orange Money !'.tr)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.phonelink_ring, color: Color(0xFFFFCC00)),
                title: Text('MTN Mobile Money'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  appState.finalizeSale(
                    paymentMethod: 'MTN MoMo',
                    amountReceived: appState.cartTotal,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vente enregistrée MTN MoMo !'.tr)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
