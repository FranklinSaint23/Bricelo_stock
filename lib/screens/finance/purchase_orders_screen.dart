import 'package:stock_prime/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/widgets/widgets.dart';

class PurchaseOrdersScreen extends StatelessWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Bons d\'achat',
        onBack: () => Navigator.pop(context),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.assignment_outlined, size: 68, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text(
              'Aucun bon d\'achat',
              style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryNavy,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Créer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewPurchaseOrderScreen()),
          );
        },
      ),
      bottomNavigationBar: StockBottomBar(
        currentIndex: 4,
        onTap: (_) => Navigator.pop(context),
      ),
    );
  }
}
