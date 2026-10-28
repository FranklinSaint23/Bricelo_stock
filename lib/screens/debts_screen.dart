import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'Par client'; // 'Par client', 'Meilleurs cli...', 'Encaisseme...'

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
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B5E20),
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF86A789).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
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
              // 1. TOP 3 KPI CARDS (Screenshot 2: Dette totale | Ventes à crédit | Clients)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // DETTE TOTALE
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Dette totale',
                              style: TextStyle(
                                color: Color(0xFFC2410C),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppTheme.formatFCFA(totalDebt),
                              style: const TextStyle(
                                color: Color(0xFFC2410C),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // VENTES À CRÉDIT
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Ventes à crédit',
                              style: TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$creditSalesCount',
                              style: const TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // CLIENTS
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Clients',
                              style: TextStyle(
                                color: Color(0xFF7E22CE),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$clientCount',
                              style: const TextStyle(
                                color: Color(0xFF7E22CE),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. SEGMENTED TABS (Screenshot 2: Par client | Meilleurs cli... | Encaisseme...)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6B7280), width: 0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // PAR CLIENT
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = 'Par client'),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Par client' ? const Color(0xFFFFDFBA) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                            ),
                            child: const Center(
                              child: Text(
                                'Par client',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 0.9, height: 42, color: const Color(0xFF6B7280)),

                      // MEILLEURS CLI...
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = 'Meilleurs cli...'),
                          child: Container(
                            height: double.infinity,
                            color: _selectedTab == 'Meilleurs cli...' ? const Color(0xFFFFDFBA) : Colors.transparent,
                            child: const Center(
                              child: Text(
                                'Meilleurs cli...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 0.9, height: 42, color: const Color(0xFF6B7280)),

                      // ENCAISSEME...
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = 'Encaisseme...'),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Encaisseme...' ? const Color(0xFFFFDFBA) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                            ),
                            child: const Center(
                              child: Text(
                                'Encaisseme...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. BODY: ÉTAT VIDE (Screenshot 2: Aucune dette en cours)
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
                                  // Cash / Banknote icon
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
                                  // Clock overlay at bottom right
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
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: BottomNavigationBar(
              currentIndex: 4, // Plus tab
              onTap: (idx) {
                Navigator.pop(context);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF1B5E20),
              unselectedItemColor: const Color(0xFF6B7280),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: 'Vente',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Produits',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warehouse_outlined),
                  activeIcon: Icon(Icons.warehouse),
                  label: 'Stock',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  activeIcon: Icon(Icons.more_horiz),
                  label: 'Plus',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
