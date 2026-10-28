import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'Par client';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final totalDebt = appState.totalCustomerDebt;
        final creditSalesCount = appState.debts.length;
        final clientCount = appState.debts.map((d) => d.customerName).toSet().length;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: StockAppBar.forestGreen(
            title: 'Recouvrement des dettes',
            onBack: () => Navigator.pop(context),
          ),
          body: Column(
            children: [
              // 1. TOP 3 KPI CARDS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'Dette totale',
                        value: AppTheme.formatFCFA(totalDebt),
                        backgroundColor: const Color(0xFFFFF1EB),
                        textColor: const Color(0xFFC2410C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: KpiCard(
                        title: 'Ventes à crédit',
                        value: '$creditSalesCount',
                        backgroundColor: const Color(0xFFEFF6FF),
                        textColor: const Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: KpiCard(
                        title: 'Clients',
                        value: '$clientCount',
                        backgroundColor: const Color(0xFFFAF5FF),
                        textColor: const Color(0xFF7E22CE),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. SEGMENTED TABS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedTabBar(
                  tabs: const ['Par client', 'Meilleurs cli...', 'Encaisseme...'],
                  selectedTab: _selectedTab,
                  onTabSelected: (tab) => setState(() => _selectedTab = tab),
                ),
              ),

              // 3. BODY
              Expanded(
                child: appState.debts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 60,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 4,
                                    child: Container(
                                      width: 60,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCBD5E1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.access_time_filled,
                                        size: 28,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucune dette en cours',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: appState.debts.length,
                        itemBuilder: (context, idx) {
                          final d = appState.debts[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(d.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(d.customerPhone),
                              trailing: Text(
                                AppTheme.formatFCFA(d.remainingDebt),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: StockBottomBar(
            currentIndex: 4,
            onTap: (_) => Navigator.pop(context),
          ),
        );
      },
    );
  }
}
