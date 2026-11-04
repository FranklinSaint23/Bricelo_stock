import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';

class CashDesksScreen extends StatefulWidget {
  const CashDesksScreen({super.key});

  @override
  State<CashDesksScreen> createState() => _CashDesksScreenState();
}

class _CashDesksScreenState extends State<CashDesksScreen> {
  final appState = AppState.instance;

  void _showAddCashDeskDialog(String storeName) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = appState.isDarkMode;
        final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Nouvelle caisse ($storeName)'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ex: Caisse 2, Caisse Comptoir'.tr,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler'.tr, style: const TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final val = controller.text.trim();
                if (val.isNotEmpty) {
                  Navigator.pop(ctx);
                  await appState.addCashDesk(name: val, storeName: storeName);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Caisse "$val" ajoutée avec succès !'.tr),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: Text('Ajouter'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCashDeskDialog(CashDesk desk) {
    final controller = TextEditingController(text: desk.name);
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = appState.isDarkMode;
        final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Renommer la caisse'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler'.tr, style: const TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final val = controller.text.trim();
                if (val.isNotEmpty) {
                  Navigator.pop(ctx);
                  await appState.updateCashDesk(desk.id, val);
                }
              },
              child: Text('Enregistrer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(CashDesk desk) {
    final count = appState.cashDesks.where((c) => c.storeName == desk.storeName).length;
    if (count <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de supprimer la seule caisse de "${desk.storeName}".'.tr),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Supprimer la caisse ?'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer "${desk.name}" ?'.tr),
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
              await appState.deleteCashDesk(desk.id);
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
              'Caisses enregistreuses'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Gérez les caisses de chaque boutique. Par défaut, chaque boutique possède automatiquement sa caisse "Caisse [Nom Boutique]". Renommer une caisse synchronise immédiatement son compte trésorerie.'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              for (final outlet in outlets) ...[
                Builder(
                  builder: (context) {
                    final storeDesks = appState.cashDesksForStore(outlet.name);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    outlet.type == 'Entrepôt' ? Icons.warehouse_rounded : Icons.storefront_rounded,
                                    color: AppTheme.accentGold,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    outlet.name,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => _showAddCashDeskDialog(outlet.name),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.add_rounded, size: 16, color: AppTheme.accentGold),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ajouter une caisse'.tr,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          if (storeDesks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Aucune caisse enregistrée.'.tr,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                              ),
                            )
                          else
                            ...storeDesks.map((desk) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F1A28) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: desk.isDefault ? AppTheme.accentGold.withValues(alpha: 0.6) : cardBorder,
                                    width: desk.isDefault ? 1.2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.point_of_sale_rounded, size: 20, color: AppTheme.accentGold),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              desk.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (desk.isDefault) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentGold.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: AppTheme.accentGold, width: 0.8),
                                              ),
                                              child: Text(
                                                'Par défaut'.tr,
                                                style: const TextStyle(
                                                  color: AppTheme.accentGold,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showRenameCashDeskDialog(desk),
                                      borderRadius: BorderRadius.circular(6),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                    if (storeDesks.length > 1) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _confirmDelete(desk),
                                        borderRadius: BorderRadius.circular(6),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
