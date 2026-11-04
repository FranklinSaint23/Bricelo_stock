import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class PhysicalInventoryScreen extends StatefulWidget {
  const PhysicalInventoryScreen({super.key});

  @override
  State<PhysicalInventoryScreen> createState() => _PhysicalInventoryScreenState();
}

class _PhysicalInventoryScreenState extends State<PhysicalInventoryScreen> {
  final appState = AppState.instance;
  late String _selectedStore;
  final Map<String, TextEditingController> _countedControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedStore = appState.currentStore;
    _initControllers();
  }

  void _initControllers() {
    for (final p in appState.products) {
      final curStock = p.stockForStore(_selectedStore);
      _countedControllers[p.id] = TextEditingController(text: curStock.toString());
    }
  }

  @override
  void dispose() {
    for (final c in _countedControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _confirmAndApplyInventory() {
    int adjustedCount = 0;

    for (final p in appState.products) {
      final ctrl = _countedControllers[p.id];
      if (ctrl != null) {
        final counted = int.tryParse(ctrl.text.trim());
        if (counted != null) {
          final cur = p.stockForStore(_selectedStore);
          if (counted != cur) {
            appState.adjustStock(
              productId: p.id,
              newStock: counted,
              reason: 'Inventaire physique ($_selectedStore)',
            );
            adjustedCount++;
          }
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Text(
          adjustedCount > 0
              ? 'Inventaire validé : $adjustedCount article(s) régularisé(s) !'.tr
              : 'Inventaire conforme : aucun écart détecté.'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    final stores = appState.outlets.map((o) => o.name).toList();
    if (stores.isEmpty) stores.add(appState.currentStore);

    final products = appState.products;

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
          'Inventaires physiques'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // SÉLECTEUR DE BOUTIQUE
          Container(
            padding: const EdgeInsets.all(16),
            color: cardBg,
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppTheme.accentGold, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Boutique :'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: cardBorder),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: stores.contains(_selectedStore) ? _selectedStore : stores.first,
                        isExpanded: true,
                        dropdownColor: cardBg,
                        items: stores.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s, style: TextStyle(color: textColor, fontSize: 13.5)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedStore = val;
                              _initControllers();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cardBorder),

          // LISTE DES PRODUITS POUR LE COMPTAGE
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text('Aucun produit à inventorier.'.tr, style: const TextStyle(color: Color(0xFF94A3B8))),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final theo = p.stockForStore(_selectedStore);
                      final ctrl = _countedControllers[p.id] ?? TextEditingController(text: theo.toString());
                      final countedVal = int.tryParse(ctrl.text.trim()) ?? theo;
                      final ecart = countedVal - theo;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${p.category} • Théorique: $theo ${p.unit}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // CHAMP COMPTÉ
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Compté :'.tr,
                                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 64,
                                      height: 36,
                                      child: TextField(
                                        controller: ctrl,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onChanged: (val) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  ecart == 0
                                      ? 'Écart : 0'.tr
                                      : (ecart > 0 ? '+ $ecart ${p.unit}' : '$ecart ${p.unit}'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ecart == 0
                                        ? const Color(0xFF10B981)
                                        : (ecart > 0 ? const Color(0xFFD97706) : const Color(0xFFDC2626)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // BOUTON VALIDER L'INVENTAIRE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(top: BorderSide(color: cardBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _confirmAndApplyInventory,
                icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryNavy),
                label: Text(
                  'Valider & Régulariser le stock'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
