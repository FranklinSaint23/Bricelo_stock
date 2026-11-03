import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final currentLang = appState.currentLanguage;

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Langue / Language'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          // 🇫🇷 FRANÇAIS
          InkWell(
            onTap: () {
              appState.setLanguage('fr');
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.primaryNavy,
                  content: Text('Langue changée en Français 🇫🇷', style: TextStyle(fontWeight: FontWeight.bold)),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              color: currentLang == 'fr' ? AppTheme.goldLight : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Français',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          'Langue par défaut (Cameroun & Afrique)',
                          style: TextStyle(
                            fontSize: 12,
                            color: currentLang == 'fr' ? AppTheme.gold600 : AppTheme.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (currentLang == 'fr')
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: AppTheme.primaryNavy, size: 18),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // 🇬🇧 ENGLISH
          InkWell(
            onTap: () {
              appState.setLanguage('en');
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.primaryNavy,
                  content: Text('Language switched to English 🇬🇧', style: TextStyle(fontWeight: FontWeight.bold)),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              color: currentLang == 'en' ? AppTheme.goldLight : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'English',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          'International & Cameroon Anglophone Regions',
                          style: TextStyle(
                            fontSize: 12,
                            color: currentLang == 'en' ? AppTheme.gold600 : AppTheme.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (currentLang == 'en')
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: AppTheme.primaryNavy, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
