// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goods_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoodsReceipt _$GoodsReceiptFromJson(Map<String, dynamic> json) =>
    _GoodsReceipt(
      id: json['id'] as String,
      purchaseOrderId: json['purchaseOrderId'] as String,
      receiptNumber: json['receiptNumber'] as String,
      receiptDate: json['receiptDate'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GoodsReceiptToJson(_GoodsReceipt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchaseOrderId': instance.purchaseOrderId,
      'receiptNumber': instance.receiptNumber,
      'receiptDate': instance.receiptDate,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
