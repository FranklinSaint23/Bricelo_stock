import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class OutletsScreen extends StatefulWidget {
  const OutletsScreen({super.key});

  @override
  State<OutletsScreen> createState() => _OutletsScreenState();
}

class _OutletsScreenState extends State<OutletsScreen> {
  final appState = AppState.instance;

  void _showAddOutletDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController(text: appState.userPhone);
    final discountController = TextEditingController(text: '0');
    String selectedType = 'Boutique'; // 'Boutique' or 'Entrepôt'
    bool isDefault = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = appState.isDarkMode;
          final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
          final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

          return Dialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nouvelle boutique'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CHAMP NOM *
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Nom du point de vente *'.tr,
                      hintText: 'Ex: Boutique Akwa, Entrepôt Bonabéri',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TYPE
                  Text(
                    'Type d\'établissement'.tr,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text('Boutique'.tr)),
                          selected: selectedType == 'Boutique',
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(
                            color: selectedType == 'Boutique' ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedType = 'Boutique');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text('Entrepôt'.tr)),
                          selected: selectedType == 'Entrepôt',
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(
                            color: selectedType == 'Entrepôt' ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedType = 'Entrepôt');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CHAMP ADRESSE
                  TextField(
                    controller: addressController,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Adresse physique'.tr,
                      hintText: 'Ex: Rue des Palmiers, Douala',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CHAMP TÉLÉPHONE
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Téléphone de contact'.tr,
                      hintText: 'Ex: 699000000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // DÉFINIR PAR DÉFAUT
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Définir comme boutique active principale'.tr, style: TextStyle(fontSize: 13, color: textColor)),
                    value: isDefault,
                    activeColor: AppTheme.accentGold,
                    onChanged: (val) => setModalState(() => isDefault = val ?? false),
                  ),
                  const SizedBox(height: 20),

                  // BOUTON VALIDER
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Le nom de la boutique est obligatoire.'.tr)),
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        final disc = double.tryParse(discountController.text.trim()) ?? 0.0;
                        await appState.addOutlet(
                          name: name,
                          type: selectedType,
                          address: addressController.text.trim(),
                          phone: phoneController.text.trim(),
                          discount: disc,
                          isDefault: isDefault,
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Boutique "$name" et sa caisse "Caisse $name" créées avec succès !'.tr),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: Text(
                        'Enregistrer la boutique'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditOutletDialog(StoreOutlet outlet) {
    final nameController = TextEditingController(text: outlet.name);
    final addressController = TextEditingController(text: outlet.address);
    final phoneController = TextEditingController(text: outlet.phone);
    final discountController = TextEditingController(text: outlet.discount.toString());
    String selectedType = outlet.type;
    bool isDefault = outlet.isDefault;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = appState.isDarkMode;
          final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
          final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

          return Dialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Modifier la boutique'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Nom du point de vente *'.tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Type d\'établissement'.tr,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text('Boutique'.tr)),
                          selected: selectedType == 'Boutique',
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(
                            color: selectedType == 'Boutique' ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedType = 'Boutique');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text('Entrepôt'.tr)),
                          selected: selectedType == 'Entrepôt',
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(
                            color: selectedType == 'Entrepôt' ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedType = 'Entrepôt');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: addressController,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Adresse physique'.tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Téléphone de contact'.tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Définir comme boutique active principale'.tr, style: TextStyle(fontSize: 13, color: textColor)),
                    value: isDefault,
                    activeColor: AppTheme.accentGold,
                    onChanged: (val) => setModalState(() => isDefault = val ?? false),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        Navigator.pop(ctx);
                        final disc = double.tryParse(discountController.text.trim()) ?? 0.0;
                        await appState.updateOutlet(
                          outlet.id,
                          name: name,
                          type: selectedType,
                          address: addressController.text.trim(),
                          phone: phoneController.text.trim(),
                          discount: disc,
                          isDefault: isDefault,
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Boutique mise à jour.'.tr),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: Text(
                        'Enregistrer les modifications'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(StoreOutlet outlet) {
    if (appState.outlets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de supprimer la seule boutique active de l\'entreprise.'.tr),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Supprimer la boutique ?'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer "${outlet.name}" et ses caisses associées ?'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr, style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await appState.deleteOutlet(outlet.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Boutique "${outlet.name}" supprimée.'.tr)),
              );
            },
            child: Text('Supprimer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
        final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
        final textColor = isDark ? Colors.white : const Color(0xFF111827);

        final outlets = appState.outlets;

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
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
              'Boutiques & Points de vente'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Gérez les boutiques et entrepôts de votre commerce. Chaque boutique possède automatiquement sa propre caisse par défaut et son inventaire dédié.'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // LISTE DYNAMIQUE DES BOUTIQUES
              for (final outlet in outlets) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: outlet.isDefault ? AppTheme.accentGold : cardBorder,
                      width: outlet.isDefault ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.3 : 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              outlet.type == 'Entrepôt' ? Icons.warehouse_rounded : Icons.storefront_rounded,
                              color: AppTheme.accentGold,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        outlet.name,
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (outlet.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppTheme.accentGold, width: 1),
                                        ),
                                        child: Text(
                                          'Active'.tr,
                                          style: const TextStyle(
                                            color: AppTheme.accentGold,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  outlet.address.isNotEmpty
                                      ? outlet.address
                                      : (outlet.type == 'Entrepôt' ? 'Entrepôt de stockage'.tr : 'Point de vente au comptoir'.tr),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: const Color(0xFF64748B),
                            onPressed: () => _showEditOutletDialog(outlet),
                          ),
                          if (outlets.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              color: const Color(0xFFDC2626),
                              onPressed: () => _confirmDelete(outlet),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: cardBorder),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.point_of_sale_rounded, size: 16, color: AppTheme.accentGold),
                              const SizedBox(width: 6),
                              Text(
                                'Caisse : Caisse ${outlet.name}'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          if (!outlet.isDefault)
                            InkWell(
                              onTap: () {
                                appState.switchStore(outlet.name);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Boutique active : ${outlet.name}'.tr)),
                                );
                              },
                              child: Text(
                                'Basculer ici'.tr,
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // BOUTON AJOUTER UNE BOUTIQUE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showAddOutletDialog,
                  icon: const Icon(Icons.add_rounded, color: AppTheme.primaryNavy),
                  label: Text(
                    'Ajouter une nouvelle boutique'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
