import 'package:flutter/material.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/widgets/widgets.dart';

class FindUnitScreen extends StatefulWidget {
  const FindUnitScreen({super.key});

  @override
  State<FindUnitScreen> createState() => _FindUnitScreenState();
}

class _FindUnitScreenState extends State<FindUnitScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppState.instance.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
      appBar: StockAppBar.navy(
        title: 'Trouver une unité',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // CHAMP RECHERCHE ARRONDI
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162540) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: 'Saisir un n° de série / IMEI...',
                hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563), fontSize: 15),
                prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563), size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // TEXTE D'INSTRUCTION CENTRÉ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Recherchez un n° de série ou IMEI pour voir son historique complet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280), fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
