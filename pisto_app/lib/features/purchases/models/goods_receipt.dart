import 'package:freezed_annotation/freezed_annotation.dart';

part 'goods_receipt.freezed.dart';
part 'goods_receipt.g.dart';

@freezed
sealed class GoodsReceipt with _$GoodsReceipt {
  const factory GoodsReceipt({
    required String id,
    required String purchaseOrderId,
    required String receiptNumber,
    required String receiptDate,
    String? notes,
    required DateTime createdAt,
  }) = _GoodsReceipt;

  factory GoodsReceipt.fromJson(Map<String, dynamic> json) =>
      _$GoodsReceiptFromJson(json);
}

/// Line for `POST /purchases/orders/:id/receive`.
class ReceiptLineInput {
  final String purchaseOrderLineId;
  final String productId;
  final double quantityReceived;

  const ReceiptLineInput({
    required this.purchaseOrderLineId,
    required this.productId,
    required this.quantityReceived,
  });

  Map<String, dynamic> toJson() => {
        'purchaseOrderLineId': purchaseOrderLineId,
        'productId': productId,
        'quantityReceived': quantityReceived.toStringAsFixed(2),
      };
}
