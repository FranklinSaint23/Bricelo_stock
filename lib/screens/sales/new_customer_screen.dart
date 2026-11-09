import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/widgets/widgets.dart';

class NewCustomerScreen extends StatefulWidget {
  const NewCustomerScreen({super.key});

  @override
  State<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  final appState = AppState.instance;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final customer = Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );

      appState.addCustomer(customer);
      Navigator.pop(context, customer);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le nom du client est obligatoire'.tr),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? AppTheme.darkScaffold : Colors.white;
        final barBg = isDark ? AppTheme.darkSurface : Colors.white;
        final borderCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Nouveau client'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            children: [
              StockTextField(
                controller: _nameController,
                hintText: '${'Nom complet'.tr} *',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              StockTextField(
                controller: _phoneController,
                hintText: 'Téléphone'.tr,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              StockTextField(
                controller: _emailController,
                hintText: 'Email'.tr,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              StockTextField(
                controller: _addressController,
                hintText: 'Adresse'.tr,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              StockTextField(
                controller: _notesController,
                hintText: 'Notes'.tr,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: barBg,
              border: Border(top: BorderSide(color: borderCol, width: 1)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _saveCustomer,
                    child: Text('Créer'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
