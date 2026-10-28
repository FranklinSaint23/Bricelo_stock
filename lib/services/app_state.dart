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
  List<Customer> customers = [];
  List<Supplier> suppliers = [];
  List<Product> products = [];
  List<CartItem> cart = [];
  List<HeldCart> heldCarts = [];
  List<Sale> sales = [];
  List<CustomerDebt> debts = [];
  List<SupplierDebt> supplierDebts = [];
  List<Expense> expenses = [];
  List<StockMovement> stockMovements = [];

  
  void addCustomer(Customer customer) {
    customers.add(customer);
    notifyListeners();
  }

  void updateCustomer(Customer customer) {
    final index = customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      notifyListeners();
    }
  }

  void removeCustomer(String id) {
    customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  
  void addSupplier(Supplier supplier) {
    suppliers.add(supplier);
    notifyListeners();
  }

  void updateSupplier(Supplier supplier) {
    final index = suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      suppliers[index] = supplier;
      notifyListeners();
    }
  }

  void removeSupplier(String id) {
    suppliers.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void _initSampleData() {
    products = [];
    sales = [];
    debts = [];
    supplierDebts = [];
    expenses = [];
    stockMovements = [];
    cart = [];
    heldCarts = [];
  }

  void resetAllData() {
    customers.clear();
    suppliers.clear();
    products.clear();
    sales.clear();
    debts.clear();
    supplierDebts.clear();
    expenses.clear();
    stockMovements.clear();
    cart.clear();
    heldCarts.clear();
    notifyListeners();
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
      quantity: diff.abs().round(),
      newStock: newStock.round(),
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
