enum OrderStatus { pending, confirmed, completed, cancelled }
enum PaymentStatus { unpaid, paid, failed }

class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double? weight;

  double get totalPrice => price * quantity;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.weight,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
    'weight': weight,
  };

  @override
  String toString() => 'OrderItemModel(product: $productName, qty: $quantity)';
}

class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItemModel> items;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentQRCode;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  final String ownerId; // Made required for mapping

  int get itemCount => items.length;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.total,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    this.paymentQRCode,
    required this.createdAt,
    this.completedAt,
    this.notes,
    required this.ownerId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      items: (json['items'] as List?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
          (e) => e.toString() == 'OrderStatus.${json['status']}',
          orElse: () => OrderStatus.pending),
      paymentStatus: PaymentStatus.values.firstWhere(
          (e) => e.toString() == 'PaymentStatus.${json['paymentStatus']}',
          orElse: () => PaymentStatus.unpaid),
      paymentQRCode: json['paymentQRCode'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      completedAt: json['completedAt'] != null 
          ? DateTime.tryParse(json['completedAt']) 
          : null,
      notes: json['notes'] as String?,
      ownerId: json['ownerId'] as String? ?? 'SYSTEM',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'userId': userId,
    'items': items.map((i) => i.toJson()).toList(),
    'total': total,
    'status': status.toString().split('.').last,
    'paymentStatus': paymentStatus.toString().split('.').last,
    'paymentQRCode': paymentQRCode,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'notes': notes,
    'ownerId': ownerId,
  };

  OrderModel copyWith({
    String? orderId,
    String? userId,
    List<OrderItemModel>? items,
    double? total,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentQRCode,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
    String? ownerId,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentQRCode: paymentQRCode ?? this.paymentQRCode,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  String toString() => 'OrderModel(id: $orderId, owner: $ownerId, total: $total)';
}
