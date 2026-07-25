// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Supplier _$SupplierFromJson(Map<String, dynamic> json) => _Supplier(
  id: json['id'] as String,
  companyName: json['companyName'] as String,
  contactName: json['contactName'] as String?,
  taxId: json['taxId'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  paymentTerms: (json['paymentTerms'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SupplierToJson(_Supplier instance) => <String, dynamic>{
  'id': instance.id,
  'companyName': instance.companyName,
  'contactName': instance.contactName,
  'taxId': instance.taxId,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'paymentTerms': instance.paymentTerms,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};
