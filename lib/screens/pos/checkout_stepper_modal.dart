import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/pos/shift_dialog_helper.dart';
import 'package:stock_prime/screens/sales/new_customer_screen.dart';
import 'package:stock_prime/screens/sales/sale_detail_screen.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/widgets/sale_receipt_dialog.dart';

class CheckoutStepperModal extends StatefulWidget {
  const CheckoutStepperModal({super.key});

  static Future<void> show(BuildContext context) async {
    final state = AppState.instance;
    if (state.isShiftsTrackingEnabled && state.activeCashShift == null) {
      final opened = await ShiftDialogHelper.showOpenShiftDialog(context);
      if (!opened) return;
    }
    if (!context.mounted) return;
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
  final DateTime _saleDate = DateTime.now();
  final _noteCtrl = TextEditingController();

  // Step 2: Client data
  Customer? _selectedCustomer;
  final _clientSearchCtrl = TextEditingController();

  // Step 3: Payment data
  String _selectedPaymentMethod = 'Caisse';
  bool _isCredit = false;
  String _amountBuffer = '';
  Sale? _completedSale;

  @override
  void initState() {
    super.initState();
    _amountBuffer = _calculatedTotal.toInt().toString();
    _selectedPaymentMethod = 'Caisse ${appState.currentStore}';
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
    if (appState.isDiscoveredPlan && appState.isMonthlySalesQuotaReached) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Plafond Découverte atteint',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
                ),
              ),
            ],
          ),
          content: Text(
            'Vous avez atteint le plafond mensuel de 50 ventes de la formule Découverte (${appState.currentMonthSalesCount}/50 ventes ce mois-ci).\n\n'
            'Pour continuer à enregistrer vos ventes en illimité et retirer le filigrane, passez à la Formule Pro sur le portail web.',
            style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Compris', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            ),
          ],
        ),
      );
      return;
    }

    final total = _calculatedTotal;
    final received = _isCredit ? _enteredAmount : (_enteredAmount >= total ? _enteredAmount : total);
    final change = _isCredit ? 0.0 : (received - total).clamp(0.0, double.infinity);

    final sale = appState.finalizeSale(
      paymentMethod: _isCredit ? 'À Crédit' : _selectedPaymentMethod,
      amountReceived: received,
      changeReturned: change,
      customerName: _selectedCustomer != null ? _selectedCustomer!.name : 'Client Comptoir',
      customerPhone: _selectedCustomer?.phone ?? '',
      overrideTotal: total,
      globalDiscount: _globalDiscount,
      saleDate: _saleDate,
    );

    setState(() {
      _completedSale = sale;
      _currentStep = 3; // Succès
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. TOP HEADER NAVY AVEC STEPPER GOLD
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: const BoxDecoration(
              color: AppTheme.primaryNavy,
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

                // BARRE D'INDICATEURS DU STEPPER
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
              color: isActive || isDone ? AppTheme.accentGold : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.accentGold : Colors.white60,
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
  // ÉTAPE 1 : RÉCAPITULATIF (Remise inline par produit max 50% + Offrir + Remise globale inline + Date stricte)
  // ==========================================
  Widget _buildStep1Recap(BuildContext context) {
    final isDark = appState.isDarkMode;
    final total = _calculatedTotal;
    final rawSubtotal = appState.cart.fold(0.0, (sum, i) => sum + i.subtotal);
    final itemsDiscountTotal = appState.cart.fold(0.0, (sum, i) => sum + i.discount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Liste des articles
        ...appState.cart.map((item) {
          final maxDiscount = (item.unitPrice / 2) * item.quantity;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.isGift ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: item.isGift ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (item.isGift) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('OFFERT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryNavy)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.isGift
                                ? '${item.quantity} x ${AppTheme.formatFCFA(item.unitPrice)} (Offert)'
                                : '${item.quantity} x ${AppTheme.formatFCFA(item.unitPrice)} = ${AppTheme.formatFCFA(item.subtotal)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: item.isGift ? AppTheme.accentGold : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              fontWeight: item.isGift ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), size: 22),
                      onPressed: () {
                        setState(() {
                          appState.updateCartQuantity(item, -1);
                          _amountBuffer = _calculatedTotal.toInt().toString();
                        });
                      },
                    ),
                    Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 22),
                      onPressed: () {
                        final ok = appState.updateCartQuantity(item, 1);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFDC2626),
                              content: Text('Stock insuffisant ! Le stock disponible pour "${item.product.name}" est de ${appState.getAvailableStockForProduct(item.product)}.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          setState(() {
                            _amountBuffer = _calculatedTotal.toInt().toString();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Ligne Actions : Bouton "Offrir" + Champ de saisie Remise inline (max 50%) + Total ligne
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton pour offrir ce produit
                    InkWell(
                      onTap: () {
                        setState(() {
                          item.isGift = !item.isGift;
                          if (item.isGift) {
                            item.discount = 0.0;
                          }
                          _amountBuffer = _calculatedTotal.toInt().toString();
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.isGift ? AppTheme.accentGold : (isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.isGift ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.isGift ? Icons.card_giftcard_rounded : Icons.card_giftcard_outlined,
                              size: 15,
                              color: item.isGift ? AppTheme.primaryNavy : (isDark ? Colors.white70 : const Color(0xFF475569)),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item.isGift ? 'Produit offert 🎁' : 'Offrir ce produit',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: item.isGift ? AppTheme.primaryNavy : (isDark ? Colors.white70 : const Color(0xFF334155)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Champ de remise inline à côté (seulement si non offert)
                    if (!item.isGift) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Remise :', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 95,
                            height: 34,
                            child: TextFormField(
                              initialValue: item.discount > 0 ? item.discount.toInt().toString() : '',
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy),
                              decoration: InputDecoration(
                                hintText: 'Max 50%',
                                hintStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                filled: isDark,
                                fillColor: isDark ? const Color(0xFF162540) : null,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppTheme.accentGold, width: 1.5)),
                                suffixText: 'F',
                                suffixStyle: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                              onChanged: (val) {
                                double entered = double.tryParse(val.trim()) ?? 0.0;
                                if (entered > maxDiscount) {
                                  entered = maxDiscount;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFFDC2626),
                                      content: Text('La remise ne peut pas dépasser 50% (${AppTheme.formatFCFA(maxDiscount)}).'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                                setState(() {
                                  item.discount = entered;
                                  _amountBuffer = _calculatedTotal.toInt().toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Total ligne
                    Text(
                      item.isGift ? '0 F CFA' : AppTheme.formatFCFA(item.total),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: item.isGift ? AppTheme.accentGold : (isDark ? Colors.white : AppTheme.primaryNavy),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),

        // Remise globale inline & Arrondir total
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.discount_outlined, size: 16, color: AppTheme.accentGold),
                    const SizedBox(width: 6),
                    Text('Remise globale :', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextFormField(
                        initialValue: _globalDiscount > 0 ? _globalDiscount.toInt().toString() : '',
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryNavy),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          suffixText: 'F CFA',
                          suffixStyle: TextStyle(fontSize: 10.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _globalDiscount = double.tryParse(val.trim()) ?? 0.0;
                            _amountBuffer = _calculatedTotal.toInt().toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.transparent,
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Arrondir', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    Switch(
                      value: _roundTotal,
                      activeThumbColor: AppTheme.accentGold,
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

        // Date de la vente (Stricte, imposée à aujourd'hui sans modification)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                'Date : ${DateTime.now().day.toString().padLeft(2, "0")}/${DateTime.now().month.toString().padLeft(2, "0")}/${DateTime.now().year} (Aujourd\'hui)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Résumé financier
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sous-total brut', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13)),
                  Text(AppTheme.formatFCFA(rawSubtotal), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                ],
              ),
              if (itemsDiscountTotal > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Remises sur produits', style: TextStyle(color: Color(0xFFD97706), fontSize: 13)),
                    Text('-${AppTheme.formatFCFA(itemsDiscountTotal)}', style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              if (_globalDiscount > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Remise globale', style: TextStyle(color: Colors.red, fontSize: 13)),
                    Text('-${AppTheme.formatFCFA(_globalDiscount)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              Divider(height: 18, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppTheme.primaryNavy)),
                  Text(AppTheme.formatFCFA(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: AppTheme.accentGold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Notes
        TextField(
          controller: _noteCtrl,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Note pour la commande (optionnel)...',
            hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            filled: isDark,
            fillColor: isDark ? const Color(0xFF162540) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),

        // Bouton Suivant (Gold background avec texte Navy)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.primaryNavy,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(() => _currentStep = 1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Suivant', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.primaryNavy),
              ],
            ),
          ),
        ),
      ],
    );
  }



  // ==========================================
  // ÉTAPE 2 : CLIENT
  // ==========================================
  Widget _buildStep2Client(BuildContext context) {
    final isDark = appState.isDarkMode;
    final search = _clientSearchCtrl.text.trim().toLowerCase();
    final filteredClients = appState.customers.where((c) {
      if (search.isEmpty) return true;
      return c.name.toLowerCase().contains(search) || c.phone.contains(search);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Associer un client (optionnel)',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),

        // Bouton "+ Nouveau client" (Gold light)
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF431407) : const Color(0xFFFED7AA),
              foregroundColor: isDark ? AppTheme.accentGold : const Color(0xFF9A3412),
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
              foregroundColor: isDark ? Colors.white : AppTheme.primaryNavy,
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
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
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Rechercher un client',
            hintStyle: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            filled: isDark,
            fillColor: isDark ? const Color(0xFF162540) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Liste des clients
        if (filteredClients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Aucun client trouvé', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
            ),
          )
        else
          ...filteredClients.map((c) {
            final isSel = _selectedCustomer?.id == c.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSel
                    ? (isDark ? const Color(0xFF382305) : const Color(0xFFFFFBEB))
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSel ? AppTheme.accentGold : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: ListTile(
                dense: true,
                onTap: () => setState(() => _selectedCustomer = c),
                leading: CircleAvatar(
                  backgroundColor: isSel
                      ? AppTheme.accentGold
                      : (isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9)),
                  foregroundColor: isSel
                      ? AppTheme.primaryNavy
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                subtitle: Text(c.phone.isNotEmpty ? c.phone : 'Sans téléphone', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                trailing: isSel ? const Icon(Icons.check_circle, color: AppTheme.accentGold) : null,
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
                  foregroundColor: isDark ? Colors.white70 : AppTheme.primaryNavy,
                  side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
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
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: AppTheme.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => setState(() => _currentStep = 2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Suivant', style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primaryNavy),
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
  // ÉTAPE 3 : PAIEMENT
  // ==========================================
  Widget _buildStep3Payment(BuildContext context) {
    final isDark = appState.isDarkMode;
    final total = _calculatedTotal;

    return Column(
      children: [
        // Total à payer
        Text(
          'Total à payer : ${AppTheme.formatFCFA(total)}',
          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),

        // Montant affiché
        Text(
          '${_amountBuffer.isEmpty ? "0" : _amountBuffer} F CFA',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: isDark ? Colors.white : AppTheme.primaryNavy),
        ),
        const SizedBox(height: 10),

        // Vente à crédit toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isCredit
                ? (isDark ? const Color(0xFF382305) : const Color(0xFFFEF3C7))
                : (isDark ? const Color(0xFF162540) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Régler plus tard (Vente à crédit)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              Switch(
                value: _isCredit,
                activeThumbColor: const Color(0xFFD97706),
                onChanged: (v) => setState(() => _isCredit = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Raccourcis monnaie exacte / +500 / +1000 (Gold theme)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => setState(() => _amountBuffer = total.toInt().toString()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Exact • ${total.toInt()}',
                  style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => setState(() => _amountBuffer = (_enteredAmount + 500).toInt().toString()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('+500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => setState(() => _amountBuffer = (_enteredAmount + 1000).toInt().toString()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('+1000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
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
          child: Text('Mode de paiement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700])),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodCard(
                icon: Icons.payments_outlined,
                title: 'Caisse ${appState.currentStore}',
                balance: AppTheme.formatFCFA(appState.currentCashInDrawer),
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
        const SizedBox(height: 18),

        // Bouton Confirmer la vente (Gold background avec texte Navy)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.primaryNavy,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.primaryNavy),
            label: Text(
              'Confirmer la vente • ${AppTheme.formatFCFA(total)}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryNavy),
            ),
            onPressed: _confirmSale,
          ),
        ),
      ],
    );
  }

  Widget _buildNumericKeypad() {
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
        padding: const EdgeInsets.all(10),
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
            Icon(icon, color: selected ? AppTheme.accentGold : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: selected
                    ? (isDark ? AppTheme.accentGold : const Color(0xFFB45309))
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            Text(balance, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ÉTAPE 4 : SUCCÈS (Gold Theme)
  // ==========================================
  Widget _buildStep4Success(BuildContext context) {
    final isDark = appState.isDarkMode;
    final sale = _completedSale;
    if (sale == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 20),
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
        const SizedBox(height: 16),
        Text(
          'Vente réussie !',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        Text(
          'Réf : ${sale.historyReference}',
          style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${AppTheme.formatFCFA(sale.total)} • ${sale.paymentMethod}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.primaryNavy),
        ),
        const SizedBox(height: 28),

        // 1. Imprimer la facture
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.primaryNavy,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.print_rounded, size: 18, color: AppTheme.primaryNavy),
            label: const Text('Imprimer la facture', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
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
              foregroundColor: isDark ? Colors.white : AppTheme.primaryNavy,
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
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
          child: const Text('Nouvelle vente', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 15)),
        ),
      ],
    );
  }
}
