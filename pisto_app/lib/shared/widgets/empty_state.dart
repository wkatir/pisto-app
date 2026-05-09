import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';

/// Empty state con jerarquía clara y CTA opcional.
///
/// Reemplaza el patrón "icon de 48px + texto descriptivo" por algo que
/// efectivamente *invita a la acción*: titular humano + descripción + CTA.
///
/// Variantes:
///  - [EmptyState] — uso general dentro de listas/tabs.
///  - [EmptyState.compact] — versión chica para diálogos o cards.
class EmptyState extends StatelessWidget {
  /// Título corto y humano. Ej: "Aún no has facturado".
  final String title;

  /// Descripción opcional con CTA implícita en texto.
  /// Ej: "Crea tu primera venta y empieza a cobrar."
  final String? description;

  /// Ícono ilustrativo. Defaults a inbox.
  final IconData icon;

  /// Acción primaria opcional — un FilledButton.
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Variante compacta — sin ícono grande.
  final bool compact;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = LucideIcons.inbox,
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
  }) : compact = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final iconBlock = compact
        ? const SizedBox.shrink()
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
