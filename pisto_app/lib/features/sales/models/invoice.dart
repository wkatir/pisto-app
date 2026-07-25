import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
sealed class Invoice with _$Invoice {
  const Invoice._();

  const factory Invoice({
    required String id,
    String? customerId,
    required String documentTypeId,
    required String warehouseId,
    required String saleNumber,
    required String saleDate,
    String? dueDate,
    required String status,
    required String paymentStatus,
    required String subtotal,
    required String taxAmount,
    required String discountAmount,
    required String total,
    String? notes,
    required DateTime createdAt,

    /// Solo presente en el listado (`GET /sales/invoices`), viene del join.
    String? customerName,

    /// Solo presentes en el detalle (`GET /sales/invoices/:id`).
    List<InvoiceItem>? lines,
    List<SalePayment>? payments,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  double get totalValue => double.parse(total);
  bool get cancelled => status == 'cancelled';
  bool get isCredit => paymentStatus == 'credit';

  String get statusLabel => switch (status) {
        'completed' => 'Completada',
        'cancelled' => 'Cancelada',
        _ => status,
      };

  String get paymentStatusLabel => switch (paymentStatus) {
        'paid' => 'Pagada',
        'credit' => 'Crédito',
        'overdue' => 'Vencida',
        _ => paymentStatus,
      };
}

@freezed
sealed class InvoiceItem with _$InvoiceItem {
  const InvoiceItem._();

  const factory InvoiceItem({
    required String id,
    required String saleId,
    required String productId,
    required String quantity,
    required String unitPrice,
    required String discountPct,
    required String discountAmount,
    String? taxId,
    required String taxAmount,
    required String lineTotal,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  double get quantityValue => double.parse(quantity);
  double get lineTotalValue => double.parse(lineTotal);
}

@freezed
sealed class SalePayment with _$SalePayment {
  const factory SalePayment({
    required String id,
    required String saleId,
    required String paymentMethodId,
    required String amount,
    String? reference,
    required String paymentDate,
  }) = _SalePayment;

  factory SalePayment.fromJson(Map<String, dynamic> json) =>
      _$SalePaymentFromJson(json);
}

/// Line for `POST /sales/invoices`: amounts in API format (2 decimals).
class SaleLineInput {
  final String productId;
  final double quantity;
  final double unitPrice;
  final double discountPct;
  final String? taxId;

  const SaleLineInput({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.discountPct = 0,
    this.taxId,
  });

  double get total => unitPrice * quantity * (1 - discountPct / 100);

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity.toStringAsFixed(2),
        'unitPrice': unitPrice.toStringAsFixed(2),
        if (discountPct > 0) 'discountPct': discountPct.toStringAsFixed(2),
        if (taxId != null) 'taxId': taxId,
      };

  SaleLineInput copyWith({
    double? quantity,
    double? unitPrice,
    double? discountPct,
    String? Function()? taxId,
  }) =>
      SaleLineInput(
        productId: productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        discountPct: discountPct ?? this.discountPct,
        taxId: taxId != null ? taxId() : this.taxId,
      );
}
