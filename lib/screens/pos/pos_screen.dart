import 'dart:async';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/screens/pos/shift_dialog_helper.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final appState = AppState.instance;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedStore = 'Toutes';
  Timer? _shiftTimer;

  @override
  void initState() {
    super.initState();
    if (!appState.isOwnerAccount) {
      _selectedStore = appState.assignedStoreForCurrentUser;
      appState.setCurrentStore(appState.assignedStoreForCurrentUser);
    }
    // Actualisation du chronomètre de shift toutes les 15 secondes
    _shiftTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && appState.activeCashShift != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _shiftTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _storeOptions {
    final isOwner = appState.isOwnerAccount;
    final canManageStock = isOwner || appState.hasPermission('Gestion du stock & Prix');
    final assigned = appState.assignedStoreForCurrentUser;

    if (!isOwner && !canManageStock) {
      // Sans droit de gestion de stock : strictement sa boutique rattachée
      return [assigned];
    }
    final all = <String>{};
    if (assigned.isNotEmpty && assigned != 'Toutes' && assigned != 'Toutes les boutiques') {
      all.add(assigned);
    }
    for (final s in appState.availableStores) {
      if (s.trim().isNotEmpty && s != 'Toutes' && s != 'Toutes les boutiques') all.add(s.trim());
    }
    for (final o in appState.outlets) {
      if (o.name.trim().isNotEmpty && o.name != 'Toutes' && o.name != 'Toutes les boutiques') all.add(o.name.trim());
    }
    if (all.isEmpty) {
      all.add(appState.currentStore.isNotEmpty ? appState.currentStore : 'Boutique Principale');
    }
    return all.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;
        final isOwner = appState.isOwnerAccount;
        final canManageStock = isOwner || appState.hasPermission('Gestion du stock & Prix');
        final assignedStore = appState.assignedStoreForCurrentUser;
        final stores = _storeOptions;

        if (!isOwner && !canManageStock) {
          _selectedStore = assignedStore;
        } else if (!stores.contains(_selectedStore)) {
          _selectedStore = stores.isNotEmpty ? stores.first : (assignedStore.isNotEmpty ? assignedStore : appState.currentStore);
        }

        final effectiveStore = (!isOwner && !canManageStock) ? assignedStore : _selectedStore;

        final products = appState.products.where((p) {
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.barcode.contains(_searchQuery);
          final matchesStore = p.storeName.isEmpty ||
              p.storeName.trim().toLowerCase() == effectiveStore.trim().toLowerCase() ||
              p.stockByStore.containsKey(effectiveStore) ||
              p.stockForStore(effectiveStore) > 0;
          return matchesSearch && matchesStore;
        }).toList();

        if (isDesktop) {
          return _buildDesktopLayout(context, products, stores);
        }

        return _buildMobileLayout(context, products, stores);
      },
    );
  }

  // ==========================================
  // VERSION GRAND ÉCRAN WEB / DESKTOP (2 COLONNES)
  // ==========================================
  Widget _buildDesktopLayout(BuildContext context, List<Product> products, List<String> stores) {
    final isDark = appState.isDarkMode;
    final isOwner = appState.isOwnerAccount;
    final canManageStock = isOwner || appState.hasPermission('Gestion du stock & Prix');
    final assignedStore = appState.assignedStoreForCurrentUser;
    final isViewingOtherStore = !isOwner && _selectedStore != assignedStore;
    final effectiveStore = (!isOwner && !canManageStock) ? assignedStore : _selectedStore;
    final canAddProduct = isOwner || appState.hasPermission('Création de produits');
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          Expanded(
            flex: 65,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cardBorder),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 4, offset: const Offset(0, 1)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: TextStyle(color: textPrimary, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Rechercher un article par nom ou code-barres...'.tr,
                              hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                              prefixIcon: Icon(Icons.search, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                      ),
                      if (canAddProduct) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add_box_outlined, color: AppTheme.accentGold, size: 20),
                          label: Text('Nouveau Produit'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (!isOwner && !canManageStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.storefront_rounded, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                          const SizedBox(width: 8),
                          Text(
                            assignedStore,
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_rounded, size: 10, color: Color(0xFF10B981)),
                                const SizedBox(width: 3),
                                Text(
                                  'Boutique rattachée'.tr,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: stores.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final store = stores[idx];
                          final isSelected = _selectedStore == store;
                          final isOther = !isOwner && store != assignedStore;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(store == 'Toutes' ? 'Toutes les boutiques'.tr : store),
                                if (isOther) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white24 : const Color(0xFFD97706).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Transfert'.tr,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppTheme.accentGold : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryNavy,
                            backgroundColor: cardBg,
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.accentGold : (isDark ? Colors.white : const Color(0xFF475569)),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryNavy : cardBorder,
                              ),
                            ),
                            onSelected: (_) => setState(() {
                              _selectedStore = store;
                              if (isOwner && store != 'Toutes') {
                                appState.setCurrentStore(store);
                              }
                            }),
                          );
                        },
                      ),
                    ),
                    if (isViewingOtherStore) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? const Color(0xFFB45309) : const Color(0xFFF59E0B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_horiz_rounded, size: 18, color: Color(0xFFD97706)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Consultation du stock de "$_selectedStore". La vente est réservée à votre boutique rattachée ($assignedStore). Cliquez sur un article pour demander un transfert.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: AppTheme.accentGold,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                              label: const Text('Nouveau transfert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NewTransferScreen(
                                      initialSourceStore: _selectedStore,
                                      initialDestinationStore: assignedStore,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),

                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Icon(Icons.storefront_outlined, size: 42, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Rien à vendre pour l'instant".tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  canAddProduct
                                      ? 'Ajoutez un produit et son stock pour démarrer vos ventes.'.tr
                                      : 'Aucun produit disponible dans cette boutique pour l\'instant.'.tr,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                if (canAddProduct) ...[
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryNavy,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    ),
                                    icon: const Icon(Icons.add, color: AppTheme.accentGold),
                                    label: Text('Ajouter mon premier produit'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                                    },
                                  ),
                                ],
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 210,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.15,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, idx) {
                              final p = products[idx];
                              final storeStock = isViewingOtherStore ? p.stockForStore(_selectedStore) : p.stockForStore(assignedStore);
                              final displayStock = isOwner ? (effectiveStore == 'Toutes' ? p.stock : p.stockForStore(effectiveStore)) : storeStock;
                              return InkWell(
                                onTap: () {
                                  if (isViewingOtherStore) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NewTransferScreen(
                                          initialSourceStore: _selectedStore,
                                          initialDestinationStore: assignedStore,
                                          initialProduct: p,
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final ok = appState.addToCart(p);
                                  if (!ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFFDC2626),
                                        content: Text('${'Stock insuffisant ! Le stock disponible pour'.tr} "${p.name}" ${'est de'.tr} ${p.stockForStore(assignedStore)}.'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: cardBorder),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 4, offset: const Offset(0, 1)),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ProductImageWidget(
                                            imageUrl: p.imageUrl,
                                            size: 50,
                                            borderRadius: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: displayStock <= 5 ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7)) : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$displayStock ${p.unit}',
                                              style: TextStyle(
                                                color: displayStock <= 5 ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        p.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppTheme.formatFCFA(p.sellPrice),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                            ),
                                          ),
                                          if (isViewingOtherStore)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.swap_horiz_rounded, size: 13, color: isDark ? AppTheme.primaryNavy : AppTheme.accentGold),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    'Transférer'.tr,
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDark ? AppTheme.primaryNavy : Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryNavy,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.add, color: AppTheme.accentGold, size: 16),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // COLONNE DROITE (35%) : TICKET DE CAISSE & PANIER ACTIF
          Container(
            width: 370,
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(left: BorderSide(color: cardBorder)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                    border: Border(bottom: BorderSide(color: cardBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Caisse / Ticket'.tr,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textPrimary),
                          ),
                        ],
                      ),
                      if (appState.cart.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => appState.clearCart(),
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 16),
                          label: Text('Vider'.tr, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: appState.cart.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart_outlined, size: 54, color: Color(0xFFCBD5E1)),
                                const SizedBox(height: 12),
                                Text(
                                  'Panier vide'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cliquez sur un produit à gauche pour l\'ajouter à la caisse.'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(14),
                          itemCount: appState.cart.length,
                          separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, idx) {
                            final item = appState.cart[idx];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${AppTheme.formatFCFA(item.unitPrice)} x ${item.quantity}',
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF64748B)),
                                      onPressed: () => appState.updateCartQuantity(item, -1),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.primaryNavy),
                                      onPressed: () {
                                        final ok = appState.updateCartQuantity(item, 1);
                                        if (!ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(0xFFDC2626),
                                              content: Text('${'Stock insuffisant ! Le stock disponible pour'.tr} "${item.product.name}" ${'est de'.tr} ${item.product.stockForStore(appState.isCashierAccount ? appState.assignedStoreForCurrentUser : appState.currentStore)}.'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppTheme.formatFCFA(item.total),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryNavy),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL'.tr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                          Text(
                            AppTheme.formatFCFA(appState.cartTotal),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                      if (appState.isShiftsTrackingEnabled) ...[
                        const SizedBox(height: 10),
                        _buildShiftBottomBar(context),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.payments_outlined, color: AppTheme.accentGold),
                          label: Text(
                            '${'Encaisser'.tr} (${AppTheme.formatFCFA(appState.cartTotal)})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: appState.cart.isEmpty
                              ? null
                              : () => _handleMobilePay(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VERSION MOBILE — STYLE BRICELO (100% DYNAMIQUE)
  // ==========================================
  Widget _buildMobileLayout(BuildContext context, List<Product> products, List<String> stores) {
    final isDark = appState.isDarkMode;
    final isOwner = appState.isOwnerAccount;
    final canManageStock = isOwner || appState.hasPermission('Gestion du stock & Prix');
    final assignedStore = appState.assignedStoreForCurrentUser;
    final isViewingOtherStore = !isOwner && _selectedStore != assignedStore;
    final effectiveStore = (!isOwner && !canManageStock) ? assignedStore : _selectedStore;
    final canAddProduct = isOwner || appState.hasPermission('Création de produits');
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Point de vente'.tr,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        actions: [
          if (appState.heldCarts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                backgroundColor: AppTheme.accentGold,
                label: Text(
                  '${appState.heldCarts.length} en attente',
                  style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                onPressed: () {
                  final held = appState.heldCarts.last;
                  appState.resumeHeldCart(held);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Panier repris (${held.customerName})')),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppTheme.accentGold, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. RECHERCHE PRODUIT + BOUTON + AU COIN DROIT (HORS DU HEADER)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit ou scanner...'.tr,
                  hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppTheme.accentGold : const Color(0xFF64748B), size: 20),
                  suffixIcon: canAddProduct
                      ? Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add_rounded, color: AppTheme.accentGold, size: 20),
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // 2. SÉLECTION DES BOUTIQUES (VERROUILLÉE SI PAS LE DROIT GESTION DU STOCK)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOwner && !canManageStock)
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorder),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02), blurRadius: 4, offset: const Offset(0, 1)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 18,
                          color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            assignedStore,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_rounded, size: 11, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text(
                                'Boutique rattachée'.tr,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorder),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02), blurRadius: 4, offset: const Offset(0, 1)),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: cardBg,
                        value: stores.contains(_selectedStore) ? _selectedStore : stores.first,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.accentGold),
                        items: stores.map((store) {
                          final isOther = !isOwner && store != assignedStore;
                          return DropdownMenuItem<String>(
                            value: store,
                            child: Row(
                              children: [
                                Icon(
                                  store == 'Toutes' ? Icons.storefront_rounded : Icons.store_rounded,
                                  size: 18,
                                  color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    store == 'Toutes' ? 'Toutes les boutiques'.tr : store,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isOther)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Transfert'.tr,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newStore) {
                          if (newStore != null) {
                            setState(() {
                              _selectedStore = newStore;
                              if (isOwner && newStore != 'Toutes') {
                                appState.setCurrentStore(newStore);
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                if (isViewingOtherStore) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFFB45309) : const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Stock de "$_selectedStore" en consultation seule. Vente interdite : demandez un transfert vers votre boutique ($assignedStore).',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. ZONE CENTRALE : GRILLE DE PRODUITS OU ÉTAT VIDE
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront_rounded, size: 40, color: AppTheme.primaryNavy),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rien à vendre pour l’instant'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            canAddProduct
                                ? 'Ajoutez un produit et son stock pour démarrer vos ventes.'.tr
                                : 'Aucun produit disponible dans cette boutique.'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                          if (canAddProduct) ...[
                            const SizedBox(height: 22),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.accentGold),
                              label: Text(
                                'Ajouter mon premier produit'.tr,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.08,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, idx) {
                      final p = products[idx];
                      final availStock = p.stockForStore(effectiveStore);
                      final isOutOfStock = p.productType != 'Service' && availStock <= 0;
                      final isLow = availStock <= 5 && !isOutOfStock;
                      final inCartQty = appState.cart
                          .where((c) => c.product.id == p.id)
                          .fold<int>(0, (sum, c) => sum + c.quantity);
                      final inCart = inCartQty > 0;
                      final cartItem = inCart ? appState.cart.firstWhere((c) => c.product.id == p.id) : null;
                      final unitLabel = p.unit.toLowerCase().contains('pièce') || p.unit.toLowerCase().contains('piece')
                          ? 'pièce(s)'
                          : p.unit;

                      return Opacity(
                        opacity: isOutOfStock ? 0.45 : 1.0,
                        child: InkWell(
                          onTap: () {
                            if (isViewingOtherStore) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NewTransferScreen(
                                    initialSourceStore: _selectedStore,
                                    initialDestinationStore: assignedStore,
                                    initialProduct: p,
                                  ),
                                ),
                              );
                              return;
                            }
                            if (isOutOfStock) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFDC2626),
                                  content: Text('Stock épuisé pour "${p.name}". Approvisionnement requis.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            if (p.productType != 'Service' && inCartQty >= availStock) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFDC2626),
                                  content: Text('Stock insuffisant ! Le stock disponible pour "${p.name}" est de $availStock $unitLabel.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            if (inCart) {
                              final ok = appState.updateCartQuantity(cartItem!, 1);
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFFDC2626),
                                    content: Text('Stock insuffisant ! Le stock disponible pour "${p.name}" est de $availStock $unitLabel.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } else {
                              final ok = appState.addToCart(p);
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFFDC2626),
                                    content: Text('Stock insuffisant ! Le stock disponible pour "${p.name}" est de $availStock $unitLabel.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: inCart ? (isDark ? const Color(0xFF2E2200) : const Color(0xFFFFFBEB)) : cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: inCart ? AppTheme.accentGold : cardBorder,
                                width: inCart ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ProductImageWidget(
                                      imageUrl: p.imageUrl,
                                      size: 48,
                                      borderRadius: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isOutOfStock
                                            ? (isDark ? const Color(0xFF5C1D1D) : const Color(0xFFFEE2E2))
                                            : (isLow ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFFF8E7)) : (isDark ? const Color(0xFF1E3052) : const Color(0xFFF1F5F9))),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isOutOfStock ? 'Épuisé'.tr : '$availStock $unitLabel',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isOutOfStock ? const Color(0xFFEF4444) : (isDark ? AppTheme.accentGold : const Color(0xFFD97706)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        AppTheme.formatFCFA(p.sellPrice),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: isDark ? AppTheme.accentGold : const Color(0xFFD97706),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isViewingOtherStore)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                          foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          minimumSize: const Size(0, 28),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.swap_horiz_rounded, size: 13),
                                        label: Text(
                                          'Transfert'.tr,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => NewTransferScreen(
                                                initialSourceStore: _selectedStore,
                                                initialDestinationStore: assignedStore,
                                                initialProduct: p,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    else if (inCart)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              appState.updateCartQuantity(cartItem!, -1);
                                            },
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: cardBg,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: cardBorder),
                                              ),
                                              child: Icon(
                                                inCartQty == 1 ? Icons.delete_outline : Icons.remove,
                                                size: 15,
                                                color: inCartQty == 1 ? Colors.red : textPrimary,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              '$inCartQty',
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textPrimary),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (p.productType != 'Service' && inCartQty >= availStock) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: const Color(0xFFDC2626),
                                                    content: Text('Stock insuffisant ! Le stock disponible pour "${p.name}" est de $availStock $unitLabel.'),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                                return;
                                              }
                                              final ok = appState.updateCartQuantity(cartItem!, 1);
                                              if (!ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: const Color(0xFFDC2626),
                                                    content: Text('Stock insuffisant ! Le stock disponible pour "${p.name}" est de $availStock $unitLabel.'),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentGold,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Icon(Icons.add, size: 15, color: AppTheme.primaryNavy),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      InkWell(
                                        onTap: isOutOfStock
                                            ? () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: const Color(0xFFDC2626),
                                                    content: Text('Stock épuisé pour "${p.name}". Approvisionnement requis.'),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            : () {
                                                final ok = appState.addToCart(p);
                                                if (!ok) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor: const Color(0xFFDC2626),
                                                      content: Text('Stock insuffisant ! Le stock disponible pour "${p.name}" est de $availStock $unitLabel.'),
                                                      duration: const Duration(seconds: 2),
                                                    ),
                                                  );
                                                }
                                              },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.add_rounded, color: isDark ? AppTheme.primaryNavy : AppTheme.accentGold, size: 18),
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
                  ),
          ),

          // 3. BARRE DE SHIFT & D'ENCAISSEMENT FLOTTANTE EN BAS
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (appState.isShiftsTrackingEnabled)
                _buildShiftBottomBar(context),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border(top: BorderSide(color: cardBorder)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Détail du panier au clic
                    Expanded(
                      child: InkWell(
                        onTap: appState.cart.isEmpty ? null : () => _showCartSummaryModal(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${appState.cartCount} ${'articles'.tr}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (appState.cart.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTheme.formatFCFA(appState.cartTotal),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (appState.cart.isNotEmpty) ...[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Mettre en attente'.tr,
                        icon: Icon(Icons.pause_circle_outline_rounded, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 22),
                        onPressed: () {
                          appState.holdCurrentCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Panier mis en attente'.tr)),
                          );
                        },
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Vider le panier'.tr,
                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 22),
                        onPressed: () => appState.clearCart(),
                      ),
                    ],
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appState.cart.isEmpty
                              ? const Color(0xFFE2E8F0)
                              : AppTheme.accentGold,
                          foregroundColor: appState.cart.isEmpty
                              ? const Color(0xFF94A3B8)
                              : AppTheme.primaryNavy,
                          elevation: appState.cart.isEmpty ? 0 : 2,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: appState.cart.isEmpty
                            ? null
                            : () => _handleMobilePay(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              appState.cart.isEmpty
                                  ? 'Payer'.tr
                                  : 'Payer • ${AppTheme.formatFCFA(appState.cartTotal)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: appState.cart.isEmpty ? const Color(0xFF94A3B8) : AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: appState.cart.isEmpty ? const Color(0xFF94A3B8) : AppTheme.primaryNavy,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCartSummaryModal(BuildContext context) {
    final isDark = appState.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'Panier en cours'.tr} (${appState.cartCount})',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isDark ? Colors.white : AppTheme.primaryNavy),
                    ),
                    TextButton(
                      onPressed: () {
                        appState.clearCart();
                        Navigator.pop(ctx);
                      },
                      child: Text('Tout vider'.tr, style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Divider(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: appState.cart.length,
                    separatorBuilder: (_, _) => const Divider(height: 12),
                    itemBuilder: (_, idx) {
                      final item = appState.cart[idx];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('${AppTheme.formatFCFA(item.unitPrice)} / u', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              appState.updateCartQuantity(item, -1);
                              setModalState(() {});
                              if (appState.cart.isEmpty) Navigator.pop(ctx);
                            },
                          ),
                          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryNavy),
                            onPressed: () {
                              appState.updateCartQuantity(item, 1);
                              setModalState(() {});
                            },
                          ),
                          Text(
                            AppTheme.formatFCFA(item.total),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryNavy),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleMobilePay(BuildContext context) async {
    if (appState.isShiftsTrackingEnabled && appState.activeCashShift == null) {
      final opened = await ShiftDialogHelper.showOpenShiftDialog(context);
      if (!opened) return;
    }
    if (!context.mounted) return;
    CheckoutStepperModal.show(context);
  }

  Widget _buildShiftBottomBar(BuildContext context) {
    final shift = appState.activeCashShift;
    final now = DateTime.now();
    final isPast17h30 = now.hour > 17 || (now.hour == 17 && now.minute >= 30);

    if (shift != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Alerte 17h30 si le service est toujours ouvert après l'heure de clôture
          if (isPast17h30)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: const Color(0xFFFEF2F2),
              child: Row(
                children: [
                  const Icon(Icons.alarm_on_rounded, color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '⚠️ Alerte 17h30 : Heure de fermeture dépassée. Pensez à faire votre caisse et clôturer.',
                      style: TextStyle(color: Color(0xFF991B1B), fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => ShiftDialogHelper.showCloseShiftDialog(context, shift),
                    child: const Text('Clôturer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: const Border(
                top: BorderSide(color: Color(0xFF1E293B)),
                bottom: BorderSide(color: Color(0xFF1E293B)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${shift.cashDeskName} ouvert',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          ShiftDurationBadge(shift: shift),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Caissier : ${shift.cashierName} · Décompte : ${AppTheme.formatFCFA(shift.cashSalesTotal)} encaissés (Fond: ${AppTheme.formatFCFA(shift.openingCash)})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => ShiftDialogHelper.showCloseShiftDialog(context, shift),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_clock, size: 14, color: Color(0xFFFCA5A5)),
                        SizedBox(width: 4),
                        Text(
                          'Clôturer',
                          style: TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          border: const Border(
            top: BorderSide(color: Color(0xFFFDE68A)),
            bottom: BorderSide(color: Color(0xFFFDE68A)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Aucun shift ouvert pour cette caisse',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: () => ShiftDialogHelper.showOpenShiftDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Ouvrir le shift',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ==========================================
  // MODAL D'ENCAISSEMENT COMPLET JUSQU'AU REÇU (COMME STOCKPLUS)
  // ==========================================
  // ignore: unused_element
  Future<void> _showCheckoutDialog(BuildContext context) async {
    if (appState.isShiftsTrackingEnabled && appState.activeCashShift == null) {
      final opened = await ShiftDialogHelper.showOpenShiftDialog(context);
      if (!opened) return;
    }
    if (!context.mounted) return;
    final isDark = appState.isDarkMode;
    final total = appState.cartTotal;
    String selectedPayment = 'Espèces';
    Customer? selectedCustomer;
    final amountCtrl = TextEditingController(text: total.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final received = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
          final change = (received - total).clamp(0.0, double.infinity);
          final remainingDebt = (total - received).clamp(0.0, double.infinity);

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Finaliser la vente'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                              color: isDark ? Colors.white : AppTheme.primaryNavy,
                            ),
                          ),
                          Text(
                            '${appState.cartCount} article(s) • Total : ${AppTheme.formatFCFA(total)}',
                            style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. SÉLECTION DU CLIENT DYNAMIQUE (+ AJOUT RAPIDE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Client'.tr,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : AppTheme.primaryNavy),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(Icons.person_add_alt_1_rounded, size: 15, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                        label: Text(
                          '+ Nouveau client'.tr,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                        ),
                        onPressed: () async {
                          final created = await Navigator.push<Customer>(
                            context,
                            MaterialPageRoute(builder: (_) => const NewCustomerScreen()),
                          );
                          if (created != null) {
                            setModalState(() => selectedCustomer = created);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<Customer?>(
                    initialValue: selectedCustomer,
                    dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: [
                      DropdownMenuItem<Customer?>(
                        value: null,
                        child: Text('Client Comptoir (Vente directe)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                      ),
                      ...appState.customers.map(
                        (c) => DropdownMenuItem<Customer?>(
                          value: c,
                          child: Text('${c.name} ${c.phone.isNotEmpty ? "(${c.phone})" : ""}', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                        ),
                      ),
                    ],
                    onChanged: (val) => setModalState(() => selectedCustomer = val),
                  ),
                  const SizedBox(height: 16),

                  // 2. MODE DE PAIEMENT
                  Text(
                    'Mode de paiement'.tr,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPaymentChip(
                        label: 'Espèces',
                        icon: Icons.payments_outlined,
                        selected: selectedPayment == 'Espèces',
                        isDark: isDark,
                        onTap: () {
                          setModalState(() {
                            selectedPayment = 'Espèces';
                            amountCtrl.text = total.toStringAsFixed(0);
                          });
                        },
                      ),
                      _buildPaymentChip(
                        label: 'Orange Money',
                        icon: Icons.phone_android_rounded,
                        selected: selectedPayment == 'Orange Money',
                        isDark: isDark,
                        onTap: () {
                          setModalState(() {
                            selectedPayment = 'Orange Money';
                            amountCtrl.text = total.toStringAsFixed(0);
                          });
                        },
                      ),
                      _buildPaymentChip(
                        label: 'MTN MoMo',
                        icon: Icons.edgesensor_high_rounded,
                        selected: selectedPayment == 'MTN MoMo',
                        isDark: isDark,
                        onTap: () {
                          setModalState(() {
                            selectedPayment = 'MTN MoMo';
                            amountCtrl.text = total.toStringAsFixed(0);
                          });
                        },
                      ),
                      _buildPaymentChip(
                        label: 'À Crédit',
                        icon: Icons.pending_actions_rounded,
                        selected: selectedPayment == 'À Crédit',
                        isDark: isDark,
                        onTap: () {
                          setModalState(() {
                            selectedPayment = 'À Crédit';
                            amountCtrl.text = '0';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. MONTANT REÇU & CALCUL AUTOMATIQUE DE MONNAIE / DETTE
                  Text(
                    selectedPayment == 'À Crédit' ? 'Acompte versé (FCFA)'.tr : 'Montant reçu du client (FCFA)'.tr,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setModalState(() {}),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : AppTheme.primaryNavy),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.attach_money_rounded, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                      suffixText: 'FCFA',
                      suffixStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Résumé Monnaie à rendre ou Reste à payer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedPayment == 'À Crédit'
                          ? (isDark ? const Color(0xFF382305) : const Color(0xFFFEF3C7))
                          : (isDark ? const Color(0xFF062E22) : const Color(0xFFECFDF5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedPayment == 'À Crédit'
                              ? 'Reste à payer (Dette client)'.tr
                              : 'Monnaie à rendre'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: selectedPayment == 'À Crédit'
                                ? (isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E))
                                : (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46)),
                          ),
                        ),
                        Text(
                          AppTheme.formatFCFA(selectedPayment == 'À Crédit' ? remainingDebt : change),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: selectedPayment == 'À Crédit'
                                ? const Color(0xFFD97706)
                                : const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. BOUTON VALIDER & GÉNÉRER LE REÇU
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                        foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.receipt_long_rounded, color: isDark ? AppTheme.primaryNavy : AppTheme.accentGold),
                      label: Text(
                        'Valider et afficher le reçu'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      onPressed: () {
                        if (appState.isDiscoveredPlan && appState.isMonthlySalesQuotaReached) {
                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF382305) : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Plafond Découverte atteint',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.5,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                'Vous avez atteint le plafond mensuel de 50 ventes de la formule Découverte (${appState.currentMonthSalesCount}/50 ventes ce mois-ci).\n\n'
                                'Pour encaisser vos ventes en illimité sans interruption et profiter du reçu personnalisé sans filigrane, passez à la Formule Pro sur le portail web.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dCtx),
                                  child: Text('Compris', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        final sale = appState.finalizeSale(
                          paymentMethod: selectedPayment,
                          amountReceived: received,
                          changeReturned: selectedPayment == 'À Crédit' ? 0 : change,
                          customerName: selectedCustomer?.name ?? 'Client Comptoir',
                          customerPhone: selectedCustomer?.phone ?? '',
                        );
                        Navigator.pop(ctx);
                        SaleReceiptDialog.show(context, sale);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppTheme.accentGold : AppTheme.primaryNavy)
              : (isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.accentGold : (isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? (isDark ? AppTheme.primaryNavy : AppTheme.accentGold)
                  : (isDark ? Colors.white70 : AppTheme.primaryNavy),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: selected
                    ? (isDark ? AppTheme.primaryNavy : Colors.white)
                    : (isDark ? Colors.white : AppTheme.primaryNavy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
