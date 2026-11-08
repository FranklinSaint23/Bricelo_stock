import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'Actifs'; // 'Actifs' or 'Archivé'
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- MODAL D'AJOUT DE CLIENT ---
  void _showAddCustomerModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final debtCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nouveau client',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nom complet *',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone *',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Adresse / Quartier',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Adresse e-mail',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: debtCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Solde de dette initial (optionnel)',
                  prefixIcon: const Icon(Icons.money_off_outlined),
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez renseigner le nom du client.')),
                      );
                      return;
                    }

                    final newCust = Customer(
                      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      phone: phone,
                      email: emailCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                    );
                    appState.addCustomer(newCust);

                    final initDebt = double.tryParse(debtCtrl.text.replaceAll(' ', '')) ?? 0.0;
                    if (initDebt > 0) {
                      appState.addManualDebt(
                        customerName: name,
                        customerPhone: phone,
                        customerCity: addressCtrl.text.trim(),
                        amount: initDebt,
                        description: 'Dette initiale',
                      );
                    }

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Client "$name" ajouté avec succès.')),
                    );
                  },
                  child: const Text('Enregistrer le client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODAL DE DÉTAILS ET D'ARCHIVAGE D'UN CLIENT ---
  void _showCustomerDetailModal(Customer customer) {
    final clientSales = appState.sales.where((s) => s.customerName.toLowerCase() == customer.name.toLowerCase()).toList();
    final clientDebt = appState.debts
        .where((d) => d.customerName.toLowerCase() == customer.name.toLowerCase() && !d.isSettled)
        .fold<double>(0.0, (sum, d) => sum + d.remainingDebt);
    final totalSpent = clientSales.fold<double>(0.0, (sum, s) => sum + s.total);

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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: customer.isArchived ? Colors.grey.shade300 : const Color(0xFFFEF3C7),
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: customer.isArchived ? Colors.grey.shade700 : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.phone.isNotEmpty ? customer.phone : 'Aucun numéro',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  if (customer.isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Archivé', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // STATS DU CLIENT
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total achats', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 3),
                          Text('${totalSpent.toInt()} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
                          Text('${clientSales.length} commande(s)', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: clientDebt > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dette en cours', style: TextStyle(fontSize: 11, color: clientDebt > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A))),
                          const SizedBox(height: 3),
                          Text(
                            '${clientDebt.toInt()} FCFA',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: clientDebt > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
                          ),
                          Text(clientDebt > 0 ? 'À recouvrer' : 'À jour', style: TextStyle(fontSize: 11, color: clientDebt > 0 ? const Color(0xFFEF4444) : const Color(0xFF22C55E))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (customer.address.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(customer.address, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                  ],
                ),
              ],
              if (customer.email.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(customer.email, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // BOUTON ARCHIVER / DÉSARCHIVER
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: customer.isArchived ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    side: BorderSide(color: customer.isArchived ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(customer.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 18),
                  label: Text(
                    customer.isArchived ? 'Désarchiver le client' : 'Archiver le client',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () {
                    final updated = customer.copyWith(isArchived: !customer.isArchived);
                    appState.updateCustomer(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          updated.isArchived
                              ? 'Client archivé avec succès (visible dans l\'onglet Archivé).'
                              : 'Client réactivé avec succès (visible dans l\'onglet Actifs).',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final query = _searchCtrl.text.trim().toLowerCase();
        final filtered = appState.customers.where((c) {
          final isArchived = c.isArchived;
          if (_selectedTab == 'Actifs' && isArchived) return false;
          if (_selectedTab == 'Archivé' && !isArchived) return false;
          if (query.isNotEmpty) {
            final matchName = c.name.toLowerCase().contains(query);
            final matchPhone = c.phone.toLowerCase().contains(query);
            return matchName || matchPhone;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
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
              'Clients'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              // CHAMP RECHERCHE
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un client...'.tr,
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4B5563)),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              // SEGMENTED TABS: Actifs | Archivé
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF9CA3AF)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = 'Actifs'),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Actifs' ? AppTheme.primaryNavy : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                              border: _selectedTab == 'Actifs' ? Border.all(color: AppTheme.primaryNavy, width: 1.2) : null,
                            ),
                            child: Center(
                              child: Text(
                                'Actifs'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _selectedTab == 'Actifs' ? AppTheme.accentGold : const Color(0xFF475569)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 38, color: const Color(0xFF9CA3AF)),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = 'Archivé'),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Archivé' ? AppTheme.primaryNavy : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                              border: _selectedTab == 'Archivé' ? Border.all(color: AppTheme.primaryNavy, width: 1.2) : null,
                            ),
                            child: Center(
                              child: Text(
                                'Archivé'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _selectedTab == 'Archivé' ? AppTheme.accentGold : const Color(0xFF475569)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // CONTENU: LISTE OU ÉTAT VIDE
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.groups_outlined, size: 68, color: Color(0xFFD1D5DB)),
                            const SizedBox(height: 14),
                            Text(
                              _selectedTab == 'Archivé' ? 'Aucun client archivé.' : 'Aucun client actif.',
                              style: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, idx) {
                          final c = filtered[idx];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: c.isArchived ? Colors.grey.shade200 : const Color(0xFFFEF3C7),
                              child: Text(
                                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: c.isArchived ? Colors.grey.shade600 : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(c.phone.isNotEmpty ? c.phone : (c.address.isNotEmpty ? c.address : 'Aucun détail')),
                            trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                            onTap: () => _showCustomerDetailModal(c),
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
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
            label: Text(
              'Ajouter un client'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: _showAddCustomerModal,
          ),
        );
      },
    );
  }
}
