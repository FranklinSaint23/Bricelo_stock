import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final appState = AppState.instance;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final activeDebts = appState.debts.where((d) {
          final matchesSearch = d.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.customerPhone.contains(_searchQuery);
          return matchesSearch;
        }).toList();

        final supplierDebts = appState.supplierDebts;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Carnet de Dettes & Créances', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.gold500,
              indicatorWeight: 3,
              labelColor: AppTheme.gold500,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 18),
                      const SizedBox(width: 8),
                      Text('Dettes Clients (${appState.debts.where((d) => !d.isSettled).length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('Dettes Grossistes (${appState.supplierDebts.where((s) => !s.isSettled).length})'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add, color: AppTheme.gold500),
                tooltip: 'Nouveau crédit client',
                onPressed: () => _showAddDebtDialog(context),
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ONGLET 1 : DETTES CLIENTS
              _buildCustomerDebtsTab(activeDebts),
              // ONGLET 2 : DETTES FOURNISSEURS
              _buildSupplierDebtsTab(supplierDebts),
            ],
          ),
        );
      },
    );
  }

  // --- ONGLET 1 : DETTES CLIENTS ---
  Widget _buildCustomerDebtsTab(List<CustomerDebt> debts) {
    return Column(
      children: [
        // Carte Résumé Dettes
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.navy900, AppTheme.navy800]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL DES CRÉANCES À RECOUVRER', style: TextStyle(color: AppTheme.gold400, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    AppTheme.formatFCFA(appState.totalCustomerDebt),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppTheme.warning, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${debts.where((d) => !d.isSettled).length} en cours',
                      style: const TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Recherche Client
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Rechercher un client ou numéro WhatsApp...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(height: 8),

        // Liste des Débiteurs
        Expanded(
          child: debts.isEmpty
              ? const Center(child: Text('Aucune dette client trouvée.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: debts.length,
                  itemBuilder: (context, idx) {
                    final d = debts[idx];
                    return _buildDebtCard(d);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDebtCard(CustomerDebt debt) {
    final progress = debt.initialDebt > 0 ? (debt.paidAmount / debt.initialDebt) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.navy900)),
                      Text(
                        '${debt.customerPhone} • ${debt.customerCity}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      debt.isSettled ? 'SOLDÉ' : AppTheme.formatFCFA(debt.remainingDebt),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: debt.isSettled ? AppTheme.success : AppTheme.danger,
                      ),
                    ),
                    Text(
                      'Dû sur ${AppTheme.formatFCFA(debt.initialDebt)}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.slate500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Barre de progression du remboursement
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(debt.isSettled ? AppTheme.success : AppTheme.warning),
              ),
            ),
            const SizedBox(height: 10),

            // Articles achetés à crédit
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 14, color: AppTheme.slate500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    debt.itemsSummary.join(', '),
                    style: const TextStyle(fontSize: 11, color: AppTheme.slate700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Actions : Encaisser Versement & Relance WhatsApp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  debt.payments.isNotEmpty
                      ? 'Dernier versement : ${debt.payments.first.date.day}/${debt.payments.first.date.month}'
                      : 'Aucun acompte versé',
                  style: const TextStyle(fontSize: 10, color: AppTheme.slate500),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.success,
                        side: const BorderSide(color: AppTheme.success),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.send_to_mobile, size: 14),
                      label: const Text('Relance WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _showWhatsAppReminderDialog(context, debt),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navy900,
                        foregroundColor: AppTheme.gold500,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.payments, size: 14),
                      label: const Text('Encaisser Acompte', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: debt.isSettled ? null : () => _showPaymentDialog(context, debt),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- ONGLET 2 : DETTES FOURNISSEURS ---
  Widget _buildSupplierDebtsTab(List<SupplierDebt> debts) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DETTES ENVERS LES GROSSISTES', style: TextStyle(color: AppTheme.slate400, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    AppTheme.formatFCFA(appState.totalSupplierDebt),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(Icons.local_shipping, color: AppTheme.gold500, size: 28),
            ],
          ),
        ),
        Expanded(
          child: debts.isEmpty
              ? const Center(child: Text('Aucune dette fournisseur enregistrée.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: debts.length,
                  itemBuilder: (context, idx) {
                    final sd = debts[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(sd.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(
                                  AppTheme.formatFCFA(sd.remainingDebt),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.danger),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Facture réf : ${sd.invoiceRef} • Tél : ${sd.supplierPhone}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Échéance : ${sd.dueDate.day}/${sd.dueDate.month}/${sd.dueDate.year}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.navy900,
                                  foregroundColor: AppTheme.gold500,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.payment, size: 14),
                                label: const Text('Régler Grossiste', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  appState.recordSupplierPayment(sd.id, sd.remainingDebt);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Paiement fournisseur vers ${sd.supplierName} validé !')),
                                  );
                                },
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
    );
  }

  // --- DIALOGUE ENCAISSEMENT ACOMPTE ---
  void _showPaymentDialog(BuildContext context, CustomerDebt debt) {
    final amtCtrl = TextEditingController(text: debt.remainingDebt.toStringAsFixed(0));
    String method = 'Espèces';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Encaisser Acompte : ${debt.customerName}', style: const TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reste dû : ${AppTheme.formatFCFA(debt.remainingDebt)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger)),
              const SizedBox(height: 12),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant versé (FCFA) *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(labelText: 'Moyen de paiement', border: OutlineInputBorder()),
                items: ['Espèces', 'Orange Money', 'MTN MoMo']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setDialogState(() => method = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text) ?? 0;
                if (amt <= 0) return;
                appState.recordCustomerDebtPayment(debt.id, amt, method);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Versement de ${AppTheme.formatFCFA(amt)} encaissé et ajouté à la caisse !')),
                );
              },
              child: const Text('Valider Versement'),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGUE RELANCE WHATSAPP ---
    // --- DIALOGUE RELANCE WHATSAPP ---
  void _showWhatsAppReminderDialog(BuildContext context, CustomerDebt debt) {
    final message = "Bonjour ${debt.customerName},\n"
        "Sauf erreur de notre part, votre solde débiteur auprès de ${appState.currentStore} est de ${AppTheme.formatFCFA(debt.remainingDebt)} pour vos achats à crédit.\n"
        "Merci de bien vouloir passer régulariser ou effectuer un versement par Orange Money / MTN MoMo.\n"
        "Nous vous remercions de votre confiance et restons à votre entière disposition !";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.send_to_mobile, color: AppTheme.success),
            const SizedBox(width: 8),
            Text('Relance WhatsApp : ${debt.customerName}', style: const TextStyle(fontSize: 14)),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 12, color: Color(0xFF14532D)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Copier / Envoyer sur WhatsApp'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message de relance copié pour ${debt.customerPhone} !')),
              );
            },
          ),
        ],
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
        title: const Text('Nouveau Crédit Client', style: TextStyle(fontSize: 15)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom du client *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Numéro WhatsApp *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Ville / Quartier', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant crédit (FCFA) *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'Articles pris à crédit', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text) ?? 0;
              if (amt <= 0 || nameCtrl.text.isEmpty) return;
              appState.addManualDebt(
                customerName: nameCtrl.text,
                customerPhone: phoneCtrl.text,
                customerCity: cityCtrl.text,
                amount: amt,
                description: itemCtrl.text.isEmpty ? 'Marchandises' : itemCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Crédit de ${AppTheme.formatFCFA(amt)} enregistré !')),
              );
            },
            child: const Text('Enregistrer le Crédit'),
          ),
        ],
      ),
    );
  }
}
