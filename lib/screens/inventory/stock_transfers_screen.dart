import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/screens/inventory/new_transfer_screen.dart';

class StockTransfersScreen extends StatefulWidget {
  const StockTransfersScreen({super.key});

  @override
  State<StockTransfersScreen> createState() => _StockTransfersScreenState();
}

class _StockTransfersScreenState extends State<StockTransfersScreen> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = [
    'Tous',
    'En attente',
    'En transit',
    'Reçu',
    'Annulé',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Transferts de stock',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // FILTRES HORIZONTAUX
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = filter),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFFFED7AA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ETAT VIDE EXACT DU SCREENSHOT
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.swap_horiz,
                    size: 52,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Aucun transfert',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOUTON FLOTTANT + Créer (VERT PASTEL MENTHE)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewTransferScreen()),
          );
        },
        backgroundColor: const Color(0xFFA7F3D0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Color(0xFF0F5132), size: 22),
        label: const Text(
          'Créer',
          style: TextStyle(
            color: Color(0xFF0F5132),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      bottomNavigationBar: StockBottomBar(
        currentIndex: 4,
        onTap: (_) => Navigator.pop(context),
      ),
    );
  }
}
