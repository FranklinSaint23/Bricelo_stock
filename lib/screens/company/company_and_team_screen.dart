import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';

class CompanyAndTeamScreen extends StatelessWidget {
  const CompanyAndTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
        title: const Text(
          'Entreprise & Équipe',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // SECTION 1: POUR COMMENCER
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Pour commencer',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(icon: Icons.rocket_launch_outlined, title: 'Configuration rapide'),
                _buildDivider(),
                _buildRow(
                  icon: Icons.storefront_outlined,
                  title: 'Profil de l\'entreprise',
                  badge: 'À compléter',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyProfileScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.palette_outlined,
                  title: 'Ma marque',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Moyens de paiement',
                  badge: 'À compléter',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.description_outlined,
                  title: 'Personnalisation des factures',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceCustomizationScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Repartir à zéro',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetDataScreen()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 2: PARAMETRES
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Paramètres',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(
                  icon: Icons.fact_check_outlined,
                  title: 'Approbations',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.people_outline,
                  title: 'Équipe',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(icon: Icons.shield_outlined, title: 'Groupes d\'accès', isLocked: true),
                _buildDivider(),
                _buildRow(
                  icon: Icons.store_mall_directory_outlined,
                  title: 'Boutiques & Entrepots',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OutletsScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.sell_outlined,
                  title: 'Categories',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(icon: Icons.history, title: 'Historique d\'activité', isLocked: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 3: CAISSE / SHIFTS
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Caisse / Shifts',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(
                  icon: Icons.payments_outlined,
                  title: 'Caisses',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CashDesksScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Suivi des shifts (caisse)',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftsTrackingScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    String? badge,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              size: 20,
              color: isLocked ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6));
  }
}
