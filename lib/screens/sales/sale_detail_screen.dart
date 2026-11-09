import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:stock_prime/widgets/sale_receipt_dialog.dart';
import 'package:stock_prime/services/invoice_print_service.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailScreen({super.key, required this.sale});

  String _formatDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final pageBg = isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC);
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
        final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        final isCredit = sale.paymentMethod == 'À Crédit';
        final remainingDebt = (sale.total - sale.amountReceived).clamp(0.0, double.infinity);

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détail de la vente'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                ),
                Text(
                  sale.historyReference,
                  style: const TextStyle(fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? (isDark ? AppTheme.accentGold.withValues(alpha: 0.2) : const Color(0xFFFEF3C7))
                          : (isDark ? const Color(0xFF064E3B) : const Color(0xFFFFFBEB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (isCredit ? 'À Crédit' : 'Terminé').tr,
                      style: TextStyle(
                        color: isCredit
                            ? (isDark ? AppTheme.accentGold : const Color(0xFFB45309))
                            : (isDark ? const Color(0xFF34D399) : const Color(0xFFD97706)),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARTES BOUTIQUE & VENDEUR
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.storefront_outlined, size: 16, color: textSecondary),
                                const SizedBox(width: 6),
                                Text('Boutique'.tr, style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sale.storeName.isNotEmpty ? sale.storeName : appState.currentStore,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 16, color: textSecondary),
                                const SizedBox(width: 6),
                                Text('Vendeur'.tr, style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sale.cashierName.isNotEmpty ? sale.cashierName : appState.displayUserName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDateTime(sale.createdAt),
                              style: TextStyle(color: textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // TABLE DES ARTICLES
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Articles vendus'.tr,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textPrimary),
                          ),
                          Text(
                            '${sale.items.length} ${'article(s)'.tr}',
                            style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(height: 20, color: cardBorder),
                      ...sale.items.map((it) {
                        final prod = appState.products.firstWhereOrNull(
                          (p) => p.name.trim().toLowerCase() == it.productName.trim().toLowerCase(),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              ProductImageWidget(
                                imageUrl: prod?.imageUrl,
                                size: 34,
                                borderRadius: 6,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.productName,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: textPrimary),
                                    ),
                                    Text(
                                      '${AppTheme.formatFCFA(it.unitPrice)} / ${'unité'.tr}',
                                      style: TextStyle(fontSize: 11.5, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'x${it.quantity}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textSecondary),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                AppTheme.formatFCFA(it.total),
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // TOTALS CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryLine('Sous-total'.tr, AppTheme.formatFCFA(sale.subtotal), isDark: isDark),
                      if (sale.discountTotal > 0) ...[
                        const SizedBox(height: 6),
                        _buildSummaryLine('Remise'.tr, '-${AppTheme.formatFCFA(sale.discountTotal)}', valueColor: Colors.red, isDark: isDark),
                      ],
                      Divider(height: 20, color: cardBorder),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL'.tr,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary),
                          ),
                          Text(
                            AppTheme.formatFCFA(sale.total),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                      Divider(height: 20, color: cardBorder),
                      _buildSummaryLine('${'Payé'.tr} (${sale.paymentMethod.tr})', AppTheme.formatFCFA(sale.amountReceived), isDark: isDark),
                      if (sale.changeReturned > 0) ...[
                        const SizedBox(height: 6),
                        _buildSummaryLine('Monnaie rendue'.tr, AppTheme.formatFCFA(sale.changeReturned), valueColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, isDark: isDark),
                      ],
                      if (isCredit && remainingDebt > 0) ...[
                        const SizedBox(height: 6),
                        _buildSummaryLine('Reste à payer (Dette)'.tr, AppTheme.formatFCFA(remainingDebt), valueColor: Colors.red, isBold: true, isDark: isDark),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ACTIONS
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryNavy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.print_rounded, size: 18, color: AppTheme.primaryNavy),
                    label: Text('Imprimer la facture'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: () => SaleReceiptDialog.show(context, sale),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF25D366),
                          side: const BorderSide(color: Color(0xFF25D366)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'Reçu ${sale.historyReference} • Total: ${AppTheme.formatFCFA(sale.total)}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reçu copié pour WhatsApp !'.tr)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : AppTheme.primaryNavy,
                          side: BorderSide(color: cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.receipt_outlined, size: 18),
                        label: Text('Partager PDF'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () async {
                          try {
                            await InvoicePrintService.shareSale(sale);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${'Erreur génération facture'.tr}: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text('Annuler la vente'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                          title: Text('Annuler la vente ?'.tr, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                          content: Text('Cette action remettra les articles (${sale.items.length}) en stock.'.tr, style: TextStyle(color: textSecondary)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Non'.tr, style: TextStyle(color: textSecondary))),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                appState.cancelSale(sale);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Vente ${sale.ticketNumber} annulée et stock restauré.'.tr)),
                                );
                              },
                              child: Text('Oui, annuler'.tr, style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryLine(String title, String value, {Color? valueColor, bool isBold = false, bool isDark = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}

