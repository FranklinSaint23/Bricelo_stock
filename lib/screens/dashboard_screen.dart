import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.storefront, color: AppTheme.gold500, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appState.currentStore,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              // Bouton Switch Magasin
              PopupMenuButton<String>(
                icon: const Icon(Icons.swap_horiz, color: Colors.white),
                tooltip: 'Changer de magasin / dépôt',
                onSelected: (store) => appState.switchStore(store),
                itemBuilder: (context) => appState.availableStores.map((store) {
                  return PopupMenuItem(
                    value: store,
                    child: Row(
                      children: [
                        Icon(
                          store == appState.currentStore ? Icons.check_circle : Icons.store,
                          color: store == appState.currentStore ? AppTheme.gold500 : AppTheme.slate400,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(store, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              // Bouton Mode Patron / Mode Caissier
              IconButton(
                icon: Icon(
                  appState.isBossMode ? Icons.admin_panel_settings : Icons.lock_outline,
                  color: appState.isBossMode ? AppTheme.gold500 : AppTheme.slate400,
                ),
                tooltip: appState.isBossMode ? 'Mode Patron actif' : 'Mode Caissier actif',
                onPressed: () {
                  appState.toggleBossMode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appState.isBossMode
                          ? 'Mode Patron activé : Marges et prix d\'achat visibles.'
                          : 'Mode Caissier activé : Données financières confidentielles masquées.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BANNIÈRE DE BIENVENUE & STATUT SYNCHRO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.navy900, AppTheme.navy800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.navy900.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.gold500,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.point_of_sale, color: AppTheme.navy900, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tableau de Bord Commercial',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cameroun • Devise : FCFA • Synchronisé avec BRICÉLO.cm',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.success),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_done, color: AppTheme.success, size: 14),
                            SizedBox(width: 4),
                            Text('Cloud Actif', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. LES 4 CARTES KPI MAJEURES
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.5 : 1.3,
                      children: [
                        _buildKpiCard(
                          title: 'Ventes du Jour',
                          value: AppTheme.formatFCFA(appState.todayRevenue),
                          subtitle: '${appState.todaySalesCount} ticket(s) encaissé(s)',
                          icon: Icons.trending_up,
                          color: AppTheme.success,
                          bgLight: const Color(0xFFDCFCE7),
                        ),
                        _buildKpiCard(
                          title: 'Bénéfice Net Estimé',
                          value: appState.isBossMode
                              ? AppTheme.formatFCFA(appState.todayNetProfit)
                              : '*** FCFA',
                          subtitle: appState.isBossMode
                              ? 'Marge - ${AppTheme.formatFCFA(appState.todayExpensesTotal)} dép.'
                              : 'Mode Caissier (Masqué)',
                          icon: Icons.monetization_on,
                          color: AppTheme.gold600,
                          bgLight: const Color(0xFFFEF3C7),
                        ),
                        _buildKpiCard(
                          title: 'Dettes Clients (Dû)',
                          value: AppTheme.formatFCFA(appState.totalCustomerDebt),
                          subtitle: '${appState.debts.where((d) => !d.isSettled).length} client(s) à relancer',
                          icon: Icons.menu_book,
                          color: AppTheme.warning,
                          bgLight: const Color(0xFFFFEDD5),
                        ),
                        _buildKpiCard(
                          title: 'Alertes Stocks',
                          value: '${appState.lowStockCount + appState.outOfStockCount}',
                          subtitle: '${appState.outOfStockCount} rupture(s) totale(s)',
                          icon: Icons.warning_amber_rounded,
                          color: AppTheme.danger,
                          bgLight: const Color(0xFFFEE2E2),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 3. ACTIONS RAPIDES DU COMMERÇANT
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Actions Rapides',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy900),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.navy900,
                                foregroundColor: AppTheme.gold500,
                              ),
                              icon: const Icon(Icons.add_shopping_cart, size: 16),
                              label: const Text('NOUVELLE VENTE'),
                              onPressed: () {
                                DefaultTabController.of(context).animateTo(1);
                              },
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add_box, size: 16),
                              label: const Text('Ajouter Produit'),
                              onPressed: () => _showAddProductDialog(context),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.receipt_long, size: 16, color: AppTheme.danger),
                              label: const Text('Enregistrer Dépense'),
                              onPressed: () => _showAddExpenseDialog(context),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.person_add, size: 16, color: AppTheme.warning),
                              label: const Text('Nouveau Crédit Client'),
                              onPressed: () => _showAddDebtDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. ALERTES DE RÉAPPROVISIONNEMENT (Stock Faible & Ruptures)
                if (appState.lowStockCount > 0 || appState.outOfStockCount > 0) ...[
                  Card(
                    color: const Color(0xFFFFFBEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFFDE68A)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notification_important, color: AppTheme.warning, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Articles à réapprovisionner d\'urgence (${appState.lowStockCount + appState.outOfStockCount})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.navy900),
                                  ),
                                ],
                              ),
                              const Text('Grossistes Yaoundé / Douala', style: TextStyle(fontSize: 11, color: AppTheme.slate600)),
                            ],
                          ),
                          const Divider(height: 16),
                          ...appState.products
                              .where((p) => p.isLowStock || p.isOutOfStock)
                              .take(4)
                              .map((p) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: p.isOutOfStock ? AppTheme.danger : AppTheme.warning,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            p.isOutOfStock ? 'RUPTURE' : 'STOCK : ${p.stock}',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          'Fournisseur : ${p.supplierName ?? "Marché"}',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () => _showRestockDialog(context, p),
                                          child: const Text('+ Réassort', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 5. DERNIÈRES VENTES ENCAISSÉES
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dernières Ventes Encaissées',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy900),
                            ),
                            Text(
                              'Aujourd\'hui : ${AppTheme.formatFCFA(appState.todayRevenue)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        if (appState.sales.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text('Aucune vente enregistrée pour le moment.', style: TextStyle(color: AppTheme.slate500)),
                            ),
                          )
                        else
                          ...appState.sales.take(5).map((sale) {
                            Color badgeColor = AppTheme.success;
                            if (sale.paymentMethod == 'Orange Money') badgeColor = AppTheme.orangeMoney;
                            if (sale.paymentMethod == 'MTN MoMo') badgeColor = AppTheme.mtnYellow;
                            if (sale.paymentMethod == 'À Crédit') badgeColor = AppTheme.danger;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.receipt, color: badgeColor, size: 20),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    sale.ticketNumber,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      sale.paymentMethod,
                                      style: TextStyle(
                                        color: badgeColor == AppTheme.mtnYellow ? Colors.black87 : badgeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${sale.items.length} article(s) • ${sale.customerName}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                              ),
                              trailing: Text(
                                AppTheme.formatFCFA(sale.total),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.navy900),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgLight,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AppTheme.slate600, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppTheme.slate500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showRestockDialog(BuildContext context, Product product) {
    final qtyCtrl = TextEditingController(text: '10');
    final costCtrl = TextEditingController(text: product.buyPrice.toStringAsFixed(0));
    final supplierCtrl = TextEditingController(text: product.supplierName ?? 'Grossiste Akwa');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Réapprovisionner : ${product.name}', style: const TextStyle(fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock actuel : ${product.stock} ${product.unit}(s)', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité reçue', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix d\'achat unitaire (FCFA)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierCtrl,
              decoration: const InputDecoration(labelText: 'Fournisseur / Grossiste', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text) ?? 10;
              final cost = double.tryParse(costCtrl.text) ?? product.buyPrice;
              AppState.instance.restockProduct(
                productId: product.id,
                quantity: qty,
                buyCost: cost,
                supplier: supplierCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Réassort de +$qty ${product.name} validé !')),
              );
            },
            child: const Text('Valider le Réassort'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'Transport / Taxi';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Enregistrer une Dépense (Petite Caisse)', style: TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Catégorie de charge', border: OutlineInputBorder()),
                items: [
                  'Transport / Taxi',
                  'Ration / Repas',
                  'Électricité / Eau (Eneo)',
                  'Emballage / Sachets',
                  'Loyer magasin',
                  'Autre charge',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setDialogState(() => category = v!),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Motif de la dépense', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant décaissé (FCFA)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0) return;
                AppState.instance.addExpense(
                  category: category,
                  description: descCtrl.text.isEmpty ? category : descCtrl.text,
                  amount: amt,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dépense de ${AppTheme.formatFCFA(amt)} enregistrée !')),
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+237 6 ');
    final cityCtrl = TextEditingController(text: 'Douala');
    final amtCtrl = TextEditingController();
    final itemCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enregistrer un Crédit Client Manuel', style: TextStyle(fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom du client', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Numéro WhatsApp', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(labelText: 'Ville / Quartier', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant de la dette (FCFA)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: itemCtrl,
              decoration: const InputDecoration(labelText: 'Articles pris à crédit', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text) ?? 0;
              if (amt <= 0 || nameCtrl.text.isEmpty) return;
              AppState.instance.addManualDebt(
                customerName: nameCtrl.text,
                customerPhone: phoneCtrl.text,
                customerCity: cityCtrl.text,
                amount: amt,
                description: itemCtrl.text.isEmpty ? 'Marchandises diverses' : itemCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dette de ${AppTheme.formatFCFA(amt)} enregistrée pour ${nameCtrl.text} !')),
              );
            },
            child: const Text('Créer le Crédit'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController(text: '690${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}');
    final buyCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    final wholesaleCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '10');
    String category = 'Électronique';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nouveau Produit au Catalogue', style: TextStyle(fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom du produit', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                  items: ['Électronique', 'Électroménager', 'Bricolage & Électricité', 'Maison & Confort', 'Mode & Voyage']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 8),
                TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'Code-barres / EAN', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: buyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix d\'achat (PAMP en FCFA)', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: sellCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix de vente détail (FCFA)', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: wholesaleCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix de vente gros (FCFA)', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock initial', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final sell = double.tryParse(sellCtrl.text) ?? 0;
                final buy = double.tryParse(buyCtrl.text) ?? 0;
                final wholesale = double.tryParse(wholesaleCtrl.text) ?? (sell * 0.9);
                final stock = int.tryParse(stockCtrl.text) ?? 0;
                if (nameCtrl.text.isEmpty || sell <= 0) return;

                AppState.instance.addProduct(Product(
                  id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  category: category,
                  barcode: barcodeCtrl.text,
                  buyPrice: buy,
                  sellPrice: sell,
                  wholesalePrice: wholesale,
                  stock: stock,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Produit ${nameCtrl.text} ajouté au catalogue !')),
                );
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
