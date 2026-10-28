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
            backgroundColor: const Color(0xFF1B5E20),
            title: const Text(
              'Point de vente',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
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
                      color: const Color(0xFF86A789).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Scanner code-barres activé')),
                            );
                          },
                          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Catalogue rafraîchi')),
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
              // 1. CHAMP DE RECHERCHE (Pilule arrondie avec bordure fine)
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
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit...',
                      hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF4B5563), size: 22),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              // 2. SÉLECTEUR DE BOUTIQUE (Badge arrondi 'Boutique principale ⌄')
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
                      children: const [
                        Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF374151)),
                        SizedBox(width: 6),
                        Text(
                          'Boutique principale',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. CONTENU : LISTE OU ÉTAT VIDE CONFORME AU SCREENSHOT
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Cercle doux orange avec icône carton +
                              Container(
                                width: 76,
                                height: 76,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF2E5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Stack(
                                      children: const [
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

                              // Titre gras
                              const Text(
                                'Rien à vendre pour l’instant',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF111827),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              // Sous-titre descriptif
                              const Text(
                                'Ajoutez un produit et son stock pour démarrer vos ventes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bouton vert forêt arrondi 'Ajouter mon premier produit'
                              SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20),
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
                                  label: const Text(
                                    'Ajouter mon premier produit',
                                    style: TextStyle(
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
                        separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          final cartItem = appState.cart.cast<CartItem?>().firstWhere(
                                (ci) => ci?.product.id == p.id,
                                orElse: () => null,
                              );

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF9CA3AF), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppTheme.formatFCFA(p.sellPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B5E20),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (cartItem == null)
                                  InkWell(
                                    onTap: () => appState.addToCart(p),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1B5E20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => appState.removeFromCart(cartItem),
                                        child: const Icon(Icons.remove_circle_outline, color: Color(0xFFDC2626), size: 22),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${cartItem.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => appState.updateCartQuantity(cartItem, 1),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1B5E20),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ],
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
                        color: const Color(0xFF1B5E20),
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
                              const Text(
                                'Payer',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            AppTheme.formatFCFA(appState.cartTotal),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.money, color: Color(0xFF16A34A)),
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
                leading: const Icon(Icons.phone_android, color: Color(0xFFFF6600)),
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
                leading: const Icon(Icons.phonelink_ring, color: Color(0xFFFFCC00)),
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
