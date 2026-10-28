import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class InvoiceCustomizationScreen extends StatefulWidget {
  const InvoiceCustomizationScreen({super.key});

  @override
  State<InvoiceCustomizationScreen> createState() => _InvoiceCustomizationScreenState();
}

class _InvoiceCustomizationScreenState extends State<InvoiceCustomizationScreen> {
  final List<String> _methods = ['Wave', 'Orange Money', 'IBAN', 'Autre'];
  String _selectedMethod = 'Wave';
  final _numberController = TextEditingController();
  final _urlController = TextEditingController();
  final _extraInfoController = TextEditingController();

  final List<Map<String, String>> _configuredPaymentOptions = [];

  @override
  Widget build(BuildContext context) {
    final charCount = _extraInfoController.text.length;

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
          'Personnalisation des factures',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ces informations apparaissent sur vos factures pour indiquer à vos clients comment payer.',
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
          ),
          const SizedBox(height: 20),

          // MOYENS DE PAIEMENT
          Row(
            children: [
              const Text(
                'Moyens de paiement',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(width: 6),
              Text(
                '(${_configuredPaymentOptions.length}/6)',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _methods.map((method) {
                final isSelected = _selectedMethod == method;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMethod = method),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? Border.all(color: const Color(0xFFD97706), width: 1.5) : null,
                      ),
                      child: Row(
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check, size: 16, color: Color(0xFF92400E)),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            method,
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _numberController,
            decoration: InputDecoration(
              labelText: 'Numéro *',
              hintText: 'Ex: 699 00 11 22',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD1D5DB),
                foregroundColor: const Color(0xFF4B5563),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onPressed: () {
                final num = _numberController.text.trim();
                if (num.isNotEmpty) {
                  setState(() {
                    _configuredPaymentOptions.add({
                      'method': _selectedMethod,
                      'number': num,
                    });
                    _numberController.clear();
                  });
                }
              },
            ),
          ),

          if (_configuredPaymentOptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._configuredPaymentOptions.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${e.value['method']} : ${e.value['number']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  InkWell(
                    onTap: () => setState(() => _configuredPaymentOptions.removeAt(e.key)),
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ],
              ),
            )),
          ],

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 20),

          // QR DE PAIEMENT OFFICIEL
          const Text(
            'QR de paiement officiel',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Importez le QR de votre application Wave ou Orange Money : il sera imprimé tel quel sur vos factures, avec son logo.',
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
          ),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF3C7),
                foregroundColor: const Color(0xFF92400E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18, color: Color(0xFF92400E)),
              label: const Text('Importer une image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélectionnez l\'image du QR code de paiement')),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 20),

          // LIEN DE PAIEMENT (QR CODE)
          const Text(
            'Lien de paiement (QR code)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'URL (ex. lien Wave)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 20),

          // INFORMATIONS COMPLÉMENTAIRES
          const Text(
            'Informations complémentaires',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _extraInfoController,
            maxLines: 4,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Texte libre en pied de facture',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(14),
              counterText: '$charCount/500',
              counterStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14532D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Personnalisation des factures enregistrée'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
