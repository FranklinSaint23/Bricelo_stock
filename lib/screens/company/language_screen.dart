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
          // FRANÇAIS SÉLECTIONNÉ (1:1 SCREENSHOT 2)
          InkWell(
            onTap: () => setState(() => _selectedLang = 'fr'),
            child: Container(
              color: _selectedLang == 'fr' ? const Color(0xFFF0FDF4) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Text('🇫🇷', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Français',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (_selectedLang == 'fr')
                    const Icon(Icons.check, color: Color(0xFF166534), size: 22),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ENGLISH NON SÉLECTIONNÉ
          InkWell(
            onTap: () => setState(() => _selectedLang = 'en'),
            child: Container(
              color: _selectedLang == 'en' ? const Color(0xFFF0FDF4) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Text('🇬🇧', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'English',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (_selectedLang == 'en')
                    const Icon(Icons.check, color: Color(0xFF166534), size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StockBottomBar(
        currentIndex: 4,
        onTap: (_) => Navigator.pop(context),
      ),
    );
  }
}
