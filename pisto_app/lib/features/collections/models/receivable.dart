import 'package:freezed_annotation/freezed_annotation.dart';

part 'receivable.freezed.dart';
part 'receivable.g.dart';

/// Full row from `account_receivable`. The minimal view used by the account
/// statement lives in sales (`customer_statement.dart`).
@freezed
sealed class Receivable with _$Receivable {
  const Receivable._();

  const factory Receivable({
    required String id,
    required String customerId,
    required String saleId,
    required String originalAmount,
    required String balance,
    required String dueDate,
    required String status,
    required DateTime createdAt,
  }) = _Receivable;

  factory Receivable.fromJson(Map<String, dynamic> json) =>
      _$ReceivableFromJson(json);

  double get balanceValue => double.parse(balance);
  double get originalAmountValue => double.parse(originalAmount);
  bool get paid => status == 'paid';
  bool get overdue => !paid && DateTime.parse(dueDate).isBefore(DateTime.now());

  String get statusLabel {
    if (paid) return 'Pagada';
    if (overdue) return 'Vencida';
    return 'Pendiente';
  }
}

/// Item de `GET /collections/receivables` — receivable + datos del join.
@freezed
sealed class ReceivableListItem with _$ReceivableListItem {
  const factory ReceivableListItem({
    required Receivable receivable,
    String? customerName,
    String? customerPhone,
    String? saleNumber,
  }) = _ReceivableListItem;

  factory ReceivableListItem.fromJson(Map<String, dynamic> json) =>
      _$ReceivableListItemFromJson(json);
}
