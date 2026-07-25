import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_movement.freezed.dart';
part 'stock_movement.g.dart';

/// Fila de `GET /inventory/products/:id/movements`.
@freezed
sealed class StockMovement with _$StockMovement {
  const StockMovement._();

  const factory StockMovement({
    required String id,
    required String productId,
    required String warehouseId,
    required String movementType,
    required String quantity,
    String? unitCost,
    String? referenceType,
    String? referenceId,
    String? notes,
    required DateTime createdAt,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);

  double get quantityValue => double.parse(quantity);
  bool get isInbound => movementType.endsWith('_in');

  String get typeLabel => switch (movementType) {
        'purchase_in' => 'Compra',
        'sale_out' => 'Venta',
        'return_in' => 'Devolución entrada',
        'return_out' => 'Devolución salida',
        'transfer_in' => 'Transferencia entrada',
        'transfer_out' => 'Transferencia salida',
        'adjustment_in' => 'Ajuste entrada',
        'adjustment_out' => 'Ajuste salida',
        _ => movementType,
      };
}
