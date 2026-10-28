import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLang = 'fr'; // 'fr' or 'en'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Langue / Language',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          _buildLanguageItem(
            code: 'fr',
            flag: '🇫🇷',
            label: 'Français',
            isSelected: _selectedLang == 'fr',
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildLanguageItem(
            code: 'en',
            flag: '🇬🇧',
            label: 'English',
            isSelected: _selectedLang == 'en',
          ),
        ],
      ),
      bottomNavigationBar: StockBottomBar(
        currentIndex: 4,
        onTap: (_) => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLanguageItem({
    required String code,
    required String flag,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedLang = code),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF1B5E20), size: 22),
          ],
        ),
      ),
    );
  }
}
