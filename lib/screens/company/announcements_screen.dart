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
    return Scaffold(
      backgroundColor: Colors.white,
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
                border: Border.all(color: const Color(0xFF6B7280), width: 0.9),
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
                          color: _selectedTab == 'Annonces' ? const Color(0xFFFED7AA) : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 18,
                              color: _selectedTab == 'Annonces' ? const Color(0xFF111827) : const Color(0xFF374151),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Annonces',
                              style: TextStyle(
                                fontWeight: _selectedTab == 'Annonces' ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                                color: _selectedTab == 'Annonces' ? const Color(0xFF111827) : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(width: 0.9, height: 42, color: const Color(0xFF6B7280)),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 'Mises à jour'),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: _selectedTab == 'Mises à jour' ? const Color(0xFFFED7AA) : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_circle_up_outlined,
                              size: 18,
                              color: _selectedTab == 'Mises à jour' ? const Color(0xFF111827) : const Color(0xFF374151),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mises à jour',
                              style: TextStyle(
                                fontWeight: _selectedTab == 'Mises à jour' ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                                color: _selectedTab == 'Mises à jour' ? const Color(0xFF111827) : const Color(0xFF374151),
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
                            const Icon(
                              Icons.arrow_circle_up_outlined,
                              size: 26,
                              color: Color(0xFF1F2937),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Nouvelle version de Stockplus: 2.3.0',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'v2.3.0 · 27 août 2026',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Installée',
                                style: TextStyle(
                                  color: Colors.white,
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
                        children: const [
                          Icon(Icons.campaign_outlined, size: 68, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 16),
                          Text(
                            'Aucune annonce pour le moment.',
                            style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.normal),
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
