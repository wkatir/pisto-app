import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/models/paginated.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/notification_item.dart';
import '../providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _page = 1;

  void _onTapNotification(NotificationItem n) {
    if (!n.isRead) {
      // No await: navigation must not wait on the server. guard reports
      // the error if the mutation fails.
      AppToast.guard(
        context,
        () async {
          await ref
              .read(notificationMutationsProvider.notifier)
              .markRead(n.id);
        },
      );
    }
    final route = switch (n.type) {
      'receivable_due' => '/collections',
      'low_stock' => '/inventory',
      _ => null,
    };
    if (route != null) context.go(route);
  }

  Future<void> _markAllRead() async {
    await AppToast.guard(
      context,
      () async {
        await ref.read(notificationMutationsProvider.notifier).markAllRead();
      },
      successMessage: 'Todas las notificaciones quedaron leídas',
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final listAsync = ref.watch(notificationsListProvider(page: _page));
    final unread = ref.watch(unreadCountProvider).value ?? 0;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              title: 'Notificaciones',
              metrics: [
                MetricChip(
                  label: unread == 0 ? 'Al día' : 'Sin leer',
                  value: unread == 0 ? '0' : '$unread',
                ),
              ],
              actions: [
                OutlinedButton.icon(
                  onPressed: unread > 0 ? _markAllRead : null,
                  icon: const Icon(LucideIcons.checkCheck, size: 14),
                  label: const Text('Marcar todas leídas'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AsyncValueWidget(
              value: listAsync,
              onRetry: () => ref.invalidate(notificationsListProvider),
              data: (page) => _buildList(context, isWide, page),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      BuildContext context, bool isWide, Paginated<NotificationItem> page) {
    if (page.data.isEmpty) {
      return const EmptyState(
        image: 'assets/illustrations/empty_notifications.png',
        title: 'Sin notificaciones',
        description:
            'Cuando haya algo que atender (stock bajo, cobros o pagos por vencer) te avisamos acá.',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding:
                EdgeInsets.fromLTRB(isWide ? 32 : 20, 4, isWide ? 32 : 20, 32),
            itemCount: page.data.length,
            separatorBuilder: (context, i) =>
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            itemBuilder: (context, i) {
              final n = page.data[i];
              return _NotificationRow(
                notification: n,
                onTap: () => _onTapNotification(n),
              );
            },
          ),
        ),
        _PagerBar(
          meta: page.meta,
          onPage: (p) => setState(() => _page = p),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationRow({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final n = notification;

    // Flat row: unread state reads via a bolder title + accent dot only,
    // no card background, no border (see docs/DESIGN-VOICE.md §1). Hairline
    // dividers between rows come from the parent ListView.separated.
    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconBadge(icon: n.typeIcon, color: n.typeColor ?? cs.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                n.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                  color: cs.onSurface,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${n.typeLabel} · ${formatDateShortEs(n.createdAt.toIso8601String())}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (!n.isRead) ...[
          const SizedBox(width: 12),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: cs.surfaceContainerHigh,
        splashFactory: NoSplash.splashFactory,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: rowContent,
        ),
      ),
    );
  }
}

class _PagerBar extends StatelessWidget {
  final PageMeta meta;
  final ValueChanged<int> onPage;

  const _PagerBar({required this.meta, required this.onPage});

  @override
  Widget build(BuildContext context) {
    if (meta.totalPages <= 1) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Anterior',
            onPressed: meta.page > 1 ? () => onPage(meta.page - 1) : null,
            icon: const Icon(LucideIcons.chevronLeft, size: 18),
          ),
          Text(
            '${meta.page} / ${meta.totalPages}',
            style: AppTheme.mono(
                fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
          ),
          IconButton(
            tooltip: 'Siguiente',
            onPressed: meta.page < meta.totalPages
                ? () => onPage(meta.page + 1)
                : null,
            icon: const Icon(LucideIcons.chevronRight, size: 18),
          ),
        ],
      ),
    );
  }
}
