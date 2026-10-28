import 'package:stock_prime/services/app_state.dart';
import 'package:flutter/material.dart';

class ResetDataScreen extends StatelessWidget {
  const ResetDataScreen({super.key});

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmation irréversible', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Cette action effacera l\'ensemble de vos données de test (produits, ventes, stock, dépenses, etc.).\n\nÊtes-vous sûr de vouloir continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              AppState.instance.resetAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Données de test réinitialisées à zéro.'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Tout effacer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827), size: 16),
            ),
          ),
        ),
        title: const Text(
          'Repartir à zéro',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF111827)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // CARD 1: EXPLANATION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repartir à zéro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                SizedBox(height: 10),
                Text(
                  'Vous avez testé avec de fausses données ? Supprimez produits, catégories, stock, ventes, clients, fournisseurs, dépenses et écritures. Vos utilisateurs, emplacements, caisses et réglages sont conservés.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CARD 2: LISTE CE QUI SERA SUPPRIMÉ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sera supprimé',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 18),
                _buildCountRow('Produits', '0'),
                const SizedBox(height: 18),
                _buildCountRow('Catégories', '0'),
                const SizedBox(height: 18),
                _buildCountRow('Ventes', '0'),
                const SizedBox(height: 18),
                _buildCountRow('Clients', '0'),
                const SizedBox(height: 18),
                _buildCountRow('Fournisseurs', '1'),
                const SizedBox(height: 18),
                _buildCountRow('Commandes fournisseurs', '0'),
                const SizedBox(height: 18),
                _buildCountRow('Dépenses', '0'),
                const SizedBox(height: 18),
                _buildCountRow('Écritures comptables', '0'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text(
                'Tout effacer...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () => _confirmReset(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountRow(String label, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827), fontWeight: FontWeight.w500),
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
      ],
    );
  }
}
