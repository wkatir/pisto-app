// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Customer _$CustomerFromJson(Map<String, dynamic> json) => _Customer(
  id: json['id'] as String,
  customerType: json['customerType'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  companyName: json['companyName'] as String?,
  taxId: json['taxId'] as String?,
  taxReg: json['taxReg'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  creditLimit: json['creditLimit'] as String,
  creditDays: (json['creditDays'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CustomerToJson(_Customer instance) => <String, dynamic>{
  'id': instance.id,
  'customerType': instance.customerType,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'companyName': instance.companyName,
  'taxId': instance.taxId,
  'taxReg': instance.taxReg,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'creditLimit': instance.creditLimit,
  'creditDays': instance.creditDays,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};
