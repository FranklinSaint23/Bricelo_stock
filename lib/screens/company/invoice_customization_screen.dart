import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
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

  @override
  void initState() {
    super.initState();
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
    setState(() {
      _loadLines();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lignes d\'en-tête réinitialisées aux valeurs par défaut.')),
    );
  }

  Future<void> _saveChanges() async {
    // Synchroniser les valeurs depuis les controllers
    for (final l in _lines) {
      l.label = _labelControllers[l.id]?.text.trim() ?? l.label;
      l.value = _valueControllers[l.id]?.text.trim() ?? l.value;
    }

    await appState.saveInvoiceHeaderLines(_lines);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('En-tête de facture personnalisé enregistré avec succès !'),
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
              const Column(
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

          // 3. BOUTON ENREGISTRER
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

