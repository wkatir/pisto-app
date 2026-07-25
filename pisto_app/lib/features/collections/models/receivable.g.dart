// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receivable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Receivable _$ReceivableFromJson(Map<String, dynamic> json) => _Receivable(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  saleId: json['saleId'] as String,
  originalAmount: json['originalAmount'] as String,
  balance: json['balance'] as String,
  dueDate: json['dueDate'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReceivableToJson(_Receivable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'saleId': instance.saleId,
      'originalAmount': instance.originalAmount,
      'balance': instance.balance,
      'dueDate': instance.dueDate,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_ReceivableListItem _$ReceivableListItemFromJson(Map<String, dynamic> json) =>
    _ReceivableListItem(
      receivable: Receivable.fromJson(
        json['receivable'] as Map<String, dynamic>,
      ),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      saleNumber: json['saleNumber'] as String?,
    );

Map<String, dynamic> _$ReceivableListItemToJson(_ReceivableListItem instance) =>
    <String, dynamic>{
      'receivable': instance.receivable,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'saleNumber': instance.saleNumber,
    };
