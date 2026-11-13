import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _selectedTab = 'Mises à jour'; // 'Annonces' or 'Mises à jour'

  @override
  Widget build(BuildContext context) {
    final isDark = AppState.instance.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Annonces',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // SEGMENTED TABS: Annonces | Mises à jour
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280), width: 0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 'Annonces'),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: _selectedTab == 'Annonces'
                              ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFED7AA))
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 18,
                              color: _selectedTab == 'Annonces'
                                  ? (isDark ? Colors.white : const Color(0xFF111827))
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Annonces',
                              style: TextStyle(
                                fontWeight: _selectedTab == 'Annonces' ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                                color: _selectedTab == 'Annonces'
                                    ? (isDark ? Colors.white : const Color(0xFF111827))
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(width: 0.9, height: 42, color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280)),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 'Mises à jour'),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: _selectedTab == 'Mises à jour'
                              ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFED7AA))
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_circle_up_outlined,
                              size: 18,
                              color: _selectedTab == 'Mises à jour'
                                  ? (isDark ? Colors.white : const Color(0xFF111827))
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mises à jour',
                              style: TextStyle(
                                fontWeight: _selectedTab == 'Mises à jour' ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                                color: _selectedTab == 'Mises à jour'
                                    ? (isDark ? Colors.white : const Color(0xFF111827))
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENU SELON ONGLET SÉLECTIONNÉ
          Expanded(
            child: _selectedTab == 'Mises à jour'
                ? ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_circle_up_outlined,
                              size: 26,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nouvelle version de Bricelo Stock: 2.5.1',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'v2.3.0 · 27 août 2026',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Installée',
                                style: TextStyle(
                                  color: AppTheme.primaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign_outlined, size: 68, color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune annonce pour le moment.',
                            style: TextStyle(fontSize: 15, color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF), fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: StockBottomBar(
        currentIndex: 4,
        onTap: (_) => Navigator.pop(context),
      ),
    );
  }
}
