import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class SupplyScreen extends StatefulWidget {
  const SupplyScreen({super.key});

  @override
  State<SupplyScreen> createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  String _selectedMode = 'Achat fournisseur'; // 'Achat fournisseur', 'Stock existant'
  String? _selectedSupplier = 'Grossiste Ets NANA & Fils (Akwa)';
  bool _tvaDeductible = false;
  bool _alreadyPaid = false;
  final _notesCtrl = TextEditingController();

  final List<String> _suppliers = [
    'Grossiste Ets NANA & Fils (Akwa)',
    'Société Camerounaise d\'Importation (SCI)',
    'Oraimo Store Officiel Douala',
    'Usine Mousse Bassa',
    'Grossiste Marché Central Yaoundé',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.circleNavy,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 16),
            ),
          ),
        ),
        title: const Text(
          'Approvisionnement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. BANNIÈRE TEXTE
                  const Text(
                    'Une seule étape pour enregistrer la commande et sa réception.',
                    style: TextStyle(color: Color(0xFF4B5563), fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  // 2. SEGMENTED TABS : Achat fournisseur | Stock existant
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedMode = 'Achat fournisseur'),
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedMode == 'Achat fournisseur' ? AppTheme.goldLight : Colors.white,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF1F2937)),
                                  SizedBox(width: 6),
                                  Text('Achat fournisseur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedMode = 'Stock existant'),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedMode == 'Stock existant' ? AppTheme.goldLight : Colors.white,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF1F2937)),
                                  SizedBox(width: 6),
                                  Text('Stock existant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. FOURNISSEUR *
                  const Text('Fournisseur *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedSupplier,
                    hint: const Text('Choisir un fournisseur', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                    items: _suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _selectedSupplier = v),
                  ),
                  const SizedBox(height: 20),

                  // 4. ARTICLES (0)
                  const Text('Articles (0)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  // Bouton Scanner ou rechercher
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F2937),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.search, size: 18, color: AppTheme.primaryNavy),
                      label: const Text('Scanner ou rechercher', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recherche d\'article pour réassort lancée !')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bouton Ajouter le stock bas
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F2937),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.playlist_add_check, size: 18, color: AppTheme.primaryNavy),
                      label: const Text('Ajouter le stock bas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Articles en stock critique ajoutés au réassort !')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('Aucun article ajouté', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                  ),
                  const SizedBox(height: 20),

                  // 5. FRAIS ACCORDION
                  const Divider(color: Color(0xFFE5E7EB)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Frais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                    ],
                  ),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),

                  // 6. SWITCHES TVA & DÉJÀ PAYÉ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TVA déductible', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(height: 2),
                            Text(
                              'Votre régime ne suit pas la TVA — non applicable. Les coûts sont enregistrés tout compris.',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _tvaDeductible,
                        activeColor: AppTheme.primaryNavy,
                        onChanged: (v) => setState(() => _tvaDeductible = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Déjà payé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(height: 2),
                            Text(
                              'La facture fournisseur est réglée en totalité avec la réception.',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _alreadyPaid,
                        activeColor: AppTheme.primaryNavy,
                        onChanged: (v) => setState(() => _alreadyPaid = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7. NOTES (OPTIONNEL)
                  const Text('Notes (optionnel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 8. BARRE FIXE INFÉRIEURE : TOTAL & ENREGISTRER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                    Text('0 F CFA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF111827))),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: const Color(0xFF475569),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez ajouter au moins un article à approvisionner !')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
