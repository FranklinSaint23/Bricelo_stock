import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/widgets/widgets.dart';

class NewTransferScreen extends StatefulWidget {
  const NewTransferScreen({super.key});

  @override
  State<NewTransferScreen> createState() => _NewTransferScreenState();
}

class _NewTransferScreenState extends State<NewTransferScreen> {
  final appState = AppState.instance;

  late String _sourceStore;
  late String _destinationStore;
  final TextEditingController _noteCtrl = TextEditingController();

  final Map<String, int> _selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    final stores = appState.outlets.map((o) => o.name).toList();
    if (stores.isEmpty) stores.add(appState.currentStore);

    _sourceStore = appState.currentStore;
    _destinationStore = stores.firstWhere((s) => s != _sourceStore, orElse: () => 'Entrepôt Central');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _showAddProductsModal() {
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final products = appState.products.where((p) {
              if (query.isEmpty) return true;
              return p.name.toLowerCase().contains(query) ||
                  p.barcode.toLowerCase().contains(query) ||
                  p.category.toLowerCase().contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Text('Sélectionner des articles à transférer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: searchCtrl,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un article...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: products.isEmpty
                        ? const Center(child: Text('Aucun article trouvé'))
                        : ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final p = products[idx];
                              final available = p.stockForStore(_sourceStore);
                              final currentSel = _selectedQuantities[p.id] ?? 0;

                              return ListTile(
                                leading: ProductImageWidget(
                                  imageUrl: p.imageUrl,
                                  size: 38,
                                  borderRadius: 8,
                                ),
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('Dispo dans $_sourceStore : $available ${p.unit}(s)', style: const TextStyle(fontSize: 12)),
                                trailing: currentSel > 0
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                            onPressed: () {
                                              setModalState(() {
                                                if (currentSel <= 1) {
                                                  _selectedQuantities.remove(p.id);
                                                } else {
                                                  _selectedQuantities[p.id] = currentSel - 1;
                                                }
                                              });
                                              setState(() {});
                                            },
                                          ),
                                          Text('$currentSel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryNavy),
                                            onPressed: currentSel < available
                                                ? () {
                                                    setModalState(() {
                                                      _selectedQuantities[p.id] = currentSel + 1;
                                                    });
                                                    setState(() {});
                                                  }
                                                : null,
                                          ),
                                        ],
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: available > 0 ? AppTheme.primaryNavy : Colors.grey,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        ),
                                        onPressed: available > 0
                                            ? () {
                                                setModalState(() {
                                                  _selectedQuantities[p.id] = 1;
                                                });
                                                setState(() {});
                                              }
                                            : null,
                                        child: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                                      ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: AppTheme.primaryNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Valider la sélection (${_selectedQuantities.length} articles)', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  void _confirmTransfer() {
    if (_sourceStore.trim().toLowerCase() == _destinationStore.trim().toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La boutique source et la boutique destination doivent être différentes.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un article à transférer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final yyyy = now.year.toString();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final seq = (appState.stockTransfers.length + 1).toString().padLeft(4, '0');
    final ref = 'BS-TRF-$yyyy$mm$dd-$seq';

    final List<TransferItem> items = [];
    for (final entry in _selectedQuantities.entries) {
      final p = appState.products.firstWhere((prod) => prod.id == entry.key);
      items.add(TransferItem(
        productId: p.id,
        productName: p.name,
        quantity: entry.value,
        unit: p.unit,
      ));
    }

    // Si l'utilisateur connecté est un équipier (Magasinier, Gérant...) : soumettre à l'approbation du Propriétaire
    if (!appState.hasPermission('Validation des approbations')) {
      appState.requestStockTransfer(
        sourceStore: _sourceStore,
        destinationStore: _destinationStore,
        items: items,
        note: _noteCtrl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de transfert de stock envoyée au propriétaire pour approbation !'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context);
      return;
    }

    final transfer = StockTransfer(
      id: 'trf_${now.millisecondsSinceEpoch}',
      reference: ref,
      sourceStore: _sourceStore,
      destinationStore: _destinationStore,
      items: items,
      date: now,
      author: appState.displayUserName,
      status: 'Effectué',
      note: _noteCtrl.text.trim(),
    );

    appState.addStockTransfer(transfer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transfert $ref effectué avec succès (${items.length} articles) !'),
        backgroundColor: const Color(0xFF059669),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final stores = appState.outlets.map((o) => o.name).toList();
    if (stores.isEmpty) stores.add(appState.currentStore);
    if (!stores.contains('Entrepôt Central')) stores.add('Entrepôt Central');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09121E) : const Color(0xFFF8FAFC),
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
        title: const Text('Nouveau transfert de stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BOUTIQUE SOURCE & BOUTIQUE DESTINATION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Boutique Source (Départ) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _sourceStore,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: stores.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _sourceStore = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_downward, color: Color(0xFFB45309), size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Boutique Destination (Arrivée) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _destinationStore,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: stores.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _destinationStore = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. ARTICLES SÉLECTIONNÉS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Articles à transférer (${_selectedQuantities.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                TextButton.icon(
                  onPressed: _showAddProductsModal,
                  icon: const Icon(Icons.add, size: 16, color: AppTheme.accentGold),
                  label: const Text('+ Ajouter', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_selectedQuantities.isEmpty)
              InkWell(
                onTap: _showAddProductsModal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.add_shopping_cart, size: 36, color: Color(0xFF94A3B8)),
                      SizedBox(height: 8),
                      Text('Aucun article sélectionné', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      SizedBox(height: 4),
                      Text('Cliquez pour ajouter des articles depuis la boutique source', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedQuantities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final pId = _selectedQuantities.keys.elementAt(idx);
                    final qty = _selectedQuantities[pId]!;
                    final p = appState.products.firstWhere((prod) => prod.id == pId);

                    return ListTile(
                      leading: ProductImageWidget(
                        imageUrl: p.imageUrl,
                        size: 38,
                        borderRadius: 8,
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Quantité à transférer : $qty ${p.unit}(s)', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _selectedQuantities.remove(pId)),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // 3. NOTE / MOTIF (OPTIONNEL)
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Note / Motif du transfert (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 24),

            // 4. BOUTON VALIDER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _confirmTransfer,
                child: Text(
                  appState.hasPermission('Validation des approbations')
                      ? 'Confirmer le transfert de stock'
                      : 'Soumettre le transfert à l\'approbation du Propriétaire',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
