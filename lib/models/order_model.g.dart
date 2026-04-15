// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'price': instance.price,
      'quantity': instance.quantity,
      'weight': instance.weight,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  orderId: json['orderId'] as String,
  userId: json['userId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toDouble(),
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
  paymentStatus:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['paymentStatus']) ??
      PaymentStatus.unpaid,
  paymentQRCode: json['paymentQRCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'userId': instance.userId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'paymentQRCode': instance.paymentQRCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.paid: 'paid',
  PaymentStatus.failed: 'failed',
};
