import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/screens.dart';
import 'services/supabase_config.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Erreur initialisation Supabase: $e');
  }

  runApp(const BriceloStockApp());
}

final supabase = Supabase.instance.client;

class BriceloStockApp extends StatelessWidget {
  const BriceloStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Bricelo Stock',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}

typedef StockPrimeApp = BriceloStockApp;
