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

  double get margin => sellPrice - buyPrice;
  double get marginPercent => buyPrice > 0 ? ((sellPrice - buyPrice) / buyPrice) * 100 : 0;
  double get wholesaleMargin => wholesalePrice - buyPrice;
  bool get isLowStock => productType != 'Service' && stock <= minStockAlert && stock > 0;
  bool get isOutOfStock => productType != 'Service' && stock <= 0;

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
  final String customerName;
  final String customerPhone;
  final String customerCity;
  final double initialDebt;
  double paidAmount;
  final DateTime createdAt;
  DateTime lastPaymentDate;
  final List<String> itemsSummary;
  final List<DebtPayment> payments;

  CustomerDebt({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerCity = '',
    required this.initialDebt,
    this.paidAmount = 0,
    required this.createdAt,
    required this.lastPaymentDate,
    required this.itemsSummary,
    List<DebtPayment>? payments,
  }) : payments = payments ?? [];

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
