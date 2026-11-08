import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/company/language_screen.dart';
import 'package:stock_prime/screens/company/announcements_screen.dart';
import 'package:stock_prime/screens/company/about_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _suggestions = true;

  void _onToggleSuggestions(bool val) {
    setState(() => _suggestions = val);
    if (val) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.lightbulb_rounded, color: AppTheme.accentGold, size: 24),
              SizedBox(width: 8),
              Text('Suggestions activées', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Bricelo Stock analyse vos données en continu pour vous guider au quotidien :',
                style: TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
              ),
              SizedBox(height: 12),
              Text('• Alertes de réapprovisionnement pour vos produits phares', style: TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
              SizedBox(height: 6),
              Text('• Conseils d\'optimisation de marge et de déstockage', style: TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
              SizedBox(height: 6),
              Text('• Recommandations de relance pour les clients débiteurs', style: TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Compris'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suggestions automatiques désactivées.')),
      );
    }
  }

  void _showSuggestionBox() {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    String category = 'Amélioration générale';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Icon(Icons.rate_review_outlined, color: AppTheme.primaryNavy, size: 22),
                  SizedBox(width: 10),
                  Text('Boîte à suggestions Bricelo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Une idée ou fonctionnalité que vous aimeriez voir dans l\'application ?', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Thème de la suggestion',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'Amélioration générale', child: Text('Amélioration générale')),
                  DropdownMenuItem(value: 'Caisse & Facturation', child: Text('Caisse & Facturation')),
                  DropdownMenuItem(value: 'Gestion des stocks', child: Text('Gestion des stocks')),
                  DropdownMenuItem(value: 'Comptabilité & Rapports', child: Text('Comptabilité & Rapports')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => category = val);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Titre de l\'idée',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Détails de votre suggestion',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Envoyer ma suggestion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez renseigner un titre.')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF16A34A),
                        content: Text('Merci ! Votre suggestion a bien été transmise à l\'équipe Bricelo.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

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
        title: Text(
          'Préférences'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(
                  Icons.translate,
                  'Langue / Language'.tr,
                  subtitle: appState.currentLanguage == 'fr' ? 'Français (par défaut)' : 'English',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
                  },
                ),
                _buildDivider(),
                _buildRow(
                  Icons.campaign_outlined,
                  'Annonces'.tr,
                  subtitle: 'Nouveautés et mises à jour Bricelo',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                  },
                ),
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 22, color: Color(0xFF374151)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suggestions'.tr,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _suggestions ? 'Conseils & alertes intelligentes activés' : 'Désactivé',
                              style: TextStyle(fontSize: 11.5, color: _suggestions ? const Color(0xFF16A34A) : AppTheme.slate500),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _suggestions,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppTheme.accentGold,
                        onChanged: _onToggleSuggestions,
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
                _buildRow(
                  Icons.rate_review_outlined,
                  'Boîte à suggestions'.tr,
                  subtitle: 'Proposer une idée d\'amélioration pour Bricelo',
                  onTap: _showSuggestionBox,
                ),
                _buildDivider(),
                _buildRow(
                  Icons.info_outline,
                  'À propos'.tr,
                  subtitle: 'Bricelo Stock · Version 2.5.1',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, {String? subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6));
  }
}
