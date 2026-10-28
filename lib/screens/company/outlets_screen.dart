import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class OutletsScreen extends StatefulWidget {
  const OutletsScreen({super.key});

  @override
  State<OutletsScreen> createState() => _OutletsScreenState();
}

class _OutletsScreenState extends State<OutletsScreen> {
  final List<Map<String, dynamic>> _outlets = [
    {
      'id': '1',
      'name': 'Boutique principale',
      'type': 'Boutique',
      'isDefault': true,
      'hasSpecificPrices': true,
      'discount': 0,
      'address': '',
    },
  ];

  void _showAddOutletDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final discountController = TextEditingController(text: '0');
    String selectedType = 'Boutique'; // 'Boutique' or 'Entrepôt'

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle boutique',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 18),

                // CHAMP NOM *
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nom *',
                    labelStyle: const TextStyle(color: Color(0xFF4B5563)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // LABEL TYPE
                const Text(
                  'Type',
                  style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                // SEGMENTED PILL TYPE: Boutique / Entrepôt
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF9CA3AF)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedType = 'Boutique'),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == 'Boutique' ? const Color(0xFFFEF3C7) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                              border: selectedType == 'Boutique'
                                  ? Border.all(color: const Color(0xFFF5B000), width: 1.2)
                                  : null,
                            ),
                            child: const Center(
                              child: Text(
                                'Boutique',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 42, color: const Color(0xFF9CA3AF)),
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedType = 'Entrepôt'),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == 'Entrepôt' ? const Color(0xFFFEF3C7) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                              border: selectedType == 'Entrepôt'
                                  ? Border.all(color: const Color(0xFFF5B000), width: 1.2)
                                  : null,
                            ),
                            child: const Center(
                              child: Text(
                                'Entrepôt',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // CHAMP ADRESSE
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    labelStyle: const TextStyle(color: Color(0xFF4B5563)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),

                // CHAMP RÉDUCTION (SEULEMENT SI BOUTIQUE)
                if (selectedType == 'Boutique') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Réduction sur tous les prix (%)',
                      labelStyle: const TextStyle(color: Color(0xFF4B5563)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '0 = prix normaux',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],

                const SizedBox(height: 24),

                // BOUTONS ANNULER / CRÉER
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF9CA3AF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14532D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          onPressed: () {
                            final name = nameController.text.trim();
                            if (name.isNotEmpty) {
                              final discount = int.tryParse(discountController.text) ?? 0;
                              setState(() {
                                _outlets.add({
                                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                                  'name': name,
                                  'type': selectedType,
                                  'isDefault': false,
                                  'hasSpecificPrices': false,
                                  'address': addressController.text.trim(),
                                  'discount': discount,
                                });
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$selectedType "$name" créé avec succès')),
                              );
                            }
                          },
                          child: const Text(
                            'Créer',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> outlet) {
    if (outlet['isDefault'] == true) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Action impossible'),
          content: const Text('L\'emplacement par défaut ne peut pas être supprimé.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'emplacement ?'),
        content: Text('Voulez-vous vraiment supprimer "${outlet['name']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              setState(() {
                _outlets.removeWhere((o) => o['id'] == outlet['id']);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
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
          'Boutiques & Entrepots',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _outlets.length,
        itemBuilder: (context, index) {
          final outlet = _outlets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outlet['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              outlet['type'] as String,
                              style: const TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (outlet['isDefault'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Par défaut',
                                style: TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          InkWell(
                            onTap: () => _confirmDelete(outlet),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.delete_outline,
                                color: Color(0xFFDC2626),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Prix spécifiques pour ${outlet['name']}')),
                    );
                  },
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.sell_outlined, color: Color(0xFF15803D), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Prix spécifiques',
                          style: TextStyle(
                            color: Color(0xFF15803D),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFA7F3D0),
        foregroundColor: const Color(0xFF064E3B),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: _showAddOutletDialog,
      ),
    );
  }
}
