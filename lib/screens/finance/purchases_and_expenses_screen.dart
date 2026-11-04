import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';

class PurchasesAndExpensesScreen extends StatelessWidget {
  const PurchasesAndExpensesScreen({super.key});

  void _showAddExpenseModal(BuildContext context, {required String category, required IconData icon}) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String paymentMethod = 'Espèces';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.goldLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.goldBorder),
                        ),
                        child: Icon(icon, color: AppTheme.primaryNavy, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enregistrer : $category',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const Text(
                              'Dépense d\'exploitation rapide',
                              style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.slate500),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Montant (F CFA)'.tr,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate700),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ex: 50.000',
                      prefixIcon: const Icon(Icons.payments_outlined, color: AppTheme.accentGold),
                      filled: true,
                      fillColor: AppTheme.surfaceRaised,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.slate200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accentGold, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Mode de paiement'.tr,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Espèces', 'MTN MoMo', 'Orange Money'].map((mode) {
                      final isSelected = paymentMethod == mode;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setModalState(() => paymentMethod = mode),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.goldLight : AppTheme.surfaceRaised,
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentGold : AppTheme.slate200,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                mode,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.primaryNavy : AppTheme.slate600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Note / Justificatif (optionnel)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate700),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Loyer boutique Mokolo - Mois en cours',
                      filled: true,
                      fillColor: AppTheme.surfaceRaised,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.slate200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accentGold, width: 2),
                      ),
                    ),
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
                      onPressed: () {
                        final val = amountController.text.trim();
                        if (val.isEmpty) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.primaryNavy,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '$category de $val F CFA enregistré avec succès',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_outlined, color: AppTheme.accentGold, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Valider la dépense ($category)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
        title: Text(
          'Achats & dépenses'.tr,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(Icons.people_outline, 'Fournisseurs'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.assignment_outlined, 'Bons d\'achat'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseOrdersScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.payments_outlined, 'Dépenses'.tr, isLocked: false, onTap: () {
                  _showAddExpenseModal(context, category: 'Dépense générale', icon: Icons.payments_outlined);
                }),
                _buildDivider(),
                // 🎯 1. NOUVEAU : Loyer (charges fixes d'exploitation)
                _buildRow(
                  Icons.storefront_outlined,
                  'Loyer'.tr,
                  isLocked: false,
                  badgeText: 'Charges',
                  onTap: () {
                    _showAddExpenseModal(context, category: 'Loyer', icon: Icons.storefront_outlined);
                  },
                ),
                _buildDivider(),
                // 🎯 2. NOUVEAU : Frais de livraison (logistique)
                _buildRow(
                  Icons.local_shipping_outlined,
                  'Frais de livraison'.tr,
                  isLocked: false,
                  badgeText: 'Transport',
                  onTap: () {
                    _showAddExpenseModal(context, category: 'Frais de livraison'.tr, icon: Icons.local_shipping_outlined);
                  },
                ),
                _buildDivider(),
                _buildRow(Icons.analytics_outlined, 'Analyse des sorties'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesAnalyticsScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.balance_outlined, 'Coût d\'achat'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseCostsScreen()));
                }),
                _buildDivider(),
                _buildRow(Icons.description_outlined, 'Dettes fournisseurs'.tr, isLocked: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierDebtsScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String title, {
    required bool isLocked,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
              ),
            ),
            if (badgeText != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.goldBorder),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.gold600),
                ),
              ),
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              size: 20,
              color: isLocked ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6));
  }
}
