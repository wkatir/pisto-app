import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
sealed class Expense with _$Expense {
  const Expense._();

  const factory Expense({
    required String id,
    String? categoryId,
    required String description,
    required String amount,
    required String expenseDate,
    String? paymentMethodId,
    String? notes,
    String? receiptUrl,
    // Absent in the create response (the API echoes the input, not the row).
    DateTime? createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  double get amountValue => double.parse(amount);
}

@freezed
sealed class ExpenseSummary with _$ExpenseSummary {
  const ExpenseSummary._();

  const factory ExpenseSummary({
    required String total,
    required int count,
  }) = _ExpenseSummary;

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSummaryFromJson(json);

  double get totalValue => double.parse(total);
}
