import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_order.freezed.dart';
part 'purchase_order.g.dart';

@freezed
sealed class PurchaseOrder with _$PurchaseOrder {
  const PurchaseOrder._();

  const factory PurchaseOrder({
    required String id,
    required String supplierId,
    required String warehouseId,
    required String orderNumber,
    required String orderDate,
    String? expectedDate,
    required String status,
    required String subtotal,
    required String taxAmount,
    required String total,
    String? notes,
    required DateTime createdAt,

    /// Solo presentes en el detalle (`GET /purchases/orders/:id`).
    List<PurchaseOrderItem>? lines,
  }) = _PurchaseOrder;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderFromJson(json);

  double get totalValue => double.parse(total);
  bool get canReceive => status == 'approved' || status == 'partial';

  String get statusLabel => switch (status) {
        'draft' => 'Borrador',
        'pending' => 'Pendiente',
        'approved' => 'Aprobada',
        'partial' => 'Parcial',
        'received' => 'Recibida',
        'cancelled' => 'Cancelada',
        _ => status,
      };
}

@freezed
sealed class PurchaseOrderItem with _$PurchaseOrderItem {
  const PurchaseOrderItem._();

  const factory PurchaseOrderItem({
    required String id,
    required String purchaseOrderId,
    required String productId,
    required String quantityOrdered,
    required String quantityReceived,
    required String unitCost,
    String? taxId,
    required String taxAmount,
    required String lineTotal,
  }) = _PurchaseOrderItem;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderItemFromJson(json);

  double get quantityOrderedValue => double.parse(quantityOrdered);
  double get quantityReceivedValue => double.parse(quantityReceived);
  double get unitCostValue => double.parse(unitCost);
  double get lineTotalValue => double.parse(lineTotal);
  double get quantityPending => quantityOrderedValue - quantityReceivedValue;
}

/// Line for `POST /purchases/orders`: amounts in API format (2 decimals).
class PurchaseLineInput {
  final String productId;
  final double quantity;
  final double unitCost;
  final String? taxId;

  const PurchaseLineInput({
    required this.productId,
    required this.quantity,
    required this.unitCost,
    this.taxId,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantityOrdered': quantity.toStringAsFixed(2),
        'unitCost': unitCost.toStringAsFixed(2),
        if (taxId != null) 'taxId': taxId,
      };
}
