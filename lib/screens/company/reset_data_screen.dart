import 'package:flutter/material.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ResetDataScreen extends StatefulWidget {
  const ResetDataScreen({super.key});

  @override
  State<ResetDataScreen> createState() => _ResetDataScreenState();
}

class _ResetDataScreenState extends State<ResetDataScreen> {
  final appState = AppState.instance;

  void _confirmReset({required bool testDataOnly}) {
    final confirmCtrl = TextEditingController();
    bool confirmed = false;

    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return AlertDialog(
              backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  Icon(
                    testDataOnly ? Icons.warning_amber_rounded : Icons.delete_forever,
                    color: const Color(0xFFDC2626),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      testDataOnly ? 'Purger les transactions' : 'Remise à zéro complète',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testDataOnly
                          ? 'Cette action effacera définitivement toutes les ventes, dépenses, créances, dettes et mouvements de stock de test.\n\nVotre catalogue de produits, catégories et clients seront PRÉSERVÉS.'
                          : 'ATTENTION : Cette action supprimera TOUTES vos données (produits, catégories, ventes, dépenses, clients, fournisseurs, stock).\n\nCette action est irréversible.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1219) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: confirmed,
                            activeColor: const Color(0xFFDC2626),
                            onChanged: (val) {
                              setModalState(() => confirmed = val ?? false);
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Je comprends le caractère irréversible de cette opération.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!testDataOnly) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Pour confirmer, tapez "EFFACER" :',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: confirmCtrl,
                        onChanged: (_) => setModalState(() {}),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'EFFACER',
                          hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: isDark,
                          fillColor: isDark ? const Color(0xFF162540) : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: confirmed && (testDataOnly || confirmCtrl.text.trim().toUpperCase() == 'EFFACER')
                      ? () async {
                          Navigator.pop(dialogCtx);
                          if (testDataOnly) {
                            await appState.resetTestDataOnly();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transactions et écritures de test purgées avec succès.'),
                                  backgroundColor: Color(0xFF059669),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } else {
                            await appState.resetAllStoreData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Remise à zéro totale effectuée.'),
                                  backgroundColor: Color(0xFFDC2626),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        }
                      : null,
                  child: const Text('Confirmer l\'effacement', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
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
              'Repartir à zéro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // BANNER EXPLICATIVE
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
                    const Row(
                      children: [
                        Icon(Icons.cleaning_services_outlined, color: AppTheme.primaryNavy, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Purger vos données d\'essai',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Vous avez terminé vos tests sur Bricelo Stock ? Choisissez l\'option adaptée pour démarrer sereinement votre activité réelle.',
                      style: TextStyle(fontSize: 13.5, color: Color(0xFF4B5563), height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // OPTION 1: TRANSACTIONS SEULEMENT (RECOMMANDÉE)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.05),
                      blurRadius: 8,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long, color: Color(0xFF059669), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ventes & Transactions de test',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827)),
                              ),
                              Text(
                                'Recommandé pour préserver votre catalogue',
                                style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Efface uniquement les ventes, créances, dépenses, devis et mouvements de test. Vos produits, prix, catégories et clients restent intacts.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.restart_alt, size: 20),
                        label: const Text('Purger les transactions uniquement', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _confirmReset(testDataOnly: true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // STATS ACTUELLES EN BASE
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
                      'Données enregistrées actuellement',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 14),
                    _buildCountRow('Produits en catalogue', '${appState.products.length}'),
                    const SizedBox(height: 10),
                    _buildCountRow('Catégories', '${appState.categories.length}'),
                    const SizedBox(height: 10),
                    _buildCountRow('Ventes enregistrées', '${appState.sales.length}'),
                    const SizedBox(height: 10),
                    _buildCountRow('Clients', '${appState.customers.length}'),
                    const SizedBox(height: 10),
                    _buildCountRow('Fournisseurs', '${appState.suppliers.length}'),
                    const SizedBox(height: 10),
                    _buildCountRow('Dettes & Créances', '${appState.debts.length + appState.supplierDebts.length}'),
                    const SizedBox(height: 10),
                    _buildCountRow('Dépenses', '${appState.expenses.length}'),
                    const SizedBox(height: 10),
                    _buildCountRow('Mouvements de stock', '${appState.stockMovements.length}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // OPTION 2: REMISE A ZERO TOTALE (DANGER ZONE)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.dangerous_outlined, color: Color(0xFFDC2626), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Zone de danger : Remise à zéro totale',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Efface tout le contenu de la boutique (catalogue de produits, clients, fournisseurs et historique). Votre compte reste actif.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.delete_forever, size: 20),
                        label: const Text('Tout réinitialiser à zéro', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _confirmReset(testDataOnly: false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountRow(String label, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}
