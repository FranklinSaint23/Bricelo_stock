import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final appState = AppState.instance;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _activityController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _rccmController;

  String? _logoBase64;
  String _selectedCountry = 'Cameroun';
  final List<String> _countries = ['Cameroun', 'Gabon', 'Congo', 'Côte d\'Ivoire', 'Sénégal', 'France'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: appState.companyName.isNotEmpty ? appState.companyName : appState.displayCompanyName);
    _phoneController = TextEditingController(text: appState.userPhone);
    _emailController = TextEditingController(text: appState.userEmail);
    _addressController = TextEditingController(text: appState.companyAddress);
    _activityController = TextEditingController(text: appState.companyActivity);
    _taxIdController = TextEditingController(text: appState.taxNumber);
    _rccmController = TextEditingController(text: appState.rccmNumber);
    _logoBase64 = appState.companyLogo.isNotEmpty ? appState.companyLogo : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _activityController.dispose();
    _taxIdController.dispose();
    _rccmController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _logoBase64 = base64String;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF059669),
              content: Text('Logo sélectionné. Cliquez sur Enregistrer pour confirmer.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text('Erreur sélection image: $e')),
        );
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _logoBase64 = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
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
          'Profil de l\'entreprise',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. SECTION LOGO (FORMAT RECTANGLE STRICT)
          Center(
            child: Column(
              children: [
                Container(
                  width: 220,
                  height: 100, // Exact rectangle (ratio 2.2:1)
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentGold,
                      width: 1.8,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (_logoBase64 != null && _logoBase64!.trim().isNotEmpty)
                        ? Image.memory(
                            base64Decode(_logoBase64!.contains(',') ? _logoBase64!.split(',').last : _logoBase64!),
                            fit: BoxFit.fill,
                            errorBuilder: (_, _, _) => _buildLogoPlaceholder(),
                          )
                        : _buildLogoPlaceholder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryNavy, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.photo_library_outlined, size: 18, color: AppTheme.primaryNavy),
                      label: Text(
                        (_logoBase64 != null && _logoBase64!.isNotEmpty) ? 'Changer le logo' : 'Ajouter un logo',
                        style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    if (_logoBase64 != null && _logoBase64!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Supprimer le logo',
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                        onPressed: _removeLogo,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Format rectangle recommandé pour l\'en-tête de facture',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // 2. NOM DE L'ENTREPRISE
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom de l\'entreprise *',
              hintText: 'Ex: Bricelo Confort',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // 3. ACTIVITÉ / SLOGAN
          TextField(
            controller: _activityController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Activité principale / Slogan',
              hintText: 'Ex: VENTE DE MATELAS, LITS, MOUSSES, MEUBLES ET ACCESSOIRES MENAGERS',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // 4. ADRESSE / SITUATION GÉOGRAPHIQUE
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Adresse / Localisation',
              hintText: 'Ex: Situé à FOURGEROLE ( Face Tradex avant le Petit Marché)',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // 5. TÉLÉPHONE
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone *',
              hintText: 'Ex: +237 689 39 88 07',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // 6. EMAIL
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'contact@bricelo.com',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          // 7. INFORMATIONS LÉGALES & FISCALES
          const Text(
            'Informations légales & fiscales',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 10),

          // N° CONTRIBUABLE (NIU)
          TextField(
            controller: _taxIdController,
            decoration: InputDecoration(
              labelText: 'N° de Contribuable (NIU)',
              hintText: 'Ex: N° Cont: P049616604139M',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // RCCM
          TextField(
            controller: _rccmController,
            decoration: InputDecoration(
              labelText: 'Registre du commerce (RCCM)',
              hintText: 'Ex: RC/DLA/2026/B/1234',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // PAYS
          DropdownButtonFormField<String>(
            initialValue: _selectedCountry,
            decoration: InputDecoration(
              labelText: 'Pays',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCountry = val);
            },
          ),
          const SizedBox(height: 30),

          // BOUTON ENREGISTRER
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: AppTheme.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom de l\'entreprise est obligatoire.'), backgroundColor: Color(0xFFDC2626)),
                  );
                  return;
                }

                await appState.updateCompanyProfile(
                  name: name,
                  phone: _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                  address: _addressController.text.trim(),
                  activity: _activityController.text.trim(),
                  taxNo: _taxIdController.text.trim(),
                  rccmNo: _rccmController.text.trim(),
                  logoBase64: _logoBase64 ?? '',
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil d\'entreprise et logo enregistrés avec succès !'),
                    backgroundColor: Color(0xFF059669),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Enregistrer le profil', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_rounded, size: 36, color: AppTheme.accentGold),
          const SizedBox(height: 4),
          const Text(
            'Logo de l\'entreprise',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
