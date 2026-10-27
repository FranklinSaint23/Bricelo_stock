import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // Singleton pour accès global immédiat et réactif
  static final AppState instance = AppState._internal();
  factory AppState() => instance;
  AppState._internal() {
    _initSampleData();
  }

  // --- Configuration & Mode ---
  bool isBossMode = true; // Si faux : masque prix d'achat et marges aux caissiers
  String currentStore = 'Boutique BRICÉLO Akwa (Douala)';
  final List<String> availableStores = [
    'Boutique BRICÉLO Akwa (Douala)',
    'Magasin BRICÉLO Bastos (Yaoundé)',
    'Dépôt Central Bonamoussadi (Douala)',
  ];

  double openingCash = 25000.0; // Fond de caisse d'ouverture du jour
  bool isSyncedToBricelo = true;

  // --- Données Centrales ---
  List<Product> products = [];
  List<CartItem> cart = [];
  List<HeldCart> heldCarts = [];
  List<Sale> sales = [];
  List<CustomerDebt> debts = [];
  List<SupplierDebt> supplierDebts = [];
  List<Expense> expenses = [];
  List<StockMovement> stockMovements = [];

  void _initSampleData() {
    products = [
      Product(
        id: 'p1',
        name: 'Tondeuse professionnelle VGR V-030 Gold',
        category: 'Électronique',
        barcode: '6901234567890',
        buyPrice: 9500,
        sellPrice: 13900,
        wholesalePrice: 12000,
        stock: 18,
        minStockAlert: 5,
        unit: 'Pièce',
        supplierName: 'Grossiste Électro Akwa',
      ),
      Product(
        id: 'p2',
        name: 'Power bank Oraimo 20.000 mAh Fast Charge',
        category: 'Électronique',
        barcode: '6909876543210',
        buyPrice: 6800,
        sellPrice: 9900,
        wholesalePrice: 8500,
        stock: 4, // Stock faible
        minStockAlert: 6,
        unit: 'Pièce',
        supplierName: 'Oraimo Store Douala',
      ),
      Product(
        id: 'p3',
        name: 'Rallonge parafoudre 5 sorties câble 3m',
        category: 'Bricolage & Électricité',
        barcode: '6904443332211',
        buyPrice: 3200,
        sellPrice: 5500,
        wholesalePrice: 4500,
        stock: 24,
        minStockAlert: 5,
        unit: 'Pièce',
        supplierName: 'Importateur Congo',
      ),
      Product(
        id: 'p4',
        name: 'Fer à repasser à vapeur Philips EasySpeed',
        category: 'Électroménager',
        barcode: '8710103857410',
        buyPrice: 12500,
        sellPrice: 17500,
        wholesalePrice: 15500,
        stock: 9,
        minStockAlert: 3,
        unit: 'Pièce',
        supplierName: 'Grossiste NANA Douala',
      ),
      Product(
        id: 'p5',
        name: 'Matelas Orthopédique PH7 2 Places 140x190',
        category: 'Maison & Confort',
        barcode: '2370011223344',
        buyPrice: 48000,
        sellPrice: 65000,
        wholesalePrice: 58000,
        stock: 0, // Rupture de stock
        minStockAlert: 2,
        unit: 'Pièce',
        supplierName: 'Usine Mousse Bassa',
      ),
      Product(
        id: 'p6',
        name: 'Ventilateur rechargeable solaire 16\" LED',
        category: 'Électroménager',
        barcode: '6907778889990',
        buyPrice: 22000,
        sellPrice: 32000,
        wholesalePrice: 28000,
        stock: 7,
        minStockAlert: 3,
        unit: 'Pièce',
        supplierName: 'Énergie Plus Yaoundé',
      ),
      Product(
        id: 'p7',
        name: 'Écouteurs sans fil Oraimo FreePods 4 ANC',
        category: 'Électronique',
        barcode: '6908889991112',
        buyPrice: 11000,
        sellPrice: 16000,
        wholesalePrice: 14000,
        stock: 15,
        minStockAlert: 4,
        unit: 'Pièce',
        supplierName: 'Oraimo Store Douala',
      ),
      Product(
        id: 'p8',
        name: 'Cafetière programmable SmartChef 1.2L',
        category: 'Électroménager',
        barcode: '6903332221110',
        buyPrice: 9000,
        sellPrice: 14500,
        wholesalePrice: 12500,
        stock: 5,
        minStockAlert: 2,
        unit: 'Pièce',
        supplierName: 'Grossiste NANA Douala',
      ),
    ];

    // Ventes d'exemple du jour
    final now = DateTime.now();
    sales = [
      Sale(
        id: 's1',
        ticketNumber: 'SP-1041',
        createdAt: now.subtract(const Duration(hours: 3)),
        items: [
          SaleItemSummary(
            productName: 'Tondeuse professionnelle VGR V-030 Gold',
            quantity: 1,
            unitPrice: 13900,
            total: 13900,
          ),
        ],
        total: 13900,
        paymentMethod: 'Orange Money',
        amountReceived: 13900,
        customerName: 'M. Paul Atangana',
        customerPhone: '+237 6 99 12 34 56',
        storeName: currentStore,
      ),
      Sale(
        id: 's2',
        ticketNumber: 'SP-1042',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
        items: [
          SaleItemSummary(
            productName: 'Power bank Oraimo 20.000 mAh Fast Charge',
            quantity: 2,
            unitPrice: 9900,
            total: 19800,
          ),
        ],
        total: 19800,
        paymentMethod: 'Espèces',
        amountReceived: 20000,
        changeReturned: 200,
        customerName: 'Client Comptoir',
        storeName: currentStore,
      ),
    ];

    // Dettes clients d'exemple
    debts = [
      CustomerDebt(
        id: 'd1',
        customerName: 'M. Emmanuel Tagne',
        customerPhone: '+237 6 77 88 99 00',
        customerCity: 'Akwa (Douala)',
        initialDebt: 35000,
        paidAmount: 10000,
        createdAt: now.subtract(const Duration(days: 3)),
        lastPaymentDate: now.subtract(const Duration(days: 1)),
        itemsSummary: ['1x Tondeuse Gold', '1x Rallonge 5 sorties'],
        payments: [
          DebtPayment(
            id: 'dp1',
            amount: 10000,
            date: now.subtract(const Duration(days: 1)),
            paymentMethod: 'Orange Money',
            note: 'Acompte versé au comptoir',
          ),
        ],
      ),
      CustomerDebt(
        id: 'd2',
        customerName: 'Mme Clarisse Mballa',
        customerPhone: '+237 6 55 44 33 22',
        customerCity: 'Bastos (Yaoundé)',
        initialDebt: 65000,
        paidAmount: 25000,
        createdAt: now.subtract(const Duration(days: 7)),
        lastPaymentDate: now.subtract(const Duration(days: 2)),
        itemsSummary: ['1x Matelas Orthopédique PH7'],
        payments: [
          DebtPayment(
            id: 'dp2',
            amount: 25000,
            date: now.subtract(const Duration(days: 2)),
            paymentMethod: 'MTN MoMo',
            note: 'Premier acompte',
          ),
        ],
      ),
      CustomerDebt(
        id: 'd3',
        customerName: 'M. Jean-Paul Kamdem',
        customerPhone: '+237 6 91 22 33 44',
        customerCity: 'Bonabéri (Douala)',
        initialDebt: 18000,
        paidAmount: 0,
        createdAt: now.subtract(const Duration(days: 1)),
        lastPaymentDate: now.subtract(const Duration(days: 1)),
        itemsSummary: ['1x Écouteurs FreePods 4'],
      ),
    ];

    // Dettes fournisseurs d'exemple
    supplierDebts = [
      SupplierDebt(
        id: 'sd1',
        supplierName: 'Ets NANA & Fils (Grossiste)',
        supplierPhone: '+237 6 99 88 77 66',
        invoiceRef: 'FAC-2026-891',
        totalAmount: 450000,
        paidAmount: 200000,
        createdAt: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 5)),
      ),
      SupplierDebt(
        id: 'sd2',
        supplierName: 'Société Camerounaise d\'Importation (SCI)',
        supplierPhone: '+237 6 70 11 22 33',
        invoiceRef: 'BL-99201',
        totalAmount: 280000,
        paidAmount: 0,
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 12)),
      ),
    ];

    // Dépenses de la boutique du jour
    expenses = [
      Expense(
        id: 'e1',
        category: 'Transport / Taxi',
        description: 'Course réassort au Marché Congo',
        amount: 2500,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Expense(
        id: 'e2',
        category: 'Ration / Repas',
        description: 'Déjeuner équipe comptoir et caisse',
        amount: 3500,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Expense(
        id: 'e3',
        category: 'Emballage / Sachets',
        description: 'Paquet 100 sachets d\'emballage plastique',
        amount: 2000,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];

    // Mouvements de stock
    stockMovements = [
      StockMovement(
        id: 'sm1',
        productId: 'p1',
        productName: 'Tondeuse professionnelle VGR V-030 Gold',
        type: 'VENTE (-)',
        quantity: 1,
        newStock: 18,
        reason: 'Ticket #SP-1041',
        date: now.subtract(const Duration(hours: 3)),
      ),
      StockMovement(
        id: 'sm2',
        productId: 'p2',
        productName: 'Power bank Oraimo 20.000 mAh Fast Charge',
        type: 'VENTE (-)',
        quantity: 2,
        newStock: 4,
        reason: 'Ticket #SP-1042',
        date: now.subtract(const Duration(hours: 1, minutes: 20)),
      ),
    ];
  }

  // --- GETTERS STATISTIQUES ---
  double get cartSubtotal => cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get cartTotal => cart.fold(0.0, (sum, item) => sum + item.total);
  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);

  int get todaySalesCount => sales.length;
  double get todayRevenue => sales.fold(0.0, (sum, sale) => sum + sale.total);
  
  // Marge brute estimée du jour
  double get todayGrossMargin {
    double totalMargin = 0;
    for (var sale in sales) {
      for (var item in sale.items) {
        final p = products.firstWhere(
          (prod) => prod.name == item.productName,
          orElse: () => Product(
            id: '',
            name: item.productName,
            category: '',
            barcode: '',
            buyPrice: item.unitPrice * 0.7,
            sellPrice: item.unitPrice,
            stock: 0,
          ),
        );
        totalMargin += (item.unitPrice - p.buyPrice) * item.quantity;
      }
    }
    return totalMargin;
  }

  double get todayExpensesTotal => expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  double get todayNetProfit => todayGrossMargin - todayExpensesTotal;

  double get totalCustomerDebt => debts.where((d) => !d.isSettled).fold(0.0, (sum, d) => sum + d.remainingDebt);
  double get totalSupplierDebt => supplierDebts.where((d) => !d.isSettled).fold(0.0, (sum, d) => sum + d.remainingDebt);

  // Espèces théoriques dans le tiroir
  double get cashInDrawerExpected {
    final cashSales = sales.where((s) => s.paymentMethod == 'Espèces').fold(0.0, (sum, s) => sum + s.total);
    double debtCash = 0;
    for (var d in debts) {
      for (var p in d.payments) {
        if (p.paymentMethod == 'Espèces') {
          debtCash += p.amount;
        }
      }
    }
    return openingCash + cashSales + debtCash - todayExpensesTotal;
  }

  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;

  // --- ACTIONS PANIER ---
  void addToCart(Product product, {bool wholesale = false}) {
    final index = cart.indexWhere((item) => item.product.id == product.id && item.isWholesale == wholesale);
    if (index >= 0) {
      cart[index].quantity += 1;
    } else {
      cart.add(CartItem(
        product: product,
        quantity: 1,
        unitPrice: wholesale ? product.wholesalePrice : product.sellPrice,
        isWholesale: wholesale,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    cart.remove(item);
    notifyListeners();
  }

  void updateCartQuantity(CartItem item, int delta) {
    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      cart.remove(item);
    } else {
      item.quantity = newQty;
    }
    notifyListeners();
  }

  void toggleCartItemWholesale(CartItem item) {
    item.isWholesale = !item.isWholesale;
    item.unitPrice = item.isWholesale ? item.product.wholesalePrice : item.product.sellPrice;
    notifyListeners();
  }

  void setCartItemDiscount(CartItem item, double discount) {
    item.discount = discount;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // --- PANIERS EN ATTENTE (Hold Cart) ---
  void holdCurrentCart({String customerName = 'Client en attente'}) {
    if (cart.isEmpty) return;
    heldCarts.add(HeldCart(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Panier #${heldCarts.length + 1}',
      createdAt: DateTime.now(),
      items: List.from(cart),
      customerName: customerName,
    ));
    cart.clear();
    notifyListeners();
  }

  void resumeHeldCart(HeldCart held) {
    cart = List.from(held.items);
    heldCarts.remove(held);
    notifyListeners();
  }

  void discardHeldCart(HeldCart held) {
    heldCarts.remove(held);
    notifyListeners();
  }

  // --- FINALISATION DE VENTE (POS Checkout) ---
  Sale finalizeSale({
    required String paymentMethod,
    required double amountReceived,
    double changeReturned = 0,
    String customerName = 'Client Comptoir',
    String customerPhone = '',
    String cashierName = 'Caissier Principal',
  }) {
    final now = DateTime.now();
    final ticketNumber = 'SP-${1000 + sales.length + 1}';
    final itemsSummary = cart.map((item) => SaleItemSummary(
      productName: item.product.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      total: item.total,
    )).toList();

    final sale = Sale(
      id: 'sale_${now.millisecondsSinceEpoch}',
      ticketNumber: ticketNumber,
      createdAt: now,
      items: itemsSummary,
      total: cartTotal,
      discountTotal: cart.fold(0.0, (sum, i) => sum + i.discount),
      paymentMethod: paymentMethod,
      amountReceived: amountReceived,
      changeReturned: changeReturned,
      customerName: customerName.trim().isEmpty ? 'Client Comptoir' : customerName.trim(),
      customerPhone: customerPhone,
      cashierName: cashierName,
      storeName: currentStore,
    );

    // Décrémenter le stock des produits et enregistrer les mouvements
    for (var item in cart) {
      final p = products.firstWhere((prod) => prod.id == item.product.id);
      p.stock -= item.quantity;
      if (p.stock < 0) p.stock = 0;

      stockMovements.insert(0, StockMovement(
        id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
        productId: p.id,
        productName: p.name,
        type: 'VENTE (-)',
        quantity: item.quantity,
        newStock: p.stock,
        reason: 'Ticket #$ticketNumber',
        date: now,
      ));
    }

    // Si vente à crédit, enregistrer dans le cahier de dettes
    if (paymentMethod == 'À Crédit') {
      debts.insert(0, CustomerDebt(
        id: 'debt_${now.millisecondsSinceEpoch}',
        customerName: customerName.trim().isEmpty ? 'Client Anonyme' : customerName.trim(),
        customerPhone: customerPhone,
        initialDebt: cartTotal,
        paidAmount: amountReceived > 0 ? amountReceived : 0,
        createdAt: now,
        lastPaymentDate: now,
        itemsSummary: itemsSummary.map((i) => '${i.quantity}x ${i.productName}').toList(),
        payments: amountReceived > 0 ? [
          DebtPayment(
            id: 'dp_${now.millisecondsSinceEpoch}',
            amount: amountReceived,
            date: now,
            paymentMethod: 'Espèces',
            note: 'Acompte initial à la vente',
          ),
        ] : [],
      ));
    }

    sales.insert(0, sale);
    cart.clear();
    notifyListeners();
    return sale;
  }

  // --- ACTIONS DETTES CLIENTS ---
  void recordCustomerDebtPayment(String debtId, double amount, String method, {String note = 'Versement'}) {
    final debt = debts.firstWhere((d) => d.id == debtId);
    debt.paidAmount += amount;
    debt.lastPaymentDate = DateTime.now();
    debt.payments.insert(0, DebtPayment(
      id: 'dp_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      paymentMethod: method,
      note: note,
    ));
    notifyListeners();
  }

  void addManualDebt({
    required String customerName,
    required String customerPhone,
    required String customerCity,
    required double amount,
    required String description,
  }) {
    final now = DateTime.now();
    debts.insert(0, CustomerDebt(
      id: 'debt_${now.millisecondsSinceEpoch}',
      customerName: customerName,
      customerPhone: customerPhone,
      customerCity: customerCity,
      initialDebt: amount,
      paidAmount: 0,
      createdAt: now,
      lastPaymentDate: now,
      itemsSummary: [description],
    ));
    notifyListeners();
  }

  // --- ACTIONS DETTES FOURNISSEURS ---
  void recordSupplierPayment(String debtId, double amount) {
    final debt = supplierDebts.firstWhere((d) => d.id == debtId);
    debt.paidAmount += amount;
    notifyListeners();
  }

  // --- ACTIONS DÉPENSES ---
  void addExpense({
    required String category,
    required String description,
    required double amount,
    String paidBy = 'Caissier Principal',
  }) {
    expenses.insert(0, Expense(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      description: description,
      amount: amount,
      createdAt: DateTime.now(),
      paidBy: paidBy,
    ));
    notifyListeners();
  }

  // --- ACTIONS GESTION DE STOCK ---
  void addProduct(Product product) {
    products.add(product);
    stockMovements.insert(0, StockMovement(
      id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      type: 'AJUSTEMENT',
      quantity: product.stock,
      newStock: product.stock,
      reason: 'Création du produit',
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  void restockProduct({
    required String productId,
    required int quantity,
    required double buyCost,
    String supplier = 'Grossiste Akwa',
  }) {
    final p = products.firstWhere((prod) => prod.id == productId);
    p.stock += quantity;
    stockMovements.insert(0, StockMovement(
      id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
      productId: p.id,
      productName: p.name,
      type: 'RÉASSORT (+)',
      quantity: quantity,
      newStock: p.stock,
      reason: 'Fournisseur: $supplier - Coût: ${buyCost.toStringAsFixed(0)} FCFA',
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  void adjustStock({
    required String productId,
    required int newStock,
    required String reason,
  }) {
    final p = products.firstWhere((prod) => prod.id == productId);
    final diff = newStock - p.stock;
    p.stock = newStock;
    stockMovements.insert(0, StockMovement(
      id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
      productId: p.id,
      productName: p.name,
      type: diff >= 0 ? 'AJUSTEMENT (+)' : 'AVARIE / PERTE (-)',
      quantity: diff.abs(),
      newStock: newStock,
      reason: reason,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  // --- PARAMÈTRES & BOUTIQUE ---
  void switchStore(String store) {
    currentStore = store;
    notifyListeners();
  }

  void toggleBossMode() {
    isBossMode = !isBossMode;
    notifyListeners();
  }
}
