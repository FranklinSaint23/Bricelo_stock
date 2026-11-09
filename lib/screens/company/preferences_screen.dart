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
    final isDark = AppState.instance.isDarkMode;
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final textPrimary = isDark ? Colors.white : AppTheme.primaryNavy;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155);

    if (val) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppTheme.accentGold, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Suggestions activées'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bricelo Stock analyse vos données en continu pour vous guider au quotidien :'.tr,
                style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text('• ${'Alertes de réapprovisionnement pour vos produits phares'.tr}', style: TextStyle(fontSize: 12.5, color: textSecondary)),
              const SizedBox(height: 6),
              Text('• ${'Conseils d\'optimisation de marge et de déstockage'.tr}', style: TextStyle(fontSize: 12.5, color: textSecondary)),
              const SizedBox(height: 6),
              Text('• ${'Recommandations de relance pour les clients débiteurs'.tr}', style: TextStyle(fontSize: 12.5, color: textSecondary)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text('Compris'.tr),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggestions automatiques désactivées.'.tr)),
      );
    }
  }

  void _showSuggestionBox() {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    String category = 'Amélioration générale';
    final isDark = AppState.instance.isDarkMode;
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final textPrimary = isDark ? Colors.white : AppTheme.primaryNavy;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.rate_review_outlined, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 22),
                  const SizedBox(width: 10),
                  Text('Boîte à suggestions Bricelo'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Une idée ou fonctionnalité que vous aimeriez voir dans l\'application ?'.tr, style: TextStyle(fontSize: 12.5, color: textSecondary)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: category,
                dropdownColor: cardBg,
                style: TextStyle(color: textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Thème de la suggestion'.tr,
                  labelStyle: TextStyle(color: textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  DropdownMenuItem(value: 'Amélioration générale', child: Text('Amélioration générale'.tr)),
                  DropdownMenuItem(value: 'Caisse & Facturation', child: Text('Caisse & Facturation'.tr)),
                  DropdownMenuItem(value: 'Gestion des stocks', child: Text('Gestion des stocks'.tr)),
                  DropdownMenuItem(value: 'Comptabilité & Rapports', child: Text('Comptabilité & Rapports'.tr)),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => category = val);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Titre de l\'idée'.tr,
                  labelStyle: TextStyle(color: textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailCtrl,
                maxLines: 3,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Détails de votre suggestion'.tr,
                  labelStyle: TextStyle(color: textSecondary),
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
                  label: Text('Envoyer ma suggestion'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Veuillez renseigner un titre.'.tr)),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF16A34A),
                        content: Text('Merci ! Votre suggestion a bien été transmise à l\'équipe Bricelo.'.tr),
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

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB);
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);
        final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : AppTheme.slate500;
        final dividerCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFF3F4F6);

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      Icons.translate,
                      'Langue / Language'.tr,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      subtitle: appState.currentLanguage == 'fr' ? 'Français (par défaut)'.tr : 'English',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
                      },
                    ),
                    Divider(height: 1, indent: 52, color: dividerCol),

                    // MODE SOMBRE TOGGLE ROW
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode_outlined, size: 22, color: isDark ? AppTheme.accentGold : const Color(0xFF374151)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mode sombre'.tr,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDark ? 'Activé (Thème sombre Bricelo)'.tr : 'Désactivé (Thème clair)'.tr,
                                  style: TextStyle(fontSize: 11.5, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accentGold,
                            onChanged: (v) {
                              appState.toggleDarkMode(v);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, indent: 52, color: dividerCol),

                    _buildRow(
                      Icons.campaign_outlined,
                      'Annonces'.tr,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      subtitle: 'Nouveautés et mises à jour Bricelo'.tr,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                      },
                    ),
                    Divider(height: 1, indent: 52, color: dividerCol),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 22, color: isDark ? AppTheme.accentGold : const Color(0xFF374151)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Suggestions'.tr,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _suggestions ? 'Conseils & alertes intelligentes activés'.tr : 'Désactivé'.tr,
                                  style: TextStyle(fontSize: 11.5, color: _suggestions ? const Color(0xFF16A34A) : textSecondary),
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
                    Divider(height: 1, indent: 52, color: dividerCol),
                    _buildRow(
                      Icons.rate_review_outlined,
                      'Boîte à suggestions'.tr,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      subtitle: 'Proposer une idée d\'amélioration pour Bricelo'.tr,
                      onTap: _showSuggestionBox,
                    ),
                    Divider(height: 1, indent: 52, color: dividerCol),
                    _buildRow(
                      Icons.info_outline,
                      'À propos'.tr,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
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
      },
    );
  }

  Widget _buildRow(
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDark ? AppTheme.accentGold : const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
