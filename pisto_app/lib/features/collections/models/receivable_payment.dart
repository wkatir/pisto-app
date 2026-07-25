import 'package:freezed_annotation/freezed_annotation.dart';

part 'receivable_payment.freezed.dart';
part 'receivable_payment.g.dart';

/// Abono sobre una cuenta por cobrar (`collection_payment`).
@freezed
sealed class ReceivablePayment with _$ReceivablePayment {
  const ReceivablePayment._();

  const factory ReceivablePayment({
    required String id,
    required String accountReceivableId,
    required String paymentMethodId,
    String? receiptNumber,
    required String amount,
    required String paymentDate,
    String? reference,
    String? notes,
    required DateTime createdAt,
  }) = _ReceivablePayment;

  factory ReceivablePayment.fromJson(Map<String, dynamic> json) =>
      _$ReceivablePaymentFromJson(json);

  double get amountValue => double.parse(amount);
}
