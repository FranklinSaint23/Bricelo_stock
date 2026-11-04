import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class CatalogShareScreen extends StatelessWidget {
  final String channel; // 'Général', 'WhatsApp', 'Facebook'
  const CatalogShareScreen({super.key, this.channel = 'Général'});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    final products = appState.products;

    // Génération automatique du catalogue textuel à partager
    final buffer = StringBuffer();
    buffer.writeln('🛍️ CATALOGUE OFFICIEL - ${appState.displayCompanyName.toUpperCase()}');
    buffer.writeln('📍 Boutique : ${appState.currentStore}');
    if (appState.userPhone.isNotEmpty) buffer.writeln('📞 Contact : ${appState.userPhone}');
    buffer.writeln('────────────────────────');
    for (final p in products) {
      if (p.stock > 0) {
        buffer.writeln('• ${p.name} - ${AppTheme.formatFCFA(p.sellPrice)} (En stock)');
      }
    }
    buffer.writeln('────────────────────────');
    buffer.writeln('Commandez dès maintenant via WhatsApp ou téléphone !');

    final catalogText = buffer.toString();

    return Scaffold(
      backgroundColor: pageBg,
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
          channel == 'WhatsApp' ? 'Catalogue WhatsApp & Réseaux'.tr : 'Catalogues à partager'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.share_rounded, color: AppTheme.accentGold, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partagez votre catalogue en 1 clic'.tr,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Envoyez directement la liste de vos articles et prix à vos clients sur WhatsApp, SMS ou réseaux sociaux.'.tr,
                        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Aperçu du catalogue généré (${products.length} articles)'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: textColor),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder),
            ),
            child: SelectableText(
              catalogText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.4,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: catalogText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Catalogue copié dans le presse-papier !'.tr),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text('Copier le texte'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: catalogText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Catalogue prêt ! Vous pouvez le coller sur WhatsApp.'.tr),
                        backgroundColor: const Color(0xFF25D366),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18, color: AppTheme.primaryNavy),
                  label: Text('Partager WhatsApp'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

