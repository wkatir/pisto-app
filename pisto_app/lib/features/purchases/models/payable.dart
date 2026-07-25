import 'package:freezed_annotation/freezed_annotation.dart';

part 'payable.freezed.dart';
part 'payable.g.dart';

@freezed
sealed class Payable with _$Payable {
  const Payable._();

  const factory Payable({
    required String id,
    required String supplierId,
    required String purchaseOrderId,
    required String originalAmount,
    required String balance,
    required String dueDate,
    required String status,
    required DateTime createdAt,
  }) = _Payable;

  factory Payable.fromJson(Map<String, dynamic> json) =>
      _$PayableFromJson(json);

  double get originalValue => double.parse(originalAmount);
  double get balanceValue => double.parse(balance);
  bool get isPaid => status == 'paid';
  bool get isOverdue =>
      !isPaid && DateTime.parse(dueDate).isBefore(DateTime.now());

  String get statusLabel {
    if (isPaid) return 'Pagada';
    if (isOverdue) return 'Vencida';
    return 'Pendiente';
  }
}

/// Item de `GET /purchases/payables`: `{ payable, supplierName }`.
@freezed
sealed class PayableRow with _$PayableRow {
  const factory PayableRow({
    required Payable payable,
    String? supplierName,
  }) = _PayableRow;

  factory PayableRow.fromJson(Map<String, dynamic> json) =>
      _$PayableRowFromJson(json);
}
