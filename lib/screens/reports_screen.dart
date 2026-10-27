import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final appState = AppState.instance;

  // Billetterie / Comptage physique des espèces
  int b10k = 2; // 2x 10.000
  int b5k = 2;  // 2x 5.000
  int b2k = 4;  // 4x 2.000
  int b1k = 3;  // 3x 1.000
  int b500 = 1; // 1x 500
  int pieces = 300; // Pièces

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get countedCash => (
      
      (b10k * 10000) +
      (b5k * 5000) +
      (b2k * 2000) +
      (b1k * 1000) +
      (b500 * 500) +
      pieces).toDouble();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final expectedCash = appState.cashInDrawerExpected;
        final cashDiff = countedCash - expectedCash;

        final orangeMoneyTotal = appState.sales
            .where((s) => s.paymentMethod == 'Orange Money')
            .fold(0.0, (sum, s) => sum + s.total);

        final mtnMomoTotal = appState.sales
            .where((s) => s.paymentMethod == 'MTN MoMo')
            .fold(0.0, (sum, s) => sum + s.total);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Bilan Financier & Clôture de Caisse (Z)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.gold500,
              indicatorWeight: 3,
              labelColor: AppTheme.gold500,
              unselectedLabelColor: Colors.white70,
              tabs: [
                const Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.point_of_sale, size: 18),
                      SizedBox(width: 8),
                      Text('Clôture Journalière (Z)'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 18),
                      const SizedBox(width: 8),
                      Text('Charges & Dépenses (${appState.expenses.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ONGLET 1 : CLÔTURE Z DE CAISSE
              _buildZClosingTab(expectedCash, cashDiff, orangeMoneyTotal, mtnMomoTotal),
              // ONGLET 2 : CHARGES & DÉPENSES
              _buildExpensesTab(),
            ],
          ),
        );
      },
    );
  }

  // --- ONGLET 1 : CLÔTURE Z DE CAISSE ---
  Widget _buildZClosingTab(double expectedCash, double cashDiff, double orangeMoneyTotal, double mtnMomoTotal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte Récapitulative du Jour
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rapport Z Journalier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy900)),
                          Text(appState.currentStore, style: const TextStyle(fontSize: 11, color: AppTheme.slate500)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.gold500, borderRadius: BorderRadius.circular(6)),
                        child: const Text('EN COURS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.navy900)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  _buildReportRow('Fond de caisse initial (Ouverture) :', AppTheme.formatFCFA(appState.openingCash), Icons.store, AppTheme.slate600),
                  const SizedBox(height: 8),
                  _buildReportRow(
                    'Ventes en Espèces :',
                    AppTheme.formatFCFA(appState.sales.where((s) => s.paymentMethod == 'Espèces').fold(0.0, (sum, s) => sum + s.total)),
                    Icons.money,
                    AppTheme.success,
                  ),
                  const SizedBox(height: 8),
                  _buildReportRow(
                    'Recouvrements de dettes (Espèces) :',
                    '+ ${AppTheme.formatFCFA(10000)}',
                    Icons.call_received,
                    AppTheme.success,
                  ),
                  const SizedBox(height: 8),
                  _buildReportRow(
                    'Sorties de caisse (Dépenses / Charges) :',
                    '- ${AppTheme.formatFCFA(appState.todayExpensesTotal)}',
                    Icons.call_made,
                    AppTheme.danger,
                  ),
                  const Divider(height: 20),

                  // Tiroir théorique
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ESPÈCES THÉORIQUES EN TIROIR :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.navy900)),
                      Text(
                        AppTheme.formatFCFA(expectedCash),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.navy900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // MODULE DE COMPTAGE PHYSIQUE DES BILLETS (Billetage)
          Card(
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calculate, color: AppTheme.navy900, size: 20),
                          SizedBox(width: 8),
                          Text('Comptage Physique des Espèces', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Text(
                        'Total compté : ${AppTheme.formatFCFA(countedCash)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.navy900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Saisissez le nombre de billets et pièces physiques dans le tiroir :', style: TextStyle(fontSize: 11, color: AppTheme.slate600)),
                  const SizedBox(height: 12),

                  // Grille des coupures
                  Row(
                    children: [
                      Expanded(child: _buildBillCounter('10.000 FCFA', b10k, (v) => setState(() => b10k = v))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildBillCounter('5.000 FCFA', b5k, (v) => setState(() => b5k = v))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildBillCounter('2.000 FCFA', b2k, (v) => setState(() => b2k = v))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildBillCounter('1.000 FCFA', b1k, (v) => setState(() => b1k = v))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildBillCounter('500 FCFA', b500, (v) => setState(() => b500 = v))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildBillCounter('Pièces (FCFA)', pieces, (v) => setState(() => pieces = v), step: 100)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Écart de Caisse
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cashDiff == 0
                          ? const Color(0xFFDCFCE7)
                          : (cashDiff < 0 ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cashDiff == 0
                            ? AppTheme.success
                            : (cashDiff < 0 ? AppTheme.danger : AppTheme.info),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cashDiff == 0
                              ? 'Écart de Caisse : Parfait (0 FCFA)'
                              : (cashDiff < 0 ? 'Manquant de caisse :' : 'Excédent de caisse :'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: cashDiff == 0
                                ? AppTheme.success
                                : (cashDiff < 0 ? AppTheme.danger : AppTheme.info),
                          ),
                        ),
                        Text(
                          AppTheme.formatFCFA(cashDiff.abs()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: cashDiff == 0
                                ? AppTheme.success
                                : (cashDiff < 0 ? AppTheme.danger : AppTheme.info),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // SYNTHÈSE DES PAIEMENTS DIGITAUX (OM & MoMo)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Encaissements Mobile Money du Jour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildReportRow('Orange Money Cameroun :', AppTheme.formatFCFA(orangeMoneyTotal), Icons.phone_android, AppTheme.orangeMoney),
                  const SizedBox(height: 8),
                  _buildReportRow('MTN Mobile Money :', AppTheme.formatFCFA(mtnMomoTotal), Icons.phonelink_ring, const Color(0xFFCC9900)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL GÉNÉRAL DU JOUR :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        AppTheme.formatFCFA(appState.todayRevenue),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.navy900),
                      ),
                    ],
                  ),
                  if (appState.isBossMode) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('BÉNÉFICE NET DU JOUR :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.success)),
                        Text(
                          AppTheme.formatFCFA(appState.todayNetProfit),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.success),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // BOUTONS D'ACTION CLÔTURE
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.success,
                    side: const BorderSide(color: AppTheme.success),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.send_to_mobile),
                  label: const Text('Envoyer Z sur WhatsApp Patron'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rapport Z complet formaté et prêt pour WhatsApp !')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navy900,
                    foregroundColor: AppTheme.gold500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.lock),
                  label: const Text('VALIDER CLÔTURE Z'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Clôture validée avec succès ! Rapport archivé.')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBillCounter(String label, int value, ValueChanged<int> onChanged, {int step = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          Row(
            children: [
              InkWell(
                onTap: value > 0 ? () => onChanged(value - step) : null,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: AppTheme.surfaceRaised, borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.remove, size: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              InkWell(
                onTap: () => onChanged(value + step),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: AppTheme.surfaceRaised, borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.add, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ONGLET 2 : CHARGES & DÉPENSES ---
  Widget _buildExpensesTab() {
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
                  const Text('TOTAL DÉPENSES SORTIES DU JOUR', style: TextStyle(color: AppTheme.slate400, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    AppTheme.formatFCFA(appState.todayExpensesTotal),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold500, foregroundColor: AppTheme.navy900),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nouvelle Dépense'),
                onPressed: () => _showAddExpenseDialog(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: appState.expenses.isEmpty
              ? const Center(child: Text('Aucune dépense enregistrée aujourd\'hui.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: appState.expenses.length,
                  separatorBuilder: (_, index) => const Divider(height: 12),
                  itemBuilder: (context, idx) {
                    final e = appState.expenses[idx];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt, color: AppTheme.danger, size: 20),
                      ),
                      title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(
                        '${e.category} • ${e.paidBy}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                      ),
                      trailing: Text(
                        '- ${AppTheme.formatFCFA(e.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.danger),
                      ),
                    );
                  },
                ),
        ),
      ],
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
          title: const Text('Enregistrer une Dépense (Sortie de caisse)', style: TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
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
                decoration: const InputDecoration(labelText: 'Description du motif', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant décaissé (FCFA) *', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0) return;
                appState.addExpense(
                  category: category,
                  description: descCtrl.text.isEmpty ? category : descCtrl.text,
                  amount: amt,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dépense de ${AppTheme.formatFCFA(amt)} déduite du tiroir caisse !')),
                );
              },
              child: const Text('Valider Dépense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.slate700))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.navy900)),
      ],
    );
  }
}
