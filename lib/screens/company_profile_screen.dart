import 'package:flutter/material.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _nameController = TextEditingController(text: 'Franklin Athletics');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(text: 'franklinnjiepi07@gmail.com');
  final _addressController = TextEditingController();
  final _taxLabelController = TextEditingController(text: 'NIU');
  final _taxIdController = TextEditingController();
  final _rccmController = TextEditingController();

  String _selectedCountry = 'Cameroun';
  String _selectedActivity = 'Non défini';
  String _selectedTaxRegime = 'Non déclaré / je ne sais pas';

  final List<String> _countries = ['Cameroun', 'Gabon', 'Congo', 'Côte d\'Ivoire', 'Sénégal', 'France'];
  final List<String> _activities = [
    'Non défini',
    'Commerce général / Alimentation',
    'Boutique de vêtements / Chaussures',
    'Quincaillerie / Bricolage',
    'Pharmacie / Parapharmacie',
    'Électronique / Informatique',
    'Restaurant / Bar / Café',
    'Autre',
  ];
  final List<String> _taxRegimes = [
    'Non déclaré / je ne sais pas',
    'Régime de l\'impôt libératoire',
    'Régime simplifié',
    'Régime réel (assujetti TVA)',
  ];

  void _showTaxHelp() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Fiscalité et facturation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Indiquez votre régime fiscal au Cameroun. Si vous êtes au régime réel, la TVA (19,25%) pourra être appliquée automatiquement sur vos factures.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }

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
          'Profil de l\'entreprise',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF111827)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // LOGO SECTION
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text(
                  'Aucun logo',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF047857), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélectionnez une image de logo')),
                );
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFF047857)),
              label: const Text(
                'Ajouter un logo',
                style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 20),

          // NOM DE L'ENTREPRISE
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom de l\'entreprise',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // TÉLÉPHONE
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // EMAIL
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // ADRESSE
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Adresse',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),

          // SECTION: PAYS & DEVISE
          const Text(
            'Pays & devise',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCountry,
            decoration: InputDecoration(
              labelText: 'Pays',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCountry = val);
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Devise : XAF (définie par le pays)',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),

          // TYPE D'ACTIVITÉ
          DropdownButtonFormField<String>(
            initialValue: _selectedActivity,
            decoration: InputDecoration(
              labelText: 'Type d\'activité',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            items: _activities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedActivity = val);
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Nous aide à adapter StockPlus à votre métier. Facultatif — ne change rien dans l\'application.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // SECTION: FISCALITÉ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fiscalité',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              InkWell(
                onTap: _showTaxHelp,
                child: const Icon(Icons.help_outline, size: 20, color: Color(0xFF4B5563)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedTaxRegime,
            decoration: InputDecoration(
              labelText: 'Régime fiscal',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            items: _taxRegimes.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedTaxRegime = val);
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Détermine si vous facturez la TVA.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),

          // LIBELLÉ & IDENTIFIANT FISCAL
          Row(
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _taxLabelController,
                  decoration: InputDecoration(
                    labelText: 'Libellé',
                    labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _taxIdController,
                  decoration: InputDecoration(
                    hintText: 'Identifiant fiscal (NIU)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // RCCM
          TextField(
            controller: _rccmController,
            decoration: InputDecoration(
              labelText: 'RCCM (optionnel)',
              labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 32),

          // ACTIONS
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
                    content: Text('Profil d\'entreprise enregistré avec succès'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
