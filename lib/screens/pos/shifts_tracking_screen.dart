import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/pos/shift_dialog_helper.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ShiftsTrackingScreen extends StatefulWidget {
  const ShiftsTrackingScreen({super.key});

  @override
  State<ShiftsTrackingScreen> createState() => _ShiftsTrackingScreenState();
}

class _ShiftsTrackingScreenState extends State<ShiftsTrackingScreen> {
  final appState = AppState.instance;

  void _showOpenShiftDialog() {
    ShiftDialogHelper.showOpenShiftDialog(context);
  }

  void _showCloseShiftDialog(CashShift shift) {
    ShiftDialogHelper.showCloseShiftDialog(context, shift);
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isEnabled = appState.isShiftsTrackingEnabled;
        final activeShift = appState.activeCashShift;
        final history = appState.cashShiftsHistory;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
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
              'Suivi des shifts (Caisse)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Suivi par service (shift)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 14),

              // OPTION 1: DESACTIVE
              InkWell(
                onTap: () => appState.setShiftsTrackingEnabled(false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: !isEnabled ? const Color(0xFFFEF3C7) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !isEnabled ? AppTheme.accentGold : const Color(0xFFE5E7EB),
                      width: !isEnabled ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        !isEnabled ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: !isEnabled ? AppTheme.primaryNavy : const Color(0xFF9CA3AF),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Désactivé',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Aucune mention de service dans le POS. Recommandé pour les boutiques solo.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // OPTION 2: ACTIVE
              InkWell(
                onTap: () => appState.setShiftsTrackingEnabled(true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isEnabled ? const Color(0xFFFEF3C7) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEnabled ? AppTheme.accentGold : const Color(0xFFE5E7EB),
                      width: isEnabled ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isEnabled ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isEnabled ? AppTheme.primaryNavy : const Color(0xFF9CA3AF),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activé',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Le caissier ouvre un service (caisse) avant de vendre, puis le clôture pour faire la caisse.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isEnabled) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                // SECTION SHIFT ACTIF
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Session de caisse en cours',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    if (activeShift != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.fiber_manual_record, size: 10, color: Color(0xFF059669)),
                            SizedBox(width: 4),
                            Text('En cours', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (activeShift != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF059669).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin, color: AppTheme.primaryNavy, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeShift.cashierName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                                  ),
                                  Text(
                                    '${activeShift.cashDeskName} · ${activeShift.storeName}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        _buildDetailRow('Heure d\'ouverture :', '${activeShift.openedAt.day.toString().padLeft(2, "0")}/${activeShift.openedAt.month.toString().padLeft(2, "0")} à ${activeShift.openedAt.hour.toString().padLeft(2, "0")}:${activeShift.openedAt.minute.toString().padLeft(2, "0")}'),
                        const SizedBox(height: 6),
                        _buildDetailRow('Fond de caisse initial :', AppTheme.formatFCFA(activeShift.openingCash)),
                        const SizedBox(height: 6),
                        _buildDetailRow('Ventes espèces encaissées :', AppTheme.formatFCFA(activeShift.cashSalesTotal)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildDetailRow(
                            'Espèces théoriques en caisse :',
                            AppTheme.formatFCFA(activeShift.openingCash + activeShift.cashSalesTotal),
                            isBold: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.lock_clock, size: 18),
                            label: const Text('Clôturer le shift (Faire la caisse)', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _showCloseShiftDialog(activeShift),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 48, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 10),
                        const Text(
                          'Aucune session de caisse ouverte',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF374151)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ouvrez un shift pour enregistrer les encaissements sous un caissier précis.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text('Ouvrir un nouveau shift', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _showOpenShiftDialog,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                // HISTORIQUE DES SHIFTS
                const Text(
                  'Historique des shifts clôturés',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 10),

                if (history.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Center(
                      child: Text(
                        'Aucun shift clôturé enregistré pour le moment.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                ] else ...[
                  for (final shift in history)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  shift.cashierName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: shift.discrepancy == 0
                                      ? const Color(0xFFD1FAE5)
                                      : (shift.discrepancy > 0 ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  shift.discrepancy == 0
                                      ? 'Écart : 0 F'
                                      : (shift.discrepancy > 0
                                          ? '+${AppTheme.formatFCFA(shift.discrepancy)}'
                                          : '-${AppTheme.formatFCFA(shift.discrepancy.abs())}'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: shift.discrepancy == 0
                                        ? const Color(0xFF065F46)
                                        : (shift.discrepancy > 0 ? const Color(0xFF1E40AF) : const Color(0xFF991B1B)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${shift.cashDeskName} · ${shift.openedAt.day}/${shift.openedAt.month} ${shift.openedAt.hour}:${shift.openedAt.minute.toString().padLeft(2, "0")} → ${shift.closedAt != null ? "${shift.closedAt!.hour}:${shift.closedAt!.minute.toString().padLeft(2, "0")}" : ""}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Fond: ${AppTheme.formatFCFA(shift.openingCash)} · Ventes: ${AppTheme.formatFCFA(shift.cashSalesTotal)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Compté: ${AppTheme.formatFCFA(shift.closingCashCounted)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                            ],
                          ),
                          if (shift.note.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Note : ${shift.note}',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ],
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
