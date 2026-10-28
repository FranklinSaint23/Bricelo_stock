// Modèles de données Stock Prime (by BRICÉLO)
// Adaptés au commerce de détail et de gros au Cameroun

class Product {
  final String id;
  final String name;
  final String category;
  final String barcode;
  final double buyPrice;          // Prix d'achat (PAMP)
  final double sellPrice;         // Prix de vente détail
  final double wholesalePrice;    // Prix de vente gros (très utilisé dans les marchés)
  int stock;
  final int minStockAlert;
  final String unit;              // Pièce, Carton, Paquet, Sac, Litre, etc.
  bool isSyncedToBricelo;
  final String? supplierName;
  final String? imageUrl;

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
    this.isSyncedToBricelo = true,
    this.supplierName = 'Grossiste Akwa',
    this.imageUrl,
  }) : wholesalePrice = wholesalePrice ?? (sellPrice * 0.88);

  double get margin => sellPrice - buyPrice;
  double get marginPercent => buyPrice > 0 ? ((sellPrice - buyPrice) / buyPrice) * 100 : 0;
  double get wholesaleMargin => wholesalePrice - buyPrice;
  bool get isLowStock => stock <= minStockAlert && stock > 0;
  bool get isOutOfStock => stock <= 0;
}

class CartItem {
  final Product product;
  int quantity;
  double unitPrice;
  double discount;         // Remise en FCFA
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
}

class Sale {
  final String id;
  final String ticketNumber;
  final DateTime createdAt;
  final List<SaleItemSummary> items;
  final double total;
  final double discountTotal;
  final String paymentMethod; // 'Espèces', 'Orange Money', 'MTN MoMo', 'Carte / Virement', 'À Crédit'
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
    this.cashierName = 'Caissier Principal',
    this.storeName = 'Boutique BRICÉLO Akwa',
  });
}

class DebtPayment {
  final String id;
  final double amount;
  final DateTime date;
  final String paymentMethod; // 'Espèces', 'Orange Money', 'MTN MoMo'
  final String note;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.note = 'Versement acompte',
  });
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
    this.customerCity = 'Douala',
    required this.initialDebt,
    this.paidAmount = 0,
    required this.createdAt,
    required this.lastPaymentDate,
    required this.itemsSummary,
    List<DebtPayment>? payments,
  }) : payments = payments ?? [];

  double get remainingDebt => initialDebt - paidAmount;
  bool get isSettled => remainingDebt <= 0;
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
}

class Expense {
  final String id;
  final String category; // 'Transport / Taxi', 'Ration / Repas', 'Électricité / Eau', 'Emballage / Sachets', 'Loyer magasin', 'Autre charge'
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
    this.paidBy = 'Caissier Principal',
  });
}

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'RÉASSORT (+)', 'VENTE (-)', 'AVARIE / PERTE (-)', 'AJUSTEMENT'
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
}
