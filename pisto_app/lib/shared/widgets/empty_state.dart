import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';

/// Empty state with clear hierarchy and optional CTA.
///
/// Replaces the "48px icon + descriptive text" pattern with something that
/// actually *invites action*: human headline + description + CTA.
///
/// Variants:
///  - [EmptyState]: general use inside lists/tabs.
///  - [EmptyState.compact]: small version for dialogs or cards.
class EmptyState extends StatelessWidget {
  /// Short, human title. E.g.: "Aún no has facturado".
  final String title;

  /// Optional description with an implicit CTA in the copy.
  /// E.g.: "Crea tu primera venta y empieza a cobrar."
  final String? description;

  /// Illustrative icon. Defaults to inbox. Ignored if [image] is set.
  final IconData icon;

  /// Brand illustration (asset). Replaces the icon; clipped to radius 18
  /// so the PNG's cream background reads as an intentional card in dark mode.
  final String? image;

  /// Optional primary action: a FilledButton.
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Compact variant: no large icon.
  final bool compact;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = LucideIcons.inbox,
    this.image,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  }) : compact = false;

  const EmptyState.compact({
    super.key,
    required this.title,
    this.description,
    this.icon = LucideIcons.inbox,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  })  : image = null,
        compact = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final iconBlock = compact
        ? const SizedBox.shrink()
        : image != null
            ? Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderSubtle(context)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(image!, fit: BoxFit.cover),
              )
            : Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.tintBg(context, cs.primary),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(
              icon,
              size: 26,
              color: cs.primary.withValues(alpha: 0.7),
            ),
          );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!compact) ...[
                iconBlock,
                const SizedBox(height: 20),
              ],
              Text(
                title,
                style: AppTheme.serif(
                  fontSize: compact ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? LucideIcons.plus, size: 16),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
