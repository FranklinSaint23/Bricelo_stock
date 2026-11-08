import 'package:stock_prime/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/company/announcements_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'À propos',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // 1. LOGO DE L'APPLICATION
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.storefront_rounded,
                    size: 40,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. NOM ET VERSION
          const Center(
            child: Text(
              'Bricelo Stock',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF111827)),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Version 2.5.1',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),

          // 3. DESCRIPTION COURTE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Gestion de stock, point de vente et comptabilité pour les petits commerces.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF4B5563), fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 24),

          // 4. CARTE STATUT MISE À JOUR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Votre application est à jour',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recherche des dernières mises à jour...')),
                    );
                  },
                  child: const Text(
                    'Rechercher les mises à jour',
                    style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. LIENS ET RESSOURCES
          _buildRow(
            icon: Icons.history,
            title: 'Mises à jour',
            subtitle: 'Historique des versions et annonces',
            trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF4B5563)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AnnouncementsScreen()));
            },
          ),
          const SizedBox(height: 14),
          _buildRow(
            icon: Icons.store_rounded,
            title: 'Disponibilité',
            subtitle: 'Application mobile & Web Bricelo',
            trailing: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF16A34A)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bricelo Stock Version Pro Connectée.')),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildRow(
            iconWidget: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
            ),
            title: 'Tutoriels Vidéo',
            subtitle: '@bricelo_stock',
            trailing: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF4B5563)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Accès aux tutoriels Bricelo Stock')),
              );
            },
          ),
          const SizedBox(height: 36),

          // 6. COPYRIGHT PIED DE PAGE
          const Center(
            child: Text(
              '© 2026 Bricelo Stock · Tous droits réservés',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
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

  Widget _buildRow({
    IconData? icon,
    Widget? iconWidget,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            if (iconWidget != null)
              iconWidget
            else if (icon != null)
              Icon(icon, size: 24, color: const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
