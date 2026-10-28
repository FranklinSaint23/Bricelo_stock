import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class CashDesksScreen extends StatefulWidget {
  const CashDesksScreen({super.key});

  @override
  State<CashDesksScreen> createState() => _CashDesksScreenState();
}

class _CashDesksScreenState extends State<CashDesksScreen> {
  final List<String> _cashDesks = ['Caisse 1'];

  void _showAddCashDeskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nouvelle caisse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ex: Caisse 2, Caisse Comptoir',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() => _cashDesks.add(val));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRenameCashDeskDialog(int index) {
    final controller = TextEditingController(text: _cashDesks[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Renommer la caisse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy),
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() => _cashDesks[index] = val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
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
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
            ),
          ),
        ),
        title: const Text(
          'Caisses',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Gérez les caisses de chaque boutique. Renommer une caisse met aussi à jour son compte espèces (trésorerie).',
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
          ),
          const SizedBox(height: 16),

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Boutique principale',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    InkWell(
                      onTap: _showAddCashDeskDialog,
                      child: const Text(
                        'Ajouter une caisse',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ..._cashDesks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final deskName = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            deskName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827)),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showRenameCashDeskDialog(idx),
                          child: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF4B5563)),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: () {
                            if (_cashDesks.length > 1) {
                              setState(() => _cashDesks.removeAt(idx));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Impossible de supprimer la seule caisse.')),
                              );
                            }
                          },
                          child: const Icon(Icons.archive_outlined, size: 20, color: Color(0xFF4B5563)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
