// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_statement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerStatement _$CustomerStatementFromJson(Map<String, dynamic> json) =>
    _CustomerStatement(
      receivables: (json['receivables'] as List<dynamic>)
          .map((e) => ReceivableEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CustomerStatementToJson(_CustomerStatement instance) =>
    <String, dynamic>{'receivables': instance.receivables};

_ReceivableEntry _$ReceivableEntryFromJson(Map<String, dynamic> json) =>
    _ReceivableEntry(
      receivable: Receivable.fromJson(
        json['receivable'] as Map<String, dynamic>,
      ),
      saleNumber: json['saleNumber'] as String?,
    );

Map<String, dynamic> _$ReceivableEntryToJson(_ReceivableEntry instance) =>
    <String, dynamic>{
      'receivable': instance.receivable,
      'saleNumber': instance.saleNumber,
    };

_Receivable _$ReceivableFromJson(Map<String, dynamic> json) => _Receivable(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  originalAmount: json['originalAmount'] as String,
  balance: json['balance'] as String,
  dueDate: json['dueDate'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$ReceivableToJson(_Receivable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'originalAmount': instance.originalAmount,
      'balance': instance.balance,
      'dueDate': instance.dueDate,
      'status': instance.status,
    };
