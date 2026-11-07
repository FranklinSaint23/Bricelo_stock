import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final appState = AppState.instance;
  String _selectedSegment = 'Ce mois';
  DateTimeRange? _customDateRange;

  final List<String> _expensePeriods = const [
    'Ce mois',
    'Mois passé',
    '3 derniers mois',
    '6 derniers mois',
    '9 derniers mois',
    '12 derniers mois',
    'Personnalisé',
  ];

  final List<({String name, IconData icon})> _cameroonCategories = const [
    (name: 'Loyer', icon: Icons.apartment_rounded),
    (name: 'Salaires', icon: Icons.groups_rounded),
    (name: 'Électricité/eau', icon: Icons.bolt_rounded),
    (name: 'Transport', icon: Icons.local_shipping_rounded),
    (name: 'Téléphone & internet', icon: Icons.wifi_rounded),
    (name: 'Impôts & taxes', icon: Icons.account_balance_rounded),
    (name: 'Emballage', icon: Icons.inventory_2_rounded),
    (name: 'Fournitures', icon: Icons.edit_note_rounded),
    (name: 'Marketing / publicité', icon: Icons.campaign_rounded),
    (name: 'Entretien', icon: Icons.cleaning_services_rounded),
    (name: 'Frais bancaires', icon: Icons.credit_card_rounded),
    (name: 'Assurance', icon: Icons.verified_user_rounded),
    (name: 'Divers', icon: Icons.more_horiz_rounded),
  ];

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryNavy,
              onPrimary: Colors.white,
              secondary: AppTheme.accentGold,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedSegment = 'Personnalisé';
      });
    }
  }

  List<Expense> _getFilteredExpenses() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (_selectedSegment) {
      case 'Ce mois':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;

      case 'Mois passé':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        break;

      case '3 derniers mois':
        start = DateTime(now.year, now.month - 2, 1);
        break;

      case '6 derniers mois':
        start = DateTime(now.year, now.month - 5, 1);
        break;

      case '9 derniers mois':
        start = DateTime(now.year, now.month - 8, 1);
        break;

      case '12 derniers mois':
        start = DateTime(now.year - 1, now.month, 1);
        break;

      case 'Personnalisé':
        if (_customDateRange != null) {
          start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
          end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59, 999);
        } else {
          start = DateTime(now.year, now.month, 1);
        }
        break;

      default:
        start = DateTime(now.year, now.month, 1);
    }

    return appState.expenses.where((e) {
      return e.createdAt.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          e.createdAt.isBefore(end.add(const Duration(milliseconds: 1)));
    }).toList();
  }

  void _showExpenseDetailModal(BuildContext context, Expense exp) {
    final isDark = appState.isDarkMode;
    final catMatch = _cameroonCategories.firstWhere(
      (c) => c.name.toLowerCase() == exp.category.toLowerCase(),
      orElse: () => (name: exp.category, icon: Icons.price_change_rounded),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entête
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(catMatch.icon, color: const Color(0xFFB45309), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exp.category,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const Text(
                              'Détail de la dépense',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Montant en grand
                Center(
                  child: Column(
                    children: [
                      Text(
                        '-${AppTheme.formatFCFA(exp.amount)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDC2626),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fiche d'informations
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Compte / Caisse', exp.paidFromCaisse, Icons.account_balance_wallet_outlined),
                      const Divider(height: 16, color: Color(0xFFE2E8F0)),
                      _buildDetailRow(
                        'Date & Heure',
                        '${exp.createdAt.day.toString().padLeft(2, "0")}/${exp.createdAt.month.toString().padLeft(2, "0")}/${exp.createdAt.year} à ${exp.createdAt.hour.toString().padLeft(2, "0")}:${exp.createdAt.minute.toString().padLeft(2, "0")}',
                        Icons.access_time_rounded,
                      ),
                      if (exp.reference != null && exp.reference!.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Référence pièce', exp.reference!, Icons.receipt_long_rounded),
                      ],
                      const Divider(height: 16, color: Color(0xFFE2E8F0)),
                      _buildDetailRow('Enregistrée par', exp.paidBy, Icons.person_outline_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton Supprimer cette dépense
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Supprimer cette dépense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeleteExpense(context, exp);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteExpense(BuildContext context, Expense exp) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer la suppression', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous supprimer cette dépense de ${AppTheme.formatFCFA(exp.amount)} ? Le solde de la caisse (${exp.paidFromCaisse}) sera réajusté.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              Navigator.pop(dlgCtx);
              // Supprimer et réajuster la caisse
              appState.expenses.removeWhere((e) => e.id == exp.id);
              final caisse = appState.cashDesks.where((c) => c.name.toLowerCase() == exp.paidFromCaisse.toLowerCase()).firstOrNull;
              if (caisse != null) {
                caisse.balance += exp.amount;
              }
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dépense supprimée et solde réajusté avec succès')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openNewExpenseModal(BuildContext context) {
    final isDark = appState.isDarkMode;
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();

    String selectedCategory = _cameroonCategories.first.name;
    final defaultAmount = appState.getLastExpenseAmount(selectedCategory);
    if (defaultAmount > 0) {
      amountCtrl.text = defaultAmount.toInt().toString();
    }

    final availableCaisses = appState.cashDesks.isNotEmpty
        ? appState.cashDesks.map((c) => c.name).toList()
        : ['Caisse ${appState.currentStore}', 'Caisse 1'];
    String selectedCaisse = availableCaisses.first;

    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Center(
                      child: Text(
                        'Nouvelle dépense',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 1. Description *
                    TextFormField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Ex: Loyer boutique mois en cours',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Montant *
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Montant *',
                        suffixText: 'F CFA',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Catégorie * (Chips horizontaux)
                    const Text(
                      'Catégorie *',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _cameroonCategories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, idx) {
                          final cat = _cameroonCategories[idx];
                          final isSelected = selectedCategory == cat.name;
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = cat.name;
                                // Règle : pré-remplir le dernier montant connu pour cette catégorie
                                final prevAmt = appState.getLastExpenseAmount(cat.name);
                                if (prevAmt > 0 && amountCtrl.text.trim().isEmpty) {
                                  amountCtrl.text = prevAmt.toInt().toString();
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentGold : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 16,
                                    color: isSelected ? const Color(0xFFB45309) : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? const Color(0xFFB45309) : const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. Payé depuis *
                    DropdownButtonFormField<String>(
                      initialValue: availableCaisses.contains(selectedCaisse) ? selectedCaisse : availableCaisses.first,
                      decoration: InputDecoration(
                        labelText: 'Payé depuis *',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: availableCaisses.map((c) {
                        return DropdownMenuItem<String>(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCaisse = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // 5. Date *
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: modalContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date : ${selectedDate.day.toString().padLeft(2, "0")}/${selectedDate.month.toString().padLeft(2, "0")}/${selectedDate.year}',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 6. Référence (optionnel)
                    TextFormField(
                      controller: refCtrl,
                      decoration: InputDecoration(
                        labelText: 'Référence (optionnel)',
                        hintText: 'Ex: FACT-2026-004',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 7. Boutons Actions (Annuler / Créer)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF475569),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(modalContext),
                            child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              foregroundColor: AppTheme.accentGold,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              final desc = descCtrl.text.trim();
                              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                              if (desc.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Veuillez saisir une description.'), backgroundColor: Color(0xFFDC2626)),
                                );
                                return;
                              }
                              if (amt <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Veuillez saisir un montant valide.'), backgroundColor: Color(0xFFDC2626)),
                                );
                                return;
                              }

                              appState.addExpense(
                                category: selectedCategory,
                                description: desc,
                                amount: amt,
                                paidFromCaisse: selectedCaisse,
                                reference: refCtrl.text.trim().isNotEmpty ? refCtrl.text.trim() : null,
                                createdAt: selectedDate,
                              );

                              Navigator.pop(modalContext);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF059669),
                                  content: Text('Dépense de ${AppTheme.formatFCFA(amt)} enregistrée avec succès.'),
                                ),
                              );
                            },
                            child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final expensesList = _getFilteredExpenses();
        final totalPeriod = expensesList.fold(0.0, (sum, e) => sum + e.amount);

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Dépenses',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              // Périodes sous le header (scroll horizontal clair et accessible)
              Container(
                color: isDark ? const Color(0xFF0F1A28) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _expensePeriods.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final p = _expensePeriods[idx];
                      final isSelected = _selectedSegment == p;
                      return InkWell(
                        onTap: () {
                          if (p == 'Personnalisé') {
                            _pickCustomDateRange();
                          } else {
                            setState(() => _selectedSegment = p);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentGold : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? AppTheme.primaryNavy : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bannière total dépenses de la période
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($_selectedSegment)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    Text(
                      AppTheme.formatFCFA(totalPeriod),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Liste des dépenses ou État vide
              Expanded(
                child: expensesList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.receipt_long_rounded, size: 36, color: AppTheme.accentGold),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune dépense ($_selectedSegment)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Cliquez sur Créer pour enregistrer un loyer, salaire, facture ou charge d\'exploitation.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: expensesList.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final exp = expensesList[idx];
                          final catMatch = _cameroonCategories.firstWhere(
                            (c) => c.name.toLowerCase() == exp.category.toLowerCase(),
                            orElse: () => (name: exp.category, icon: Icons.price_change_rounded),
                          );

                          return InkWell(
                            onTap: () => _showExpenseDetailModal(context, exp),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(catMatch.icon, color: const Color(0xFFB45309), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exp.description.isNotEmpty ? exp.description : exp.category,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                exp.category,
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                '${exp.createdAt.day.toString().padLeft(2, "0")}/${exp.createdAt.month.toString().padLeft(2, "0")}/${exp.createdAt.year} • ${exp.paidFromCaisse}',
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '-${AppTheme.formatFCFA(exp.amount)}',
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Bouton Créer en bas (Protégé contre la barre de boutons Samsung / Android)
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: AppTheme.accentGold,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20, color: AppTheme.accentGold),
                      label: const Text(
                        'Créer une dépense',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                      ),
                      onPressed: () => _openNewExpenseModal(context),
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
}
