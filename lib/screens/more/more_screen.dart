import 'package:stock_prime/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: const Text('Plus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. RECHERCHER DANS LE MENU
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Rechercher dans le menu',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                              _query = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => setState(() => _query = val.toLowerCase()),
              ),
            ),
            const SizedBox(height: 16),

            // 2. CARTE PROFIL ENTREPRISE (Tappable -> Mon compte)
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAccountScreen()));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Text(
                          'FN',
                          style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Franklin Athletics',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Proprietaire',
                                style: TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Formule Gratuit',
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. BANNIÈRE E-MAIL NON VÉRIFIÉ
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline, color: AppTheme.danger, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E-mail non vérifié',
                          style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sécurisez votre compte — touchez pour vérifier',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.danger,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'À vérifier',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            ),
            const SizedBox(height: 16),

            // 4. LISTE DU MENU
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.receipt_long_outlined, 'Ventes & clients', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesAndCustomersScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(Icons.campaign_outlined, 'Promotion & boutique', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PromotionAndShopScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(Icons.warehouse_outlined, 'Stock', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockSubMenuScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(Icons.shopping_cart_outlined, 'Achats & dépenses', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesAndExpensesScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(Icons.trending_down_outlined, 'Pertes & dépréciations', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationReportScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(Icons.menu_book_outlined, 'Comptabilité & trésorerie', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountingScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.badge_outlined,
                    'Entreprise & équipe',
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyAndTeamScreen()));
                    },
                    badge: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.badgeOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('À compléter', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  _buildDivider(),
                  _buildMenuItem(Icons.settings_outlined, 'Préférences', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(Icons.smart_toy_outlined, 'Assistant Pilo', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PiloAssistantScreen()));
                  }),
                  _buildDivider(),
                  _buildMenuItem(Icons.help_outline, 'Centre d\'aide', () {}),
                  _buildDivider(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? badge,
    Color textColor = const Color(0xFF1F2937),
    Color iconColor = const Color(0xFF374151),
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
              ),
            ),
            if (badge != null) ...[
              badge,
              const SizedBox(width: 8),
            ],
            const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 48, color: Color(0xFFF3F4F6));
  }
}
