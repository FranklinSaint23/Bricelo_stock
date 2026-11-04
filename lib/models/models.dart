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
  }) : wholesalePrice = wholesalePrice ?? (sellPrice * 0.9);

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
      };

  factory Product.fromJson(Map<String, dynamic> j) {
    final sell = (j['sellPrice'] ?? j['price'] ?? 0).toDouble();
    final buy = (j['buyPrice'] ?? j['purchase_price'] ?? (sell * 0.7)).toDouble();
    return Product(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      category: (j['category'] ?? 'Non catégorisé').toString(),
      barcode: (j['barcode'] ?? '').toString(),
      buyPrice: buy,
      sellPrice: sell,
      wholesalePrice: (j['wholesalePrice'] as num?)?.toDouble() ?? (sell * 0.9),
      stock: (j['stock'] as num?)?.toInt() ?? 0,
      minStockAlert: (j['minStockAlert'] ?? j['min_stock'] ?? 5 as num).toInt(),
      unit: (j['unit'] ?? 'Pièce').toString(),
      productType: (j['productType'] ?? j['product_type'] ?? 'Produit').toString(),
      isSyncedToBricelo: j['isSyncedToBricelo'] as bool? ?? true,
      supplierName: j['supplierName']?.toString(),
      imageUrl: j['imageUrl']?.toString(),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;
  double unitPrice;
  double discount;
  bool isWholesale;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.unitPrice,
    this.discount = 0,
    this.isWholesale = false,
  });

  double get subtotal => quantity * unitPrice;
  double get total => (quantity * unitPrice) - discount;
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

  SaleItemSummary({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': total,
      };

  factory SaleItemSummary.fromJson(Map<String, dynamic> j) {
    final qty = (j['quantity'] as num?)?.toInt() ?? 1;
    final up = ((j['unitPrice'] ?? j['unit_price'] ?? 0) as num).toDouble();
    return SaleItemSummary(
      productName: (j['productName'] ?? j['product_name'] ?? '').toString(),
      quantity: qty,
      unitPrice: up,
      total: (j['total'] as num?)?.toDouble() ?? (qty * up).toDouble(),
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
    this.discountTotal = 0,
    required this.paymentMethod,
    required this.amountReceived,
    this.changeReturned = 0,
    this.customerName = 'Client Comptoir',
    this.customerPhone = '',
    this.cashierName = 'Gérant',
    this.storeName = 'Boutique Principale',
  });

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

  factory Sale.fromJson(Map<String, dynamic> j) => Sale(
        id: (j['id'] ?? '').toString(),
        ticketNumber: (j['ticketNumber'] ?? j['id'] ?? 'SP-1001').toString(),
        createdAt: DateTime.tryParse((j['createdAt'] ?? j['sale_date'] ?? j['created_at'] ?? '').toString()) ?? DateTime.now(),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => SaleItemSummary.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        total: (j['total'] ?? j['total_amount'] ?? 0 as num).toDouble(),
        discountTotal: (j['discountTotal'] as num?)?.toDouble() ?? 0,
        paymentMethod: (j['paymentMethod'] ?? j['payment_method'] ?? 'Espèces').toString(),
        amountReceived: (j['amountReceived'] ?? j['amount_received'] ?? j['total'] ?? 0 as num).toDouble(),
        changeReturned: (j['changeReturned'] ?? j['change_returned'] ?? 0 as num).toDouble(),
        customerName: (j['customerName'] ?? j['customer_name'] ?? 'Client Comptoir').toString(),
        customerPhone: (j['customerPhone'] ?? '').toString(),
        cashierName: (j['cashierName'] ?? j['cashier_name'] ?? 'Gérant').toString(),
        storeName: (j['storeName'] ?? j['store_name'] ?? 'Boutique Principale').toString(),
      );
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

  SupplierDebt({
    required this.id,
    required this.supplierName,
    required this.supplierPhone,
    required this.invoiceRef,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.createdAt,
    required this.dueDate,
  });

  double get remainingDebt => totalAmount - paidAmount;
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
      );
}

class Expense {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime createdAt;
  final String paidBy;

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.createdAt,
    this.paidBy = 'Gérant',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'description': description,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'paidBy': paidBy,
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: (j['id'] ?? '').toString(),
        category: (j['category'] ?? 'Autre charge').toString(),
        description: (j['description'] ?? j['title'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse((j['createdAt'] ?? j['expense_date'] ?? '').toString()) ?? DateTime.now(),
        paidBy: (j['paidBy'] ?? j['beneficiary'] ?? 'Gérant').toString(),
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
