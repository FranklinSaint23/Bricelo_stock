import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class ExternalOrderScreen extends StatefulWidget {
  const ExternalOrderScreen({super.key});

  @override
  State<ExternalOrderScreen> createState() => _ExternalOrderScreenState();
}

class _ExternalOrderScreenState extends State<ExternalOrderScreen> {
  final appState = AppState.instance;

  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  String _selectedChannel = 'WhatsApp';
  String _paymentStatus = 'Payé à la livraison';

  final List<CartItem> _orderItems = [];

  void _showAddProductModal() {
    final isDark = appState.isDarkMode;
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setMState) {
            final q = searchCtrl.text.trim().toLowerCase();
            final products = appState.products.where((p) {
              if (q.isNotEmpty) return p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
              return true;
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: 450,
                child: Column(
                  children: [
                    Text(
                      'Sélectionner un article'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit...'.tr,
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                        prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        filled: isDark,
                        fillColor: isDark ? const Color(0xFF162540) : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (_) => setMState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return ListTile(
                            title: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                            subtitle: Text(
                              '${AppTheme.formatFCFA(p.sellPrice)} • Stock: ${p.stock}',
                              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                            trailing: Icon(Icons.add_circle_outline, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                            onTap: () {
                              setState(() {
                                final existing = _orderItems.indexWhere((i) => i.product.id == p.id);
                                if (existing != -1) {
                                  _orderItems[existing].quantity++;
                                } else {
                                  _orderItems.add(CartItem(product: p, quantity: 1, unitPrice: p.sellPrice));
                                }
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double get _totalOrder => _orderItems.fold(0.0, (sum, i) => sum + i.total);

  void _saveExternalOrder() {
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ajouter au moins un produit à la commande.'.tr)),
      );
      return;
    }

    final custName = _customerNameCtrl.text.trim().isNotEmpty ? _customerNameCtrl.text.trim() : 'Client $_selectedChannel';
    final custPhone = _customerPhoneCtrl.text.trim();

    // Enregistrer comme vente POS ou commande
    appState.clearCart();
    for (final item in _orderItems) {
      for (int i = 0; i < item.quantity; i++) {
        appState.addToCart(item.product);
      }
    }
    appState.finalizeSale(
      paymentMethod: _paymentStatus == 'Payé d\'avance' ? _selectedChannel : 'À Crédit',
      amountReceived: _paymentStatus == 'Payé d\'avance' ? _totalOrder : 0.0,
      customerName: custName,
      customerPhone: custPhone,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande externe enregistrée avec succès (${AppTheme.formatFCFA(_totalOrder)}) !'.tr),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
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
          'Commande externe'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Canal de provenance'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['WhatsApp', 'Téléphone', 'Instagram', 'Boutique en ligne'].map((ch) {
                    final sel = _selectedChannel == ch;
                    return ChoiceChip(
                      label: Text(ch),
                      selected: sel,
                      selectedColor: AppTheme.accentGold,
                      onSelected: (val) {
                        if (val) setState(() => _selectedChannel = ch);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _customerNameCtrl,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nom du client'.tr,
                    hintText: 'Ex: Jean Paul',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _customerPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Téléphone WhatsApp / Appel'.tr,
                    hintText: 'Ex: 699000000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ARTICLES
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Articles commandés'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    InkWell(
                      onTap: _showAddProductModal,
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, size: 18, color: AppTheme.accentGold),
                          const SizedBox(width: 4),
                          Text('Ajouter'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_orderItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('Aucun article ajouté à cette commande.'.tr, style: const TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  )
                else
                  ..._orderItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: textColor)),
                                Text('${item.quantity} x ${AppTheme.formatFCFA(item.unitPrice)} = ${AppTheme.formatFCFA(item.total)}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                } else {
                                  _orderItems.removeAt(idx);
                                }
                              });
                            },
                          ),
                          Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: () {
                              setState(() => item.quantity++);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // TOTAL & VALIDER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total commande'.tr, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text(AppTheme.formatFCFA(_totalOrder), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveExternalOrder,
                  child: Text('Enregistrer la commande'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
