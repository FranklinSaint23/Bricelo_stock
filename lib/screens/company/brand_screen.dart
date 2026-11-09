import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

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
  List<String> _photos = [];
  bool _isSaving = false;

  final List<String> _tones = ['Chaleureux', 'Dynamique', 'Premium', 'Naturel'];
  final List<String> _addressingOptions = ['« tu »', '« vous »'];

  final List<Map<String, dynamic>> _palettes = [
    {'bg': const Color(0xFF0D1B2E), 'dot': const Color(0xFFF5B000)}, // Navy Bricelo + Gold
    {'bg': Colors.white, 'dot': const Color(0xFFDC2626)}, // Blanc + Rouge
    {'bg': AppTheme.primaryNavy, 'dot': const Color(0xFFF5B000)}, // Vert/Navy + Jaune
    {'bg': const Color(0xFFFDF2F8), 'dot': const Color(0xFFDB2777)}, // Rose
    {'bg': const Color(0xFF1E3A8A), 'dot': const Color(0xFF38BDF8)}, // Bleu royal
    {'bg': const Color(0xFFFFF7ED), 'dot': const Color(0xFFEA580C)}, // Peche
  ];

  @override
  void initState() {
    super.initState();
    final state = AppState.instance;
    _sloganCtrl.text = state.brandSlogan;
    _distinctionCtrl.text = state.brandDistinction;
    _storyCtrl.text = state.brandStory;
    _cityCtrl.text = state.brandCity;
    _quarterCtrl.text = state.brandQuarter;
    _deliveryCtrl.text = state.brandDelivery;
    _clientsCtrl.text = state.brandClients;
    _goodWordsCtrl.text = state.brandGoodWords;
    _badWordsCtrl.text = state.brandBadWords;
    if (_tones.contains(state.brandTone)) {
      _selectedTone = state.brandTone;
    }
    if (_addressingOptions.contains(state.brandAddressing)) {
      _addressing = state.brandAddressing;
    }
    if (state.brandPaletteIndex >= 0 && state.brandPaletteIndex < _palettes.length) {
      _selectedColorPalette = state.brandPaletteIndex;
    }
    _photos = List<String>.from(state.brandPhotos);
  }

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

  Future<void> _pickPhoto() async {
    if (_photos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 4 photos atteinte.')),
      );
      return;
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Img = base64Encode(bytes);
        setState(() {
          _photos.add(base64Img);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection : $e')),
        );
      }
    }
  }

  Future<void> _saveBrand() async {
    setState(() => _isSaving = true);
    await AppState.instance.updateBrandProfile(
      slogan: _sloganCtrl.text.trim(),
      distinction: _distinctionCtrl.text.trim(),
      story: _storyCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      quarter: _quarterCtrl.text.trim(),
      delivery: _deliveryCtrl.text.trim(),
      clients: _clientsCtrl.text.trim(),
      tone: _selectedTone,
      addressing: _addressing,
      goodWords: _goodWordsCtrl.text.trim(),
      badWords: _badWordsCtrl.text.trim(),
      paletteIndex: _selectedColorPalette,
      photos: _photos,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations de marque enregistrées avec succès !'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      Navigator.pop(context);
    }
  }

  List<String> _getMissingFields() {
    final missing = <String>[];
    if (_sloganCtrl.text.trim().isEmpty) missing.add('votre slogan');
    if (_cityCtrl.text.trim().isEmpty) missing.add('votre ville');
    if (_distinctionCtrl.text.trim().isEmpty) missing.add('ce qui vous distingue');
    if (_photos.isEmpty) missing.add('une photo de votre boutique');
    if (_clientsCtrl.text.trim().isEmpty) missing.add('vos clients');
    return missing;
  }

  @override
  Widget build(BuildContext context) {
    final missingFields = _getMissingFields();

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
            Text(
              AppState.instance.displayCompanyName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dites qui vous êtes : vos communications reprennent vos mots, vos couleurs et votre boutique. Tout est facultatif.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
            ),
            if (missingFields.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Il manque : ${missingFields.join(", ")}.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 1. VOTRE SLOGAN
            _buildInputField(
              controller: _sloganCtrl,
              label: 'Votre slogan',
              subtext: 'Sans prix ni offre : un slogan accrocheur pour valoriser votre enseigne.',
            ),
            const SizedBox(height: 14),

            // 2. CE QUI VOUS DISTINGUE
            _buildInputField(
              controller: _distinctionCtrl,
              label: 'Ce qui vous distingue',
              subtext: 'Ex: Qualité garantie, arrivages hebdomadaires, meilleur SAV...',
            ),
            const SizedBox(height: 14),

            // 3. VOTRE HISTOIRE, EN QUELQUES LIGNES
            _buildInputField(
              controller: _storyCtrl,
              label: 'Votre histoire, en quelques lignes',
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            // 4. VILLE
            _buildInputField(controller: _cityCtrl, label: 'Ville (ex: Douala, Abidjan, Dakar...)'),
            const SizedBox(height: 14),

            // 5. QUARTIER
            _buildInputField(controller: _quarterCtrl, label: 'Quartier (ex: Akwa, Cocody, Plateau...)'),
            const SizedBox(height: 14),

            // 6. VOTRE LIVRAISON
            _buildInputField(controller: _deliveryCtrl, label: 'Votre livraison (ex: Expédition 24h, coursier express)'),
            const SizedBox(height: 14),

            // 7. VOS CLIENTS
            _buildInputField(controller: _clientsCtrl, label: 'Vos clients (ex: Particuliers, PME, Bâtiment...)'),
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
            _buildInputField(controller: _goodWordsCtrl, label: 'Vos mots fétiches (séparés par des virgules)'),
            const SizedBox(height: 14),
            _buildInputField(controller: _badWordsCtrl, label: 'Les mots à éviter absolument'),
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
                        color: isSelected ? AppTheme.accentGold : const Color(0xFFD1D5DB),
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

            // 12. PHOTOS DE VOTRE BOUTIQUE (X/4)
            Text(
              'Photos de votre boutique (${_photos.length}/4)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (int i = 0; i < _photos.length; i++)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(_photos[i]),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _photos.removeAt(i);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_photos.length < 4)
                  InkWell(
                    onTap: _pickPhoto,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 72,
                      height: 72,
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
              ],
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
                onPressed: _isSaving ? null : _saveBrand,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
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
          onChanged: (_) => setState(() {}),
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
