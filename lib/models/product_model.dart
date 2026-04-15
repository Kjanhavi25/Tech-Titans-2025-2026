import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final double? weight;
  final String category;
  final String? description;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String ownerId; // Required for multi-user isolation
  final String? createdBy;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.weight,
    required this.category,
    this.description,
    this.quantity = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    required this.ownerId,
    this.createdBy,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return ProductModel(
      productId: json['productId']?.toString() ?? 'UNKNOWN',
      productName: json['productName']?.toString() ?? 'Unnamed Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      weight: (json['weight'] as num?)?.toDouble(),
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      isActive: json['isActive'] == true || json['isActive'] == null,
      ownerId: json['ownerId']?.toString() ?? 'SYSTEM_LEGACY',
      createdBy: json['createdBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'imageUrl': imageUrl,
    'weight': weight,
    'category': category,
    'description': description,
    'quantity': quantity,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'ownerId': ownerId,
    'createdBy': createdBy,
  };

  factory ProductModel.fromQRData(Map<String, dynamic> qrData) {
    return ProductModel(
      productId: qrData['productId'] ?? '',
      productName: qrData['productName'] ?? 'Unknown',
      price: (qrData['price'] ?? 0).toDouble(),
      imageUrl: qrData['imageUrl'] ?? '',
      weight: qrData['weight'] != null ? (qrData['weight']).toDouble() : null,
      category: qrData['category'] ?? 'General',
      description: qrData['description'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerId: qrData['ownerId'] ?? 'SYSTEM',
      createdBy: qrData['createdBy'],
    );
  }

  ProductModel copyWith({
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    double? weight,
    String? category,
    String? description,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? ownerId,
    String? createdBy,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      weight: weight ?? this.weight,
      category: category ?? this.category,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() => 'ProductModel(id: $productId, name: $productName, ownerId: $ownerId)';
}
