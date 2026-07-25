// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PurchaseOrder _$PurchaseOrderFromJson(Map<String, dynamic> json) =>
    _PurchaseOrder(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      warehouseId: json['warehouseId'] as String,
      orderNumber: json['orderNumber'] as String,
      orderDate: json['orderDate'] as String,
      expectedDate: json['expectedDate'] as String?,
      status: json['status'] as String,
      subtotal: json['subtotal'] as String,
      taxAmount: json['taxAmount'] as String,
      total: json['total'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lines: (json['lines'] as List<dynamic>?)
          ?.map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PurchaseOrderToJson(_PurchaseOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplierId': instance.supplierId,
      'warehouseId': instance.warehouseId,
      'orderNumber': instance.orderNumber,
      'orderDate': instance.orderDate,
      'expectedDate': instance.expectedDate,
      'status': instance.status,
      'subtotal': instance.subtotal,
      'taxAmount': instance.taxAmount,
      'total': instance.total,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'lines': instance.lines,
    };

_PurchaseOrderItem _$PurchaseOrderItemFromJson(Map<String, dynamic> json) =>
    _PurchaseOrderItem(
      id: json['id'] as String,
      purchaseOrderId: json['purchaseOrderId'] as String,
      productId: json['productId'] as String,
      quantityOrdered: json['quantityOrdered'] as String,
      quantityReceived: json['quantityReceived'] as String,
      unitCost: json['unitCost'] as String,
      taxId: json['taxId'] as String?,
      taxAmount: json['taxAmount'] as String,
      lineTotal: json['lineTotal'] as String,
    );

Map<String, dynamic> _$PurchaseOrderItemToJson(_PurchaseOrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchaseOrderId': instance.purchaseOrderId,
      'productId': instance.productId,
      'quantityOrdered': instance.quantityOrdered,
      'quantityReceived': instance.quantityReceived,
      'unitCost': instance.unitCost,
      'taxId': instance.taxId,
      'taxAmount': instance.taxAmount,
      'lineTotal': instance.lineTotal,
    };
