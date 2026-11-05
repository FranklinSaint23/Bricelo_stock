import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
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
        final isDark = appState.isDarkMode;
        final query = _searchCtrl.text.trim().toLowerCase();
        final filtered = appState.suppliers.where((s) {
          if (_selectedTab == 'Actifs' && s.isArchived) return false;
          if (_selectedTab == 'Archivé' && !s.isArchived) return false;
          if (query.isNotEmpty) {
            final matchName = s.name.toLowerCase().contains(query);
            final matchContact = s.contactName.toLowerCase().contains(query);
            final matchPhone = s.phone.toLowerCase().contains(query);
            final matchEmail = s.email.toLowerCase().contains(query);
            return matchName || matchContact || matchPhone || matchEmail;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
          appBar: StockAppBar.navy(
            title: 'Fournisseurs',
            onBack: () => Navigator.pop(context),
          ),
          body: Column(
            children: [
              // 1. CHAMP DE RECHERCHE
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un fournisseur...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                        size: 22,
                      ),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              // 2. SEGMENTED TABS: Actifs | Archivé (Image 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedTabBar(
                  tabs: const ['Actifs', 'Archivé'],
                  selectedTab: _selectedTab,
                  activeColor: isDark ? AppTheme.primaryNavy : const Color(0xFFFFDFBA),
                  activeTextColor: isDark ? AppTheme.accentGold : const Color(0xFF111827),
                  inactiveTextColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151),
                  borderColor: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280),
                  onTabSelected: (tab) => setState(() => _selectedTab = tab),
                ),
              ),
              const SizedBox(height: 20),

              // 3. CONTENU : LISTE OU ÉTAT VIDE CONFORME IMAGE 3
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 72,
                              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Aucun fournisseur.',
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ajoutez votre premier fournisseur !',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final s = filtered[idx];
                          final initials = s.name.isNotEmpty
                              ? s.name.substring(0, s.name.length >= 2 ? 2 : 1).toUpperCase()
                              : 'FS';

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SupplierDetailScreen(supplier: s),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: isDark
                                        ? AppTheme.accentGold.withValues(alpha: 0.2)
                                        : const Color(0xFFFEF3C7),
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF92400E),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: isDark ? Colors.white : const Color(0xFF111827),
                                          ),
                                        ),
                                        if (s.contactName.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Contact : ${s.contactName}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                                            ),
                                          ),
                                        ],
                                        if (s.phone.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone_outlined, size: 13, color: AppTheme.accentGold),
                                              const SizedBox(width: 4),
                                              Text(
                                                s.phone,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (s.phone.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.call, color: AppTheme.accentGold, size: 20),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Appel de ${s.phone}...')),
                                        );
                                      },
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
          // 4. BOUTON + AJOUTER (Capsule button styled with Bricelo theme)
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.add, color: AppTheme.accentGold, size: 20),
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
