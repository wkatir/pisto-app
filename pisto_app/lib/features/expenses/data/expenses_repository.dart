import '../../../config/api_client.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

/// Typed access to `/expenses`. Dio errors propagate; the shared UI layer
/// (AsyncErrorState / AppToast.guard) parses them.
class ExpensesRepository {
  final ApiClient _api;
  ExpensesRepository(this._api);

  Future<List<ExpenseCategory>> listCategories() async {
    final res = await _api.dio.get('/expenses/categories');
    return [
      for (final e in res.data['data'] as List)
        ExpenseCategory.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<ExpenseCategory> createCategory({
    required String name,
    String? icon,
  }) async {
    final res = await _api.dio.post('/expenses/categories', data: {
      'name': name,
      'icon': ?icon,
    });
    return ExpenseCategory.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// The endpoint accepts page/limit but responds with a flat list without
  /// meta, so `Paginated` doesn't apply here.
  Future<List<Expense>> listExpenses({
    String? startDate,
    String? endDate,
    String? categoryId,
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _api.dio.get('/expenses', queryParameters: {
      'page': page,
      'limit': limit,
      'startDate': ?startDate,
      'endDate': ?endDate,
      'categoryId': ?categoryId,
    });
    return [
      for (final e in res.data['data'] as List)
        Expense.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<Expense> getExpense(String id) async {
    final res = await _api.dio.get('/expenses/$id');
    return Expense.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<Expense> createExpense({
    required String description,
    required String amount,
    required String expenseDate,
    String? categoryId,
    String? paymentMethodId,
    String? notes,
    String? receiptUrl,
  }) async {
    final res = await _api.dio.post('/expenses', data: {
      'description': description,
      'amount': amount,
      'expenseDate': expenseDate,
      'categoryId': ?categoryId,
      'paymentMethodId': ?paymentMethodId,
      'notes': ?notes,
      'receiptUrl': ?receiptUrl,
    });
    return Expense.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteExpense(String id) async {
    await _api.dio.delete('/expenses/$id');
  }

  Future<ExpenseSummary> getSummary({String? from, String? to}) async {
    final res = await _api.dio.get('/expenses/summary', queryParameters: {
      'from': ?from,
      'to': ?to,
    });
    return ExpenseSummary.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
