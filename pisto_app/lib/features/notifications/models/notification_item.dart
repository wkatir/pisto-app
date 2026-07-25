import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

/// Contract: GET /notifications. Types: low_stock, receivable_due,
/// payable_due, ai_suggestion.
@freezed
sealed class NotificationItem with _$NotificationItem {
  const NotificationItem._();

  const factory NotificationItem({
    required String id,
    required String businessId,
    required String type,
    required String title,
    required String body,
    String? entityType,
    String? entityId,
    String? readAt,
    required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  bool get isRead => readAt != null;

  String get typeLabel => switch (type) {
        'low_stock' => 'Stock bajo',
        'receivable_due' => 'Cobro por vencer',
        'payable_due' => 'Pago por vencer',
        'ai_suggestion' => 'Sugerencia IA',
        // New server types must not break the list.
        _ => type,
      };

  IconData get typeIcon => switch (type) {
        'low_stock' => LucideIcons.package,
        'receivable_due' => LucideIcons.wallet,
        'payable_due' => LucideIcons.shoppingCart,
        'ai_suggestion' => LucideIcons.sparkles,
        _ => LucideIcons.bell,
      };

  /// Severity color for the row's [IconBadge]. Overdue money types (receivables
  /// and payables due) get the danger tint: everything else stays plain so
  /// urgency doesn't get diluted by decoration.
  bool get isOverdue => type == 'receivable_due' || type == 'payable_due';

  Color? get typeColor => isOverdue ? AppTheme.danger : null;
}
