import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, dynamic>> _categories = [];

  void _showAddCategoryBottomSheet() {
    final nameController = TextEditingController();
    String selectedParent = 'Aucune (racine)';
    String selectedTva = 'Hériter (défaut du tenant)';

    final tvaOptions = [
      'Hériter (défaut du tenant)',
      'TVA 19,25% (CEMAC)',
      'Taux zéro 0% (exportations)',
      'Exonéré (hors champ TVA)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HANDLE BAR
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // HEADER: Titre + Bouton Fermer ✕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nouvelle catégorie',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, size: 22, color: Color(0xFF374151)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 18),

              // CATÉGORIE PARENTE (OPTIONNEL)
              const Text(
                'Catégorie parente (optionnel)',
                style: TextStyle(fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 16, color: Color(0xFF92400E)),
                    const SizedBox(width: 6),
                    Text(
                      selectedParent,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // SECTION TVA (CEMAC)
              const Text(
                'TVA',
                style: TextStyle(fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tvaOptions.map((opt) {
                  final isSelected = selectedTva == opt;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => setSheetState(() => selectedTva = opt),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: const Color(0xFFD97706), width: 1.2) : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check, size: 16, color: Color(0xFF92400E)),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              opt,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // BOUTONS ANNULER & CRÉER
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14532D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        setState(() {
                          _categories.add({
                            'name': name,
                            'parent': selectedParent,
                            'tva': selectedTva,
                          });
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Catégorie "$name" créée avec succès')),
                        );
                      }
                    },
                    child: const Text(
                      'Créer',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.785,
                    child: const Icon(
                      Icons.local_offer,
                      size: 64,
                      color: Color(0xFFD1D5DB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune catégorie',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return ListTile(
                  leading: const Icon(Icons.sell_outlined, color: AppTheme.primaryNavy),
                  title: Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text('TVA: ${cat['tva']}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                    onPressed: () {
                      setState(() => _categories.removeAt(index));
                    },
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
        onPressed: _showAddCategoryBottomSheet,
      ),
    );
  }
}
