import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';

class NewSupplierScreen extends StatefulWidget {
  const NewSupplierScreen({super.key});

  @override
  State<NewSupplierScreen> createState() => _NewSupplierScreenState();
}

class _NewSupplierScreenState extends State<NewSupplierScreen> {
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        contactName: _contactController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );

      AppState.instance.addSupplier(supplier);
      Navigator.pop(context, supplier);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nom * est obligatoire'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StockAppBar.white(
        title: 'Nouveau fournisseur',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          StockTextField(
            controller: _nameController,
            hintText: 'Nom *',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          StockTextField(
            controller: _contactController,
            hintText: 'Nom du contact',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          StockTextField(
            controller: _phoneController,
            hintText: 'Téléphone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          StockTextField(
            controller: _emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          StockTextField(
            controller: _addressController,
            hintText: 'Adresse',
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          StockTextField(
            controller: _notesController,
            hintText: 'Notes',
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: PrimaryButton(
              label: 'Créer',
              onPressed: _saveSupplier,
            ),
          ),
        ),
      ),
    );
  }
}
