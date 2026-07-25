import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_statement.freezed.dart';
part 'customer_statement.g.dart';

/// `GET /collections/customers/:id/statement` → `{ receivables, payments }`.
@freezed
sealed class CustomerStatement with _$CustomerStatement {
  const CustomerStatement._();

  const factory CustomerStatement({
    required List<ReceivableEntry> receivables,
  }) = _CustomerStatement;

  factory CustomerStatement.fromJson(Map<String, dynamic> json) =>
      _$CustomerStatementFromJson(json);

  double get totalPending => receivables
      .where((e) => e.receivable.status != 'paid')
      .fold(0, (sum, e) => sum + double.parse(e.receivable.balance));
}

@freezed
sealed class ReceivableEntry with _$ReceivableEntry {
  const factory ReceivableEntry({
    required Receivable receivable,
    String? saleNumber,
  }) = _ReceivableEntry;

  factory ReceivableEntry.fromJson(Map<String, dynamic> json) =>
      _$ReceivableEntryFromJson(json);
}

@freezed
sealed class Receivable with _$Receivable {
  const factory Receivable({
    required String id,
    required String saleId,
    required String originalAmount,
    required String balance,
    required String dueDate,
    required String status,
  }) = _Receivable;

  factory Receivable.fromJson(Map<String, dynamic> json) =>
      _$ReceivableFromJson(json);
}
