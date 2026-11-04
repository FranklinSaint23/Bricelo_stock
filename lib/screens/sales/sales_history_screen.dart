import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/sale_receipt_dialog.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final appState = AppState.instance;
  String _selectedPeriod = '30j';
  final _searchCtrl = TextEditingController();

  final List<String> _periods = ['Aujourd\'hui', '7j', '30j', '90j'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Sale> get _filteredSales {
    final now = DateTime.now();
    final q = _searchCtrl.text.trim().toLowerCase();

    return appState.sales.where((s) {
      if (q.isNotEmpty) {
        final matchId = s.ticketNumber.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
        final matchCustomer = s.customerName.toLowerCase().contains(q);
        final matchItem = s.items.any((i) => i.productName.toLowerCase().contains(q));
        if (!matchId && !matchCustomer && !matchItem) return false;
      }

      final diff = now.difference(s.createdAt);
      if (_selectedPeriod == 'Aujourd\'hui') {
        return s.createdAt.year == now.year && s.createdAt.month == now.month && s.createdAt.day == now.day;
      } else if (_selectedPeriod == '7j') {
        return diff.inDays <= 7;
      } else if (_selectedPeriod == '30j') {
        return diff.inDays <= 30;
      } else if (_selectedPeriod == '90j') {
        return diff.inDays <= 90;
      }
      return true;
    }).toList();
  }

  String _formatDateTime(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final sales = _filteredSales;
        final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.total);

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
              'Historique des ventes'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Partager', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rapport (${sales.length} ventes) prêt à partager')),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RECHERCHE & FILTRES
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par numéro, client ou article...',
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4B5563)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : const Icon(Icons.filter_list, color: Color(0xFF4B5563)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              // SÉLECTEUR DE PÉRIODES + ICÔNE CALENDRIER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    ..._periods.map((p) {
                      final isSelected = _selectedPeriod == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedPeriod = p),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF92400E) : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // BANNIÈRE RÉSUMÉ DYNAMIQUE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppTheme.accentGold.withValues(alpha: 0.7),
                child: Text(
                  '${sales.length} vente(s) · ${AppTheme.formatFCFA(totalRevenue)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Appuyez sur une vente pour afficher ou réimprimer son reçu.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ),

              // LISTE DYNAMIQUE DES VENTES OU ÉTAT VIDE
              Expanded(
                child: sales.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_outlined, size: 70, color: Color(0xFFD1D5DB)),
                            SizedBox(height: 14),
                            Text(
                              'Aucune vente enregistrée',
                              style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: sales.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final sale = sales[index];
                          final shortId = sale.ticketNumber.isNotEmpty ? sale.ticketNumber : sale.id;
                          return InkWell(
                            onTap: () => SaleReceiptDialog.show(context, sale),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryNavy),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Reçu #$shortId',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryNavy),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (sale.paymentMethod == 'À Crédit') ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                sale.paymentMethod,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: (sale.paymentMethod == 'À Crédit') ? const Color(0xFFD97706) : const Color(0xFF059669),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${sale.customerName} • ${sale.items.length} article(s)',
                                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          _formatDateTime(sale.createdAt),
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        AppTheme.formatFCFA(sale.total),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryNavy),
                                      ),
                                      const SizedBox(height: 4),
                                      const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.visibility_outlined, size: 13, color: AppTheme.accentGold),
                                          SizedBox(width: 3),
                                          Text('Voir reçu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                        ],
                                      ),
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
        );
      },
    );
  }
}
