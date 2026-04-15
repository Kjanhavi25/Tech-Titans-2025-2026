// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      cartItemId: json['cartItemId'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      quantity: (json['quantity'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      addedAt: DateTime.parse(json['addedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      'cartItemId': instance.cartItemId,
      'userId': instance.userId,
      'productId': instance.productId,
      'productName': instance.productName,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'quantity': instance.quantity,
      'weight': instance.weight,
      'addedAt': instance.addedAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
