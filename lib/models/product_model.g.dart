// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String,
  weight: (json['weight'] as num?)?.toDouble(),
  category: json['category'] as String,
  description: json['description'] as String?,
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'weight': instance.weight,
      'category': instance.category,
      'description': instance.description,
      'quantity': instance.quantity,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
    };
