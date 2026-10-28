import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';

class StockDepreciationScreen extends StatefulWidget {
  const StockDepreciationScreen({super.key});

  @override
  State<StockDepreciationScreen> createState() => _StockDepreciationScreenState();
}

class _StockDepreciationScreenState extends State<StockDepreciationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Depreciation de stock',
        onBack: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Produit',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF6B7280), width: 1.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un produit',
                  hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF374151), size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
