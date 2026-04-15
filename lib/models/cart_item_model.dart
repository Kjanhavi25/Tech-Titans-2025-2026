import 'product_model.dart';

class CartItemModel {
  final String cartItemId;
  final String userId;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;
  final double? weight;
  final String ownerId; // Made required for multi-owner tracking
  final DateTime addedAt;
  final DateTime updatedAt;

  double get totalPrice => price * quantity;

  CartItemModel({
    required this.cartItemId,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.weight,
    required this.ownerId,
    required this.addedAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cartItemId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
      ownerId: json['ownerId'] as String? ?? 'SYSTEM',
      addedAt: json['addedAt'] != null 
          ? DateTime.tryParse(json['addedAt']) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'cartItemId': cartItemId,
    'userId': userId,
    'productId': productId,
    'productName': productName,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'weight': weight,
    'ownerId': ownerId,
    'addedAt': addedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CartItemModel.fromProduct(ProductModel product, String userId) {
    return CartItemModel(
      cartItemId: product.productId,
      userId: userId,
      productId: product.productId,
      productName: product.productName,
      price: product.price,
      imageUrl: product.imageUrl,
      quantity: 1,
      weight: product.weight,
      ownerId: product.ownerId,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  CartItemModel copyWith({
    String? cartItemId,
    String? userId,
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? quantity,
    double? weight,
    String? ownerId,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      cartItemId: cartItemId ?? this.cartItemId,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      ownerId: ownerId ?? this.ownerId,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'CartItemModel(id: $cartItemId, product: $productName, owner: $ownerId)';
}
