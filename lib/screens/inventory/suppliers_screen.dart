import 'package:flutter/material.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/widgets/widgets.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final appState = AppState.instance;
  String _selectedTab = 'Actifs'; // 'Actifs' or 'Archivé'
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final query = _searchCtrl.text.trim().toLowerCase();
        final filtered = appState.suppliers.where((s) {
          if (_selectedTab == 'Actifs' && s.isArchived) return false;
          if (_selectedTab == 'Archivé' && !s.isArchived) return false;
          if (query.isNotEmpty) {
            final matchName = s.name.toLowerCase().contains(query);
            final matchContact = s.contactName.toLowerCase().contains(query);
            final matchPhone = s.phone.toLowerCase().contains(query);
            return matchName || matchContact || matchPhone;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: StockAppBar.forestGreen(
            title: 'Fournisseurs',
            onBack: () => Navigator.pop(context),
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
                    hintText: 'Rechercher un fournisseur...',
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
                child: SegmentedTabBar(
                  tabs: const ['Actifs', 'Archivé'],
                  selectedTab: _selectedTab,
                  onTabSelected: (tab) => setState(() => _selectedTab = tab),
                ),
              ),
              const SizedBox(height: 20),

              // CONTENU: LISTE OU ÉTAT VIDE CONFORME
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 68, color: Color(0xFFCBD5E1)),
                            SizedBox(height: 14),
                            Text(
                              'Aucun fournisseur.',
                              style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ajoutez votre premier fournisseur !',
                              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, idx) {
                          final s = filtered[idx];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFEF3C7),
                              child: Icon(Icons.business, color: Color(0xFF92400E)),
                            ),
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(s.contactName.isNotEmpty ? s.contactName : s.phone),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFFA7F3D0),
            foregroundColor: const Color(0xFF064E3B),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Ajouter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewSupplierScreen()),
              );
            },
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
