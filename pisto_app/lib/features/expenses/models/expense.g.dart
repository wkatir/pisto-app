// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String?,
  description: json['description'] as String,
  amount: json['amount'] as String,
  expenseDate: json['expenseDate'] as String,
  paymentMethodId: json['paymentMethodId'] as String?,
  notes: json['notes'] as String?,
  receiptUrl: json['receiptUrl'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'categoryId': instance.categoryId,
  'description': instance.description,
  'amount': instance.amount,
  'expenseDate': instance.expenseDate,
  'paymentMethodId': instance.paymentMethodId,
  'notes': instance.notes,
  'receiptUrl': instance.receiptUrl,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_ExpenseSummary _$ExpenseSummaryFromJson(Map<String, dynamic> json) =>
    _ExpenseSummary(
      total: json['total'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ExpenseSummaryToJson(_ExpenseSummary instance) =>
    <String, dynamic>{'total': instance.total, 'count': instance.count};
