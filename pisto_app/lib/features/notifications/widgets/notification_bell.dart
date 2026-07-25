import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/notifications_providers.dart';
import '../../../shared/widgets/focus_ring.dart';

/// Bell with an unread badge — lives in the shell (sidebar and mobile app
/// bar). The badge hides at 0 and while the counter is loading.
class NotificationBell extends ConsumerStatefulWidget {
  /// Icon color — the shell passes it depending on its surface (sidebar/app bar).
  final Color? iconColor;
  final Color? hoverColor;

  const NotificationBell({super.key, this.iconColor, this.hoverColor});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = ref.watch(unreadCountProvider).value ?? 0;

    return Tooltip(
      message: 'Notificaciones',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => context.go('/notifications'),
          onFocusChange: (v) => setState(() => _focused = v),
          borderRadius: BorderRadius.circular(10),
          splashFactory: NoSplash.splashFactory,
          hoverColor: widget.hoverColor ?? cs.surfaceContainerHigh,
          child: FocusRing(
            focused: _focused,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(LucideIcons.bell,
                      size: 18, color: widget.iconColor ?? cs.onSurfaceVariant),
                  if (count > 0)
                    Positioned(
                      top: 4,
                      right: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3.5),
                        constraints:
                            const BoxConstraints(minWidth: 15, minHeight: 15),
                        decoration: BoxDecoration(
                          color: cs.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: TextStyle(
                            color: cs.onError,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
