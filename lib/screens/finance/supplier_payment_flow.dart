import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class SupplierPaymentScreen extends StatefulWidget {
  final String supplierName;
  final String invoiceRef;
  final double remainingDebt;
  final String? debtId;

  const SupplierPaymentScreen({
    super.key,
    required this.supplierName,
    required this.invoiceRef,
    required this.remainingDebt,
    this.debtId,
  });

  @override
  State<SupplierPaymentScreen> createState() => _SupplierPaymentScreenState();
}

class _SupplierPaymentScreenState extends State<SupplierPaymentScreen> {
  final appState = AppState.instance;
  String _amountBuffer = '';
  String _selectedPaymentMethod = 'Caisse';
  DateTime _paymentDate = DateTime.now();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountBuffer = widget.remainingDebt > 0 ? widget.remainingDebt.toInt().toString() : '0';
    _selectedPaymentMethod = 'Caisse ${appState.currentStore}';
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _enteredAmount {
    if (_amountBuffer.isEmpty) return 0.0;
    return double.tryParse(_amountBuffer) ?? 0.0;
  }

  void _onKeypadTap(String val) {
    setState(() {
      if (val == '⌫') {
        if (_amountBuffer.isNotEmpty) {
          _amountBuffer = _amountBuffer.substring(0, _amountBuffer.length - 1);
        }
      } else if (val == '00') {
        if (_amountBuffer.isNotEmpty && _amountBuffer.length < 9) {
          _amountBuffer += '00';
        }
      } else {
        if (_amountBuffer == '0') {
          _amountBuffer = val;
        } else if (_amountBuffer.length < 9) {
          _amountBuffer += val;
        }
      }
    });
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    return '$dd/$mm/$yyyy';
  }

  void _confirmPayment() {
    final amount = _enteredAmount;
    if (amount <= 0) return;

    if (widget.debtId != null) {
      appState.recordSupplierPayment(
        widget.debtId!,
        amount,
        paymentMethod: _selectedPaymentMethod,
        paymentDate: _paymentDate,
        note: _noteCtrl.text.trim(),
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierPaymentSuccessScreen(
          supplierName: widget.supplierName,
          amountPaid: amount,
          invoiceRef: widget.invoiceRef,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final amount = _enteredAmount;
    final cashBalance = appState.currentCashInDrawer;
    final isCashInsufficient = _selectedPaymentMethod.startsWith('Caisse') && (cashBalance < amount);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : const Color(0xFF0F172A), size: 16),
            ),
          ),
        ),
        title: Text(
          'Payer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            // 1. CARTE INFO FOURNISSEUR & FACTURE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.supplierName,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.invoiceRef,
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  Divider(height: 18, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reste à payer', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
                      Text(
                        '${widget.remainingDebt.toInt()} F CFA',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFFD97706)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. MONTANT AFFICHÉ
            Text('Montant', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '${_amountBuffer.isEmpty ? "0" : _amountBuffer} F CFA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            // 3. RACCOURCIS (Exact • X, +500, +1000)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => setState(() => _amountBuffer = widget.remainingDebt.toInt().toString()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Exact',
                      style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() => _amountBuffer = (_enteredAmount + 500).toInt().toString()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('+500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() => _amountBuffer = (_enteredAmount + 1000).toInt().toString()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('+1000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. PAVÉ NUMÉRIQUE (1-9, 00, 0, ⌫)
            _buildKeypad(),
            const SizedBox(height: 14),

            // 5. MODE DE PAIEMENT
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mode de paiement',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodCard(
                    icon: Icons.payments_outlined,
                    title: 'Caisse ${appState.currentStore}',
                    balance: '${cashBalance.toInt()} F CFA',
                    selected: _selectedPaymentMethod.startsWith('Caisse'),
                    onTap: () => setState(() => _selectedPaymentMethod = 'Caisse ${appState.currentStore}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPaymentMethodCard(
                    icon: Icons.phone_android_rounded,
                    title: 'Mobile Money',
                    balance: '0 F CFA',
                    selected: _selectedPaymentMethod == 'Mobile Money',
                    onTap: () => setState(() => _selectedPaymentMethod = 'Mobile Money'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPaymentMethodCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Carte',
                    balance: '0 F CFA',
                    selected: _selectedPaymentMethod == 'Carte',
                    onTap: () => setState(() => _selectedPaymentMethod = 'Carte'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 6. ALERTE SOLDE INSUFFISANT (Exact comme dans la capture)
            if (isCashInsufficient) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF451A03) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solde estimé insuffisant (${cashBalance.toInt()} F CFA). Vous pouvez continuer.',
                        style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 7. DATE DU PAIEMENT (Conforme Image 4)
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _paymentDate = picked);
              },
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date du paiement',
                  labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  suffixIcon: Icon(Icons.calendar_month_outlined, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                child: Text(
                  _formatDate(_paymentDate),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 8. NOTE (OPTIONNEL)
            TextField(
              controller: _noteCtrl,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Note (optionnel)',
                hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                filled: isDark,
                fillColor: isDark ? const Color(0xFF162540) : Colors.transparent,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // 9. BOUTON CONFIRMER LE PAIEMENT
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: AppTheme.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.payments_rounded, size: 18, color: AppTheme.primaryNavy),
                label: Text(
                  'Confirmer le paiement • ${amount.toInt()} F CFA',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                onPressed: amount > 0 ? _confirmPayment : null,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final isDark = appState.isDarkMode;
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['00', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: row.map((k) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => _onKeypadTap(k),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black12,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: k == '⌫'
                            ? Icon(Icons.backspace_outlined, size: 18, color: isDark ? Colors.white : const Color(0xFF0F172A))
                            : Text(
                                k,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String balance,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = appState.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? const Color(0xFF382305) : const Color(0xFFFFFBEB))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppTheme.accentGold : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), size: 18),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: selected ? (isDark ? AppTheme.accentGold : AppTheme.primaryNavy) : (isDark ? Colors.white : const Color(0xFF0F172A)))),
            Text(balance, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ÉCRAN SUCCÈS : PAIEMENT ENREGISTRÉ (media_1793841990313_91a8f7b7.jpg)
// ==========================================
class SupplierPaymentSuccessScreen extends StatelessWidget {
  final String supplierName;
  final double amountPaid;
  final String invoiceRef;

  const SupplierPaymentSuccessScreen({
    super.key,
    required this.supplierName,
    required this.amountPaid,
    required this.invoiceRef,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppState.instance.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : const Color(0xFF0F172A), size: 16),
            ),
          ),
        ),
        title: Text(
          'Paiement enregistré.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF382305) : const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_circle_rounded, color: AppTheme.accentGold, size: 54),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${amountPaid.toInt()} F CFA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Payé à $supplierName',
              style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Faites signer la décharge par le fournisseur, puis joignez la preuve.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const Spacer(),

            // 1. Imprimer la décharge
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: AppTheme.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.print_rounded, size: 18, color: AppTheme.primaryNavy),
                label: const Text('Imprimer la décharge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Décharge $invoiceRef envoyée à l\'imprimante !')),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // 2. Ajouter la preuve signée
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : AppTheme.primaryNavy,
                  side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Ajouter la preuve signée', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo de la décharge signée ajoutée')),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 3. Terminé
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Terminé', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
