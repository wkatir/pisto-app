// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aging_bucket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AgingBucket _$AgingBucketFromJson(Map<String, dynamic> json) => _AgingBucket(
  range: json['range'] as String,
  count: (json['count'] as num).toInt(),
  total: json['total'] as String,
);

Map<String, dynamic> _$AgingBucketToJson(_AgingBucket instance) =>
    <String, dynamic>{
      'range': instance.range,
      'count': instance.count,
      'total': instance.total,
    };
