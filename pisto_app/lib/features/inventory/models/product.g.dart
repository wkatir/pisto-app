// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  sku: json['sku'] as String?,
  barcode: json['barcode'] as String?,
  name: json['name'] as String,
  costPrice: json['costPrice'] as String,
  salePrice: json['salePrice'] as String,
  minStock: json['minStock'] as String,
  isService: json['isService'] as bool,
  isTaxable: json['isTaxable'] as bool,
  isActive: json['isActive'] as bool,
  imageUrl: json['imageUrl'] as String?,
  categoryName: json['categoryName'] as String?,
  unitCode: json['unitCode'] as String?,
  totalStock: json['totalStock'] as String,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'sku': instance.sku,
  'barcode': instance.barcode,
  'name': instance.name,
  'costPrice': instance.costPrice,
  'salePrice': instance.salePrice,
  'minStock': instance.minStock,
  'isService': instance.isService,
  'isTaxable': instance.isTaxable,
  'isActive': instance.isActive,
  'imageUrl': instance.imageUrl,
  'categoryName': instance.categoryName,
  'unitCode': instance.unitCode,
  'totalStock': instance.totalStock,
};

_LowStockAlert _$LowStockAlertFromJson(Map<String, dynamic> json) =>
    _LowStockAlert(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      sku: json['sku'] as String?,
      minStock: json['minStock'] as String,
      totalStock: json['totalStock'] as String,
    );

Map<String, dynamic> _$LowStockAlertToJson(_LowStockAlert instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'sku': instance.sku,
      'minStock': instance.minStock,
      'totalStock': instance.totalStock,
    };
