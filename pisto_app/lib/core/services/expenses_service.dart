import '../../config/api_client.dart';

class ExpensesService {
  final ApiClient _api;
  ExpensesService(this._api);

  Future<List<Map<String, dynamic>>> listCategories() async {
    final resp = await _api.dio.get('/expenses/categories');
    final list = (resp.data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createCategory(String name, {String? icon}) async {
    final resp = await _api.dio.post('/expenses/categories', data: {'name': name, 'icon': icon});
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listExpenses({String? startDate, String? endDate, String? categoryId}) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (categoryId != null) params['categoryId'] = categoryId;
    final resp = await _api.dio.get('/expenses', queryParameters: params.isEmpty ? null : params);
    final list = (resp.data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createExpense({
    required String description,
    required String amount,
    required String expenseDate,
    String? categoryId,
    String? paymentMethodId,
    String? notes,
  }) async {
    final resp = await _api.dio.post('/expenses', data: {
      'description': description,
      'amount': amount,
      'expenseDate': expenseDate,
      'categoryId': categoryId,
      'paymentMethodId': paymentMethodId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteExpense(String id) async {
    await _api.dio.delete('/expenses/$id');
  }

  Future<Map<String, dynamic>> getSummary({String? startDate, String? endDate}) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final resp = await _api.dio.get('/expenses/summary', queryParameters: params.isEmpty ? null : params);
    return (resp.data['data'] as Map<String, dynamic>?) ?? {'total': '0.00', 'count': 0};
  }
}
