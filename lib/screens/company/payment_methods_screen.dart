import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final appState = AppState.instance;

  bool _isAdding = false;
  String _selectedType = 'Mobile Money'; // 'Mobile Money', 'Banque', 'Carte'
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    final isDark = appState.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
            const SizedBox(width: 8),
            Text('Comptes de paiement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          ],
        ),
        content: Text(
          'Les comptes de paiement vous permettent de suivre précisément les encaissements par canal (Espèces, Mobile Money, Carte, Virement). Chaque vente alimente le compte sélectionné lors du passage en caisse.',
          style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fermer', style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _addAccount() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final newAcc = PaymentAccount(
        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
        title: name,
        balance: 0.0,
        type: _selectedType,
        isActive: true,
      );
      await appState.addPaymentAccount(newAcc);
      _nameController.clear();
      setState(() {
        _isAdding = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte "$name" ajouté avec succès'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    }
  }

  String _getHintText() {
    switch (_selectedType) {
      case 'Banque':
        return 'Nom (ex. Ecobank, Afriland, Virement)';
      case 'Carte':
        return 'Nom (ex. Carte Visa, Mastercard, TPE)';
      case 'Mobile Money':
      default:
        return 'Nom (ex. Orange Money, Wave, MTN MoMo)';
    }
  }

  // MODALE CAISSE
  void _showCashDeskModal(BuildContext context, CashDesk desk) {
    String activeTab = 'Solde initial';
    final initialBalanceCtrl = TextEditingController(
      text: desk.balance > 0 ? desk.balance.toInt().toString() : '',
    );
    final initialReasonCtrl = TextEditingController();

    final adjustCountedCtrl = TextEditingController(
      text: desk.balance.toInt().toString(),
    );
    final adjustReasonCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        final isDark = appState.isDarkMode;
        return StatefulBuilder(
          builder: (modalCtx, setDlgState) {
            final isInitial = activeTab == 'Solde initial';

            return Dialog(
              backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        desk.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280), width: 0.9),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setDlgState(() => activeTab = 'Solde initial'),
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isInitial
                                        ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFED7AA))
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Solde initial',
                                      style: TextStyle(
                                        fontWeight: isInitial ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 13.5,
                                        color: isInitial
                                            ? (isDark ? AppTheme.accentGold : const Color(0xFF111827))
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 0.9, color: isDark ? const Color(0xFF334155) : const Color(0xFF6B7280)),
                            Expanded(
                              child: InkWell(
                                onTap: () => setDlgState(() => activeTab = 'Ajuster'),
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !isInitial
                                        ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFED7AA))
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Ajuster',
                                      style: TextStyle(
                                        fontWeight: !isInitial ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 13.5,
                                        color: !isInitial
                                            ? (isDark ? AppTheme.accentGold : const Color(0xFF111827))
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        isInitial
                            ? 'À définir une seule fois — le solde de départ du compte.'
                            : 'Saisissez le solde réel compté ; l\'écart est enregistré.',
                        style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280), height: 1.35),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Solde actuel: ${AppTheme.formatFCFA(desk.balance)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.accentGold : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (isInitial) ...[
                        TextField(
                          controller: initialBalanceCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Solde initial',
                            labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                            hintText: '0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          onChanged: (_) => setDlgState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: initialReasonCtrl,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Motif (optionnel)',
                            labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: adjustCountedCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Solde réel compté',
                            labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                            hintText: '0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          onChanged: (_) => setDlgState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: adjustReasonCtrl,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Motif (obligatoire)',
                            labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                            hintText: 'Ex: Contrôle fond de caisse fin de journée',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          onChanged: (_) => setDlgState(() {}),
                        ),
                      ],
                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? const Color(0xFF94A3B8) : AppTheme.primaryNavy,
                                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canConfirm(isInitial, initialBalanceCtrl.text, adjustCountedCtrl.text, adjustReasonCtrl.text)
                                    ? (isDark ? AppTheme.accentGold : AppTheme.primaryNavy)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                                foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: _canConfirm(isInitial, initialBalanceCtrl.text, adjustCountedCtrl.text, adjustReasonCtrl.text)
                                  ? () async {
                                      if (isInitial) {
                                        final newAmt = double.tryParse(initialBalanceCtrl.text.trim()) ?? 0.0;
                                        await appState.setCashDeskInitialBalance(
                                          desk.id,
                                          newAmt,
                                          reason: initialReasonCtrl.text.trim(),
                                        );
                                      } else {
                                        final countedAmt = double.tryParse(adjustCountedCtrl.text.trim()) ?? 0.0;
                                        await appState.adjustCashDeskBalance(
                                          desk.id,
                                          countedAmt,
                                          reason: adjustReasonCtrl.text.trim(),
                                        );
                                      }
                                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppTheme.primaryNavy,
                                            content: Text('Solde de ${desk.name} mis à jour avec succès'),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // MODALE COMPTE DE PAIEMENT PERSONNALISÉ
  void _showPaymentAccountModal(BuildContext context, PaymentAccount acc) {
    final isDark = appState.isDarkMode;
    final balanceCtrl = TextEditingController(text: acc.balance.toInt().toString());

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          acc.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${acc.type}',
              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 6),
            Text(
              'Solde actuel: ${AppTheme.formatFCFA(acc.balance)}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppTheme.accentGold : const Color(0xFF111827)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: balanceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Nouveau solde (FCFA)',
                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Annuler', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
              foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final newBal = double.tryParse(balanceCtrl.text.trim()) ?? acc.balance;
              await appState.updatePaymentAccountBalance(acc.id, newBal);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Solde de "${acc.title}" mis à jour')),
                );
              }
            },
            child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool _canConfirm(bool isInitial, String initVal, String adjustVal, String adjustReason) {
    if (isInitial) {
      return initVal.trim().isNotEmpty && double.tryParse(initVal.trim()) != null;
    } else {
      return adjustVal.trim().isNotEmpty &&
          double.tryParse(adjustVal.trim()) != null &&
          adjustReason.trim().isNotEmpty;
    }
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'banque':
        return Icons.account_balance;
      case 'carte':
        return Icons.credit_card;
      case 'mobile money':
      default:
        return Icons.phone_android;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final desks = appState.cashDesks;
        final customAccounts = appState.paymentAccounts;

        return Scaffold(
          backgroundColor: Colors.white,
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
              'Comptes de paiement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: _showHelpDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.help_outline, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Les comptes de paiement déterminent les options proposées en caisse et où atterrit l\'argent. Les caisses (espèces) sont créées automatiquement avec chaque caisse.',
                style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
              ),
              const SizedBox(height: 16),

              // 1. LISTE DES CAISSES (Espèces)
              ...desks.map((desk) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 24, color: Color(0xFF1F2937)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre avec troncature sécurisée pour éliminer tout overflow
                            Text(
                              desk.storeName.isNotEmpty ? '${desk.name} · ${desk.storeName}' : desk.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppTheme.formatFCFA(desk.balance),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Icône modifier / ajuster le solde
                      InkWell(
                        onTap: () => _showCashDeskModal(context, desk),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.edit_note, size: 24, color: Color(0xFF4B5563)),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // 2. LISTE DES AUTRES COMPTES (Mobile Money, Carte, Banque, etc.)
              ...customAccounts.map((acc) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(_iconForType(acc.type), size: 24, color: const Color(0xFF1F2937)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    acc.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    acc.type,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppTheme.formatFCFA(acc.balance),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Modifier le solde
                      InkWell(
                        onTap: () => _showPaymentAccountModal(context, acc),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.edit_note, size: 22, color: Color(0xFF4B5563)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Supprimer / Archiver
                      IconButton(
                        icon: const Icon(Icons.archive_outlined, size: 18, color: Color(0xFF6B7280)),
                        tooltip: 'Archiver le compte',
                        onPressed: () {
                          final isDark = appState.isDarkMode;
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('Archiver le compte ?', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                              content: Text('Voulez-vous archiver le compte de paiement "${acc.title}" ?', style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Annuler', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280))),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                                  onPressed: () {
                                    appState.removePaymentAccount(acc.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Archiver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 6),
              Builder(builder: (_) {
                final now = DateTime.now();
                final dStr = '${now.day.toString().padLeft(2, "0")}/${now.month.toString().padLeft(2, "0")}/${now.year} à ${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}';
                return Text(
                  'Soldes actualisés au $dStr',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                );
              }),
              const SizedBox(height: 16),

              // 3. FORMULAIRE D'AJOUT DE COMPTE PERSONNALISÉ
              if (_isAdding) ...[
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF9CA3AF)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedType = 'Mobile Money'),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: _selectedType == 'Mobile Money' ? const Color(0xFFFEF3C7) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                            ),
                            child: const Center(
                              child: Text('Mobile Money', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 46, color: const Color(0xFF9CA3AF)),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedType = 'Banque'),
                          child: Container(
                            height: 46,
                            color: _selectedType == 'Banque' ? const Color(0xFFFEF3C7) : Colors.transparent,
                            child: const Center(
                              child: Text('Banque', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 46, color: const Color(0xFF9CA3AF)),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedType = 'Carte'),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: _selectedType == 'Carte' ? const Color(0xFFFEF3C7) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                            ),
                            child: const Center(
                              child: Text('Carte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _nameController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _getHintText(),
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isAdding = false;
                            _nameController.clear();
                          });
                        },
                        child: const Text('Annuler', style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _nameController.text.trim().isNotEmpty ? AppTheme.primaryNavy : const Color(0xFFD1D5DB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          onPressed: _nameController.text.trim().isNotEmpty ? _addAccount : null,
                          child: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF4B5563), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => setState(() => _isAdding = true),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Color(0xFF111827), size: 18),
                      SizedBox(width: 8),
                      Text('Ajouter un compte', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
