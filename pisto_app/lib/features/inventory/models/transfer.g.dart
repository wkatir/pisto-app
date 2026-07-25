// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transfer _$TransferFromJson(Map<String, dynamic> json) => _Transfer(
  id: json['id'] as String,
  fromWarehouseId: json['fromWarehouseId'] as String,
  toWarehouseId: json['toWarehouseId'] as String,
  status: json['status'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$TransferToJson(_Transfer instance) => <String, dynamic>{
  'id': instance.id,
  'fromWarehouseId': instance.fromWarehouseId,
  'toWarehouseId': instance.toWarehouseId,
  'status': instance.status,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};
