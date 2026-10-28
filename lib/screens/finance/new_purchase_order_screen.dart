import 'package:flutter/material.dart';

class NewPurchaseOrderScreen extends StatefulWidget {
  const NewPurchaseOrderScreen({super.key});

  @override
  State<NewPurchaseOrderScreen> createState() => _NewPurchaseOrderScreenState();
}

class _NewPurchaseOrderScreenState extends State<NewPurchaseOrderScreen> {
  final int _currentStep = 0;
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: const Text(
          'Nouveau bon d\'achat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // STEPPER HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                _buildStepHeader(0, 'Fournisseur'),
                _buildStepHeader(1, 'Destination'),
                _buildStepHeader(2, 'Articles demand...'),
                _buildStepHeader(3, 'Récapitulatif'),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // STEP 1 CONTENT: CHOIX DU FOURNISSEUR
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                const Text(
                  'Veuillez choisir un fournisseur.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 14),

                // CHAMP RECHERCHE
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
                      hintText: 'Rechercher',
                      hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF4B5563), size: 22),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // ÉTAT VIDE
                const Center(
                  child: Text(
                    'Aucun fournisseur',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                  ),
                ),
              ],
            ),
          ),

          // BOUTON SUIVANT EN BAS À DROITE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez sélectionner un fournisseur')),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Suivant',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(int step, String title) {
    final isActive = _currentStep == step;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1B5E20) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF1B5E20) : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
