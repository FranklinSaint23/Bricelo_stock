import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/inventory/new_transfer_screen.dart';

class StockTransfersScreen extends StatefulWidget {
  const StockTransfersScreen({super.key});

  @override
  State<StockTransfersScreen> createState() => _StockTransfersScreenState();
}

class _StockTransfersScreenState extends State<StockTransfersScreen> {
  final appState = AppState.instance;
  String _selectedFilter = 'Tous';
  final List<String> _filters = const [
    'Tous',
    'Effectué',
    'En transit',
    'Reçu',
  ];

  void _showTransferDetail(BuildContext context, StockTransfer trf) {
    final isDark = appState.isDarkMode;
    final dtStr = '${trf.date.day.toString().padLeft(2, "0")}/${trf.date.month.toString().padLeft(2, "0")}/${trf.date.year} à ${trf.date.hour.toString().padLeft(2, "0")}:${trf.date.minute.toString().padLeft(2, "0")}';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trf.reference,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppTheme.primaryNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF062E22) : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trf.status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Date : $dtStr • Par ${trf.author}',
                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              Divider(height: 20, color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Source', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                        Text(trf.sourceStore, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: AppTheme.accentGold),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Destination', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                        Text(trf.destinationStore, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                'Articles transférés :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              ...trf.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('• ${i.productName}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
                        Text(
                          '${i.quantity} ${i.unit}(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (trf.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Note : ${trf.note}', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final transfers = appState.stockTransfers.where((t) {
          if (_selectedFilter == 'Tous') return true;
          return t.status.toLowerCase() == _selectedFilter.toLowerCase();
        }).toList();

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF09121E) : const Color(0xFFF8FAFC),
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
            title: const Text('Transferts de stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
          ),
          body: Column(
            children: [
              // FILTRES HORIZONTAUX
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = filter),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentGold : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // LISTE DYNAMIQUE DES TRANSFERTS OU ÉTAT VIDE
              Expanded(
                child: transfers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.swap_horiz, size: 52, color: Color(0xFFCBD5E1)),
                            SizedBox(height: 12),
                            Text('Aucun transfert enregistré', style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF))),
                            SizedBox(height: 6),
                            Text('Cliquez sur le bouton « + » pour transférer des articles entre vos boutiques.',
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: transfers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final trf = transfers[idx];
                          final dtStr = '${trf.date.day.toString().padLeft(2, "0")}/${trf.date.month.toString().padLeft(2, "0")}/${trf.date.year}';

                          return InkWell(
                            onTap: () => _showTransferDetail(context, trf),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        trf.reference,
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryNavy),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD1FAE5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          trf.status,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.storefront, size: 15, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text('${trf.sourceStore} ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      const Icon(Icons.arrow_right_alt, size: 16, color: AppTheme.accentGold),
                                      Text(' ${trf.destinationStore}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$dtStr • Par ${trf.author}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                                      Text(
                                        '${trf.totalQuantity} article(s)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: AppTheme.accentGold,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewTransferScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nouveau transfert', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
