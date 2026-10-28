import 'package:flutter/material.dart';

class NewQuoteScreen extends StatefulWidget {
  const NewQuoteScreen({super.key});

  @override
  State<NewQuoteScreen> createState() => _NewQuoteScreenState();
}

class _NewQuoteScreenState extends State<NewQuoteScreen> {
  String _selectedClient = 'Client (optionnel)';
  final _validUntilController = TextEditingController(text: '2026-11-27');
  final _notesController = TextEditingController();
  final List<Map<String, dynamic>> _quoteItems = [];

  void _showClientMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_alt_1, color: Color(0xFF14532D)),
              title: const Text('Nouveau client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onTap: () {
                Navigator.pop(ctx);
                _showNewClientDialog();
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Sans client', style: TextStyle(fontSize: 15)),
              onTap: () {
                setState(() => _selectedClient = 'Sans client');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewClientDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau client'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nom du client'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() => _selectedClient = nameCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _validUntilController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _addItem(String type) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ajouter un $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Désignation du $type')),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix (F CFA)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceCtrl.text) ?? 0;
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _quoteItems.add({
                    'type': type,
                    'name': nameCtrl.text.trim(),
                    'price': price,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  double get _total => _quoteItems.fold(0.0, (sum, i) => sum + (i['price'] as num));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827), size: 16),
            ),
          ),
        ),
        title: const Text(
          'Nouveau devis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF111827)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SÉLECTEUR CLIENT
          InkWell(
            onTap: _showClientMenu,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF9CA3AF)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedClient,
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedClient == 'Client (optionnel)' ? const Color(0xFF4B5563) : const Color(0xFF111827),
                      fontWeight: _selectedClient == 'Client (optionnel)' ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF374151)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // DATE VALABLE JUSQU'AU
          InkWell(
            onTap: _pickDate,
            child: TextField(
              controller: _validUntilController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Valable jusqu\'au',
                labelStyle: const TextStyle(color: Color(0xFF4B5563)),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // BOUTONS SERVICE / PRODUIT
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF9CA3AF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.build_outlined, size: 18, color: Color(0xFF14532D)),
                label: const Text('Service', style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () => _addItem('Service'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF9CA3AF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.inventory_2_outlined, size: 18, color: Color(0xFF14532D)),
                label: const Text('Produit', style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () => _addItem('Produit'),
              ),
            ],
          ),

          if (_quoteItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._quoteItems.asMap().entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${entry.value['name']} (${entry.value['type']})', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Text('${entry.value['price']} F CFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        onPressed: () => setState(() => _quoteItems.removeAt(entry.key)),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],

          const SizedBox(height: 16),

          // NOTES
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Notes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  Text(
                    '${_total.round()} F CFA',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14532D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.save_outlined, size: 20, color: Colors.white),
                  label: const Text(
                    'Enregistrer le devis',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      'client': _selectedClient == 'Client (optionnel)' ? 'Sans client' : _selectedClient,
                      'validUntil': _validUntilController.text,
                      'total': _total,
                      'notes': _notesController.text,
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
