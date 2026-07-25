// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockMovement _$StockMovementFromJson(Map<String, dynamic> json) =>
    _StockMovement(
      id: json['id'] as String,
      productId: json['productId'] as String,
      warehouseId: json['warehouseId'] as String,
      movementType: json['movementType'] as String,
      quantity: json['quantity'] as String,
      unitCost: json['unitCost'] as String?,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StockMovementToJson(_StockMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'warehouseId': instance.warehouseId,
      'movementType': instance.movementType,
      'quantity': instance.quantity,
      'unitCost': instance.unitCost,
      'referenceType': instance.referenceType,
      'referenceId': instance.referenceId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
