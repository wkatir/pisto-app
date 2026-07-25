// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payable _$PayableFromJson(Map<String, dynamic> json) => _Payable(
  id: json['id'] as String,
  supplierId: json['supplierId'] as String,
  purchaseOrderId: json['purchaseOrderId'] as String,
  originalAmount: json['originalAmount'] as String,
  balance: json['balance'] as String,
  dueDate: json['dueDate'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PayableToJson(_Payable instance) => <String, dynamic>{
  'id': instance.id,
  'supplierId': instance.supplierId,
  'purchaseOrderId': instance.purchaseOrderId,
  'originalAmount': instance.originalAmount,
  'balance': instance.balance,
  'dueDate': instance.dueDate,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
};

_PayableRow _$PayableRowFromJson(Map<String, dynamic> json) => _PayableRow(
  payable: Payable.fromJson(json['payable'] as Map<String, dynamic>),
  supplierName: json['supplierName'] as String?,
);

Map<String, dynamic> _$PayableRowToJson(_PayableRow instance) =>
    <String, dynamic>{
      'payable': instance.payable,
      'supplierName': instance.supplierName,
    };
