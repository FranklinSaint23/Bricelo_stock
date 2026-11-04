import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/auth/login_screen.dart';

class LanguageOnboardingScreen extends StatefulWidget {
  const LanguageOnboardingScreen({super.key});

  @override
  State<LanguageOnboardingScreen> createState() => _LanguageOnboardingScreenState();
}

class _LanguageOnboardingScreenState extends State<LanguageOnboardingScreen> {
  String _selectedLang = AppState.instance.currentLanguage;

  Future<void> _continue() async {
    await AppState.instance.completeLanguageOnboarding(_selectedLang);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = _selectedLang == 'en';

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // LOGO BRICELO OFFICIEL
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.storefront_rounded,
                    size: 52,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'BRICELO STOCK',
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                isEn ? 'Choose your language' : 'Choisissez votre langue',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'Select your preferred language to configure your store'
                    : 'Sélectionnez la langue de l\'application pour démarrer',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              // CARTE FRANÇAIS
              _buildLanguageOption(
                code: 'fr',
                flag: '🇫🇷',
                title: 'Français',
                subtitle: 'Langue principale • Cameroun & Zone CEMAC / UEMOA',
                isSelected: _selectedLang == 'fr',
              ),
              const SizedBox(height: 14),

              // CARTE ENGLISH
              _buildLanguageOption(
                code: 'en',
                flag: '🇬🇧',
                title: 'English',
                subtitle: 'International & English-speaking regions',
                isSelected: _selectedLang == 'en',
              ),

              const Spacer(flex: 2),

              // BOUTON CONTINUER
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _continue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEn ? 'Continue' : 'Continuer',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryNavy, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String code,
    required String flag,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() => _selectedLang = code);
        AppState.instance.setLanguage(code);
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : Colors.white24,
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryNavy.withValues(alpha: 0.08) : Colors.white12,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppTheme.primaryNavy : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? const Color(0xFF64748B) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentGold : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.accentGold : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppTheme.primaryNavy)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
