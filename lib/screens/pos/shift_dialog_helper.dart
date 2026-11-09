import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ShiftDialogHelper {
  /// Ouvre la modale pour démarrer un shift de caisse
  static Future<bool> showOpenShiftDialog(BuildContext context) async {
    final appState = AppState.instance;
    final isCashier = appState.userRole.toLowerCase() == 'caissier';
    final cashiers = appState.teamMembers.isNotEmpty
        ? appState.teamMembers.map((m) => m.name).toList()
        : [appState.displayUserName];
    String selectedCashier = (isCashier && cashiers.contains(appState.displayUserName))
        ? appState.displayUserName
        : cashiers.first;

    final desks = appState.cashDesks.isNotEmpty
        ? appState.cashDesks.map((d) => d.name).toList()
        : ['Caisse Principale'];
    String selectedDesk = (isCashier && appState.userAssignedCashDesk != null && desks.contains(appState.userAssignedCashDesk))
        ? appState.userAssignedCashDesk!
        : desks.first;

    final openingCashCtrl = TextEditingController(text: '0');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.point_of_sale, color: AppTheme.primaryNavy),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ouvrir un shift de caisse',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Un shift de caisse doit être ouvert avant d\'encaisser les ventes.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedCashier,
                      decoration: InputDecoration(
                        labelText: 'Caissier responsable',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: cashiers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setDlgState(() => selectedCashier = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDesk,
                      decoration: InputDecoration(
                        labelText: 'Poste de caisse',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: desks.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (val) {
                        if (val != null) setDlgState(() => selectedDesk = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: openingCashCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fond de caisse initial (FCFA) *',
                        hintText: '0',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final openAmt = double.tryParse(openingCashCtrl.text.trim()) ?? 0.0;
                    await appState.openCashShift(
                      cashierName: selectedCashier,
                      cashDeskName: selectedDesk,
                      storeName: appState.currentStore,
                      openingCash: openAmt,
                    );
                    if (ctx.mounted) Navigator.pop(ctx, true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Shift de caisse ouvert pour $selectedCashier !'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  child: const Text('Démarrer le shift', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  /// Ouvre la modale pour clôturer un shift de caisse en cours
  static Future<bool> showCloseShiftDialog(BuildContext context, CashShift shift) async {
    final appState = AppState.instance;
    final expectedTotal = shift.openingCash + shift.cashSalesTotal;
    final countedCtrl = TextEditingController(text: expectedTotal.toInt().toString());
    final noteCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            final counted = double.tryParse(countedCtrl.text.trim()) ?? 0.0;
            final discrepancy = counted - expectedTotal;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.lock_clock, color: AppTheme.primaryNavy),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fermer le shift (Faire la caisse)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Caissier :', shift.cashierName),
                          const SizedBox(height: 4),
                          _buildDetailRow(
                            'Poste de caisse :',
                            shift.storeName.isNotEmpty && !shift.cashDeskName.toLowerCase().contains(shift.storeName.toLowerCase())
                                ? '${shift.cashDeskName} · ${shift.storeName}'
                                : shift.cashDeskName,
                          ),
                          const SizedBox(height: 4),
                          _buildDetailRow('Fond initial :', AppTheme.formatFCFA(shift.openingCash)),
                          const SizedBox(height: 4),
                          _buildDetailRow('Ventes espèces décomptées :', AppTheme.formatFCFA(shift.cashSalesTotal)),
                          const Divider(height: 12),
                          _buildDetailRow(
                            'Total théorique attendu :',
                            AppTheme.formatFCFA(expectedTotal),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: countedCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDlgState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Espèces réelles comptées (FCFA) *',
                        hintText: '0',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: discrepancy == 0
                            ? const Color(0xFFD1FAE5)
                            : (discrepancy > 0 ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              discrepancy == 0
                                  ? 'Caisse parfaite (Aucun écart)'
                                  : (discrepancy > 0 ? 'Excédent de caisse :' : 'Déficit de caisse :'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: discrepancy == 0
                                    ? const Color(0xFF065F46)
                                    : (discrepancy > 0 ? const Color(0xFF1E40AF) : const Color(0xFF991B1B)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppTheme.formatFCFA(discrepancy.abs()),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: discrepancy == 0
                                  ? const Color(0xFF065F46)
                                  : (discrepancy > 0 ? const Color(0xFF1E40AF) : const Color(0xFF991B1B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Remarque de fin de service (optionnel)',
                        hintText: 'Ex: Billet déchiré, rendu monnaie...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx, true);
                    await appState.closeCashShift(
                      closingCashCounted: counted,
                      note: noteCtrl.text.trim(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shift de caisse clôturé avec succès.'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  child: const Text('Fermer le shift', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  static Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: const Color(0xFF4B5563),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: const Color(0xFF111827),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

