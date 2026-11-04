import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class GlobalStatsScreen extends StatefulWidget {
  const GlobalStatsScreen({super.key});

  @override
  State<GlobalStatsScreen> createState() => _GlobalStatsScreenState();
}

class _GlobalStatsScreenState extends State<GlobalStatsScreen> {
  final appState = AppState.instance;
  String _selectedPeriod = 'Tous'; // 'Aujourd\'hui', '7 jours', 'Ce mois', 'Tous'
  String _selectedStore = 'Tous';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        // Filtrer les ventes selon la période et boutique
        final now = DateTime.now();
        final sales = appState.sales.where((s) {
          if (_selectedStore != 'Tous' && s.storeName != _selectedStore) {
            return false;
          }
          if (_selectedPeriod == 'Aujourd\'hui') {
            return s.createdAt.year == now.year && s.createdAt.month == now.month && s.createdAt.day == now.day;
          } else if (_selectedPeriod == '7 jours') {
            return s.createdAt.isAfter(now.subtract(const Duration(days: 7)));
          } else if (_selectedPeriod == 'Ce mois') {
            return s.createdAt.year == now.year && s.createdAt.month == now.month;
          }
          return true;
        }).toList();

        final totalRevenue = sales.fold<double>(0.0, (sum, s) => sum + s.total);
        final totalSalesCount = sales.length;
        final averageBasket = totalSalesCount > 0 ? (totalRevenue / totalSalesCount) : 0.0;

        // Calcul marge brute et COGS
        double cogs = 0.0;
        for (final s in sales) {
          for (final it in s.items) {
            final p = appState.products.firstWhere(
              (prod) => prod.name == it.productName,
              orElse: () => Product(id: '', name: it.productName, category: '', barcode: '', buyPrice: it.unitPrice * 0.7, sellPrice: it.unitPrice, stock: 0),
            );
            cogs += p.buyPrice * it.quantity;
          }
        }
        final grossMargin = totalRevenue - cogs;
        final marginRate = totalRevenue > 0 ? (grossMargin / totalRevenue * 100) : 0.0;

        // Dépenses de la période
        final expenses = appState.expenses.where((e) {
          if (_selectedPeriod == 'Aujourd\'hui') {
            return e.createdAt.year == now.year && e.createdAt.month == now.month && e.createdAt.day == now.day;
          } else if (_selectedPeriod == '7 jours') {
            return e.createdAt.isAfter(now.subtract(const Duration(days: 7)));
          } else if (_selectedPeriod == 'Ce mois') {
            return e.createdAt.year == now.year && e.createdAt.month == now.month;
          }
          return true;
        }).toList();
        final totalExpenses = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
        final netProfit = grossMargin - totalExpenses;

        // Répartition par mode de paiement
        final paymentsMap = <String, double>{};
        for (final s in sales) {
          paymentsMap[s.paymentMethod] = (paymentsMap[s.paymentMethod] ?? 0.0) + s.total;
        }

        // Top 5 Produits vendus
        final productSalesCount = <String, int>{};
        final productSalesRevenue = <String, double>{};
        for (final s in sales) {
          for (final it in s.items) {
            productSalesCount[it.productName] = (productSalesCount[it.productName] ?? 0) + it.quantity;
            productSalesRevenue[it.productName] = (productSalesRevenue[it.productName] ?? 0.0) + it.total;
          }
        }
        final sortedProducts = productSalesCount.keys.toList()
          ..sort((a, b) => (productSalesCount[b] ?? 0).compareTo(productSalesCount[a] ?? 0));
        final top5Products = sortedProducts.take(5).toList();

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Statistiques globales',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. FILTRE TEMPOREL & BOUTIQUE
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                          items: ['Aujourd\'hui', '7 jours', 'Ce mois', 'Tous'].map((p) {
                            return DropdownMenuItem(value: p, child: Text(p, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary)));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedPeriod = v!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStore,
                          isExpanded: true,
                          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                          items: ['Tous', ...appState.outlets.map((o) => o.name)].map((s) {
                            return DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppTheme.textPrimary), overflow: TextOverflow.ellipsis));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedStore = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. BANDEAU CHIFFRE & BÉNÉFICE NET
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryNavy, Color(0xFF1E3052)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CHIFFRE D\'AFFAIRES GLOBAL', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.accentGold, borderRadius: BorderRadius.circular(6)),
                          child: Text('${marginRate.toStringAsFixed(1)}% marge', style: const TextStyle(color: AppTheme.primaryNavy, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(AppTheme.formatFCFA(totalRevenue), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bénéfice Net', style: TextStyle(color: Colors.white60, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(AppTheme.formatFCFA(netProfit), style: TextStyle(color: netProfit >= 0 ? AppTheme.accentGold : const Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Dépenses', style: TextStyle(color: Colors.white60, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(AppTheme.formatFCFA(totalExpenses), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Panier Moyen', style: TextStyle(color: Colors.white60, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(AppTheme.formatFCFA(averageBasket), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. TOP PRODUITS PLUS VENDUS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 20),
                        const SizedBox(width: 8),
                        Text('Top Produits les plus vendus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (top5Products.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('Aucune vente sur la période sélectionnée', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      )
                    else
                      ...top5Products.map((pName) {
                        final qty = productSalesCount[pName] ?? 0;
                        final rev = productSalesRevenue[pName] ?? 0.0;
                        final maxRev = top5Products.isNotEmpty ? (productSalesRevenue[top5Products.first] ?? 1.0) : 1.0;
                        final ratio = maxRev > 0 ? (rev / maxRev).clamp(0.05, 1.0) : 0.05;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(pName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                  Text('$qty vendus • ${AppTheme.formatFCFA(rev)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 6,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. RÉPARTITION PAR MODE DE PAIEMENT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payment_rounded, color: AppTheme.primaryNavy, size: 20),
                        const SizedBox(width: 8),
                        Text('Modes de paiement utilisés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (paymentsMap.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('Aucune transaction enregistrée', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      )
                    else
                      ...paymentsMap.entries.map((entry) {
                        final pct = totalRevenue > 0 ? (entry.value / totalRevenue * 100) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    entry.key == 'Espèces' ? Icons.money : (entry.key == 'À Crédit' ? Icons.assignment_late_outlined : Icons.phone_android),
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Text('${AppTheme.formatFCFA(entry.value)} (${pct.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
