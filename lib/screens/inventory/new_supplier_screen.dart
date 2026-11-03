import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';

class NewSupplierScreen extends StatefulWidget {
  const NewSupplierScreen({super.key});

  @override
  State<NewSupplierScreen> createState() => _NewSupplierScreenState();
}

class _NewSupplierScreenState extends State<NewSupplierScreen> {
  final appState = AppState.instance;

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveSupplier() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final supplier = Supplier(
        id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        contactName: _contactController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );

      AppState.instance.addSupplier(supplier);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primaryNavy,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Fournisseur "$name" créé avec succès !',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pop(context, supplier);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le champ "Nom *" est obligatoire'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
      appBar: StockAppBar(
        title: 'Nouveau fournisseur',
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        titleColor: isDark ? Colors.white : const Color(0xFF111827),
        backButtonColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
        backIconColor: isDark ? Colors.white : const Color(0xFF111827),
        showBottomDivider: true,
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildField(
            controller: _nameController,
            hint: 'Nom *',
            textCapitalization: TextCapitalization.words,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _contactController,
            hint: 'Nom du contact',
            textCapitalization: TextCapitalization.words,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _phoneController,
            hint: 'Téléphone',
            keyboardType: TextInputType.phone,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _addressController,
            hint: 'Adresse',
            textCapitalization: TextCapitalization.sentences,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _notesController,
            hint: 'Notes',
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            isDark: isDark,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _saveSupplier,
                child: const Text(
                  'Créer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
          fontSize: 15,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.8),
        ),
      ),
    );
  }
}
