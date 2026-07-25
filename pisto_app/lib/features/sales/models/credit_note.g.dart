// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditNote _$CreditNoteFromJson(Map<String, dynamic> json) => _CreditNote(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  customerId: json['customerId'] as String,
  noteNumber: json['noteNumber'] as String,
  reason: json['reason'] as String,
  total: json['total'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CreditNoteToJson(_CreditNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'customerId': instance.customerId,
      'noteNumber': instance.noteNumber,
      'reason': instance.reason,
      'total': instance.total,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };
