// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    _NotificationItem(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      readAt: json['readAt'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationItemToJson(_NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'readAt': instance.readAt,
      'createdAt': instance.createdAt.toIso8601String(),
    };
