// Modèles de données Bricelo Stock (100% Dynamiques & Persistants)

class CategoryItem {
  final String id;
  String name;
  String parent;
  double tva;
  final DateTime createdAt;

  CategoryItem({
    required this.id,
    required this.name,
    this.parent = 'Aucune (Catégorie principale)',
    this.tva = 19.25,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parent': parent,
        'tva': tva,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CategoryItem.fromJson(Map<String, dynamic> j) => CategoryItem(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        parent: (j['parent'] ?? j['parent_name'] ?? 'Aucune (Catégorie principale)').toString(),
        tva: (j['tva'] as num?)?.toDouble() ?? 19.25,
        createdAt: DateTime.tryParse((j['createdAt'] ?? j['created_at'] ?? '').toString()) ?? DateTime.now(),
      );
}

class Product {
  final String id;
  String name;
  String category;
  String barcode;
  double buyPrice;
  double sellPrice;
  double wholesalePrice;
  int stock;
  int minStockAlert;
  String unit;
  String productType; // 'Produit', 'Service', 'Pack'
  bool isSyncedToBricelo;
  String? supplierName;
  String? imageUrl;
  DateTime? expiryDate;
  String? lotNumber;

  Map<String, int> stockByStore;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.barcode,
    required this.buyPrice,
    required this.sellPrice,
    double? wholesalePrice,
    required this.stock,
    this.minStockAlert = 5,
    this.unit = 'Pièce',
    this.productType = 'Produit',
    this.isSyncedToBricelo = true,
    this.supplierName,
    this.imageUrl,
    this.expiryDate,
    this.lotNumber,
    Map<String, int>? stockByStore,
  })  : wholesalePrice = wholesalePrice ?? (sellPrice * 0.9),
        stockByStore = stockByStore ?? {};

  int stockForStore(String storeName) {
    if (storeName == 'Tous' || storeName == 'Toutes' || storeName.trim().isEmpty) return stock;
    final normalized = storeName.trim().toLowerCase();
    for (final entry in stockByStore.entries) {
      if (entry.key.trim().toLowerCase() == normalized) {
        return entry.value;
      }
    }
    if (stockByStore.isNotEmpty) return 0;
    return stock;
  }

  void setStockForStore(String storeName, int qty) {
    stockByStore[storeName.trim()] = qty;
    if (stockByStore.length > 1) {
      stock = stockByStore.values.fold(0, (sum, v) => sum + v);
    } else {
      stock = qty;
    }
  }

  double get price => sellPrice;
  set price(double val) => sellPrice = val;

  double get margin => sellPrice - buyPrice;
  double get marginPercent => buyPrice > 0 ? ((sellPrice - buyPrice) / buyPrice) * 100 : 0;
  double get wholesaleMargin => wholesalePrice - buyPrice;
  bool get isLowStock => productType != 'Service' && stock <= minStockAlert && stock > 0;
  bool get isOutOfStock => productType != 'Service' && stock <= 0;

  bool get hasExpiry => expiryDate != null;
  bool isExpired() => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool isExpiringSoon(int alertDays) {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final diff = expiryDate!.difference(now).inDays;
    return diff >= 0 && diff <= alertDays;
  }
  int? daysUntilExpiry() {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'barcode': barcode,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'wholesalePrice': wholesalePrice,
        'stock': stock,
        'minStockAlert': minStockAlert,
        'unit': unit,
        'productType': productType,
        'isSyncedToBricelo': isSyncedToBricelo,
        'supplierName': supplierName,
        'imageUrl': imageUrl,
        'expiryDate': expiryDate?.toIso8601String(),
        'lotNumber': lotNumber,
        'stockByStore': stockByStore,
      };

