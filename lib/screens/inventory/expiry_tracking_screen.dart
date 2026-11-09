import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/inventory/stock_depreciation_screen.dart';
import 'package:stock_prime/widgets/widgets.dart';

class ExpiryTrackingScreen extends StatefulWidget {
  const ExpiryTrackingScreen({super.key});

  @override
  State<ExpiryTrackingScreen> createState() => _ExpiryTrackingScreenState();
}

class _ExpiryTrackingScreenState extends State<ExpiryTrackingScreen> {
  final appState = AppState.instance;
  late TextEditingController _daysController;
  final TextEditingController _searchController = TextEditingController();
  String _filterTab = 'Tous'; // 'Tous', 'Périmés', 'Bientôt périmés', 'Sans date'

  @override
  void initState() {
    super.initState();
    _daysController = TextEditingController(text: appState.expiryAlertDays.toString());
  }

  @override
  void dispose() {
    _daysController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _saveAlertDays() {
    final days = int.tryParse(_daysController.text.trim()) ?? 30;
    appState.setExpiryAlertDays(days);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alerte de péremption configurée à $days jours'),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openSetExpiryModal(Product product) {
    final isDark = appState.isDarkMode;
    DateTime selectedDate = product.expiryDate ?? DateTime.now().add(const Duration(days: 30));
    final lotCtrl = TextEditingController(text: product.lotNumber ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Date de péremption : ${product.name}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Numéro de lot (optionnel)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                    ),
                    child: TextField(
                      controller: lotCtrl,
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                      decoration: const InputDecoration(
                        hintText: 'Ex: LOT-2026-A12',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Date d\'expiration *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
                          ),
                          const Spacer(),
                          Text('Changer', style: TextStyle(color: isDark ? AppTheme.accentGold : const Color(0xFFEA580C), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (product.expiryDate != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              appState.updateProductExpiry(product.id, null, lotNumber: '');
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Date de péremption supprimée')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Supprimer'),
                          ),
                        ),
                      if (product.expiryDate != null) const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            appState.updateProductExpiry(
                              product.id,
                              selectedDate,
                              lotNumber: lotCtrl.text.trim(),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Date de péremption mise à jour avec succès'),
                                backgroundColor: Color(0xFF16A34A),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppTheme.accentGold : const Color(0xFF0D1B2E),
                            foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final strategy = appState.stockDestockingStrategy;
        final alertDays = appState.expiryAlertDays;

        // Filtrage des produits
        final query = _searchController.text.trim().toLowerCase();
        final allProducts = appState.products.where((p) {
          if (query.isEmpty) return true;
          return p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              (p.lotNumber ?? '').toLowerCase().contains(query);
        }).toList();

        final expiredProducts = allProducts.where((p) => p.isExpired()).toList();
        final expiringSoonProducts = allProducts.where((p) => p.isExpiringSoon(alertDays)).toList();
        final withoutDateProducts = allProducts.where((p) => p.expiryDate == null).toList();

        List<Product> displayedProducts;
        switch (_filterTab) {
          case 'Périmés':
            displayedProducts = expiredProducts;
            break;
          case 'Bientôt périmés':
            displayedProducts = expiringSoonProducts;
            break;
          case 'Sans date':
            displayedProducts = withoutDateProducts;
            break;
          default:
            displayedProducts = allProducts;
        }

        final isDark = appState.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: StockAppBar.forestGreen(
            title: 'Suivi de péremption',
            onBack: () => Navigator.pop(context),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            children: [
              // 1. STRATÉGIE DE DÉSTOCKAGE
              Text(
                'Stratégie de déstockage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              Text(
                'Change l\'ordre de sortie des lots et le coût attribué à chaque vente. Le coût moyen du produit reste inchangé.',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563), fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 16),

              // OPTION 1: FIFO
              InkWell(
                onTap: () => appState.setStockDestockingStrategy('FIFO'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: strategy == 'FIFO'
                        ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFDCFCE7))
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: strategy == 'FIFO'
                          ? (isDark ? const Color(0xFF10B981) : const Color(0xFF0D1B2E))
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                      width: strategy == 'FIFO' ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        strategy == 'FIFO' ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: strategy == 'FIFO'
                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF0D1B2E))
                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF6B7280)),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FIFO — Premier entré, premier sorti',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: strategy == 'FIFO'
                                    ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF0D1B2E))
                                    : (isDark ? Colors.white : const Color(0xFF111827)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Les ventes déstockent les lots les plus anciens d\'abord. Recommandé pour la plupart des commerces.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : (strategy == 'FIFO' ? const Color(0xFF0D1B2E) : const Color(0xFF6B7280)),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // OPTION 2: FEFO
              InkWell(
                onTap: () => appState.setStockDestockingStrategy('FEFO'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: strategy == 'FEFO'
                        ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFDCFCE7))
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: strategy == 'FEFO'
                          ? (isDark ? const Color(0xFF10B981) : const Color(0xFF0D1B2E))
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                      width: strategy == 'FEFO' ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        strategy == 'FEFO' ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: strategy == 'FEFO'
                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF0D1B2E))
                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF6B7280)),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FEFO — Premier périmé, premier sorti',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: strategy == 'FEFO'
                                    ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF0D1B2E))
                                    : (isDark ? Colors.white : const Color(0xFF111827)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Les ventes déstockent les lots qui périment le plus tôt. Indispensable pour l\'alimentaire et la cosmétique.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : (strategy == 'FEFO' ? const Color(0xFF0D1B2E) : const Color(0xFF6B7280)),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
              const SizedBox(height: 20),

              // 2. FENÊTRE D'ALERTE DE PÉREMPTION
              Text(
                'Fenêtre d\'alerte de péremption',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              Text(
                'Un lot qui périme dans ce nombre de jours est signalé « bientôt périmé » sur le tableau de bord.',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563), fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 14),

              // CHAMP NOMBRE DE JOURS AVEC VALIDATION
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _daysController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _saveAlertDays(),
                            ),
                          ),
                          Text(
                            'jours',
                            style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280), fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _saveAlertDays,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.accentGold : const Color(0xFF0D1B2E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: isDark ? const Color(0xFF0F172A) : Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
              const SizedBox(height: 20),

              // 3. STATUT DES PRODUITS & ARTICLES EN STOCK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suivi des dates d\'expiration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF111827)),
                  ),
                  Text(
                    '${allProducts.length} produit(s)',
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // BARRE DE RECHERCHE PRODUITS
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit, lot...',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                    prefixIcon: Icon(Icons.search, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ONGLETS DE FILTRE (Tous, Périmés, Bientôt périmés, Sans date)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip('Tous', allProducts.length, isDark: isDark),
                    const SizedBox(width: 8),
                    _buildTabChip('Périmés', expiredProducts.length, isAlert: expiredProducts.isNotEmpty, isDark: isDark),
                    const SizedBox(width: 8),
                    _buildTabChip('Bientôt périmés', expiringSoonProducts.length, isWarning: expiringSoonProducts.isNotEmpty, isDark: isDark),
                    const SizedBox(width: 8),
                    _buildTabChip('Sans date', withoutDateProducts.length, isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // LISTE DES PRODUITS
              if (displayedProducts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                  ),
                  child: Center(
                    child: Text(
                      'Aucun produit dans la catégorie « $_filterTab »',
                      style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280), fontSize: 13),
                    ),
                  ),
                )
              else
                ...displayedProducts.map((p) {
                  final isExpired = p.isExpired();
                  final isSoon = p.isExpiringSoon(alertDays);
                  final days = p.daysUntilExpiry();

                  Color badgeColor = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);
                  Color textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
                  String badgeText = 'Date non définie';

                  if (p.expiryDate != null) {
                    if (isExpired) {
                      badgeColor = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEE2E2);
                      textColor = const Color(0xFFEF4444);
                      badgeText = 'Périmé (${days?.abs()} j)';
                    } else if (isSoon) {
                      badgeColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7);
                      textColor = const Color(0xFFF59E0B);
                      badgeText = 'Périme dans $days j';
                    } else {
                      badgeColor = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFDCFCE7);
                      textColor = const Color(0xFF10B981);
                      badgeText = 'Valide ($days j)';
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isExpired
                            ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                            : (isSoon ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB))),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Stock: ${p.stock} ${p.unit}${p.lotNumber != null && p.lotNumber!.isNotEmpty ? " • Lot: ${p.lotNumber}" : ""}',
                                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _openSetExpiryModal(p),
                              icon: Icon(Icons.edit_calendar, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                              label: Text(
                                p.expiryDate == null ? 'Définir la date' : 'Modifier',
                                style: TextStyle(fontSize: 12, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                              ),
                            ),
                            if (isExpired || isSoon) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StockDepreciationScreen(
                                        initialProduct: p,
                                        initialReason: 'Péremption',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.remove_circle, size: 14, color: Colors.white),
                                label: const Text(
                                  'Déprécier',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
          bottomNavigationBar: StockBottomBar(
            currentIndex: 1, // Inventaire
            onTap: (_) => Navigator.pop(context),
          ),
        );
      },
    );
  }

  Widget _buildTabChip(String title, int count, {bool isAlert = false, bool isWarning = false, bool isDark = false}) {
    final isSelected = _filterTab == title;
    Color bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
    Color txt = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);

    if (isSelected) {
      bg = isDark ? AppTheme.accentGold : const Color(0xFF0D1B2E);
      txt = isDark ? const Color(0xFF0F172A) : Colors.white;
    } else if (isAlert) {
      bg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      txt = const Color(0xFFEF4444);
    } else if (isWarning) {
      bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
      txt = const Color(0xFFF59E0B);
    }

    return InkWell(
      onTap: () => setState(() => _filterTab = title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: txt),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: txt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
