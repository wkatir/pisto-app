// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  customerId: json['customerId'] as String?,
  documentTypeId: json['documentTypeId'] as String,
  warehouseId: json['warehouseId'] as String,
  saleNumber: json['saleNumber'] as String,
  saleDate: json['saleDate'] as String,
  dueDate: json['dueDate'] as String?,
  status: json['status'] as String,
  paymentStatus: json['paymentStatus'] as String,
  subtotal: json['subtotal'] as String,
  taxAmount: json['taxAmount'] as String,
  discountAmount: json['discountAmount'] as String,
  total: json['total'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  customerName: json['customerName'] as String?,
  lines: (json['lines'] as List<dynamic>?)
      ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>?)
      ?.map((e) => SalePayment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'documentTypeId': instance.documentTypeId,
  'warehouseId': instance.warehouseId,
  'saleNumber': instance.saleNumber,
  'saleDate': instance.saleDate,
  'dueDate': instance.dueDate,
  'status': instance.status,
  'paymentStatus': instance.paymentStatus,
  'subtotal': instance.subtotal,
  'taxAmount': instance.taxAmount,
  'discountAmount': instance.discountAmount,
  'total': instance.total,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'customerName': instance.customerName,
  'lines': instance.lines,
  'payments': instance.payments,
};

_InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => _InvoiceItem(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  productId: json['productId'] as String,
  quantity: json['quantity'] as String,
  unitPrice: json['unitPrice'] as String,
  discountPct: json['discountPct'] as String,
  discountAmount: json['discountAmount'] as String,
  taxId: json['taxId'] as String?,
  taxAmount: json['taxAmount'] as String,
  lineTotal: json['lineTotal'] as String,
);

Map<String, dynamic> _$InvoiceItemToJson(_InvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'productId': instance.productId,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'discountPct': instance.discountPct,
      'discountAmount': instance.discountAmount,
      'taxId': instance.taxId,
      'taxAmount': instance.taxAmount,
      'lineTotal': instance.lineTotal,
    };

_SalePayment _$SalePaymentFromJson(Map<String, dynamic> json) => _SalePayment(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  paymentMethodId: json['paymentMethodId'] as String,
  amount: json['amount'] as String,
  reference: json['reference'] as String?,
  paymentDate: json['paymentDate'] as String,
);

Map<String, dynamic> _$SalePaymentToJson(_SalePayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'paymentMethodId': instance.paymentMethodId,
      'amount': instance.amount,
      'reference': instance.reference,
      'paymentDate': instance.paymentDate,
    };
