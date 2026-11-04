import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final appState = AppState.instance;

  final List<Map<String, dynamic>> _promos = [
    {
      'title': 'Remise Fin de Semaine',
      'discount': 10,
      'isPercent': true,
      'isActive': true,
      'target': 'Toutes les catégories',
    },
    {
      'title': 'Offre Spéciale Nouveautés',
      'discount': 15,
      'isPercent': true,
      'isActive': false,
      'target': 'Articles sélectionnés',
    },
  ];

  void _showAddPromoDialog() {
    final titleCtrl = TextEditingController();
    final discountCtrl = TextEditingController(text: '10');
    bool isPercent = true;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = appState.isDarkMode;
        final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

        return StatefulBuilder(
          builder: (ctx, setModalState) => AlertDialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text('Nouvelle promotion'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nom de la remise *'.tr,
                    hintText: 'Ex: Promo Déstockage, Solde',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: discountCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Valeur de la remise *'.tr,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('%'),
                      selected: isPercent,
                      selectedColor: AppTheme.accentGold,
                      onSelected: (val) => setModalState(() => isPercent = true),
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text('FCFA'),
                      selected: !isPercent,
                      selectedColor: AppTheme.accentGold,
                      onSelected: (val) => setModalState(() => isPercent = false),
                    ),
                  ],
                ),
              ],
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
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final val = int.tryParse(discountCtrl.text.trim()) ?? 0;
                  if (title.isNotEmpty && val > 0) {
                    setState(() {
                      _promos.add({
                        'title': title,
                        'discount': val,
                        'isPercent': isPercent,
                        'isActive': true,
                        'target': 'Toutes les catégories',
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Promotion "$title" activée !'.tr)),
                    );
                  }
                },
                child: Text('Activer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

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
          'Promotions & Remises'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Créez des remises et offres promotionnelles applicables directement au point de vente pour récompenser vos clients.'.tr,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          for (int i = 0; i < _promos.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _promos[i]['isActive'] ? AppTheme.accentGold : cardBorder,
                  width: _promos[i]['isActive'] ? 1.4 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.3 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_offer_rounded, color: AppTheme.accentGold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _promos[i]['title'] as String,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_promos[i]['target']} • ${_promos[i]['isPercent'] ? '-${_promos[i]['discount']}%' : '-${AppTheme.formatFCFA((_promos[i]['discount'] as num).toDouble())}'}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _promos[i]['isActive'] as bool,
                    activeColor: AppTheme.accentGold,
                    activeTrackColor: AppTheme.primaryNavy,
                    onChanged: (val) {
                      setState(() => _promos[i]['isActive'] = val);
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showAddPromoDialog,
              icon: const Icon(Icons.add_rounded, color: AppTheme.primaryNavy),
              label: Text(
                'Créer une nouvelle promotion'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
