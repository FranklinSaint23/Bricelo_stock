import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/sales/new_customer_screen.dart';
import 'package:stock_prime/screens/sales/sale_detail_screen.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/widgets/sale_receipt_dialog.dart';

class CheckoutStepperModal extends StatefulWidget {
  const CheckoutStepperModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CheckoutStepperModal(),
    );
  }

  @override
  State<CheckoutStepperModal> createState() => _CheckoutStepperModalState();
}

class _CheckoutStepperModalState extends State<CheckoutStepperModal> {
  final appState = AppState.instance;
  int _currentStep = 0; // 0: Recap, 1: Client, 2: Paiement, 3: Succes

  // Step 1: Recap data
  double _globalDiscount = 0.0;
  bool _roundTotal = false;
  DateTime _saleDate = DateTime.now();
  final _noteCtrl = TextEditingController();

  // Step 2: Client data
  Customer? _selectedCustomer;
  final _clientSearchCtrl = TextEditingController();

  // Step 3: Payment data
  String _selectedPaymentMethod = 'Caisse 1';
  bool _isCredit = false;
  String _amountBuffer = '';
  Sale? _completedSale;

  @override
  void initState() {
    super.initState();
    _amountBuffer = _calculatedTotal.toInt().toString();
    if (appState.cashDesks.isNotEmpty) {
      _selectedPaymentMethod = appState.cashDesks.first.name;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _clientSearchCtrl.dispose();
    super.dispose();
  }

  double get _calculatedTotal {
    double total = appState.cartTotal - _globalDiscount;
    if (_roundTotal) {
      total = (total / 100).ceil() * 100.0;
    }
    return total < 0 ? 0.0 : total;
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

  void _confirmSale() {
    final total = _calculatedTotal;
    final received = _isCredit ? _enteredAmount : (_enteredAmount >= total ? _enteredAmount : total);
    final change = _isCredit ? 0.0 : (received - total).clamp(0.0, double.infinity);

    final sale = appState.finalizeSale(
      paymentMethod: _isCredit ? 'À Crédit' : _selectedPaymentMethod,
      amountReceived: received,
      changeReturned: change,
      customerName: _selectedCustomer != null ? _selectedCustomer!.name : 'Client Comptoir',
      customerPhone: _selectedCustomer?.phone ?? '',
    );

    setState(() {
      _completedSale = sale;
      _currentStep = 3; // Succès
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. TOP HEADER GREEN / NAVY AVEC STEPPER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: const BoxDecoration(
              color: Color(0xFF14532D), // Green theme from screenshot
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      onPressed: _currentStep > 0 && _currentStep < 3
                          ? () => setState(() => _currentStep--)
                          : () => Navigator.pop(context),
                    ),
                    Text(
                      _currentStep == 0
                          ? 'Récapitulatif'
                          : _currentStep == 1
                              ? 'Client'
                              : _currentStep == 2
                                  ? 'Paiement'
                                  : 'Succès',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // BARRE D'INDICATEURS DU STEPPER (Recapitulatif | Client | Paiement | Succes)
                Row(
                  children: [
                    _buildStepIndicator(0, 'Recapitulatif'),
                    _buildStepConnector(0),
                    _buildStepIndicator(1, 'Client'),
                    _buildStepConnector(1),
                    _buildStepIndicator(2, 'Paiement'),
                    _buildStepConnector(2),
                    _buildStepIndicator(3, 'Succes'),
                  ],
                ),
              ],
            ),
          ),

          // 2. CORPS EN FONCTION DU STEP ACTIF
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: bottomInset + 16),
              child: _buildCurrentStepContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isActive || isDone ? const Color(0xFF86EFAC) : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : Colors.white60,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int stepIndex) {
    return const SizedBox(width: 4);
  }

  Widget _buildCurrentStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Recap(context);
      case 1:
        return _buildStep2Client(context);
      case 2:
        return _buildStep3Payment(context);
      case 3:
      default:
        return _buildStep4Success(context);
    }
  }

  // ==========================================
  // ÉTAPE 1 : RÉCAPITULATIF (media_1793841691097_efc9e29c.jpg)
  // ==========================================
  Widget _buildStep1Recap(BuildContext context) {
    final total = _calculatedTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Liste des articles
        ...appState.cart.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '${item.quantity} x ${AppTheme.formatFCFA(item.unitPrice)} = ${AppTheme.formatFCFA(item.total)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF64748B)),
                    onPressed: () {
                      setState(() {
                        appState.updateCartQuantity(item, -1);
                      });
                    },
                  ),
                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF15803D)),
                    onPressed: () {
                      setState(() {
                        appState.updateCartQuantity(item, 1);
                      });
                    },
                  ),
                ],
              ),
            )),
        const SizedBox(height: 10),

        // Remise globale & Arrondir total
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF15803D),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.discount_outlined, size: 16),
                label: Text(_globalDiscount > 0 ? 'Remise: -${_globalDiscount.toInt()}' : 'Remise globale', style: const TextStyle(fontSize: 12.5)),
                onPressed: () {
                  final discountCtrl = TextEditingController(text: _globalDiscount > 0 ? _globalDiscount.toInt().toString() : '');
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remise globale (F CFA)'),
                      content: TextField(
                        controller: discountCtrl,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Montant de remise'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D)),
                          onPressed: () {
                            setState(() {
                              _globalDiscount = double.tryParse(discountCtrl.text.trim()) ?? 0.0;
                              _amountBuffer = _calculatedTotal.toInt().toString();
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Appliquer', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Arrondir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Switch(
                      value: _roundTotal,
                      activeThumbColor: const Color(0xFF15803D),
                      onChanged: (v) {
                        setState(() {
                          _roundTotal = v;
                          _amountBuffer = _calculatedTotal.toInt().toString();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Date de la vente
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _saleDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _saleDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(
                      'Date : ${_saleDate.day.toString().padLeft(2, "0")}/${_saleDate.month.toString().padLeft(2, "0")}/${_saleDate.year}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Icon(Icons.edit_calendar_outlined, size: 16, color: Color(0xFF15803D)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Résumé financier
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sous-total', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  Text(AppTheme.formatFCFA(appState.cartTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              if (_globalDiscount > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Remise', style: TextStyle(color: Colors.red, fontSize: 13)),
                    Text('-${AppTheme.formatFCFA(_globalDiscount)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(AppTheme.formatFCFA(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF15803D))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Notes
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(
            hintText: 'Note pour la commande (optionnel)...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),

        // Bouton Suivant
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(() => _currentStep = 1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Suivant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ÉTAPE 2 : CLIENT (media_1793841778054_221be706.jpg)
  // ==========================================
  Widget _buildStep2Client(BuildContext context) {
    final search = _clientSearchCtrl.text.trim().toLowerCase();
    final filteredClients = appState.customers.where((c) {
      if (search.isEmpty) return true;
      return c.name.toLowerCase().contains(search) || c.phone.contains(search);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Associer un client (optionnel)',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 14),

        // Bouton "+ Nouveau client" (Beige/Gold)
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFED7AA), // Beige tint from screenshot
              foregroundColor: const Color(0xFF9A3412),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: const Text('Nouveau client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () async {
              final created = await Navigator.push<Customer>(
                context,
                MaterialPageRoute(builder: (_) => const NewCustomerScreen()),
              );
              if (created != null) {
                setState(() => _selectedCustomer = created);
              }
            },
          ),
        ),
        const SizedBox(height: 10),

        // Bouton "Continuer sans client"
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF14532D),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () {
              setState(() {
                _selectedCustomer = null;
                _currentStep = 2; // Pass to payment
              });
            },
            child: const Text('Continuer sans client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 14),

        // Recherche client
        TextField(
          controller: _clientSearchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Rechercher un client',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Liste des clients
        if (filteredClients.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Aucun client trouvé', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          )
        else
          ...filteredClients.map((c) {
            final isSel = _selectedCustomer?.id == c.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFFDCFCE7) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSel ? const Color(0xFF15803D) : const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                dense: true,
                onTap: () => setState(() => _selectedCustomer = c),
                leading: CircleAvatar(
                  backgroundColor: isSel ? const Color(0xFF15803D) : const Color(0xFFF1F5F9),
                  foregroundColor: isSel ? Colors.white : const Color(0xFF0F172A),
                  child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C'),
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.phone.isNotEmpty ? c.phone : 'Sans téléphone'),
                trailing: isSel ? const Icon(Icons.check_circle, color: Color(0xFF15803D)) : null,
              ),
            );
          }),
        const SizedBox(height: 20),

        // Boutons Retour / Suivant
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF14532D),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Retour', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14532D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => setState(() => _currentStep = 2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Suivant', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // ÉTAPE 3 : PAIEMENT (media_1793841783754_a6a48d9d.jpg & media_1793841789096_89788e60.jpg)
  // ==========================================
  Widget _buildStep3Payment(BuildContext context) {
    final total = _calculatedTotal;

    return Column(
      children: [
        // Total à payer
        Text(
          'Total à payer : ${AppTheme.formatFCFA(total)}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),

        // Montant affiché
        Text(
          '${_amountBuffer.isEmpty ? "0" : _amountBuffer} F CFA',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),

        // Vente à crédit toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isCredit ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Régler plus tard (Vente à crédit)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Switch(
                value: _isCredit,
                activeThumbColor: const Color(0xFFD97706),
                onChanged: (v) => setState(() => _isCredit = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Raccourcis monnaie exacte / +500 / +1000
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => setState(() => _amountBuffer = total.toInt().toString()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14532D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Exact • ${total.toInt()}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => setState(() => _amountBuffer = (_enteredAmount + 500).toInt().toString()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('+500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => setState(() => _amountBuffer = (_enteredAmount + 1000).toInt().toString()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('+1000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Pavé numérique 1-9, 00, 0, ⌫
        _buildNumericKeypad(),
        const SizedBox(height: 14),

        // Mode de paiement
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Mode de paiement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodCard(
                icon: Icons.payments_outlined,
                title: appState.cashDesks.isNotEmpty ? appState.cashDesks.first.name : 'Caisse 1',
                balance: AppTheme.formatFCFA(appState.currentCashInDrawer),
                selected: _selectedPaymentMethod.startsWith('Caisse'),
                onTap: () => setState(() => _selectedPaymentMethod = appState.cashDesks.isNotEmpty ? appState.cashDesks.first.name : 'Caisse 1'),
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
        const SizedBox(height: 18),

        // Bouton Confirmer la vente
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(
              'Confirmer la vente • ${AppTheme.formatFCFA(total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: _confirmSale,
          ),
        ),
      ],
    );
  }

  Widget _buildNumericKeypad() {
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                      ),
                      child: Center(
                        child: k == '⌫'
                            ? const Icon(Icons.backspace_outlined, size: 18, color: Color(0xFF0F172A))
                            : Text(
                                k,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF15803D) : const Color(0xFFE2E8F0), width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? const Color(0xFF15803D) : const Color(0xFF64748B), size: 20),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: selected ? const Color(0xFF15803D) : const Color(0xFF0F172A))),
            Text(balance, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ÉTAPE 4 : SUCCÈS (media_1793841789096_89788e60.jpg)
  // ==========================================
  Widget _buildStep4Success(BuildContext context) {
    final sale = _completedSale;
    if (sale == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 54),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Vente réussie !',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        Text(
          'Réf : ${sale.ticketNumber}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${AppTheme.formatFCFA(sale.total)} • ${sale.paymentMethod}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
        ),
        const SizedBox(height: 28),

        // 1. Imprimer le reçu
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text('Imprimer le reçu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () => SaleReceiptDialog.show(context, sale),
          ),
        ),
        const SizedBox(height: 10),

        // 2. Partager WhatsApp
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF25D366),
              side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Partager WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Reçu ${sale.ticketNumber} • Total: ${AppTheme.formatFCFA(sale.total)}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reçu copié pour WhatsApp !')),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // 3. Voir le détail
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryNavy,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Voir le détail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SaleDetailScreen(sale: sale)));
            },
          ),
        ),
        const SizedBox(height: 14),

        // 4. Nouvelle vente
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Nouvelle vente', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }
}
