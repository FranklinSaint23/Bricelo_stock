import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/shell/main_shell.dart';
import 'package:stock_prime/screens/auth/language_onboarding_screen.dart';
import 'package:stock_prime/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _bootApp();
  }

  Future<void> _bootApp() async {
    final start = DateTime.now();
    await AppState.instance.initStorage();
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    if (elapsed < 1600) {
      await Future.delayed(Duration(milliseconds: 1600 - elapsed));
    }
    if (!mounted) return;

    final state = AppState.instance;
    Widget nextScreen;
    if (!state.hasSelectedLanguage) {
      nextScreen = const LanguageOnboardingScreen();
    } else if (!state.isLoggedIn) {
      nextScreen = const LoginScreen();
    } else {
      nextScreen = const MainShell();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2238),
                  AppTheme.primaryNavy,
                  Color(0xFF070E18),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    blurRadius: 70,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.storefront,
                              size: 60,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'BRICELO STOCK',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Market & Stock',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 38,
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gestion & Commerce Connecté',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
