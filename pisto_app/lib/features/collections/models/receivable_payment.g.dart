// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receivable_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReceivablePayment _$ReceivablePaymentFromJson(Map<String, dynamic> json) =>
    _ReceivablePayment(
      id: json['id'] as String,
      accountReceivableId: json['accountReceivableId'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      receiptNumber: json['receiptNumber'] as String?,
      amount: json['amount'] as String,
      paymentDate: json['paymentDate'] as String,
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReceivablePaymentToJson(_ReceivablePayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountReceivableId': instance.accountReceivableId,
      'paymentMethodId': instance.paymentMethodId,
      'receiptNumber': instance.receiptNumber,
      'amount': instance.amount,
      'paymentDate': instance.paymentDate,
      'reference': instance.reference,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