  factory Product.fromJson(Map<String, dynamic> j) {
    final sell = (j['sellPrice'] as num?)?.toDouble() ?? (j['price'] as num?)?.toDouble() ?? 0.0;
    final buy = (j['buyPrice'] as num?)?.toDouble() ?? (j['purchase_price'] as num?)?.toDouble() ?? (sell * 0.7);
    final rawMap = j['stockByStore'];
    final Map<String, int> sMap = {};
    if (rawMap is Map) {
      rawMap.forEach((k, v) {
        sMap[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }

    return Product(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      category: (j['category'] ?? 'Non catégorisé').toString(),
      barcode: (j['barcode'] ?? '').toString(),
      buyPrice: buy,
      sellPrice: sell,
      wholesalePrice: (j['wholesalePrice'] as num?)?.toDouble() ?? (sell * 0.9),
      stock: (j['stock'] as num?)?.toInt() ?? 0,
      minStockAlert: (j['minStockAlert'] as num?)?.toInt() ?? (j['min_stock'] as num?)?.toInt() ?? 5,
      unit: (j['unit'] ?? 'Pièce').toString(),
      productType: (j['productType'] ?? j['product_type'] ?? 'Produit').toString(),
      isSyncedToBricelo: j['isSyncedToBricelo'] as bool? ?? true,
      supplierName: j['supplierName']?.toString(),
      imageUrl: j['imageUrl']?.toString() ?? j['image_url']?.toString(),
      expiryDate: j['expiryDate'] != null
          ? DateTime.tryParse(j['expiryDate'].toString())
          : (j['expiry_date'] != null ? DateTime.tryParse(j['expiry_date'].toString()) : null),
      lotNumber: j['lotNumber']?.toString() ?? j['lot_number']?.toString(),
      stockByStore: sMap,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;
  double unitPrice;
  double discount;
  bool isWholesale;
  bool isGift;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.unitPrice,
    this.discount = 0,
    this.isWholesale = false,
    this.isGift = false,
  });

  double get subtotal => isGift ? 0.0 : quantity * unitPrice;
  double get total => isGift ? 0.0 : ((quantity * unitPrice) - discount).clamp(0.0, double.infinity);
}

class HeldCart {
  final String id;
  final String label;
  final DateTime createdAt;
  final List<CartItem> items;
  final String customerName;

  HeldCart({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.items,
    this.customerName = 'Client Comptoir',
  });

  double get total => items.fold(0.0, (sum, item) => sum + item.total);
}

class SaleItemSummary {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;
  final bool isGift;
  final double buyPrice;

  SaleItemSummary({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.isGift = false,
    this.buyPrice = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': total,
        'isGift': isGift,
        'buyPrice': buyPrice,
      };

  factory SaleItemSummary.fromJson(Map<String, dynamic> j) {
    final qty = (j['quantity'] as num?)?.toInt() ?? 1;
    final up = (j['unitPrice'] as num?)?.toDouble() ?? (j['unit_price'] as num?)?.toDouble() ?? 0.0;
    final bp = (j['buyPrice'] as num?)?.toDouble() ?? (j['buy_price'] as num?)?.toDouble() ?? 0.0;
    final tot = (j['total'] as num?)?.toDouble() ?? (qty * up);
    return SaleItemSummary(
      productName: (j['productName'] ?? j['product_name'] ?? '').toString(),
      quantity: qty,
      unitPrice: up,
      total: tot,
      isGift: (j['isGift'] as bool?) ?? false,
      buyPrice: bp,
    );
  }
}

class Sale {
  final String id;
  final String ticketNumber;
  final DateTime createdAt;
  final List<SaleItemSummary> items;
  final double total;
  final double discountTotal;
  final String paymentMethod;
  final double amountReceived;
  final double changeReturned;
  final String customerName;
  final String customerPhone;
  final String cashierName;
  final String storeName;

  Sale({
    required this.id,
    required this.ticketNumber,
    required this.createdAt,
    required this.items,
    required this.total,
    this.discountTotal = 0.0,
    required this.paymentMethod,
    required this.amountReceived,
    this.changeReturned = 0.0,
    this.customerName = 'Client Comptoir',
    this.customerPhone = '',
    this.cashierName = 'Gérant',
    this.storeName = 'Boutique Principale',
  });

  double get subtotal => total + discountTotal;

  String get historyReference {
    if (ticketNumber.startsWith('BS-VTE-')) {
      return ticketNumber;
    }
    final yyyy = createdAt.year.toString();
    final mm = createdAt.month.toString().padLeft(2, '0');
    final dd = createdAt.day.toString().padLeft(2, '0');
    final lastDigits = formattedInvoiceNumber.replaceAll(RegExp(r'\D'), '');
    final numVal = int.tryParse(lastDigits) ?? 1;
    final seq = numVal.toString().padLeft(4, '0');
    return 'BS-VTE-$yyyy$mm$dd-$seq';
  }

  String get formattedInvoiceNumber {
    final regex = RegExp(r'(\d+)');
    final matches = regex.allMatches(ticketNumber);
    if (matches.isNotEmpty) {
      final lastNum = int.tryParse(matches.last.group(0) ?? '');
      if (lastNum != null) {
        return lastNum.toString().padLeft(5, '0');
      }
    }
    return '00651';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketNumber': ticketNumber,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'discountTotal': discountTotal,
        'paymentMethod': paymentMethod,
        'amountReceived': amountReceived,
        'changeReturned': changeReturned,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'cashierName': cashierName,
        'storeName': storeName,
      };

  factory Sale.fromJson(Map<String, dynamic> j) {
    final tot = (j['total'] as num?)?.toDouble() ?? (j['total_amount'] as num?)?.toDouble() ?? 0.0;
    final disc = (j['discountTotal'] as num?)?.toDouble() ?? 0.0;
    final rec = (j['amountReceived'] as num?)?.toDouble() ?? (j['amount_received'] as num?)?.toDouble() ?? tot;
    final chg = (j['changeReturned'] as num?)?.toDouble() ?? (j['change_returned'] as num?)?.toDouble() ?? 0.0;
    return Sale(
      id: (j['id'] ?? '').toString(),
      ticketNumber: (j['ticketNumber'] ?? j['id'] ?? 'SP-1001').toString(),
      createdAt: DateTime.tryParse((j['createdAt'] ?? j['sale_date'] ?? j['created_at'] ?? '').toString()) ?? DateTime.now(),
      items: (j['items'] as List<dynamic>? ?? [])
          .map((e) => SaleItemSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: tot,
      discountTotal: disc,
      paymentMethod: (j['paymentMethod'] ?? j['payment_method'] ?? 'Espèces').toString(),
      amountReceived: rec,
      changeReturned: chg,
      customerName: (j['customerName'] ?? j['customer_name'] ?? 'Client Comptoir').toString(),
      customerPhone: (j['customerPhone'] ?? '').toString(),
      cashierName: (j['cashierName'] ?? j['cashier_name'] ?? 'Gérant').toString(),
      storeName: (j['storeName'] ?? j['store_name'] ?? 'Boutique Principale').toString(),
    );
  }
}

class DebtPayment {
  final String id;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String note;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.note = 'Versement acompte',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'paymentMethod': paymentMethod,
        'note': note,
      };

  factory DebtPayment.fromJson(Map<String, dynamic> j) => DebtPayment(
        id: (j['id'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse((j['date'] ?? j['payment_date'] ?? '').toString()) ?? DateTime.now(),
        paymentMethod: (j['paymentMethod'] ?? j['payment_method'] ?? 'Espèces').toString(),
        note: (j['note'] ?? 'Versement acompte').toString(),
      );
}

class CustomerDebt {
  final String id;
  final String? saleId;
  final String customerName;
  final String customerPhone;
  final String customerCity;
  final double initialDebt;
  double paidAmount;
  final DateTime createdAt;
  DateTime lastPaymentDate;
  final DateTime? dueDate;
  final List<String> itemsSummary;
  final List<DebtPayment> payments;

  CustomerDebt({
    required this.id,
    this.saleId,
    required this.customerName,
    required this.customerPhone,
    this.customerCity = '',
    double? initialDebt,
    double? originalDebt,
    double? remainingDebt,
    this.paidAmount = 0,
    DateTime? createdAt,
    DateTime? saleDate,
    DateTime? lastPaymentDate,
    this.dueDate,
    List<String>? itemsSummary,
    List<DebtPayment>? payments,
  })  : initialDebt = initialDebt ?? originalDebt ?? remainingDebt ?? 0.0,
        createdAt = createdAt ?? saleDate ?? DateTime.now(),
        lastPaymentDate = lastPaymentDate ?? createdAt ?? saleDate ?? DateTime.now(),
        itemsSummary = itemsSummary ?? (saleId != null ? [saleId] : ['Créance']),
        payments = payments ?? [];

  double get originalDebt => initialDebt;
  DateTime get saleDate => createdAt;
  double get remainingDebt => initialDebt - paidAmount;
  bool get isSettled => remainingDebt <= 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerCity': customerCity,
        'initialDebt': initialDebt,
        'paidAmount': paidAmount,
        'createdAt': createdAt.toIso8601String(),
        'lastPaymentDate': lastPaymentDate.toIso8601String(),
        'itemsSummary': itemsSummary,
        'payments': payments.map((e) => e.toJson()).toList(),
      };

  factory CustomerDebt.fromJson(Map<String, dynamic> j) {
    final initDebt = (j['initialDebt'] ?? j['total_debt'] ?? 0 as num).toDouble();
    final rem = (j['remaining_amount'] as num?)?.toDouble();
    final paid = (j['paidAmount'] as num?)?.toDouble() ?? (rem != null ? (initDebt - rem) : 0.0);
    return CustomerDebt(
      id: (j['id'] ?? '').toString(),
      customerName: (j['customerName'] ?? j['customer_name'] ?? '').toString(),
      customerPhone: (j['customerPhone'] ?? j['phone'] ?? '').toString(),
      customerCity: (j['customerCity'] ?? '').toString(),
      initialDebt: initDebt,
      paidAmount: paid,
      createdAt: DateTime.tryParse((j['createdAt'] ?? j['created_at'] ?? '').toString()) ?? DateTime.now(),
      lastPaymentDate: DateTime.tryParse((j['lastPaymentDate'] ?? j['last_activity'] ?? '').toString()) ?? DateTime.now(),
      itemsSummary: (j['itemsSummary'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      payments: (j['payments'] as List<dynamic>? ?? [])
          .map((e) => DebtPayment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class SupplierDebt {
  final String id;
  final String supplierName;
  final String supplierPhone;
  final String invoiceRef;
  final double totalAmount;
  double paidAmount;
  final DateTime createdAt;
  final DateTime dueDate;
  final List<DebtPayment> payments;
  final String? orderRef;
  final String? storeName;

  SupplierDebt({
    required this.id,
    required this.supplierName,
    required this.supplierPhone,
    required this.invoiceRef,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.createdAt,
    required this.dueDate,
    List<DebtPayment>? payments,
    this.orderRef,
    this.storeName,
  }) : payments = payments ?? [];

  double get remainingDebt => (totalAmount - paidAmount).clamp(0.0, double.infinity);
  bool get isSettled => remainingDebt <= 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplierName': supplierName,
        'supplierPhone': supplierPhone,
        'invoiceRef': invoiceRef,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'payments': payments.map((e) => e.toJson()).toList(),
        'orderRef': orderRef,
        'storeName': storeName,
      };

  factory SupplierDebt.fromJson(Map<String, dynamic> j) => SupplierDebt(
        id: (j['id'] ?? '').toString(),
        supplierName: (j['supplierName'] ?? '').toString(),
        supplierPhone: (j['supplierPhone'] ?? '').toString(),
        invoiceRef: (j['invoiceRef'] ?? '').toString(),
        totalAmount: (j['totalAmount'] as num?)?.toDouble() ?? 0,
        paidAmount: (j['paidAmount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
        dueDate: DateTime.tryParse((j['dueDate'] ?? '').toString()) ?? DateTime.now(),
        payments: (j['payments'] as List<dynamic>? ?? [])
            .map((e) => DebtPayment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        orderRef: j['orderRef']?.toString(),
        storeName: j['storeName']?.toString(),
      );
}

class Expense {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime createdAt;
  final String paidBy;
  final String paidFromCaisse;
  final String? reference;

  DateTime get date => createdAt;

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.createdAt,
    this.paidBy = 'Gérant',
    this.paidFromCaisse = 'Caisse 1',
    this.reference,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'description': description,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'paidBy': paidBy,
        'paidFromCaisse': paidFromCaisse,
        'reference': reference,
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: (j['id'] ?? '').toString(),
        category: (j['category'] ?? 'Autre charge').toString(),
        description: (j['description'] ?? j['title'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse((j['createdAt'] ?? j['expense_date'] ?? '').toString()) ?? DateTime.now(),
        paidBy: (j['paidBy'] ?? j['beneficiary'] ?? 'Gérant').toString(),
        paidFromCaisse: (j['paidFromCaisse'] ?? j['caisse'] ?? 'Caisse 1').toString(),
        reference: j['reference']?.toString(),
      );
}

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String type;
  final int quantity;
  final int newStock;
  final String reason;
  final DateTime date;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.newStock,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'type': type,
        'quantity': quantity,
        'newStock': newStock,
        'reason': reason,
        'date': date.toIso8601String(),
      };

  factory StockMovement.fromJson(Map<String, dynamic> j) => StockMovement(
        id: (j['id'] ?? '').toString(),
        productId: (j['productId'] ?? '').toString(),
        productName: (j['productName'] ?? j['product_name'] ?? '').toString(),
        type: (j['type'] ?? j['movement_type'] ?? 'AJUSTEMENT').toString(),
        quantity: (j['quantity'] as num?)?.toInt() ?? 0,
        newStock: (j['newStock'] as num?)?.toInt() ?? 0,
        reason: (j['reason'] ?? '').toString(),
        date: DateTime.tryParse((j['date'] ?? j['movement_date'] ?? '').toString()) ?? DateTime.now(),
      );
}

class StockDepreciation {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitCost;
  final double totalLoss;
  final String reason;
  final String notes;
  final String storeName;
  final DateTime date;

  StockDepreciation({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
    required this.totalLoss,
    required this.reason,
    this.notes = '',
    required this.storeName,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitCost': unitCost,
        'totalLoss': totalLoss,
        'reason': reason,
        'notes': notes,
        'storeName': storeName,
        'date': date.toIso8601String(),
      };

  factory StockDepreciation.fromJson(Map<String, dynamic> j) => StockDepreciation(
        id: (j['id'] ?? '').toString(),
        productId: (j['productId'] ?? '').toString(),
        productName: (j['productName'] ?? '').toString(),
        quantity: (j['quantity'] as num?)?.toInt() ?? 0,
        unitCost: (j['unitCost'] as num?)?.toDouble() ?? 0.0,
        totalLoss: (j['totalLoss'] as num?)?.toDouble() ?? 0.0,
        reason: (j['reason'] ?? 'Casse / Dommage').toString(),
        notes: (j['notes'] ?? '').toString(),
        storeName: (j['storeName'] ?? '').toString(),
        date: DateTime.tryParse((j['date'] ?? '').toString()) ?? DateTime.now(),
      );
}

class QuoteItem {
  final String name;
  final int quantity;
  final double price;
  final double total;

  QuoteItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        'total': total,
      };

  factory QuoteItem.fromJson(Map<String, dynamic> j) => QuoteItem(
        name: (j['name'] ?? '').toString(),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        price: (j['price'] as num?)?.toDouble() ?? 0.0,
        total: (j['total'] as num?)?.toDouble() ?? 0.0,
      );
}

class Quote {
  final String id;
  final String client;
  final String phone;
  final DateTime validUntil;
  final List<QuoteItem> items;
  final double total;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.client,
    required this.phone,
    required this.validUntil,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'client': client,
        'phone': phone,
        'validUntil': validUntil.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        id: (j['id'] ?? '').toString(),
        client: (j['client'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        validUntil: DateTime.tryParse((j['validUntil'] ?? '').toString()) ?? DateTime.now().add(const Duration(days: 15)),
        items: (j['items'] as List<dynamic>? ?? []).map((e) => QuoteItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        total: (j['total'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
      );
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final bool isArchived;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.isArchived = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'notes': notes,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        address: (j['address'] ?? '').toString(),
        notes: (j['notes'] ?? '').toString(),
        isArchived: j['isArchived'] as bool? ?? false,
        createdAt: DateTime.tryParse((j['createdAt'] ?? j['created_at'] ?? '').toString()) ?? DateTime.now(),
      );
}

class Supplier {
  final String id;
  final String name;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final bool isArchived;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    this.contactName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.isArchived = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contactName': contactName,
        'phone': phone,
        'email': email,
        'address': address,
        'notes': notes,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        contactName: (j['contactName'] ?? j['category'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        address: (j['address'] ?? '').toString(),
        notes: (j['notes'] ?? '').toString(),
        isArchived: j['isArchived'] as bool? ?? false,
        createdAt: DateTime.tryParse((j['createdAt'] ?? j['created_at'] ?? '').toString()) ?? DateTime.now(),
      );
}

// ==========================================
// MODÈLES BONS D'ACHAT & COMMANDES FOURNISSEUR
// ==========================================
class PurchaseOrderItem {
  final String productId;
  final String productName;
  final int quantityRequested;
  int quantityReceived;
  final double unitPrice;

  PurchaseOrderItem({
    required this.productId,
    required this.productName,
    required this.quantityRequested,
    this.quantityReceived = 0,
    required this.unitPrice,
  });

  double get totalPrice => quantityRequested * unitPrice;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantityRequested': quantityRequested,
        'quantityReceived': quantityReceived,
        'unitPrice': unitPrice,
      };

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> j) => PurchaseOrderItem(
        productId: (j['productId'] ?? '').toString(),
        productName: (j['productName'] ?? '').toString(),
        quantityRequested: (j['quantityRequested'] as num?)?.toInt() ?? 0,
        quantityReceived: (j['quantityReceived'] as num?)?.toInt() ?? 0,
        unitPrice: (j['unitPrice'] as num?)?.toDouble() ?? 0.0,
      );
}

class PurchaseOrderReception {
  final String reference; // ex: BS-REC-20261105-0001
  final DateTime date;
  final String storeName;
  final int articlesCount;
  final double supplierPrice;
  final double costPrice;

  PurchaseOrderReception({
    required this.reference,
    required this.date,
    required this.storeName,
    required this.articlesCount,
    required this.supplierPrice,
    required this.costPrice,
  });

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'date': date.toIso8601String(),
        'storeName': storeName,
        'articlesCount': articlesCount,
        'supplierPrice': supplierPrice,
        'costPrice': costPrice,
      };

  factory PurchaseOrderReception.fromJson(Map<String, dynamic> j) => PurchaseOrderReception(
        reference: (j['reference'] ?? '').toString(),
        date: DateTime.tryParse((j['date'] ?? '').toString()) ?? DateTime.now(),
        storeName: (j['storeName'] ?? 'Boutique principale').toString(),
        articlesCount: (j['articlesCount'] as num?)?.toInt() ?? 0,
        supplierPrice: (j['supplierPrice'] as num?)?.toDouble() ?? 0.0,
        costPrice: (j['costPrice'] as num?)?.toDouble() ?? 0.0,
      );
}

class PurchaseOrder {
  final String id;
  final String reference; // ex: BS-ACH-20261105-0001
  final String supplierId;
  final String supplierName;
  final String destinationStore;
  final DateTime createdAt;
  final DateTime? deliveryDate;
  String status; // 'En attente', 'Reçu', 'Partiel'
  final List<PurchaseOrderItem> items;
  final List<PurchaseOrderReception> receptions;
  final String notes;

  PurchaseOrder({
    required this.id,
    required this.reference,
    required this.supplierId,
    required this.supplierName,
    required this.destinationStore,
    required this.createdAt,
    this.deliveryDate,
    this.status = 'En attente',
    List<PurchaseOrderItem>? items,
    List<PurchaseOrderReception>? receptions,
    this.notes = '',
  })  : items = items ?? [],
        receptions = receptions ?? [];

  double get totalAmount => items.fold(0.0, (sum, i) => sum + i.totalPrice);
  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantityRequested);
  int get totalReceived => items.fold(0, (sum, i) => sum + i.quantityReceived);

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'destinationStore': destinationStore,
        'createdAt': createdAt.toIso8601String(),
        'deliveryDate': deliveryDate?.toIso8601String(),
        'status': status,
        'items': items.map((e) => e.toJson()).toList(),
        'receptions': receptions.map((e) => e.toJson()).toList(),
        'notes': notes,
      };

  factory PurchaseOrder.fromJson(Map<String, dynamic> j) => PurchaseOrder(
        id: (j['id'] ?? '').toString(),
        reference: (j['reference'] ?? '').toString(),
        supplierId: (j['supplierId'] ?? '').toString(),
        supplierName: (j['supplierName'] ?? '').toString(),
        destinationStore: (j['destinationStore'] ?? 'Boutique Principale').toString(),
        createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
        deliveryDate: j['deliveryDate'] != null ? DateTime.tryParse(j['deliveryDate'].toString()) : null,
        status: (j['status'] ?? 'En attente').toString(),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => PurchaseOrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        receptions: (j['receptions'] as List<dynamic>? ?? [])
            .map((e) => PurchaseOrderReception.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        notes: (j['notes'] ?? '').toString(),
      );
}


// ==========================================
// MODÈLE BOUTIQUE & POINT DE VENTE (OUTLET)
// ==========================================
class StoreOutlet {
  final String id;
  String name;
  String type; // 'Boutique' or 'Entrepôt'
  bool isDefault;
  bool hasSpecificPrices;
  double discount;
  String address;
  String phone;
  DateTime createdAt;

  StoreOutlet({
    required this.id,
    required this.name,
    this.type = 'Boutique',
    this.isDefault = false,
    this.hasSpecificPrices = false,
    this.discount = 0.0,
    this.address = '',
    this.phone = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'isDefault': isDefault,
        'hasSpecificPrices': hasSpecificPrices,
        'discount': discount,
        'address': address,
        'phone': phone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StoreOutlet.fromJson(Map<String, dynamic> json) => StoreOutlet(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        type: (json['type'] ?? 'Boutique').toString(),
        isDefault: json['isDefault'] as bool? ?? false,
        hasSpecificPrices: json['hasSpecificPrices'] as bool? ?? false,
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
        address: (json['address'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );
}

// ==========================================
// MODÈLE CAISSE ENREGISTREUSE (CASH DESK)
// ==========================================
class CashDesk {
  final String id;
  String name;
  String storeName;
  bool isDefault;
  double balance;
  DateTime createdAt;

  CashDesk({
    required this.id,
    required this.name,
    required this.storeName,
    this.isDefault = false,
    this.balance = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'storeName': storeName,
        'isDefault': isDefault,
        'balance': balance,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CashDesk.fromJson(Map<String, dynamic> json) => CashDesk(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        storeName: (json['storeName'] ?? '').toString(),
        isDefault: json['isDefault'] as bool? ?? false,
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );
}

// ==========================================
// MODÈLE TRANSFERT DE STOCK INTER-BOUTIQUES
// ==========================================
class TransferItem {
  final String productId;
  final String productName;
  final int quantity;
  final String unit;

  TransferItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.unit = 'Pièce',
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unit': unit,
      };

  factory TransferItem.fromJson(Map<String, dynamic> j) => TransferItem(
        productId: (j['productId'] ?? '').toString(),
        productName: (j['productName'] ?? '').toString(),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        unit: (j['unit'] ?? 'Pièce').toString(),
      );
}

class StockTransfer {
  final String id;
  final String reference;
  final String sourceStore;
  final String destinationStore;
  final List<TransferItem> items;
  final DateTime date;
  final String author;
  final String status; // 'Effectué', 'En transit', 'Reçu'
  final String note;

  StockTransfer({
    required this.id,
    required this.reference,
    required this.sourceStore,
    required this.destinationStore,
    required this.items,
    required this.date,
    this.author = 'Gérant',
    this.status = 'Effectué',
    this.note = '',
  });

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'sourceStore': sourceStore,
        'destinationStore': destinationStore,
        'items': items.map((e) => e.toJson()).toList(),
        'date': date.toIso8601String(),
        'author': author,
        'status': status,
        'note': note,
      };

  factory StockTransfer.fromJson(Map<String, dynamic> j) => StockTransfer(
        id: (j['id'] ?? '').toString(),
        reference: (j['reference'] ?? 'TRF-1001').toString(),
        sourceStore: (j['sourceStore'] ?? 'Boutique Principale').toString(),
        destinationStore: (j['destinationStore'] ?? 'Entrepôt').toString(),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => TransferItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        date: DateTime.tryParse((j['date'] ?? '').toString()) ?? DateTime.now(),
        author: (j['author'] ?? 'Gérant').toString(),
        status: (j['status'] ?? 'Effectué').toString(),
        note: (j['note'] ?? '').toString(),
      );
}

// ==========================================
// MODÈLES SESSION D'INVENTAIRE PHYSIQUE
// ==========================================
class InventoryItemRecord {
  final String productId;
  final String productName;
  final String category;
  final String barcode;
  final String unit;
  final int theoreticalStock;
  final int countedStock;
  final double buyPrice;
  final double sellPrice;
  final String supplierName;
  final List<String> recentBuyers;
  final String discrepancyReason;

  InventoryItemRecord({
    required this.productId,
    required this.productName,
    required this.category,
    required this.barcode,
    this.unit = 'Pièce',
    required this.theoreticalStock,
    required this.countedStock,
    required this.buyPrice,
    required this.sellPrice,
    this.supplierName = '',
    this.recentBuyers = const [],
    this.discrepancyReason = '',
  });

  int get difference => countedStock - theoreticalStock;
  double get theoreticalValue => theoreticalStock * buyPrice;
  double get countedValue => countedStock * buyPrice;
  double get discrepancyValue => difference * buyPrice;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'category': category,
        'barcode': barcode,
        'unit': unit,
        'theoreticalStock': theoreticalStock,
        'countedStock': countedStock,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'supplierName': supplierName,
        'recentBuyers': recentBuyers,
        'discrepancyReason': discrepancyReason,
      };

  factory InventoryItemRecord.fromJson(Map<String, dynamic> j) => InventoryItemRecord(
        productId: (j['productId'] ?? '').toString(),
        productName: (j['productName'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        barcode: (j['barcode'] ?? '').toString(),
        unit: (j['unit'] ?? 'Pièce').toString(),
        theoreticalStock: (j['theoreticalStock'] as num?)?.toInt() ?? 0,
        countedStock: (j['countedStock'] as num?)?.toInt() ?? 0,
        buyPrice: (j['buyPrice'] as num?)?.toDouble() ?? 0.0,
        sellPrice: (j['sellPrice'] as num?)?.toDouble() ?? 0.0,
        supplierName: (j['supplierName'] ?? '').toString(),
        recentBuyers: (j['recentBuyers'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        discrepancyReason: (j['discrepancyReason'] ?? '').toString(),
      );
}

class InventorySession {
  final String id;
  final String reference;
  final String storeName;
  final DateTime startedAt;
  final DateTime completedAt;
  final String conductedBy;
  final String status; // 'Validé', 'En cours'
  final List<InventoryItemRecord> items;
  final String note;

  InventorySession({
    required this.id,
    required this.reference,
    required this.storeName,
    required this.startedAt,
    required this.completedAt,
    required this.conductedBy,
    this.status = 'Validé',
    required this.items,
    this.note = '',
  });

  int get totalArticlesCounted => items.length;
  int get articlesWithDiscrepancy => items.where((i) => i.difference != 0).length;
  double get totalDiscrepancyValue => items.fold(0.0, (sum, i) => sum + i.discrepancyValue);
  double get totalCountedValue => items.fold(0.0, (sum, i) => sum + i.countedValue);
  double get totalTheoreticalValue => items.fold(0.0, (sum, i) => sum + i.theoreticalValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'storeName': storeName,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'conductedBy': conductedBy,
        'status': status,
        'items': items.map((e) => e.toJson()).toList(),
        'note': note,
      };

  factory InventorySession.fromJson(Map<String, dynamic> j) => InventorySession(
        id: (j['id'] ?? '').toString(),
        reference: (j['reference'] ?? 'INV-1001').toString(),
        storeName: (j['storeName'] ?? 'Boutique Principale').toString(),
        startedAt: DateTime.tryParse((j['startedAt'] ?? '').toString()) ?? DateTime.now(),
        completedAt: DateTime.tryParse((j['completedAt'] ?? '').toString()) ?? DateTime.now(),
        conductedBy: (j['conductedBy'] ?? 'Gérant').toString(),
        status: (j['status'] ?? 'Validé').toString(),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => InventoryItemRecord.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        note: (j['note'] ?? '').toString(),
      );
}

class TeamMember {
  final String id;
  String name;
  String phone;
  String? email;
  String role; // 'Propriétaire', 'Gérant', 'Caissier', 'Magasinier'
  String storeName;
  String pinCode;
  String? assignedCashDesk;
  bool isActive;
  DateTime createdAt;

  TeamMember({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.storeName = 'Toutes les boutiques',
    this.pinCode = '',
    this.assignedCashDesk,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'storeName': storeName,
        'pinCode': pinCode,
        'assignedCashDesk': assignedCashDesk,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        email: j['email']?.toString(),
        role: (j['role'] ?? 'Caissier').toString(),
        storeName: (j['storeName'] ?? 'Toutes les boutiques').toString(),
        pinCode: (j['pinCode'] ?? '').toString(),
        assignedCashDesk: j['assignedCashDesk']?.toString(),
        isActive: j['isActive'] as bool? ?? true,
        createdAt: DateTime.tryParse((j['createdAt'] ?? j['created_at'] ?? '').toString()) ?? DateTime.now(),
      );
}

class InvoiceHeaderLine {
  String id;
  String label;
  String value;

  InvoiceHeaderLine({
    required this.id,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'value': value,
      };

  factory InvoiceHeaderLine.fromJson(Map<String, dynamic> j) => InvoiceHeaderLine(
        id: (j['id'] ?? '').toString(),
        label: (j['label'] ?? '').toString(),
        value: (j['value'] ?? '').toString(),
      );
}

class PaymentAccount {
  final String id;
  String title;
  double balance;
  String type; // 'Mobile Money', 'Banque', 'Carte'
  String? accountNumber;
  bool isActive;

  PaymentAccount({
    required this.id,
    required this.title,
    this.balance = 0.0,
    required this.type,
    this.accountNumber,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'balance': balance,
        'type': type,
        'accountNumber': accountNumber,
        'isActive': isActive,
      };

  factory PaymentAccount.fromJson(Map<String, dynamic> j) => PaymentAccount(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        balance: (j['balance'] as num?)?.toDouble() ?? 0.0,
        type: (j['type'] ?? 'Mobile Money').toString(),
        accountNumber: j['accountNumber']?.toString(),
        isActive: j['isActive'] as bool? ?? true,
      );
}

class ApprovalRequest {
  final String id;
  final String title;
  final String type; // 'Remise', 'Dépense', 'Dépréciation', 'Crédit', 'Annulation', 'Approvisionnement', 'Transfert de stock'
  final String requesterName;
  final String storeName;
  final double amount;
  final String details;
  final DateTime date;
  String status; // 'pending', 'approved', 'rejected'
  String? decisionNote;
  DateTime? decisionDate;
  String paymentStatus; // 'unpaid', 'paid'

  ApprovalRequest({
    required this.id,
    required this.title,
    required this.type,
    required this.requesterName,
    required this.storeName,
    required this.amount,
    required this.details,
    required this.date,
    this.status = 'pending',
    this.decisionNote,
    this.decisionDate,
    this.paymentStatus = 'unpaid',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'requesterName': requesterName,
        'storeName': storeName,
        'amount': amount,
        'details': details,
        'date': date.toIso8601String(),
        'status': status,
        'decisionNote': decisionNote,
        'decisionDate': decisionDate?.toIso8601String(),
        'paymentStatus': paymentStatus,
      };

  factory ApprovalRequest.fromJson(Map<String, dynamic> j) => ApprovalRequest(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        type: (j['type'] ?? 'Remise').toString(),
        requesterName: (j['requesterName'] ?? 'Employé').toString(),
        storeName: (j['storeName'] ?? 'Boutique Principale').toString(),
        amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
        details: (j['details'] ?? '').toString(),
        date: DateTime.tryParse((j['date'] ?? '').toString()) ?? DateTime.now(),
        status: (j['status'] ?? 'pending').toString(),
        decisionNote: j['decisionNote']?.toString(),
        decisionDate: j['decisionDate'] != null ? DateTime.tryParse(j['decisionDate'].toString()) : null,
        paymentStatus: (j['paymentStatus'] ?? 'unpaid').toString(),
      );
}

class CashShift {
  final String id;
  final String cashierName;
  final String cashDeskName;
  final String storeName;
  final DateTime openedAt;
  final double openingCash;
  DateTime? closedAt;
  double cashSalesTotal;
  double closingCashCounted;
  double discrepancy;
  String note;
  bool isClosed;
  int salesCount;
  double totalSalesAmount;
  Map<String, double> paymentMethodsBreakdown;

  CashShift({
    required this.id,
    required this.cashierName,
    required this.cashDeskName,
    required this.storeName,
    required this.openedAt,
    required this.openingCash,
    this.closedAt,
    this.cashSalesTotal = 0.0,
    this.closingCashCounted = 0.0,
    this.discrepancy = 0.0,
    this.note = '',
    this.isClosed = false,
    this.salesCount = 0,
    this.totalSalesAmount = 0.0,
    Map<String, double>? paymentMethodsBreakdown,
  }) : paymentMethodsBreakdown = paymentMethodsBreakdown ?? {};

  Duration get duration {
    DateTime start = openedAt;
    if (id.startsWith('shift_')) {
      final ms = int.tryParse(id.replaceFirst('shift_', ''));
      if (ms != null && ms > 1600000000000) {
        start = DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    final end = closedAt ?? DateTime.now();
    final localStart = start.isUtc ? start.toLocal() : start;
    final localEnd = end.isUtc ? end.toLocal() : end;
    var diff = localEnd.difference(localStart);
    if (diff.isNegative) {
      final altDiff = localEnd.difference(localStart.subtract(DateTime.now().timeZoneOffset));
      if (!altDiff.isNegative && altDiff < const Duration(days: 30)) {
        diff = altDiff;
      } else {
        diff = Duration.zero;
      }
    }
    return diff;
  }

  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).abs();
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m';
  }

  String get formattedDurationHms {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).abs();
    final seconds = d.inSeconds.remainder(60).abs();
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cashierName': cashierName,
        'cashDeskName': cashDeskName,
        'storeName': storeName,
        'openedAt': openedAt.toUtc().toIso8601String(),
        'openingCash': openingCash,
        'closedAt': closedAt?.toUtc().toIso8601String(),
        'cashSalesTotal': cashSalesTotal,
        'closingCashCounted': closingCashCounted,
        'discrepancy': discrepancy,
        'note': note,
        'isClosed': isClosed,
        'salesCount': salesCount,
        'totalSalesAmount': totalSalesAmount,
        'paymentMethodsBreakdown': paymentMethodsBreakdown,
      };

  factory CashShift.fromJson(Map<String, dynamic> j) {
    Map<String, double> breakdown = {};
    final rawBreakdown = j['paymentMethodsBreakdown'] ?? j['payment_methods_breakdown'];
    if (rawBreakdown is Map) {
      rawBreakdown.forEach((k, v) {
        breakdown[k.toString()] = (v as num?)?.toDouble() ?? 0.0;
      });
    }

    final cashSales = (j['cashSalesTotal'] ?? j['cash_sales_total'] ?? j['cash_sales']) as num?;
    final totalSales = (j['totalSalesAmount'] ?? j['total_sales_amount'] ?? j['total_sales']) as num?;
    final finalCashSales = cashSales?.toDouble() ?? 0.0;
    final finalTotalSales = totalSales?.toDouble() ?? finalCashSales;

    final idStr = (j['id'] ?? '').toString();
    DateTime? parsedOpened;
    if (idStr.startsWith('shift_')) {
      final ms = int.tryParse(idStr.replaceFirst('shift_', ''));
      if (ms != null && ms > 1600000000000) {
        parsedOpened = DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    if (parsedOpened == null) {
      final rawOpen = (j['openedAt'] ?? j['opened_at'] ?? '').toString();
      if (rawOpen.isNotEmpty) {
        final dt = DateTime.tryParse(rawOpen);
        if (dt != null) {
          parsedOpened = dt.toLocal();
        }
      }
    }

    DateTime? parsedClosed;
    final rawClosed = (j['closedAt'] ?? j['closed_at'])?.toString();
    if (rawClosed != null && rawClosed.isNotEmpty) {
      final dt = DateTime.tryParse(rawClosed);
      if (dt != null) {
        parsedClosed = dt.toLocal();
      }
    }

    return CashShift(
      id: idStr,
      cashierName: (j['cashierName'] ?? j['cashier_name'] ?? '').toString(),
      cashDeskName: ((j['cashDeskName'] ?? j['cash_desk_name'] ?? '').toString()).isNotEmpty
          ? (j['cashDeskName'] ?? j['cash_desk_name']).toString()
          : 'Caisse Principale',
      storeName: (j['storeName'] ?? j['store_name'] ?? '').toString(),
      openedAt: parsedOpened ?? DateTime.now(),
      openingCash: (j['openingCash'] ?? j['opening_cash'] as num?)?.toDouble() ?? 0.0,
      closedAt: parsedClosed,
      cashSalesTotal: finalCashSales,
      closingCashCounted: (j['closingCashCounted'] ?? j['closing_cash'] as num?)?.toDouble() ?? 0.0,
      discrepancy: (j['discrepancy'] as num?)?.toDouble() ?? 0.0,
      note: (j['note'] ?? '').toString(),
      isClosed: (j['isClosed'] ?? j['is_closed']) as bool? ?? false,
      salesCount: (j['salesCount'] ?? j['sales_count'] as num?)?.toInt() ?? 0,
      totalSalesAmount: finalTotalSales,
      paymentMethodsBreakdown: breakdown,
    );
  }
}


