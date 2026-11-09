import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/services/translations.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ShiftDialogHelper {
  /// Ouvre la modale pour démarrer un shift de caisse
  static Future<bool> showOpenShiftDialog(BuildContext context) async {
    final appState = AppState.instance;
    final isDark = appState.isDarkMode;
    final isCashier = appState.isCashierAccount || appState.userRole.toLowerCase() == 'caissier';
    final cashiers = appState.teamMembers.isNotEmpty
        ? appState.teamMembers.map((m) => m.name).toList()
        : [appState.displayUserName];
    if (isCashier && !cashiers.contains(appState.displayUserName)) {
      cashiers.insert(0, appState.displayUserName);
    }
    String selectedCashier = isCashier
        ? appState.displayUserName
        : (cashiers.contains(appState.displayUserName) ? appState.displayUserName : cashiers.first);

    final desks = appState.cashDesks.isNotEmpty
        ? appState.cashDesks.map((d) => d.name).toList()
        : ['Caisse Principale'];
    if (appState.userAssignedCashDesk != null &&
        appState.userAssignedCashDesk!.isNotEmpty &&
        !desks.contains(appState.userAssignedCashDesk!)) {
      desks.insert(0, appState.userAssignedCashDesk!);
    }
    final isDeskAssigned = isCashier &&
        appState.userAssignedCashDesk != null &&
        appState.userAssignedCashDesk!.isNotEmpty;
    String selectedDesk = isDeskAssigned
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
              backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  const Icon(Icons.point_of_sale, color: AppTheme.accentGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ouvrir un shift de caisse'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Un shift de caisse doit être ouvert avant d\'encaisser les ventes.'.tr,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedCashier,
                      dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: isCashier ? FontWeight.bold : FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Caissier responsable'.tr,
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        filled: true,
                        fillColor: isCashier
                            ? (isDark ? const Color(0xFF0F1B2E) : const Color(0xFFF1F5F9))
                            : (isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        suffixIcon: isCashier
                            ? const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.lock_rounded, size: 18, color: Color(0xFF10B981)),
                              )
                            : null,
                        helperText: isCashier ? 'Caissier de session verrouillé (sécurité)'.tr : null,
                        helperStyle: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      items: cashiers
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A))),
                              ))
                          .toList(),
                      onChanged: isCashier
                          ? null
                          : (val) {
                              if (val != null) setDlgState(() => selectedCashier = val);
                            },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDesk,
                      dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: isDeskAssigned ? FontWeight.bold : FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Poste de caisse'.tr,
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        filled: true,
                        fillColor: isDeskAssigned
                            ? (isDark ? const Color(0xFF0F1B2E) : const Color(0xFFF1F5F9))
                            : (isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        suffixIcon: isDeskAssigned
                            ? const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.lock_rounded, size: 18, color: Color(0xFF10B981)),
                              )
                            : null,
                        helperText: isDeskAssigned ? 'Caisse attribuée'.tr : null,
                        helperStyle: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      items: desks
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A))),
                              ))
                          .toList(),
                      onChanged: isDeskAssigned
                          ? null
                          : (val) {
                              if (val != null) setDlgState(() => selectedDesk = val);
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: openingCashCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        labelText: '${'Fond de caisse initial'.tr} (FCFA) *',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        hintText: '0',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
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
                  child: Text(
                    'Annuler'.tr,
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final openAmt = double.tryParse(openingCashCtrl.text.trim()) ?? 0.0;
                    final effectiveStore = isCashier
                        ? appState.assignedStoreForCurrentUser
                        : appState.currentStore;
                    await appState.openCashShift(
                      cashierName: selectedCashier,
                      cashDeskName: selectedDesk,
                      storeName: effectiveStore,
                      openingCash: openAmt,
                    );
                    if (ctx.mounted) Navigator.pop(ctx, true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${'Shift de caisse ouvert pour'.tr} $selectedCashier !'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  child: Text('Démarrer le shift'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final isDark = appState.isDarkMode;
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
              backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  const Icon(Icons.lock_clock, color: AppTheme.accentGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fermer le shift (Faire la caisse)'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
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
                        color: isDark ? const Color(0xFF162540) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Caissier :'.tr, shift.cashierName, isDark: isDark),
                          const SizedBox(height: 4),
                          _buildDetailRow(
                            'Poste de caisse :'.tr,
                            shift.storeName.isNotEmpty && !shift.cashDeskName.toLowerCase().contains(shift.storeName.toLowerCase())
                                ? '${shift.cashDeskName} · ${shift.storeName}'
                                : shift.cashDeskName,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 4),
                          _buildDetailRow('Fond initial :'.tr, AppTheme.formatFCFA(shift.openingCash), isDark: isDark),
                          const SizedBox(height: 4),
                          _buildDetailRow('Ventes espèces décomptées :'.tr, AppTheme.formatFCFA(shift.cashSalesTotal), isDark: isDark),
                          Divider(height: 12, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                          _buildDetailRow(
                            'Total théorique attendu :'.tr,
                            AppTheme.formatFCFA(expectedTotal),
                            isBold: true,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: countedCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDlgState(() {}),
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        labelText: '${'Espèces réelles comptées'.tr} (FCFA) *',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        hintText: '0',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: discrepancy == 0
                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFD1FAE5))
                            : (discrepancy > 0
                                ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFDBEAFE))
                                : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEE2E2))),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              discrepancy == 0
                                  ? 'Caisse parfaite (Aucun écart)'.tr
                                  : (discrepancy > 0 ? 'Excédent de caisse :'.tr : 'Déficit de caisse :'.tr),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: discrepancy == 0
                                    ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                                    : (discrepancy > 0
                                        ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF))
                                        : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))),
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
                                  ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                                  : (discrepancy > 0
                                      ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF))
                                      : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        labelText: 'Remarque de fin de service (optionnel)'.tr,
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        hintText: 'Ex: Billet déchiré, rendu monnaie...'.tr,
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
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
                  child: Text(
                    'Annuler'.tr,
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  ),
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
                        SnackBar(
                          content: Text('Shift de caisse clôturé avec succès.'.tr),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  child: Text('Fermer le shift'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  static Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isDark = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
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
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
