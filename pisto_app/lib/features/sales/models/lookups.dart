import 'package:freezed_annotation/freezed_annotation.dart';

part 'lookups.freezed.dart';
part 'lookups.g.dart';

@freezed
sealed class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    required String name,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
}

@freezed
sealed class DocumentType with _$DocumentType {
  const factory DocumentType({
    required String id,
    required String name,
    required String code,
  }) = _DocumentType;

  factory DocumentType.fromJson(Map<String, dynamic> json) =>
      _$DocumentTypeFromJson(json);
}

@freezed
sealed class Tax with _$Tax {
  const factory Tax({
    required String id,
    required String name,
    required String rate,
  }) = _Tax;

  factory Tax.fromJson(Map<String, dynamic> json) => _$TaxFromJson(json);
}

/// Minimal views of inventory entities the sales flow needs as a catalog.
/// The full model lives in the inventory feature.
@freezed
sealed class ProductRef with _$ProductRef {
  const ProductRef._();

  const factory ProductRef({
    required String id,
    required String name,
    String? sku,
    required String salePrice,
  }) = _ProductRef;

  factory ProductRef.fromJson(Map<String, dynamic> json) =>
      _$ProductRefFromJson(json);

  double get salePriceValue => double.parse(salePrice);
}

@freezed
sealed class WarehouseRef with _$WarehouseRef {
  const factory WarehouseRef({
    required String id,
    required String name,
  }) = _WarehouseRef;

  factory WarehouseRef.fromJson(Map<String, dynamic> json) =>
      _$WarehouseRefFromJson(json);
}
