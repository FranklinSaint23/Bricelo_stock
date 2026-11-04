import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

// ==========================================
// 1. JOURNAL COMPTABLE
// ==========================================
class AccountingJournalScreen extends StatefulWidget {
  const AccountingJournalScreen({super.key});

  @override
  State<AccountingJournalScreen> createState() => _AccountingJournalScreenState();
}

class _AccountingJournalScreenState extends State<AccountingJournalScreen> {
  final appState = AppState.instance;
  String _filter = 'Tous'; // 'Tous', 'Ventes', 'Achats', 'Dépenses'

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        // Génération des écritures à partir des ventes et dépenses
        final entries = <Map<String, dynamic>>[];
        for (final s in appState.sales) {
          if (_filter == 'Tous' || _filter == 'Ventes') {
            entries.add({
              'date': s.createdAt,
              'piece': s.ticketNumber,
              'libelle': 'Vente comptoir (${s.paymentMethod}) - ${s.customerName}',
              'compteDebit': s.paymentMethod == 'À Crédit' ? '411 Clients' : '531 Caisse',
              'compteCredit': '701 Ventes de Marchandises',
              'debit': s.total,
              'credit': s.total,
              'type': 'VENTE',
            });
          }
        }
        for (final e in appState.expenses) {
          if (_filter == 'Tous' || _filter == 'Dépenses') {
            entries.add({
              'date': e.date,
              'piece': 'DEP-${e.id.length > 5 ? e.id.substring(e.id.length - 5) : e.id}',
              'libelle': '${e.category}: ${e.description}',
              'compteDebit': '605 Charges Générales (${e.category})',
              'compteCredit': '531 Caisse principale',
              'debit': e.amount,
              'credit': e.amount,
              'type': 'DEPENSE',
            });
          }
        }
        for (final m in appState.stockMovements.where((m) => m.type.contains('RÉASSORT'))) {
          if (_filter == 'Tous' || _filter == 'Achats') {
            final p = appState.products.firstWhere((prod) => prod.id == m.productId, orElse: () => appState.products.first);
            final val = m.quantity * p.buyPrice;
            if (val > 0) {
              entries.add({
                'date': m.date,
                'piece': 'REC-${m.id.length > 5 ? m.id.substring(m.id.length - 5) : m.id}',
                'libelle': 'Réassort: ${m.quantity}x ${m.productName}',
                'compteDebit': '601 Achats de Marchandises',
                'compteCredit': '401 Fournisseurs / Trésorerie',
                'debit': val,
                'credit': val,
                'type': 'ACHAT',
              });
            }
          }
        }

        // Trier par date décroissante
        entries.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

