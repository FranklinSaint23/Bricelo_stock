import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final appState = AppState.instance;

  void _showCategoryBottomSheet({CategoryItem? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedParent = existing?.parent ?? 'Aucune (racine)';
    String selectedTva = existing != null ? (existing.tva == 0 ? 'Exonéré (hors champ TVA)' : 'TVA 19,25% (CEMAC)') : 'TVA 19,25% (CEMAC)';

    final tvaOptions = [
      'Hériter (défaut du tenant)',
      'TVA 19,25% (CEMAC)',
      'Taux zéro 0% (exportations)',
      'Exonéré (hors champ TVA)',
    ];

    final parentOptions = <String>{
      'Aucune (racine)',
      ...appState.categories
          .where((c) => c.id != existing?.id)
          .map((c) => c.name),
    }.toList();
    if (!parentOptions.contains(selectedParent)) {
      selectedParent = 'Aucune (racine)';
    }

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      existing == null ? 'Nouvelle catégorie'.tr : 'Modifier la catégorie'.tr,
                      style: const TextStyle(
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
                const Text(
                  'Catégorie parente (optionnel)',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: parentOptions.map((parent) {
                    final isSel = selectedParent == parent;
                    return InkWell(
                      onTap: () => setSheetState(() => selectedParent = parent),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                          border: isSel ? Border.all(color: const Color(0xFFD97706), width: 1.2) : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSel) ...[
                              const Icon(Icons.check, size: 15, color: Color(0xFF92400E)),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              parent,
                              style: TextStyle(
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12.5,
                                color: isSel ? const Color(0xFF92400E) : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        if (existing == null) {
                          final tvaVal = selectedTva.contains('19,25') ? 19.25 : 0.0;
                          appState.addCategory(
                            CategoryItem(
                              id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              parent: selectedParent,
                              tva: tvaVal,
                            ),
                          );
                        } else {
                          final tvaVal = selectedTva.contains('19,25') ? 19.25 : 0.0;
                          appState.updateCategory(
                            CategoryItem(
                              id: existing.id,
                              name: name,
                              parent: selectedParent,
                              tva: tvaVal,
                            ),
                          );
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existing == null
                                  ? 'Catégorie "$name" créée avec succès'
                                  : 'Catégorie "$name" mise à jour',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        existing == null ? 'Créer' : 'Enregistrer',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final categories = appState.categories;
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
            title: Text(
              'Catégories'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: categories.isEmpty
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
                      Text(
                        'Aucune catégorie'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Appuyez sur "+ Ajouter" pour créer vos rayons.'.tr,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final productCount = appState.products.where((p) => p.category == cat.name).length;
                    return ListTile(
                      onTap: () => _showCategoryBottomSheet(existing: cat),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.sell_outlined, color: AppTheme.primaryNavy, size: 20),
                      ),
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: Text(
                        '$productCount produit(s) • TVA: ${cat.tva}%',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryNavy, size: 20),
                            onPressed: () => _showCategoryBottomSheet(existing: cat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                            onPressed: () => appState.removeCategory(cat.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accentGold,
            foregroundColor: AppTheme.primaryNavy,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              'Ajouter'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () => _showCategoryBottomSheet(),
          ),
        );
      },
    );
  }
}
