import 'package:stock_prime/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';

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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
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
              const SizedBox(height: 20),

              // CONTENU: LISTE OU ÉTAT VIDE
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups_outlined, size: 68, color: Color(0xFFD1D5DB)),
                            SizedBox(height: 14),
                            Text(
                              'Aucun client.'.tr,
                              style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ajoutez votre premier client !'.tr,
                              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, idx) {
                          final c = filtered[idx];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFEF3C7),
                              child: Icon(Icons.person, color: Color(0xFF92400E)),
                            ),
                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(c.phone.isNotEmpty ? c.phone : 'Aucun téléphone'.tr),
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
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              'Ajouter'.tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewCustomerScreen()),
              );
            },
          ),
        );
      },
    );
  }
}