        final totalDebit = entries.fold<double>(0.0, (sum, e) => sum + (e['debit'] as double));
        final totalCredit = entries.fold<double>(0.0, (sum, e) => sum + (e['credit'] as double));

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Journal & activation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
          body: Column(
            children: [
              // Totaux Débit / Crédit
              Container(
                color: AppTheme.primaryNavy,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL DÉBIT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(AppTheme.formatFCFA(totalDebit), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL CRÉDIT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(AppTheme.formatFCFA(totalCredit), style: const TextStyle(color: AppTheme.accentGold, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtres
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? AppTheme.darkSurface : Colors.white,
                child: Row(
                  children: ['Tous', 'Ventes', 'Achats', 'Dépenses'].map((f) {
                    final sel = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: sel ? Colors.white : AppTheme.textPrimary)),
                        selected: sel,
                        selectedColor: AppTheme.primaryNavy,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Liste des écritures
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 50, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('Aucune écriture comptable enregistrée', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final e = entries[idx];
                          final d = e['date'] as DateTime;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(e['piece'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(e['libelle'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Débit: ${e['compteDebit']}', style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A))),
                                            const SizedBox(height: 2),
                                            Text('Crédit: ${e['compteCredit']}', style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        AppTheme.formatFCFA(e['debit'] as double),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppTheme.primaryNavy),
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
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 2. BALANCE GÉNÉRALE COMPTABLE
// ==========================================
class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        final salesTotal = appState.sales.fold<double>(0.0, (sum, s) => sum + s.total);
        final cashSalesTotal = appState.sales.where((s) => s.paymentMethod != 'À Crédit').fold<double>(0.0, (sum, s) => sum + s.total);
        final expTotal = appState.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
        final custDebts = appState.totalCustomerDebt;
        final suppDebts = appState.totalSupplierDebt;
        final stockVal = appState.products.fold<double>(0.0, (sum, p) => sum + (p.stock * p.buyPrice));

        final accounts = [
          {'code': '101', 'name': 'Capital & Apports', 'debit': 0.0, 'credit': 500000.0},
          {'code': '311', 'name': 'Stocks de Marchandises', 'debit': stockVal, 'credit': 0.0},
          {'code': '401', 'name': 'Fournisseurs & comptes rattachés', 'debit': 0.0, 'credit': suppDebts},
          {'code': '411', 'name': 'Clients & comptes rattachés', 'debit': custDebts, 'credit': 0.0},
          {'code': '531', 'name': 'Caisse Principale (Espèces & Tréso)', 'debit': cashSalesTotal > expTotal ? (cashSalesTotal - expTotal) : 0.0, 'credit': expTotal > cashSalesTotal ? (expTotal - cashSalesTotal) : 0.0},
          {'code': '601', 'name': 'Achats de Marchandises', 'debit': stockVal * 0.7, 'credit': 0.0},
          {'code': '605', 'name': 'Autres Charges d\'Exploitation', 'debit': expTotal, 'credit': 0.0},
          {'code': '701', 'name': 'Ventes de Marchandises', 'debit': 0.0, 'credit': salesTotal},
        ];

        final sumDebit = accounts.fold<double>(0.0, (sum, a) => sum + (a['debit'] as double));
        final sumCredit = accounts.fold<double>(0.0, (sum, a) => sum + (a['credit'] as double));

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Balance des comptes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
          body: Column(
            children: [
              Container(
                color: AppTheme.primaryNavy,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL MOUVEMENT DÉBIT', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(AppTheme.formatFCFA(sumDebit), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('TOTAL MOUVEMENT CRÉDIT', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(AppTheme.formatFCFA(sumCredit), style: const TextStyle(color: AppTheme.accentGold, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final a = accounts[idx];
                    final d = a['debit'] as double;
                    final c = a['credit'] as double;
                    final solde = d - c;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(a['code'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  a['name'] as String,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Débit: ${AppTheme.formatFCFA(d)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              Text('Crédit: ${AppTheme.formatFCFA(c)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(
                                solde >= 0 ? '+${AppTheme.formatFCFA(solde)} (D)' : '-${AppTheme.formatFCFA(solde.abs())} (C)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: solde >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
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
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 3. COMPTE DE RÉSULTAT (P&L)
// ==========================================
class IncomeStatementScreen extends StatelessWidget {
  const IncomeStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        final caBrut = appState.sales.fold<double>(0.0, (sum, s) => sum + s.total);
        final remises = appState.sales.fold<double>(0.0, (sum, s) => sum + s.discountTotal);
        final caNet = caBrut - remises;

        // Calcul du coût des marchandises vendues (COGS)
        double cogs = 0.0;
        for (final s in appState.sales) {
          for (final it in s.items) {
            final p = appState.products.firstWhere(
              (prod) => prod.name == it.productName,
              orElse: () => Product(id: '', name: it.productName, category: '', barcode: '', buyPrice: it.unitPrice * 0.7, sellPrice: it.unitPrice, stock: 0),
            );
            cogs += p.buyPrice * it.quantity;
          }
        }

        final margeBrute = caNet - cogs;
        final margePct = caNet > 0 ? (margeBrute / caNet * 100) : 0.0;
        final totalCharges = appState.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
        final resultatNet = margeBrute - totalCharges;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Compte de résultat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Résultat net banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: resultatNet >= 0
                        ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                        : [const Color(0xFF7F1D1D), const Color(0xFF991B1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RÉSULTAT NET D\'EXPLOITATION', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatFCFA(resultatNet),
                      style: TextStyle(
                        color: resultatNet >= 0 ? AppTheme.accentGold : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resultatNet >= 0 ? 'Bénéfice net réalisé sur la période' : 'Perte d\'exploitation sur la période',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Détails P&L
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildRowItem('Chiffre d\'Affaires brut', caBrut, isPositive: true),
                    if (remises > 0) _buildRowItem('Remises accordées', -remises, isPositive: false),
                    const Divider(height: 20),
                    _buildRowItem('Chiffre d\'Affaires net', caNet, isBold: true),
                    _buildRowItem('Coût d\'Achat des Marchandises', -cogs, isPositive: false),
                    const Divider(height: 20),
                    _buildRowItem('Marge Brute commerciale (${margePct.toStringAsFixed(1)}%)', margeBrute, isBold: true, color: const Color(0xFF16A34A)),
                    _buildRowItem('Charges d\'exploitation & dépenses', -totalCharges, isPositive: false),
                    const Divider(height: 24, thickness: 1.5),
                    _buildRowItem('RÉSULTAT NET', resultatNet, isBold: true, fontSize: 15, color: resultatNet >= 0 ? AppTheme.primaryNavy : const Color(0xFFDC2626)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRowItem(String label, double val, {bool isPositive = true, bool isBold = false, double fontSize = 13, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
          Text(
            AppTheme.formatFCFA(val),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: fontSize,
              color: color ?? (isPositive ? const Color(0xFF1E293B) : const Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. BILAN COMPTABLE
// ==========================================
class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        final stockVal = appState.products.fold<double>(0.0, (sum, p) => sum + (p.stock * p.buyPrice));
        final custDebts = appState.totalCustomerDebt;
        final cashSalesTotal = appState.sales.where((s) => s.paymentMethod != 'À Crédit').fold<double>(0.0, (sum, s) => sum + s.total);
        final expTotal = appState.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
        final cashInHand = cashSalesTotal > expTotal ? (cashSalesTotal - expTotal) : 0.0;
        final totalActif = stockVal + custDebts + cashInHand + 250000.0; // 250k d'immobilisations

        final suppDebts = appState.totalSupplierDebt;
        final resultNet = (stockVal * 0.3) + cashInHand;
        final capitaux = totalActif - suppDebts;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Bilan comptable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ACTIF
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: AppTheme.primaryNavy, size: 20),
                        const SizedBox(width: 8),
                        Text('ACTIF (Emplois)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppTheme.primaryNavy)),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildBalanceLine('Immobilisations corporelles (matériel/mobilier)', 250000.0),
                    _buildBalanceLine('Stocks de marchandises (${appState.products.length} articles)', stockVal),
                    _buildBalanceLine('Créances clients (crédits non réglés)', custDebts),
                    _buildBalanceLine('Disponibilités en caisse & banques', cashInHand),
                    const Divider(height: 24, thickness: 1.5),
                    _buildBalanceLine('TOTAL DE L\'ACTIF', totalActif, isBold: true, color: AppTheme.primaryNavy),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PASSIF
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield, color: AppTheme.accentGold, size: 20),
                        const SizedBox(width: 8),
                        Text('PASSIF (Ressources)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppTheme.primaryNavy)),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildBalanceLine('Capitaux propres & Apports de départ', capitaux - resultNet),
                    _buildBalanceLine('Résultat de l\'exercice en cours', resultNet),
                    _buildBalanceLine('Dettes fournisseurs (achats à crédit)', suppDebts),
                    const Divider(height: 24, thickness: 1.5),
                    _buildBalanceLine('TOTAL DU PASSIF', totalActif, isBold: true, color: AppTheme.primaryNavy),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceLine(String label, double val, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
          Text(AppTheme.formatFCFA(val), style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ==========================================
// 5. RAPPORT DE TVA
// ==========================================
class VatReportScreen extends StatefulWidget {
  const VatReportScreen({super.key});

  @override
  State<VatReportScreen> createState() => _VatReportScreenState();
}

class _VatReportScreenState extends State<VatReportScreen> {
  final appState = AppState.instance;
  double _taxRate = 18.0; // 18% standard UEMOA

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        final caBrut = appState.sales.fold<double>(0.0, (sum, s) => sum + s.total);
        final tvaCollectee = caBrut * (_taxRate / (100 + _taxRate));

        final totalAchats = appState.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
        final tvaDeductible = totalAchats * (_taxRate / (100 + _taxRate));

        final tvaDue = tvaCollectee - tvaDeductible;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Déclaration & TVA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Choix du taux
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Taux de TVA applicable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    DropdownButton<double>(
                      value: _taxRate,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 18.0, child: Text('18% (Standard UEMOA)')),
                        DropdownMenuItem(value: 19.25, child: Text('19.25% (CEMAC)')),
                        DropdownMenuItem(value: 10.0, child: Text('10% (Taux réduit)')),
                        DropdownMenuItem(value: 0.0, child: Text('0% (Exonéré)')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _taxRate = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Synthèse TVA Due
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SOLDE DE TVA NET', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatFCFA(tvaDue > 0 ? tvaDue : 0),
                      style: const TextStyle(color: AppTheme.accentGold, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tvaDue >= 0 ? 'TVA nette à reverser au Trésor Public' : 'Crédit de TVA reportable',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tableau de calcul
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildRow('Chiffre d\'Affaires taxable', caBrut),
                    _buildRow('TVA Collectée sur ventes ($_taxRate%)', tvaCollectee, color: const Color(0xFFDC2626)),
                    const Divider(height: 20),
                    _buildRow('Charges & Achats taxables', totalAchats),
                    _buildRow('TVA Déductible sur charges ($_taxRate%)', tvaDeductible, color: const Color(0xFF16A34A)),
                    const Divider(height: 24, thickness: 1.5),
                    _buildRow('TVA NETTE DUE', tvaDue, isBold: true, fontSize: 14),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false, double fontSize = 13, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(AppTheme.formatFCFA(amount), style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ==========================================
// 6. GESTION DE LA PAIE & SALAIRES
// ==========================================
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final appState = AppState.instance;

  final List<Map<String, dynamic>> _staff = [
    {'name': 'Amadou Cissé', 'role': 'Gérant principal', 'base': 180000.0, 'primes': 25000.0, 'avances': 0.0, 'paid': false},
    {'name': 'Fatou Touré', 'role': 'Caissière', 'base': 110000.0, 'primes': 10000.0, 'avances': 15000.0, 'paid': false},
    {'name': 'Mamadou Diallo', 'role': 'Magasinier / Livreur', 'base': 95000.0, 'primes': 5000.0, 'avances': 0.0, 'paid': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final totalMasse = _staff.fold<double>(0.0, (sum, s) => sum + ((s['base'] as double) + (s['primes'] as double) - (s['avances'] as double)));

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Paie & Salaires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryNavy,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MASSE SALARIALE MENSUELLE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(AppTheme.formatFCFA(totalMasse), style: const TextStyle(color: AppTheme.accentGold, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _staff.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final s = _staff[idx];
                final base = s['base'] as double;
                final primes = s['primes'] as double;
                final avances = s['avances'] as double;
                final net = base + primes - avances;
                final paid = s['paid'] as bool;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.textPrimary)),
                              Text(s['role'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: paid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              paid ? 'Payé' : 'En attente',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: paid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Base: ${AppTheme.formatFCFA(base)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Primes: +${AppTheme.formatFCFA(primes)}', style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A))),
                          if (avances > 0) Text('Avance: -${AppTheme.formatFCFA(avances)}', style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Net à payer: ${AppTheme.formatFCFA(net)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: paid ? Colors.grey : AppTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: paid
                                ? null
                                : () {
                                    setState(() {
                                      s['paid'] = true;
                                    });
                                    appState.addExpense(
                                      category: 'Salaires & Paie',
                                      description: 'Salaire ${s['name']} (${s['role']})',
                                      amount: net,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppTheme.primaryNavy,
                                        content: Text('Salaire de ${s['name']} (${AppTheme.formatFCFA(net)}) enregistré dans les dépenses.'),
                                      ),
                                    );
                                  },
                            child: Text(paid ? 'Régularisé' : 'Payer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. REGISTRE DES IMMOBILISATIONS
// ==========================================
class FixedAssetsScreen extends StatefulWidget {
  const FixedAssetsScreen({super.key});

  @override
  State<FixedAssetsScreen> createState() => _FixedAssetsScreenState();
}

class _FixedAssetsScreenState extends State<FixedAssetsScreen> {
  final appState = AppState.instance;

  final List<Map<String, dynamic>> _assets = [
    {'name': 'Ordinateur portable caisse', 'date': '15/01/2026', 'valeur': 280000.0, 'duree': '3 ans', 'amorti': 70000.0},
    {'name': 'Imprimante thermique reçus', 'date': '15/01/2026', 'valeur': 65000.0, 'duree': '3 ans', 'amorti': 16250.0},
    {'name': 'Rayonnages métalliques magasin', 'date': '02/02/2026', 'valeur': 190000.0, 'duree': '5 ans', 'amorti': 31600.0},
    {'name': 'Moto de livraison', 'date': '10/03/2026', 'valeur': 650000.0, 'duree': '4 ans', 'amorti': 81250.0},
  ];

  void _showAddAssetDialog() {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final dureeCtrl = TextEditingController(text: '3 ans');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle immobilisation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Désignation de l\'actif *', hintText: 'Ex: Climatiseur magasin')),
            const SizedBox(height: 8),
            TextField(controller: valueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valeur d\'achat (FCFA) *')),
            const SizedBox(height: 8),
            TextField(controller: dureeCtrl, decoration: const InputDecoration(labelText: 'Durée d\'amortissement', hintText: 'Ex: 5 ans')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy),
            onPressed: () {
              final n = nameCtrl.text.trim();
              final v = double.tryParse(valueCtrl.text.trim()) ?? 0.0;
              if (n.isNotEmpty && v > 0) {
                setState(() {
                  _assets.insert(0, {
                    'name': n,
                    'date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    'valeur': v,
                    'duree': dureeCtrl.text.trim().isEmpty ? '3 ans' : dureeCtrl.text.trim(),
                    'amorti': 0.0,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final totalValeur = _assets.fold<double>(0.0, (sum, a) => sum + (a['valeur'] as double));
    final totalAmorti = _assets.fold<double>(0.0, (sum, a) => sum + (a['amorti'] as double));
    final vnc = totalValeur - totalAmorti;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Immobilisations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppTheme.accentGold), onPressed: _showAddAssetDialog),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryNavy,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VALEUR BRUTE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(AppTheme.formatFCFA(totalValeur), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VALEUR NETTE (VNC)', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(AppTheme.formatFCFA(vnc), style: const TextStyle(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _assets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final a = _assets[idx];
                final val = a['valeur'] as double;
                final amort = a['amorti'] as double;
                final net = val - amort;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(a['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary)),
                          ),
                          Text(AppTheme.formatFCFA(val), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Acquis le ${a['date']} • Durée: ${a['duree']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('VNC: ${AppTheme.formatFCFA(net)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. CLÔTURE JOURNALIÈRE DE CAISSE
// ==========================================
class DailyClosingScreen extends StatefulWidget {
  const DailyClosingScreen({super.key});

  @override
  State<DailyClosingScreen> createState() => _DailyClosingScreenState();
}

class _DailyClosingScreenState extends State<DailyClosingScreen> {
  final appState = AppState.instance;
  final _countedCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isClosed = false;

  @override
  void dispose() {
    _countedCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        final cashSales = appState.sales.where((s) => s.paymentMethod == 'Espèces').fold<double>(0.0, (sum, s) => sum + s.total);
        final mobileSales = appState.sales.where((s) => s.paymentMethod != 'Espèces' && s.paymentMethod != 'À Crédit').fold<double>(0.0, (sum, s) => sum + s.total);
        final expCaisse = appState.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
        final attendu = cashSales - expCaisse;

        final counted = double.tryParse(_countedCtrl.text.trim()) ?? 0.0;
        final ecart = counted - attendu;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Clôture journalière', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info Caisse
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.point_of_sale, color: AppTheme.accentGold, size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Caisse active: ${appState.currentStore}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Caissier: ${appState.displayUserName} • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Synthèse attendue
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildRow('Ventes en Espèces', cashSales),
                    _buildRow('Ventes Digitales (Wave/OM/Carte)', mobileSales),
                    _buildRow('Dépenses payées de la caisse', -expCaisse, color: const Color(0xFFDC2626)),
                    const Divider(height: 20, thickness: 1.5),
                    _buildRow('SOLDE ESPÈCES THÉORIQUE', attendu, isBold: true, fontSize: 14, color: AppTheme.primaryNavy),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Saisie physique
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Montant physique compté en caisse (FCFA) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _countedCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Saisissez le total compté',
                        prefixIcon: const Icon(Icons.money, color: AppTheme.accentGold),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_countedCtrl.text.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Écart de caisse:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            ecart == 0
                                ? 'Aucun écart (Parfait !)'
                                : (ecart > 0 ? '+${AppTheme.formatFCFA(ecart)} (Excédent)' : '${AppTheme.formatFCFA(ecart)} (Manquant)'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: ecart == 0 ? const Color(0xFF16A34A) : (ecart > 0 ? const Color(0xFF2563EB) : const Color(0xFFDC2626)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Text('Commentaires / Justification éventuelle', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Notes pour la clôture...',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isClosed ? Colors.grey : AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isClosed
                            ? null
                            : () {
                                setState(() => _isClosed = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF16A34A),
                                    content: Text('Clôture validée avec succès et verrouillée !'),
                                  ),
                                );
                              },
                        child: Text(_isClosed ? 'Caisse clôturée' : 'Valider la clôture du jour'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, double val, {bool isBold = false, double fontSize = 13, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(AppTheme.formatFCFA(val), style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ==========================================
// 9. MÉDIATHÈQUE & JUSTIFICATIFS
// ==========================================
class AccountingMediaScreen extends StatelessWidget {
  const AccountingMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppState.instance.isDarkMode;

    final docs = [
      {'title': 'Facture Fournisseur #FRN-902', 'category': 'Factures d\'achat', 'date': '02/11/2026', 'size': '1.2 Mo'},
      {'title': 'Reçu paiement loyer local', 'category': 'Quittances', 'date': '01/11/2026', 'size': '540 Ko'},
      {'title': 'Bordereau livraison réassort', 'category': 'Bons de livraison', 'date': '29/10/2026', 'size': '890 Ko'},
      {'title': 'Relevé bancaire mensuel', 'category': 'Banque & Relevés', 'date': '28/10/2026', 'size': '2.1 Mo'},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Médiathèque comptable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo, color: AppTheme.accentGold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.primaryNavy,
                  content: Text('Module appareil photo & téléversement prêt pour capture directe.'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, idx) {
          final d = docs[idx];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryNavy, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary)),
                      const SizedBox(height: 3),
                      Text('${d['category']} • ${d['date']} • ${d['size']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 18, color: Colors.grey),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Partage de ${d['title']} en cours...')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
