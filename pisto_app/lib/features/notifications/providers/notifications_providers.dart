import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/paginated.dart';
import '../../../core/providers/core_providers.dart';
import '../data/notifications_repository.dart';
import '../models/notification_item.dart';

part 'notifications_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(apiClientProvider));
}

// ── Queries ──────────────────────────────────────────────────────────────────

@riverpod
Future<Paginated<NotificationItem>> notificationsList(
  Ref ref, {
  int page = 1,
  bool unreadOnly = false,
}) {
  return ref
      .watch(notificationsRepositoryProvider)
      .list(page: page, unreadOnly: unreadOnly);
}

/// Counter for the shell's badge. keepAlive + a timer that re-arms on every
/// rebuild → refreshes every 60s while the app is alive (includes retry
/// after an error).
@Riverpod(keepAlive: true)
Future<int> unreadCount(Ref ref) {
  final timer = Timer(const Duration(seconds: 60), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return ref.watch(notificationsRepositoryProvider).unreadCount();
}

// ── Mutations ────────────────────────────────────────────────────────────────

@riverpod
class NotificationMutations extends _$NotificationMutations {
  @override
  void build() {}

  Future<NotificationItem> markRead(String id) async {
    final item =
        await ref.read(notificationsRepositoryProvider).markRead(id);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadCountProvider);
    return item;
  }

  Future<int> markAllRead() async {
    final updated =
        await ref.read(notificationsRepositoryProvider).markAllRead();
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadCountProvider);
    return updated;
  }
}
