import 'package:flutter/material.dart';
import 'package:stock_prime/widgets/widgets.dart';

class ExpiryTrackingScreen extends StatefulWidget {
  const ExpiryTrackingScreen({super.key});

  @override
  State<ExpiryTrackingScreen> createState() => _ExpiryTrackingScreenState();
}

class _ExpiryTrackingScreenState extends State<ExpiryTrackingScreen> {
  String _strategy = 'FIFO'; // 'FIFO' or 'FEFO'
  final _daysController = TextEditingController(text: '30');

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.forestGreen(
        title: 'Suivi de péremption',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          // 1. STRATÉGIE DE DÉSTOCKAGE
          const Text(
            'Stratégie de déstockage',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Change l\'ordre de sortie des lots et le coût attribué à chaque vente. Le coût moyen du produit reste inchangé.',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 16),

          // OPTION 1: FIFO
          InkWell(
            onTap: () => setState(() => _strategy = 'FIFO'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _strategy == 'FIFO' ? const Color(0xFFDCFCE7) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _strategy == 'FIFO' ? const Color(0xFF166534) : const Color(0xFFD1D5DB),
                  width: _strategy == 'FIFO' ? 1.2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _strategy == 'FIFO' ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _strategy == 'FIFO' ? const Color(0xFF166534) : const Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FIFO — Premier entré, premier sorti',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _strategy == 'FIFO' ? const Color(0xFF14532D) : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Les ventes déstockent les lots les plus anciens d\'abord. Recommandé pour la plupart des commerces.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _strategy == 'FIFO' ? const Color(0xFF166534) : const Color(0xFF6B7280),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // OPTION 2: FEFO
          InkWell(
            onTap: () => setState(() => _strategy = 'FEFO'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _strategy == 'FEFO' ? const Color(0xFFDCFCE7) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _strategy == 'FEFO' ? const Color(0xFF166534) : const Color(0xFFD1D5DB),
                  width: _strategy == 'FEFO' ? 1.2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _strategy == 'FEFO' ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _strategy == 'FEFO' ? const Color(0xFF166534) : const Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FEFO — Premier périmé, premier sorti',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _strategy == 'FEFO' ? const Color(0xFF14532D) : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Les ventes déstockent les lots qui périment le plus tôt. Pour les produits périssables.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _strategy == 'FEFO' ? const Color(0xFF166534) : const Color(0xFF6B7280),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 20),

          // 2. FENÊTRE D'ALERTE DE PÉREMPTION
          const Text(
            'Fenêtre d\'alerte de péremption',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Un lot qui périme dans ce nombre de jours est signalé « bientôt périmé » sur le tableau de bord.',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 14),

          // CHAMP NOMBRE DE JOURS
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6B7280)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _daysController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF111827), fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const Text(
                        'jours',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 22),
              ),
            ],
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
