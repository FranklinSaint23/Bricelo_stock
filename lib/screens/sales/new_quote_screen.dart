import 'package:flutter/material.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class NewQuoteScreen extends StatefulWidget {
  const NewQuoteScreen({super.key});

  @override
  State<NewQuoteScreen> createState() => _NewQuoteScreenState();
}

class _NewQuoteScreenState extends State<NewQuoteScreen> {
  final appState = AppState.instance;
  String _selectedClient = 'Client (optionnel)';
  final _validUntilController = TextEditingController(text: '2026-11-27');
  final _notesController = TextEditingController();
  final List<Map<String, dynamic>> _quoteItems = [];

  void _showClientMenu() {
    final isDark = appState.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_add_alt_1, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
              title: Text('Nouveau client'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppTheme.primaryNavy)),
              onTap: () {
                Navigator.pop(ctx);
                _showNewClientDialog();
              },
            ),
            Divider(height: 1, color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
            ListTile(
              title: Text('Sans client'.tr, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF111827))),
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
    final isDark = appState.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text('Nouveau client'.tr, style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameCtrl,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
          decoration: InputDecoration(
            labelText: 'Nom du client'.tr,
            labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
              foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() => _selectedClient = nameCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text('OK'.tr),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _validUntilController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _addItem(String type) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text('${'Ajouter un'.tr} ${type.tr}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
              decoration: InputDecoration(
                labelText: 'Nom de la ligne'.tr,
                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
              decoration: InputDecoration(
                labelText: 'Montant (F CFA)'.tr,
                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler'.tr, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
              foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
            ),
            onPressed: () {
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              if (nameCtrl.text.trim().isNotEmpty && price > 0) {
                setState(() {
                  _quoteItems.add({
                    'name': nameCtrl.text.trim(),
                    'type': type,
                    'price': price,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: Text('Ajouter'.tr),
          ),
        ],
      ),
    );
  }

  double get _total => _quoteItems.fold(0.0, (sum, i) => sum + (i['price'] as double));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? AppTheme.darkScaffold : Colors.white;
        final barBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBg = isDark ? AppTheme.darkSurface : const Color(0xFFF9FAFB);
        final borderCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);
        final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Nouveau devis'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            centerTitle: true,
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
                    border: Border.all(color: borderCol),
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedClient.tr,
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedClient == 'Client (optionnel)' ? textSecondary : textPrimary,
                          fontWeight: _selectedClient == 'Client (optionnel)' ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: textSecondary),
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
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Valable jusqu\'au'.tr,
                    labelStyle: TextStyle(color: textSecondary),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderCol),
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
                      foregroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      side: BorderSide(color: borderCol),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: Icon(Icons.build_outlined, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                    label: Text('Service'.tr, style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _addItem('Service'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      side: BorderSide(color: borderCol),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: Icon(Icons.inventory_2_outlined, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                    label: Text('Produit'.tr, style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13)),
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
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${entry.value['name']} (${(entry.value['type'] as String).tr})', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                      Row(
                        children: [
                          Text('${entry.value['price']} F CFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
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
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Notes'.tr,
                  hintStyle: TextStyle(color: textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderCol),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderCol),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: barBg,
                border: Border(top: BorderSide(color: borderCol)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                      Text(
                        '${_total.round()} F CFA',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                        foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.save_outlined, size: 20, color: isDark ? AppTheme.primaryNavy : Colors.white),
                      label: Text(
                        'Enregistrer le devis'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
      },
    );
  }
}
