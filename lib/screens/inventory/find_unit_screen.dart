import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.white(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: 'Saisir un n° de série / IMEI...',
                hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Color(0xFF4B5563), size: 22),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // TEXTE D'INSTRUCTION CENTRÉ
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Recherchez un n° de série ou IMEI pour voir son historique complet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
