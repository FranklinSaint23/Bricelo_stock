import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'En cours'; // 'En cours', 'Toutes', 'Soldées'
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showRecordPaymentModal(CustomerDebt debt) {
    final amountCtrl = TextEditingController(text: debt.remainingDebt.toInt().toString());
    final noteCtrl = TextEditingController(text: 'Versement');
    String paymentMethod = 'Espèces';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Encaisser un recouvrement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryNavy)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Client : ${debt.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
              Text('Reste à payer : ${AppTheme.formatFCFA(debt.remainingDebt)}', style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant versé (FCFA) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Mode d\'encaissement',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'Espèces', child: Text('Espèces (Caisse)')),
                  DropdownMenuItem(value: 'Orange Money', child: Text('Orange Money')),
                  DropdownMenuItem(value: 'MTN Mobile Money', child: Text('MTN Mobile Money')),
                  DropdownMenuItem(value: 'Virement bancaire', child: Text('Virement bancaire')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => paymentMethod = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Observation / Référence',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Valider le recouvrement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  onPressed: () {
                    final amount = double.tryParse(amountCtrl.text.replaceAll(' ', '')) ?? 0.0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un montant valide.')));
                      return;
                    }
                    if (amount > debt.remainingDebt) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le montant ne peut pas dépasser la dette restante.')));
                      return;
                    }

                    appState.recordCustomerDebtPayment(debt.id, amount, paymentMethod, note: noteCtrl.text.trim());
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF16A34A),
                        content: Text('Règlement de ${amount.toInt()} FCFA enregistré pour ${debt.customerName}.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddManualDebtModal() {
    final clientCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ajouter une dette client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryNavy)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: clientCtrl,
                decoration: InputDecoration(labelText: 'Nom du client *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Téléphone client', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Montant dû (FCFA) *', suffixText: 'FCFA', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setModalState(() => dueDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: AppTheme.primaryNavy, size: 20),
                      const SizedBox(width: 8),
                      Text('Échéance : ${DateFormat('dd/MM/yyyy').format(dueDate)}'),
                      const Spacer(),
                      const Icon(Icons.calendar_month, color: AppTheme.accentGold, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, foregroundColor: AppTheme.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    final name = clientCtrl.text.trim();
                    final amt = double.tryParse(amountCtrl.text.replaceAll(' ', '')) ?? 0.0;
                    if (name.isEmpty || amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez renseigner le client et le montant.')));
                      return;
                    }
                    appState.addCustomerDebt(
                      CustomerDebt(
                        id: 'debt_${DateTime.now().millisecondsSinceEpoch}',
                        saleId: 'crédit_direct',
                        customerName: name,
                        customerPhone: phoneCtrl.text.trim(),
                        originalDebt: amt,
                        remainingDebt: amt,
                        saleDate: DateTime.now(),
                        dueDate: dueDate,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dette enregistrée pour $name.')));
                  },
                  child: const Text('Enregistrer la créance', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final totalDebt = appState.totalCustomerDebt;
        final unsettledDebts = appState.debts.where((d) => !d.isSettled).toList();
        final clientCount = unsettledDebts.map((d) => d.customerName).toSet().length;

        final query = _searchCtrl.text.trim().toLowerCase();
        final displayedDebts = appState.debts.where((d) {
          if (_selectedTab == 'En cours' && d.isSettled) return false;
          if (_selectedTab == 'Soldées' && !d.isSettled) return false;
          if (query.isNotEmpty) {
            final matchName = d.customerName.toLowerCase().contains(query);
            final matchPhone = d.customerPhone.toLowerCase().contains(query);
            return matchName || matchPhone;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
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
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
            ),
            title: const Text(
              'Recouvrement des dettes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              // 1. TOP 3 KPI CARDS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFFF1EB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDBA74))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dette totale', style: TextStyle(fontSize: 11, color: Color(0xFFC2410C), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(AppTheme.formatFCFA(totalDebt), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFC2410C))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF93C5FD))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dettes en cours', style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${unsettledDebts.length}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD8B4FE))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Débiteurs', style: TextStyle(fontSize: 11, color: Color(0xFF7E22CE), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('$clientCount', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF7E22CE))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. RECHERCHE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un client ou téléphone...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),

              // 3. SEGMENTED TABS: En cours | Toutes | Soldées
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: ['En cours', 'Toutes', 'Soldées'].map((tab) {
                    final isSel = _selectedTab == tab;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = tab),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.primaryNavy : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSel ? AppTheme.primaryNavy : const Color(0xFFCBD5E1)),
                            ),
                            child: Center(
                              child: Text(
                                tab,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: isSel ? AppTheme.accentGold : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 4. LISTE DES CRÉANCES
              Expanded(
                child: displayedDebts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline_rounded, size: 60, color: Color(0xFFCBD5E1)),
                            SizedBox(height: 12),
                            Text('Aucune créance dans cette catégorie.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayedDebts.length,
                        itemBuilder: (context, idx) {
                          final d = displayedDebts[idx];
                          final isOverdue = !d.isSettled && (d.dueDate != null && d.dueDate!.isBefore(DateTime.now()));

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(d.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: d.isSettled
                                              ? const Color(0xFFDCFCE7)
                                              : (isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          d.isSettled ? 'Soldé' : (isOverdue ? 'En retard' : 'En cours'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: d.isSettled ? const Color(0xFF166534) : (isOverdue ? const Color(0xFF991B1B) : const Color(0xFF92400E)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (d.customerPhone.isNotEmpty)
                                    Text('Tél : ${d.customerPhone}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Dette initiale : ${d.originalDebt.toInt()} F', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      Text(
                                        'Reste : ${d.remainingDebt.toInt()} F CFA',
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: d.isSettled ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!d.isSettled) ...[
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF25D366),
                                            side: const BorderSide(color: Color(0xFF25D366)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.chat_bubble_outline, size: 15),
                                          label: const Text('Relancer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Message de relance WhatsApp prêt pour ${d.customerName}.')),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.accentGold,
                                            foregroundColor: AppTheme.primaryNavy,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.payments_rounded, size: 16),
                                          label: const Text('Encaisser', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          onPressed: () => _showRecordPaymentModal(d),
                                        ),
                                      ] else ...[
                                        const Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
                                        const SizedBox(width: 4),
                                        const Text('Dette entièrement régularisée', style: TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                                      ],
                                    ],
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accentGold,
            foregroundColor: AppTheme.primaryNavy,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Nouvelle dette', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: _showAddManualDebtModal,
          ),
        );
      },
    );
  }
}
