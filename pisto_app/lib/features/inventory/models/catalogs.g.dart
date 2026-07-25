// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  parentId: json['parentId'] as String?,
  name: json['name'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'parentId': instance.parentId,
  'name': instance.name,
  'description': instance.description,
  'isActive': instance.isActive,
};

_Warehouse _$WarehouseFromJson(Map<String, dynamic> json) => _Warehouse(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$WarehouseToJson(_Warehouse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'isActive': instance.isActive,
    };

_UnitOfMeasure _$UnitOfMeasureFromJson(Map<String, dynamic> json) =>
    _UnitOfMeasure(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$UnitOfMeasureToJson(_UnitOfMeasure instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };
