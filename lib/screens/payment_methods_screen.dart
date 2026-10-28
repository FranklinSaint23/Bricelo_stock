import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _accounts = [
    {
      'id': '1',
      'title': 'Caisse 1',
      'subtitle': 'Boutique principale',
      'balance': '0 F CFA',
      'icon': Icons.payments_outlined,
      'isCashDesk': true,
      'type': 'Espèces',
    },
    {
      'id': '2',
      'title': 'Mobile Money',
      'subtitle': null,
      'balance': '0 F CFA',
      'icon': Icons.smartphone,
      'isCashDesk': false,
      'type': 'Mobile Money',
    },
    {
      'id': '3',
      'title': 'Carte',
      'subtitle': null,
      'balance': '0 F CFA',
      'icon': Icons.credit_card,
      'isCashDesk': false,
      'type': 'Carte',
    },
  ];

  bool _isAdding = false;
  String _selectedType = 'Mobile Money'; // 'Mobile Money', 'Banque', 'Carte'
  final _nameController = TextEditingController();

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primaryNavy),
            SizedBox(width: 8),
            Text('Comptes de paiement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Les comptes de paiement vous permettent de suivre précisément les encaissements par canal (Espèces, Mobile Money, Carte, Virement). Chaque vente alimente le compte sélectionné lors du passage en caisse.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _addAccount() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      IconData icon = Icons.smartphone;
      if (_selectedType == 'Banque') icon = Icons.account_balance;
      if (_selectedType == 'Carte') icon = Icons.credit_card;

      setState(() {
        _accounts.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': name,
          'subtitle': null,
          'balance': '0 F CFA',
          'icon': icon,
          'isCashDesk': false,
          'type': _selectedType,
        });
        _nameController.clear();
        _isAdding = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compte "$name" ajouté')),
      );
    }
  }

  String _getHintText() {
    switch (_selectedType) {
      case 'Banque':
        return 'Nom (ex. Ecobank, Afriland, Virement)';
      case 'Carte':
        return 'Nom (ex. Carte Visa, Mastercard, TPE)';
      case 'Mobile Money':
      default:
        return 'Nom (ex. Orange Money, Wave)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Comptes de paiement',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: _showHelpDialog,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Les comptes de paiement déterminent les options proposées en caisse et où atterrit l\'argent. Les caisses (espèces) sont créées automatiquement avec chaque caisse.',
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
          ),
          const SizedBox(height: 16),

          // LISTE DES COMPTES EXISTANTS
          ..._accounts.map((acc) {
            final isCash = acc['isCashDesk'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(acc['icon'] as IconData, size: 24, color: const Color(0xFF1F2937)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              acc['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827)),
                            ),
                            if (acc['subtitle'] != null) ...[
                              Text(
                                ' · ${acc['subtitle']}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          acc['balance'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ajustement du solde pour ${acc['title']}')),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.edit_note, size: 22, color: Color(0xFF4B5563)),
                    ),
                  ),
                  if (!isCash) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Modifier ${acc['title']}')),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4B5563)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _accounts.removeWhere((a) => a['id'] == acc['id']);
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.archive_outlined, size: 18, color: Color(0xFF4B5563)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 6),
          const Text(
            'Soldes au 28/10/2026 02:39:20',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // FORMULAIRE EN LIGNE (SCREENSHOT 2) vs BOUTON AJOUTER (SCREENSHOT 1)
          if (_isAdding) ...[
            // SEGMENTED PILLS: Mobile Money | Banque | Carte
            Container(
              height: 46,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF9CA3AF)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  // MOBILE MONEY
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = 'Mobile Money'),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _selectedType == 'Mobile Money' ? const Color(0xFFFEF3C7) : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          border: _selectedType == 'Mobile Money'
                              ? Border.all(color: const Color(0xFFF5B000), width: 1.2)
                              : null,
                        ),
                        child: const Center(
                          child: Text(
                            'Mobile Money',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 46, color: const Color(0xFF9CA3AF)),

                  // BANQUE
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = 'Banque'),
                      child: Container(
                        height: 46,
                        color: _selectedType == 'Banque' ? const Color(0xFFFEF3C7) : Colors.transparent,
                        child: const Center(
                          child: Text(
                            'Banque',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 46, color: const Color(0xFF9CA3AF)),

                  // CARTE
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = 'Carte'),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _selectedType == 'Carte' ? const Color(0xFFFEF3C7) : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          border: _selectedType == 'Carte'
                              ? Border.all(color: const Color(0xFFF5B000), width: 1.2)
                              : null,
                        ),
                        child: const Center(
                          child: Text(
                            'Carte',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // CHAMP NOM (EX. ORANGE MONEY, WAVE)
            TextField(
              controller: _nameController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _getHintText(),
                hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),

            // ACTIONS: ANNULER & AJOUTER
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isAdding = false;
                          _nameController.clear();
                        });
                      },
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _nameController.text.trim().isNotEmpty
                            ? const Color(0xFF14532D)
                            : const Color(0xFFD1D5DB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      onPressed: _nameController.text.trim().isNotEmpty ? _addAccount : null,
                      child: Text(
                        'Ajouter',
                        style: TextStyle(
                          color: _nameController.text.trim().isNotEmpty ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF4B5563), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => setState(() => _isAdding = true),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF111827), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Ajouter un compte',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
