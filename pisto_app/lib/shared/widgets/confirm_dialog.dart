import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';

/// Diálogo de confirmación que reemplaza showDialog genérico.
///
/// Diseñado para acciones destructivas o irreversibles (cancelar venta,
/// eliminar producto, etc.) con un diseño que hace sentir el peso de la acción.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final bool destructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.icon = LucideIcons.triangleAlert,
    this.destructive = true,
  });

  /// Muestra el diálogo y retorna true si el usuario confirma.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    IconData icon = LucideIcons.triangleAlert,
    bool destructive = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.4),
      builder: (_) => ConfirmDialog(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = destructive ? AppTheme.danger : cs.primary;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.tintBg(context, color),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelLabel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: destructive
                          ? FilledButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: cs.onError,
                            )
                          : null,
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
