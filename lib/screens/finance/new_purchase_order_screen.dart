import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/inventory/new_supplier_screen.dart';

class NewPurchaseOrderScreen extends StatefulWidget {
  const NewPurchaseOrderScreen({super.key});

  @override
  State<NewPurchaseOrderScreen> createState() => _NewPurchaseOrderScreenState();
}

class _NewPurchaseOrderScreenState extends State<NewPurchaseOrderScreen> {
  final appState = AppState.instance;
  int _currentStep = 0; // 0: Fournisseur, 1: Destination, 2: Articles demandés, 3: Récapitulatif

  // Step 0: Fournisseur
  final _searchSupplierCtrl = TextEditingController();
  Supplier? _selectedSupplier;

  // Step 1: Destination
  String _selectedDestination = 'Boutique Principale';
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 3));

  // Step 2: Articles
  final _searchProductCtrl = TextEditingController();
  final Map<String, int> _selectedQuantities = {};
  final Map<String, double> _customPurchasePrices = {};

  // Step 3: Notes
  final _notesCtrl = TextEditingController();

  final List<String> _destinations = [
    'Boutique Principale',
    'Entrepôt / Dépôt Central',
    'Point de Vente 2'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDestination = _destinations.first;
  }

  @override
  void dispose() {
    _searchSupplierCtrl.dispose();
    _searchProductCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _totalEstimatedCost {
    double total = 0;
    for (final entry in _selectedQuantities.entries) {
      final pid = entry.key;
      final qty = entry.value;
      if (qty <= 0) continue;
      final product = appState.products.firstWhere(
        (p) => p.id == pid,
        orElse: () => Product(id: pid, name: '', barcode: '', buyPrice: 0, sellPrice: 0, stock: 0, category: ''),
      );
      final price = _customPurchasePrices[pid] ?? product.buyPrice;
      total += (price * qty);
    }
    return total;
  }

  int get _totalArticlesCount {
    int total = 0;
    for (final q in _selectedQuantities.values) {
      total += q;
    }
    return total;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedSupplier == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFDC2626),
            content: Text('Veuillez choisir un fournisseur.'),
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedDestination.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFDC2626),
            content: Text('Veuillez choisir une destination.'),
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_selectedQuantities.isEmpty || _totalArticlesCount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFDC2626),
            content: Text('Veuillez ajouter au moins un article.'),
          ),
        );
        return;
      }
    } else if (_currentStep == 3) {
      _finalizeOrder();
      return;
    }

    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _finalizeOrder() {
    final ref = 'BA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Si une dette fournisseur doit être générée ou un log
    if (_selectedSupplier != null && _totalEstimatedCost > 0) {
      appState.addSupplierDebt(
        SupplierDebt(
          id: 'sdebt_${DateTime.now().millisecondsSinceEpoch}',
          supplierName: _selectedSupplier!.name,
          supplierPhone: _selectedSupplier!.phone,
          invoiceRef: ref,
          totalAmount: _totalEstimatedCost,
          createdAt: DateTime.now(),
          dueDate: _deliveryDate,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryNavy,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bon d\'achat $ref créé avec succès !',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Nouveau bon d\'achat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. STEPPER PROGRESS BAR (Image 2)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            color: isDark ? AppTheme.darkSurface : Colors.white,
            child: Row(
              children: [
                _buildStepHeader(0, 'Fournisseur'),
                const SizedBox(width: 8),
                _buildStepHeader(1, 'Destination'),
                const SizedBox(width: 8),
                _buildStepHeader(2, 'Articles demand...'),
                const SizedBox(width: 8),
                _buildStepHeader(3, 'Récapitulatif'),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          ),

          // 2. ACTIVE STEP CONTENT
          Expanded(
            child: _buildCurrentStepContent(isDark),
          ),

          // 3. BOTTOM ACTIONS (Précédent / Suivant)
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildStepHeader(int step, String title) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;
    final isDark = appState.isDarkMode;

    Color barColor;
    if (isActive) {
      barColor = AppTheme.primaryNavy;
    } else if (isDone) {
      barColor = AppTheme.accentGold;
    } else {
      barColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    }

    Color textColor;
    if (isActive) {
      barColor = isDark ? AppTheme.accentGold : AppTheme.primaryNavy;
      textColor = isDark ? AppTheme.accentGold : AppTheme.primaryNavy;
    } else if (isDone) {
      textColor = isDark ? Colors.white70 : const Color(0xFF4B5563);
    } else {
      textColor = isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          if (step < _currentStep) {
            setState(() => _currentStep = step);
          }
        },
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStepFournisseur(isDark);
      case 1:
        return _buildStepDestination(isDark);
      case 2:
        return _buildStepArticles(isDark);
      case 3:
        return _buildStepRecapitulatif(isDark);
      default:
        return const SizedBox();
    }
  }

  // ================= STEP 0: FOURNISSEUR =================
  Widget _buildStepFournisseur(bool isDark) {
    final query = _searchSupplierCtrl.text.trim().toLowerCase();
    final suppliers = appState.suppliers.where((s) {
      if (s.isArchived) return false;
      if (query.isNotEmpty) {
        return s.name.toLowerCase().contains(query) ||
            s.contactName.toLowerCase().contains(query) ||
            s.phone.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Text(
          'Veuillez choisir un fournisseur.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 14),

        // CHAMP RECHERCHE (Pill shape conformed to Image 2)
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _searchSupplierCtrl,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: 'Rechercher',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                size: 22,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchSupplierCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (suppliers.isEmpty) ...[
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 48,
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun fournisseur',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentGold,
                    side: const BorderSide(color: AppTheme.accentGold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Créer un fournisseur'),
                  onPressed: () async {
                    final newSup = await Navigator.push<Supplier>(
                      context,
                      MaterialPageRoute(builder: (_) => const NewSupplierScreen()),
                    );
                    if (newSup != null) {
                      setState(() => _selectedSupplier = newSup);
                    }
                  },
                ),
              ],
            ),
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suppliers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final sup = suppliers[idx];
              final isSelected = _selectedSupplier?.id == sup.id;

              return InkWell(
                onTap: () => setState(() => _selectedSupplier = sup),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB))
                        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentGold
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentGold : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business,
                          color: isSelected ? AppTheme.primaryNavy : const Color(0xFF475569),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sup.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            if (sup.contactName.isNotEmpty || sup.phone.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                '${sup.contactName}${sup.contactName.isNotEmpty && sup.phone.isNotEmpty ? ' • ' : ''}${sup.phone}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 22)
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // ================= STEP 1: DESTINATION =================
  Widget _buildStepDestination(bool isDark) {
    final outlets = _destinations;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Text(
          'Point de vente ou dépôt de destination',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Indiquez où les marchandises commandées doivent être livrées et réceptionnées.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 18),

        ...outlets.map((outlet) {
          final isSelected = _selectedDestination == outlet;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedDestination = outlet),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB))
                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentGold
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warehouse_outlined,
                      color: isSelected ? AppTheme.accentGold : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        outlet,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 22)
                    else
                      Icon(
                        Icons.radio_button_unchecked,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
        Text(
          'Date de livraison souhaitée',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _deliveryDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() => _deliveryDate = picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppTheme.accentGold),
                const SizedBox(width: 12),
                Text(
                  '${_deliveryDate.day}/${_deliveryDate.month}/${_deliveryDate.year}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= STEP 2: ARTICLES DEMANDÉS =================
  Widget _buildStepArticles(bool isDark) {
    final query = _searchProductCtrl.text.trim().toLowerCase();
    final products = appState.products.where((p) {
      if (query.isNotEmpty) {
        return p.name.toLowerCase().contains(query) || p.category.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Recherche produit
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _searchProductCtrl,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: 'Rechercher un article...',
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                  size: 20,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchProductCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ),

        // Total sélectionné bannière
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Articles : $_totalArticlesCount sélectionné(s)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF92400E),
                ),
              ),
              Text(
                AppTheme.formatFCFA(_totalEstimatedCost),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ),

        // Liste produits
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Text(
                    'Aucun article trouvé',
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final p = products[idx];
                    final qty = _selectedQuantities[p.id] ?? 0;
                    final buyPrice = _customPurchasePrices[p.id] ?? p.buyPrice;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: qty > 0
                              ? AppTheme.accentGold
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Prix d\'achat : ${AppTheme.formatFCFA(buyPrice)} • Stock actuel: ${p.stock}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 22),
                                color: qty > 0 ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                                onPressed: qty > 0
                                    ? () {
                                        setState(() {
                                          if (qty == 1) {
                                            _selectedQuantities.remove(p.id);
                                          } else {
                                            _selectedQuantities[p.id] = qty - 1;
                                          }
                                        });
                                      }
                                    : null,
                              ),
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '$qty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, size: 22, color: AppTheme.accentGold),
                                onPressed: () {
                                  setState(() {
                                    _selectedQuantities[p.id] = qty + 1;
                                    if (!_customPurchasePrices.containsKey(p.id)) {
                                      _customPurchasePrices[p.id] = p.buyPrice;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ================= STEP 3: RÉCAPITULATIF =================
  Widget _buildStepRecapitulatif(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Text(
          'Vérifiez et confirmez le bon d\'achat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),

        // Carte Fournisseur
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, color: AppTheme.accentGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Fournisseur sélectionné',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedSupplier?.name ?? 'Non spécifié',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              if (_selectedSupplier?.phone.isNotEmpty ?? false) ...[
                const SizedBox(height: 2),
                Text(
                  'Téléphone : ${_selectedSupplier!.phone}',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : const Color(0xFF6B7280)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Carte Destination
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warehouse_outlined, color: AppTheme.accentGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination & Livraison',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_selectedDestination • Date: ${_deliveryDate.day}/${_deliveryDate.month}/${_deliveryDate.year}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Articles List
        Text(
          'Articles commandés ($_totalArticlesCount)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),

        ..._selectedQuantities.entries.map((entry) {
          final pid = entry.key;
          final qty = entry.value;
          final p = appState.products.firstWhere(
            (item) => item.id == pid,
            orElse: () => Product(id: pid, name: 'Article', barcode: '', buyPrice: 0, sellPrice: 0, stock: 0, category: ''),
          );
          final price = _customPurchasePrices[pid] ?? p.buyPrice;
          final lineTotal = price * qty;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '$qty × ${AppTheme.formatFCFA(price)}',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppTheme.formatFCFA(lineTotal),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFEA580C)),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        // Total Estimé Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Estimé :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                AppTheme.formatFCFA(_totalEstimatedCost),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Notes
        TextField(
          controller: _notesCtrl,
          maxLines: 2,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
          decoration: InputDecoration(
            labelText: 'Notes ou instructions au fournisseur (facultatif)',
            labelStyle: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF6B7280), fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ================= BOTTOM BAR =================
  Widget _buildBottomBar(bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : AppTheme.primaryNavy,
                  side: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onPressed: _previousStep,
                child: const Text('Précédent', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _nextStep,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentStep == 3 ? 'Valider le bon d\'achat' : 'Suivant',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentStep == 3 ? Icons.check_circle : Icons.arrow_forward,
                    size: 18,
                    color: AppTheme.accentGold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
