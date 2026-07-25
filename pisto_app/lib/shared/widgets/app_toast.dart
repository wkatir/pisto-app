import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/api_client.dart';
import '../../config/app_theme.dart';

/// Toast's visual intent.
enum ToastType { success, error, warning, info }

/// Floating toast that replaces Material's generic SnackBar.
///
/// Shown at the top of the screen with a compact design, a colored side
/// border per intent, and automatic dismiss.
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    late final AnimationController controller;

    controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
    );

    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    );

    void dismiss() {
      controller.reverse().then((_) {
        entry.remove();
        controller.dispose();
      });
    }

    entry = OverlayEntry(
      builder: (context) {
        final mq = MediaQuery.of(context);
        return Positioned(
          top: mq.padding.top + 12,
          left: 16,
          right: 16,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(curved),
              child: _ToastCard(
                message: message,
                type: type,
                actionLabel: actionLabel,
                onAction: onAction != null
                    ? () {
                        onAction();
                        dismiss();
                      }
                    : null,
                onDismiss: dismiss,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    controller.forward();

    Future.delayed(duration, () {
      if (controller.isAnimating || controller.isCompleted) {
        dismiss();
      }
    });
  }

  /// Shorthand for API errors.
  static void error(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.error);

  /// Shorthand for confirmations.
  static void success(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.success);

  /// Runs a mutation: on failure shows the parsed API error; on success
  /// shows [successMessage] if one was passed. Returns true if it succeeded.
  /// Only place (besides AsyncErrorState) where ApiClient.parseError is called.
  static Future<bool> guard(
    BuildContext context,
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) error(context, ApiClient.parseError(e));
      return false;
    }
    if (successMessage != null && context.mounted) {
      success(context, successMessage);
    }
    return true;
  }
}

class _ToastCard extends StatelessWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _ToastCard({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (color, icon) = switch (type) {
      ToastType.success => (AppTheme.success, LucideIcons.circleCheck),
      ToastType.error => (AppTheme.danger, LucideIcons.circleX),
      ToastType.warning => (AppTheme.warning, LucideIcons.triangleAlert),
      ToastType.info => (AppTheme.info, LucideIcons.info),
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderSubtle(context)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored side bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(LucideIcons.x, size: 14, color: cs.onSurfaceVariant),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
