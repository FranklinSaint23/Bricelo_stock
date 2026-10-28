import 'package:flutter/material.dart';

class NewTransferScreen extends StatefulWidget {
  const NewTransferScreen({super.key});

  @override
  State<NewTransferScreen> createState() => _NewTransferScreenState();
}

class _NewTransferScreenState extends State<NewTransferScreen> {
  int _currentStep = 0; // 0: Source, 1: Destination, 2: Articles demandés, 3: Récapitulatif

  final List<String> _steps = [
    'Source',
    'Destination',
    'Articles demand...',
    'Récapitulatif',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Nouveau transfert',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // STEPPER HEADER
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentStep;
                    return Expanded(
                      child: Row(
                        children: [
                          if (index > 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                          Container(
                            width: isActive ? 28 : 8,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF1B5E20) : const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          if (index < _steps.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentStep;
                    return Expanded(
                      child: Text(
                        _steps[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? const Color(0xFF1B5E20) : const Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // CORPS SELON L'ÉTAPE
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_currentStep == 0) ...[
                  const Text(
                    'Boutique source',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Boutique principale',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFED7AA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Boutique',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C2D12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_currentStep == 1) ...[
                  const Text(
                    'Boutique destination',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dépôt Central Bonamoussadi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFED7AA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Entrepôt',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C2D12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_currentStep == 2) ...[
                  const Text(
                    'Articles demandés',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 12),
                          Text(
                            'Aucun article sélectionné',
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Récapitulatif du transfert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Source: Boutique principale', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 6),
                        Text('Destination: Dépôt Central', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 6),
                        Text('Articles: 0', style: TextStyle(color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // BOUTON SUIVANT EN BAS À DROITE
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < _steps.length - 1) {
                  setState(() => _currentStep++);
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentStep == _steps.length - 1 ? 'Confirmer' : 'Suivant',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
