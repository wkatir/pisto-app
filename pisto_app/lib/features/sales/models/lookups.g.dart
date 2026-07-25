// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookups.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    _PaymentMethod(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$PaymentMethodToJson(_PaymentMethod instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_DocumentType _$DocumentTypeFromJson(Map<String, dynamic> json) =>
    _DocumentType(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$DocumentTypeToJson(_DocumentType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
    };

_Tax _$TaxFromJson(Map<String, dynamic> json) => _Tax(
  id: json['id'] as String,
  name: json['name'] as String,
  rate: json['rate'] as String,
);

Map<String, dynamic> _$TaxToJson(_Tax instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'rate': instance.rate,
};

_ProductRef _$ProductRefFromJson(Map<String, dynamic> json) => _ProductRef(
  id: json['id'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String?,
  salePrice: json['salePrice'] as String,
);

Map<String, dynamic> _$ProductRefToJson(_ProductRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sku': instance.sku,
      'salePrice': instance.salePrice,
    };

_WarehouseRef _$WarehouseRefFromJson(Map<String, dynamic> json) =>
    _WarehouseRef(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$WarehouseRefToJson(_WarehouseRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
