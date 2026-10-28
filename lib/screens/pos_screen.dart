import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final appState = AppState.instance;
  final _searchCtrl = TextEditingController();

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
        final products = appState.products;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            title: const Text(
              'Point de vente',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Scanner code-barres caméra activé !')),
                          );
                        },
                        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Catalogue de caisse rafraîchi !')),
                          );
                        },
                        child: const Icon(Icons.refresh, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. RECHERCHE (Screenshot 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              // 2. SÉLECTEUR DE BOUTIQUE (Screenshot 5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.storefront, size: 16, color: Color(0xFF374151)),
                        SizedBox(width: 8),
                        Text(
                          'Boutique principale',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3. LISTE DES PRODUITS AVEC ÉTAT PANIER (Screenshot 5)
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.point_of_sale_outlined, size: 64, color: Color(0xFFD1D5DB)),
                              SizedBox(height: 12),
                              Text(
                                'Aucun produit en rayon',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF374151)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Créez vos produits dans l\'onglet Produits pour commencer à vendre.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: products.length,
                  itemBuilder: (context, idx) {
                    final p = products[idx];
                    final cartIndex = appState.cart.indexWhere((c) => c.product.id == p.id);
                    final isInCart = cartIndex >= 0;
                    final cartItem = isInCart ? appState.cart[cartIndex] : null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isInCart ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isInCart ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
                          width: isInCart ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Image / Icône
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryNavy, size: 24),
                          ),
                          const SizedBox(width: 12),
                          // Nom & Catégorie
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.category,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          // Prix & Contrôles (+ ou Trash / Qte / +)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppTheme.formatFCFA(p.sellPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                              ),
                              const SizedBox(height: 6),
                              if (!isInCart)
                                InkWell(
                                  onTap: () => appState.addToCart(p),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryNavy,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, color: AppTheme.accentGold, size: 18),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => appState.removeFromCart(cartItem!),
                                      child: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${cartItem!.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => appState.updateCartQuantity(cartItem, 1),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryNavy,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add, color: AppTheme.accentGold, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 4. BARRE INFÉRIEURE DU PANIER : Payer Total (Screenshot 5)
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
                                      color: AppTheme.badgeOrange,
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
                              const Text(
                                'Payer',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            AppTheme.formatFCFA(appState.cartTotal),
                            style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
                  const Text('Encaissement Rapide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(
                    AppTheme.formatFCFA(appState.cartTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.money, color: AppTheme.success),
                title: const Text('Espèces (Cash)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Avec calcul automatique de monnaie à rendre'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  appState.finalizeSale(
                    paymentMethod: 'Espèces',
                    amountReceived: appState.cartTotal,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vente enregistrée en espèces !')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android, color: AppTheme.orangeMoney),
                title: const Text('Orange Money Cameroun', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  appState.finalizeSale(
                    paymentMethod: 'Orange Money',
                    amountReceived: appState.cartTotal,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vente enregistrée Orange Money !')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.phonelink_ring, color: AppTheme.mtnYellow),
                title: const Text('MTN Mobile Money', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  appState.finalizeSale(
                    paymentMethod: 'MTN MoMo',
                    amountReceived: appState.cartTotal,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vente enregistrée MTN MoMo !')),
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
