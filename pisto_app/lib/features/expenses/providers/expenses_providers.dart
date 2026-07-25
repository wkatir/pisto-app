import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/core_providers.dart';
import '../data/expenses_repository.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

part 'expenses_providers.g.dart';

@Riverpod(keepAlive: true)
ExpensesRepository expensesRepository(Ref ref) {
  return ExpensesRepository(ref.watch(apiClientProvider));
}

// ── Queries ──────────────────────────────────────────────────────────────────

/// Everything the expenses screen needs, fetched in parallel.
@riverpod
Future<
    ({
      List<ExpenseCategory> categories,
      List<Expense> expenses,
      ExpenseSummary summary,
    })> expensesOverview(Ref ref, {required String startDate}) async {
  final repo = ref.watch(expensesRepositoryProvider);
  final (categories, expenses, summary) = await (
    repo.listCategories(),
    repo.listExpenses(startDate: startDate),
    repo.getSummary(from: startDate),
  ).wait;
  return (categories: categories, expenses: expenses, summary: summary);
}

// ── Mutations ────────────────────────────────────────────────────────────────
// Each mutation invalidates only the queries it changed.

@riverpod
class ExpenseMutations extends _$ExpenseMutations {
  @override
  void build() {}

  Future<Expense> create({
    required String description,
    required String amount,
    required String expenseDate,
    String? categoryId,
    String? paymentMethodId,
    String? notes,
    String? receiptUrl,
  }) async {
    final expense = await ref.read(expensesRepositoryProvider).createExpense(
          description: description,
          amount: amount,
          expenseDate: expenseDate,
          categoryId: categoryId,
          paymentMethodId: paymentMethodId,
          notes: notes,
          receiptUrl: receiptUrl,
        );
    ref.invalidate(expensesOverviewProvider);
    return expense;
  }

  Future<void> delete(String id) async {
    await ref.read(expensesRepositoryProvider).deleteExpense(id);
    ref.invalidate(expensesOverviewProvider);
  }

  Future<ExpenseCategory> createCategory({
    required String name,
    String? icon,
  }) async {
    final category = await ref
        .read(expensesRepositoryProvider)
        .createCategory(name: name, icon: icon);
    ref.invalidate(expensesOverviewProvider);
    return category;
  }
}
