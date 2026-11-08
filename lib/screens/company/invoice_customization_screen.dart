import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/services/invoice_print_service.dart';
import 'package:stock_prime/theme/app_theme.dart';

class InvoiceCustomizationScreen extends StatefulWidget {
  const InvoiceCustomizationScreen({super.key});

  @override
  State<InvoiceCustomizationScreen> createState() => _InvoiceCustomizationScreenState();
}

class _InvoiceCustomizationScreenState extends State<InvoiceCustomizationScreen> {
  final appState = AppState.instance;
  late List<InvoiceHeaderLine> _lines;
  final Map<String, TextEditingController> _labelControllers = {};
  final Map<String, TextEditingController> _valueControllers = {};

  late TextEditingController _signatureController;
  int _selectedSignatureStyle = 0;

  @override
  void initState() {
    super.initState();
    _signatureController = TextEditingController(text: appState.invoiceSignatureText);
    _selectedSignatureStyle = appState.invoiceSignatureStyle;
    _loadLines();
  }

  void _loadLines() {
    _lines = appState.invoiceHeaderLines.map((l) {
      return InvoiceHeaderLine(id: l.id, label: l.label, value: l.value);
    }).toList();

    _labelControllers.clear();
    _valueControllers.clear();
    for (final l in _lines) {
      _labelControllers[l.id] = TextEditingController(text: l.label);
      _valueControllers[l.id] = TextEditingController(text: l.value);
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    for (final c in _labelControllers.values) {
      c.dispose();
    }
    for (final c in _valueControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _addNewLine() {
    final newId = 'line_${DateTime.now().millisecondsSinceEpoch}';
    final newLine = InvoiceHeaderLine(
      id: newId,
      label: 'Info suppl.',
      value: 'Nouvelle information',
    );
    _labelControllers[newId] = TextEditingController(text: newLine.label);
    _valueControllers[newId] = TextEditingController(text: newLine.value);
    setState(() {
      _lines.add(newLine);
    });
  }

  void _removeLine(int index) {
    if (_lines.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La facture doit comporter au moins une ligne d\'information.')),
      );
      return;
    }
    final removed = _lines.removeAt(index);
    _labelControllers[removed.id]?.dispose();
    _labelControllers.remove(removed.id);
    _valueControllers[removed.id]?.dispose();
    _valueControllers.remove(removed.id);
    setState(() {});
  }

