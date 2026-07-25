import '../../../config/api_client.dart';
import '../../../core/models/paginated.dart';
import '../../sales/models/lookups.dart';
import '../models/aging_bucket.dart';
import '../models/receivable.dart';
import '../models/receivable_payment.dart';

/// Typed access to `/collections` (+ payment method catalog that the payment
/// needs). Dio errors propagate; the shared UI layer parses them
/// (AsyncErrorState / AppToast.guard).
class CollectionsRepository {
  final ApiClient _api;
  CollectionsRepository(this._api);

  Future<Paginated<ReceivableListItem>> listReceivables({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.dio.get('/collections/receivables',
        queryParameters: {'page': page, 'limit': limit});
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, ReceivableListItem.fromJson);
  }

  Future<List<AgingBucket>> getAgingReport() async {
    final res = await _api.dio.get('/collections/receivables/aging');
    return [
      for (final e in res.data as List)
        AgingBucket.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<ReceivablePayment>> getReceivablePayments(
      String receivableId) async {
    final res =
        await _api.dio.get('/collections/receivables/$receivableId/payments');
    return [
      for (final e in res.data as List)
        ReceivablePayment.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<ReceivablePayment> createPayment(
    String receivableId, {
    required String paymentMethodId,
    required String amount,
    String? reference,
    String? notes,
  }) async {
    final res = await _api.dio
        .post('/collections/receivables/$receivableId/payments', data: {
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'reference': ?reference,
      'notes': ?notes,
    });
    return ReceivablePayment.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<PaymentMethod>> listPaymentMethods() async {
    final res = await _api.dio.get('/sales/payment-methods');
    return [
      for (final e in res.data['data'] as List)
        PaymentMethod.fromJson(e as Map<String, dynamic>),
    ];
  }
}
