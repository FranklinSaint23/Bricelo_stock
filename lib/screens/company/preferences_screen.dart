import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/company/language_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _suggestions = true;

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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Aucune nouvelle annonce'.tr)),
                    );
                  },
                ),
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 22, color: Color(0xFF374151)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Suggestions'.tr,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                        ),
                      ),
                      Switch(
                        value: _suggestions,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppTheme.accentGold,
                        onChanged: (val) => setState(() => _suggestions = val),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
                _buildRow(
                  Icons.info_outline,
                  'À propos'.tr,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Bricelo Stock',
                      applicationVersion: '1.0.0 (Bricélo Edition)',
                      applicationLegalese: '© 2026 Bricélo Stock',
                    );
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
