import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Fila de `GET /inventory/products` (lista con joins). Los campos de join
/// (`categoryName`, `unitCode`, `totalStock`) no vienen en las respuestas de
/// create/update, pero esas no se parsean: las mutaciones invalidan la lista.
@freezed
sealed class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    String? sku,
    String? barcode,
    required String name,
    required String costPrice,
    required String salePrice,
    required String minStock,
    required bool isService,
    required bool isTaxable,
    required bool isActive,
    String? imageUrl,
    String? categoryName,
    String? unitCode,
    required String totalStock,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  double get salePriceValue => double.parse(salePrice);
  double get costPriceValue => double.parse(costPrice);
  double get totalStockValue => double.parse(totalStock);

  String get stockDisplay => totalStockValue % 1 == 0
      ? totalStockValue.toStringAsFixed(0)
      : totalStockValue.toStringAsFixed(2);
}

/// Row from `GET /inventory/alerts` — products with stock below the minimum.
@freezed
sealed class LowStockAlert with _$LowStockAlert {
  const LowStockAlert._();

  const factory LowStockAlert({
    required String productId,
    required String productName,
    String? sku,
    required String minStock,
    required String totalStock,
  }) = _LowStockAlert;

  factory LowStockAlert.fromJson(Map<String, dynamic> json) =>
      _$LowStockAlertFromJson(json);

  double get minStockValue => double.parse(minStock);
  double get totalStockValue => double.parse(totalStock);
}
