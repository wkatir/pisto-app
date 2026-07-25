import '../../../config/api_client.dart';
import '../../../core/models/paginated.dart';
import '../models/notification_item.dart';

/// Typed access to `/notifications`. Dio errors propagate; the shared UI
/// layer (AsyncErrorState / AppToast.guard) parses them.
class NotificationsRepository {
  final ApiClient _api;
  NotificationsRepository(this._api);

  Future<Paginated<NotificationItem>> list({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    final res = await _api.dio.get('/notifications', queryParameters: {
      'page': page,
      'limit': limit,
      if (unreadOnly) 'unreadOnly': true,
    });
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, NotificationItem.fromJson);
  }

  /// The server sweeps pending-to-generate notifications during this call.
  Future<int> unreadCount() async {
    final res = await _api.dio.get('/notifications/unread-count');
    return (res.data['data'] as Map<String, dynamic>)['count'] as int;
  }

  Future<NotificationItem> markRead(String id) async {
    final res = await _api.dio.post('/notifications/$id/read');
    return NotificationItem.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  Future<int> markAllRead() async {
    final res = await _api.dio.post('/notifications/read-all');
    return (res.data['data'] as Map<String, dynamic>)['updated'] as int;
  }
}
