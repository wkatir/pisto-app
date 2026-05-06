import '../../config/api_client.dart';

class SalesService {
  final ApiClient _api;
  SalesService(this._api);

  Future<Map<String, dynamic>> listCustomers({int page = 1, int limit = 20, String? search}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.dio.get('/sales/customers', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/sales/customers', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> data) async {
    final res = await _api.dio.put('/sales/customers/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCustomer(String id) async {
    final res = await _api.dio.get('/sales/customers/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listInvoices({int page = 1, int limit = 20, String? customerId}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (customerId != null) params['customerId'] = customerId;
    final res = await _api.dio.get('/sales/invoices', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getInvoice(String id) async {
    final res = await _api.dio.get('/sales/invoices/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/sales/invoices', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> cancelSale(String id) async {
    await _api.dio.post('/sales/invoices/$id/cancel');
  }

  Future<Map<String, dynamic>> listCreditNotes({int page = 1, int limit = 20}) async {
    final res = await _api.dio.get('/sales/credit-notes', queryParameters: {'page': page, 'limit': limit});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCreditNote(String saleId, Map<String, dynamic> data) async {
    final res = await _api.dio.post('/sales/invoices/$saleId/credit-note', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listPaymentMethods() async {
    final resp = await _api.dio.get('/sales/payment-methods');
    final list = (resp.data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listDocumentTypes() async {
    final resp = await _api.dio.get('/sales/document-types');
    final list = (resp.data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listTaxes() async {
    final resp = await _api.dio.get('/sales/taxes');
    final list = (resp.data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
