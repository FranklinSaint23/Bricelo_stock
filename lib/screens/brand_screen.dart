import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final _sloganCtrl = TextEditingController();
  final _distinctionCtrl = TextEditingController();
  final _storyCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _quarterCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _clientsCtrl = TextEditingController();
  final _goodWordsCtrl = TextEditingController();
  final _badWordsCtrl = TextEditingController();

  String _selectedTone = 'Dynamique';
  String _addressing = '« vous »';
  int _selectedColorPalette = 0;

  final List<String> _tones = ['Chaleureux', 'Dynamique', 'Premium', 'Naturel'];
  final List<String> _addressingOptions = ['« tu »', '« vous »'];

  final List<Map<String, dynamic>> _palettes = [
    {'bg': const Color(0xFF0D1B2E), 'dot': const Color(0xFFF5B000)}, // Navy Bricelo + Gold
    {'bg': Colors.white, 'dot': const Color(0xFFDC2626)}, // Blanc + Rouge
    {'bg': const Color(0xFF064E3B), 'dot': const Color(0xFFF5B000)}, // Vert + Jaune
    {'bg': const Color(0xFFFDF2F8), 'dot': const Color(0xFFDB2777)}, // Rose
    {'bg': const Color(0xFF1E3A8A), 'dot': const Color(0xFF38BDF8)}, // Bleu royal
    {'bg': const Color(0xFFFFF7ED), 'dot': const Color(0xFFEA580C)}, // Peche
  ];

  @override
  void dispose() {
    _sloganCtrl.dispose();
    _distinctionCtrl.dispose();
    _storyCtrl.dispose();
    _cityCtrl.dispose();
    _quarterCtrl.dispose();
    _deliveryCtrl.dispose();
    _clientsCtrl.dispose();
    _goodWordsCtrl.dispose();
    _badWordsCtrl.dispose();
    super.dispose();
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
          'Ma marque',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENTETE ENTREPRISE
            const Text(
              'Franklin Athletics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dites qui vous êtes : vos vidéos reprennent vos mots, vos couleurs et votre boutique. Tout est facultatif.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
            ),
            const SizedBox(height: 10),
            const Text(
              'Il manque : votre slogan, votre ville, le ton de votre boutique, vos couleurs, une photo de votre boutique, vos clients, ce qui vous distingue.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
            ),
            const SizedBox(height: 20),

            // 1. VOTRE SLOGAN
            _buildInputField(
              controller: _sloganCtrl,
              label: 'Votre slogan',
              subtext: 'Sans prix ni offre : un slogan qui en annonce n\'apparaît pas dans vos vidéos.',
            ),
            const SizedBox(height: 14),

            // 2. CE QUI VOUS DISTINGUE
            _buildInputField(controller: _distinctionCtrl, label: 'Ce qui vous distingue'),
            const SizedBox(height: 14),

            // 3. VOTRE HISTOIRE, EN QUELQUES LIGNES
            _buildInputField(controller: _storyCtrl, label: 'Votre histoire, en quelques lignes', maxLines: 3),
            const SizedBox(height: 14),

            // 4. VILLE
            _buildInputField(controller: _cityCtrl, label: 'Ville'),
            const SizedBox(height: 14),

            // 5. QUARTIER
            _buildInputField(controller: _quarterCtrl, label: 'Quartier'),
            const SizedBox(height: 14),

            // 6. VOTRE LIVRAISON
            _buildInputField(controller: _deliveryCtrl, label: 'Votre livraison'),
            const SizedBox(height: 14),

            // 7. VOS CLIENTS
            _buildInputField(controller: _clientsCtrl, label: 'Vos clients'),
            const SizedBox(height: 24),

            // 8. LE TON DE VOTRE BOUTIQUE
            const Text(
              'Le ton de votre boutique',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tones.map((t) {
                final isSelected = _selectedTone == t;
                return InkWell(
                  onTap: () => setState(() => _selectedTone = t),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryNavy : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppTheme.primaryNavy : const Color(0xFFD1D5DB)),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 9. VOUS DITES A VOS CLIENTS
            const Text(
              'Vous dites à vos clients',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 10),
            Row(
              children: _addressingOptions.map((opt) {
                final isSelected = _addressing == opt;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: InkWell(
                    onTap: () => setState(() => _addressing = opt),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryNavy : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppTheme.primaryNavy : const Color(0xFFD1D5DB)),
                      ),
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 10. MOTS A UTILISER ET A EVITER
            _buildInputField(controller: _goodWordsCtrl, label: 'Vos mots (séparés par des virgules)'),
            const SizedBox(height: 14),
            _buildInputField(controller: _badWordsCtrl, label: 'Les mots à éviter'),
            const SizedBox(height: 24),

            // 11. VOS COULEURS
            const Text(
              'Vos couleurs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_palettes.length, (idx) {
                final pal = _palettes[idx];
                final isSelected = _selectedColorPalette == idx;
                return InkWell(
                  onTap: () => setState(() => _selectedColorPalette = idx),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 48,
                    decoration: BoxDecoration(
                      color: pal['bg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryNavy : const Color(0xFFD1D5DB),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Aa',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: (pal['bg'] as Color).computeLuminance() > 0.5 ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: pal['dot'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // 12. PHOTOS DE VOTRE BOUTIQUE (0/4)
            const Text(
              'Photos de votre boutique (0/4)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélectionner des photos de la boutique')),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: const Center(
                  child: Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF6B7280), size: 28),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // BOUTON ENREGISTRER
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informations de marque enregistrées !')),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? subtext,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
            ),
          ),
        ),
        if (subtext != null) ...[
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.3),
          ),
        ],
      ],
    );
  }
}
