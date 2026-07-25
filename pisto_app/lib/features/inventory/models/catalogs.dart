import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalogs.freezed.dart';
part 'catalogs.g.dart';

@freezed
sealed class Category with _$Category {
  const factory Category({
    required String id,
    String? parentId,
    required String name,
    String? description,
    required bool isActive,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

@freezed
sealed class Warehouse with _$Warehouse {
  const factory Warehouse({
    required String id,
    required String name,
    String? address,
    required bool isActive,
  }) = _Warehouse;

  factory Warehouse.fromJson(Map<String, dynamic> json) =>
      _$WarehouseFromJson(json);
}

@freezed
sealed class UnitOfMeasure with _$UnitOfMeasure {
  const factory UnitOfMeasure({
    required String id,
    required String code,
    required String name,
  }) = _UnitOfMeasure;

  factory UnitOfMeasure.fromJson(Map<String, dynamic> json) =>
      _$UnitOfMeasureFromJson(json);
}