  void _resetToDefault() {
    appState.resetInvoiceHeaderLinesToDefault();
    appState.resetInvoiceSignature();
    setState(() {
      _signatureController.text = 'Bricelo';
      _selectedSignatureStyle = 0;
      _loadLines();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facture et signature réinitialisées aux valeurs par défaut (Bricelo).')),
    );
  }

  Future<void> _saveChanges() async {
    // Synchroniser les valeurs depuis les controllers
    for (final l in _lines) {
      l.label = _labelControllers[l.id]?.text.trim() ?? l.label;
      l.value = _valueControllers[l.id]?.text.trim() ?? l.value;
    }

    await appState.saveInvoiceHeaderLines(_lines);
    await appState.updateInvoiceSignature(
      text: _signatureController.text,
      style: _selectedSignatureStyle,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personnalisation de la facture enregistrée avec succès !'),
        backgroundColor: Color(0xFF059669),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white),
            tooltip: 'Réinitialiser par défaut',
            onPressed: _resetToDefault,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. APERÇU EN DIRECT DU RECTANGLE D'EN-TÊTE
          const Text(
            'Aperçu de l\'en-tête de la facture',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),

          _buildInvoiceHeaderPreview(),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 2. ÉDITION DES LIGNES D'INFORMATIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations sur la facture',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Modifiez les lignes affichées à côté du logo',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppTheme.accentGold),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _addNewLine,
              ),
            ],
          ),
          const SizedBox(height: 12),

          ..._lines.asMap().entries.map((entry) {
            final idx = entry.key;
            final line = entry.value;
            final labelCtrl = _labelControllers[line.id]!;
            final valCtrl = _valueControllers[line.id]!;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ligne ${idx + 1}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFDC2626)),
                        onPressed: () => _removeLine(idx),
                        tooltip: 'Supprimer cette ligne',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Libellé (label)
                  TextField(
                    controller: labelCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Libellé du champ',
                      hintText: 'Ex: Activité, Téléphone, N° Contribuable',
                      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Texte affiché (valeur)
                  TextField(
                    controller: valCtrl,
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Texte affiché sur la facture *',
                      hintText: 'Ex: Situé à FOURGEROLE...',
                      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 3. PERSONNALISATION DE LA SIGNATURE DE CAISSE
          _buildSignatureCustomizationSection(isDark),

          const SizedBox(height: 24),

          // 4. BOUTON ENREGISTRER
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
              onPressed: _saveChanges,
              child: const Text('Enregistrer la personnalisation', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget de personnalisation de la signature de caisse
  Widget _buildSignatureCustomizationSection(bool isDark) {
    final signatureText = _signatureController.text.trim().isEmpty
        ? 'Bricelo'
        : _signatureController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.draw_rounded, size: 19, color: AppTheme.accentGold),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Signature de caisse (Facture)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Générez automatiquement la signature apposée sur la facture',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            if (_signatureController.text.trim().toLowerCase() != 'bricelo' || _selectedSignatureStyle != 0) ...[
              const SizedBox(width: 6),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    _signatureController.text = 'Bricelo';
                    _selectedSignatureStyle = 0;
                  });
                },
                child: const Text('Rétablir Bricelo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Carte d'aperçu en direct de la signature générée
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.remove_red_eye_rounded, size: 12, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Aperçu sur la facture (Zone Caisse)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Plaqué sur PDF & Reçu',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Simulation fidèle du cadre "Caisse" de la facture A6
              Container(
                width: 170,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Caisse',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 140,
                      height: 46,
                      child: CustomPaint(
                        painter: InvoiceSignaturePainter(
                          text: signatureText,
                          styleIndex: _selectedSignatureStyle,
                          color: const Color(0xFF1E3A8A),
                          strokeWidth: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Champ texte du nom/vendeur
              TextField(
                controller: _signatureController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Nom à signer à la caisse *',
                  hintText: 'Ex: Bricelo, Franklin, Ousmane, Gérant...',
                  helperText: 'Chaque lettre est convertie en calligraphie vectorielle avec paraphe',
                  helperStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  prefixIcon: const Icon(Icons.edit_rounded, color: AppTheme.accentGold, size: 20),
                  suffixIcon: _signatureController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _signatureController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 14),

              // Sélecteur de style de calligraphie
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Style de calligraphie :',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 4 styles calligraphiques parfaitement équilibrés en grille 2x2
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3.2,
                children: [
                  _buildStyleChip(0, 'Bouclé Élégant'),
                  _buildStyleChip(1, 'Vague Moderne'),
                  _buildStyleChip(2, 'Double Prestige'),
                  _buildStyleChip(3, 'Plume & Paraphe'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleChip(int styleIdx, String label) {
    final isSelected = _selectedSignatureStyle == styleIdx;
    return InkWell(
      onTap: () => setState(() => _selectedSignatureStyle = styleIdx),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryNavy : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, color: AppTheme.accentGold, size: 14),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget aperçu du rectangle double-bordure
  Widget _buildInvoiceHeaderPreview() {
    final logo = appState.companyLogo;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryNavy, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryNavy, width: 1),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LOGO RECTANGLE EXACT
            Container(
              width: 100,
              height: 52, // Exact ratio rectangle
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(4),
              ),
              child: (logo.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        base64Decode(logo.contains(',') ? logo.split(',').last : logo),
                        fit: BoxFit.fill,
                        errorBuilder: (_, _, _) => _defaultLogoPreview(),
                      ),
                    )
                  : _defaultLogoPreview(),
            ),
            const SizedBox(width: 10),

            // INFORMATIONS DYNAMIQUES
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: _lines.map((l) {
                  final text = _valueControllers[l.id]?.text.trim() ?? l.value;
                  final isActivity = l.label.toLowerCase().contains('activité') || l.id == 'line_1';
                  final isPhone = l.label.toLowerCase().contains('tél');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isActivity ? 8.5 : (isPhone ? 9.5 : 8.0),
                        fontWeight: (isActivity || isPhone) ? FontWeight.w900 : FontWeight.w600,
                        color: AppTheme.primaryNavy,
                        letterSpacing: isActivity ? 0.3 : 0,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultLogoPreview() {
    return Container(
      padding: const EdgeInsets.all(4),
      color: AppTheme.primaryNavy,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_outlined, color: Colors.white, size: 14),
              SizedBox(width: 3),
              Text(
                'BRICELO',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8),
              ),
            ],
          ),
          Text(
            'CONFORT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 7, letterSpacing: 0.8),
          ),
          Text(
            'Juste le confort, tout simplement !',
            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 4.5),
          ),
        ],
      ),
    );
  }
}

