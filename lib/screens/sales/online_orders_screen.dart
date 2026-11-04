import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';

class OnlineOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<String> items;
  final double totalAmount;
  final DateTime createdAt;
  String status; // 'Nouvelle', 'Confirmée', 'Prête', 'En livraison', 'Livrée', 'Annulée'

  OnlineOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.status = 'Nouvelle',
  });
}

class OnlineOrdersScreen extends StatefulWidget {
  const OnlineOrdersScreen({super.key});

  @override
  State<OnlineOrdersScreen> createState() => _OnlineOrdersScreenState();
}

class _OnlineOrdersScreenState extends State<OnlineOrdersScreen> {
  final appState = AppState.instance;

  String _selectedStatus = 'Toutes';

  final List<String> _statusFilters = [
    'Toutes',
    'Nouvelle',
    'Confirmée',
    'Prête',
    'En livraison',
    'Livrée',
    'Annulée',
  ];

  // Liste locale des commandes en ligne
  final List<OnlineOrder> _orders = [];

  void _addSampleOrder() {
    final now = DateTime.now();
    final nextNum = _orders.length + 1;
    setState(() {
      _orders.insert(
        0,
        OnlineOrder(
          id: 'ord_${now.millisecondsSinceEpoch}',
          orderNumber: 'CMD-${1000 + nextNum}',
          customerName: 'Client Boutique #$nextNum',
          customerPhone: '+237 690 12 34 56',
          customerAddress: 'Cameroun',
          items: ['2x Ciment Dangote 50kg', '1x Brouette Pro'],
          totalAmount: 25000,
          createdAt: now,
          status: 'Nouvelle',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primaryNavy,
        content: Text('Nouvelle commande test reçue !'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;

        final filteredOrders = _orders.where((o) {
          if (_selectedStatus == 'Toutes') return true;
          return o.status == _selectedStatus;
        }).toList();

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: StockAppBar.navy(
            title: 'Commandes en ligne',
            onBack: () => Navigator.pop(context),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: AppTheme.accentGold),
                tooltip: 'Simuler une commande',
                onPressed: _addSampleOrder,
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. FILTER TABS HORIZONTAUX (Conforme Image 5)
              Container(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _statusFilters.map((status) {
                      final isSelected = _selectedStatus == status;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedStatus = status),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppTheme.primaryNavy : const Color(0xFFFFDFBA))
                                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppTheme.accentGold : const Color(0xFFE5A93C))
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  Icon(
                                    Icons.check,
                                    size: 15,
                                    color: isDark ? AppTheme.accentGold : const Color(0xFF111827),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? (isDark ? AppTheme.accentGold : const Color(0xFF111827))
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 2. CONTENU : LISTE OU ÉTAT VIDE CONFORME IMAGE 5
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aucune commande pour le moment.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Les commandes passées depuis votre boutique en ligne apparaîtront ici.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final order = filteredOrders[idx];
                          return _buildOrderCard(order, isDark);
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: StockBottomBar(
            currentIndex: 4,
            onTap: (_) => Navigator.pop(context),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(OnlineOrder order, bool isDark) {
    Color badgeColor;
    Color badgeTextColor;

    switch (order.status) {
      case 'Nouvelle':
        badgeColor = const Color(0xFFDBEAFE);
        badgeTextColor = const Color(0xFF1E40AF);
        break;
      case 'Confirmée':
        badgeColor = const Color(0xFFFEF3C7);
        badgeTextColor = const Color(0xFF92400E);
        break;
      case 'Prête':
        badgeColor = const Color(0xFFE0E7FF);
        badgeTextColor = const Color(0xFF3730A3);
        break;
      case 'En livraison':
        badgeColor = const Color(0xFFF3E8FF);
        badgeTextColor = const Color(0xFF6B21A8);
        break;
      case 'Livrée':
        badgeColor = const Color(0xFFD1FAE5);
        badgeTextColor = const Color(0xFF065F46);
        break;
      default:
        badgeColor = const Color(0xFFFEE2E2);
        badgeTextColor = const Color(0xFF991B1B);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.primaryNavy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.customerName} • ${order.customerPhone}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            order.customerAddress,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.items.join(', '),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                ),
              ),
              Text(
                AppTheme.formatFCFA(order.totalAmount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEA580C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (order.status == 'Nouvelle')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => setState(() => order.status = 'Confirmée'),
                  child: const Text('Confirmer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              if (order.status == 'Confirmée')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => setState(() => order.status = 'Prête'),
                  child: const Text('Marquer Prête', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              if (order.status == 'Prête')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => setState(() => order.status = 'En livraison'),
                  child: const Text('Expédier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              if (order.status == 'En livraison')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => setState(() => order.status = 'Livrée'),
                  child: const Text('Marquer Livrée', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
