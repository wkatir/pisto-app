import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Semantic intent of a chip / status.
/// Replaces the indiscriminate use of cs.primary/secondary/tertiary for
/// statuses, which visually collapse into the same teal tone on screen.
enum ChipIntent { success, warning, danger, info, neutral, brand }

/// Status category (keeps compatibility with the rest of the app).
enum StatusType { sale, payment, order, transfer, receivable }

class StatusChip extends StatelessWidget {
  final String status;
  final StatusType type;

  const StatusChip({
    super.key,
    required this.status,
    this.type = StatusType.sale,
  });

  @override
  Widget build(BuildContext context) {
    final (intent, label) = _getIntentAndLabel();
    return _ChipBase(label: label, intent: intent, size: _ChipSize.regular);
  }

  (ChipIntent, String) _getIntentAndLabel() {
    return switch (type) {
      StatusType.sale => switch (status) {
          'completed' => (ChipIntent.neutral, 'Completada'),
          'cancelled' => (ChipIntent.danger, 'Cancelada'),
          _ => (ChipIntent.neutral, status),
        },
      StatusType.payment => switch (status) {
          'paid' => (ChipIntent.success, 'Pagada'),
          'credit' => (ChipIntent.warning, 'Crédito'),
          'overdue' => (ChipIntent.danger, 'Vencida'),
          _ => (ChipIntent.neutral, status),
        },
      StatusType.order => switch (status) {
          'draft' => (ChipIntent.neutral, 'Borrador'),
          'approved' => (ChipIntent.info, 'Aprobada'),
          'partial' => (ChipIntent.warning, 'Parcial'),
          'received' => (ChipIntent.success, 'Recibida'),
          'cancelled' => (ChipIntent.danger, 'Cancelada'),
          _ => (ChipIntent.neutral, status),
        },
      StatusType.transfer => switch (status) {
          'pending' => (ChipIntent.warning, 'Pendiente'),
          'completed' => (ChipIntent.success, 'Completada'),
          'cancelled' => (ChipIntent.danger, 'Cancelada'),
          _ => (ChipIntent.neutral, status),
        },
      StatusType.receivable => switch (status) {
          'pending' => (ChipIntent.warning, 'Pendiente'),
          'overdue' => (ChipIntent.danger, 'Vencida'),
          'paid' => (ChipIntent.success, 'Pagada'),
          _ => (ChipIntent.neutral, status),
        },
    };
  }
}

class PaymentChip extends StatelessWidget {
  final String status;

  const PaymentChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (intent, label) = switch (status) {
      'paid' => (ChipIntent.success, 'Pagada'),
      'credit' => (ChipIntent.warning, 'Crédito'),
      'overdue' => (ChipIntent.danger, 'Vencida'),
      _ => (ChipIntent.neutral, status),
    };
    return _ChipBase(label: label, intent: intent, size: _ChipSize.small);
  }
}

/// Generic chip with semantic intent — use it when no StatusType fits.
class IntentChip extends StatelessWidget {
  final String label;
  final ChipIntent intent;
  final IconData? icon;
  final bool small;

  const IntentChip({
    super.key,
    required this.label,
    this.intent = ChipIntent.neutral,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return _ChipBase(
      label: label,
      intent: intent,
      icon: icon,
      size: small ? _ChipSize.small : _ChipSize.regular,
    );
  }
}

// ── internals ────────────────────────────────────────────────────────────────

enum _ChipSize { small, regular }

class _ChipBase extends StatelessWidget {
  final String label;
  final ChipIntent intent;
  final IconData? icon;
  final _ChipSize size;

  const _ChipBase({
    required this.label,
    required this.intent,
    required this.size,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _intentColor(intent, cs);
    // The tinted fill is derived from the plain intent, but the label must not
    // be: plain intents sit at 1.8-2.9:1 on their own containers (docs/DESIGN.md).
    final fg = _intentTextColor(intent, context, cs);

    final hPad = size == _ChipSize.small ? 10.0 : 14.0;
    final vPad = size == _ChipSize.small ? 4.0 : 6.0;
    final fontSize = size == _ChipSize.small ? 10.0 : 11.0;
    final iconSize = size == _ChipSize.small ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, color),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: fg,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static Color _intentColor(ChipIntent intent, ColorScheme cs) => switch (intent) {
        ChipIntent.success => AppTheme.success,
        ChipIntent.warning => AppTheme.warning,
        ChipIntent.danger => AppTheme.danger,
        ChipIntent.info => AppTheme.info,
        ChipIntent.brand => cs.primary,
        ChipIntent.neutral => cs.onSurfaceVariant,
      };

  static Color _intentTextColor(
          ChipIntent intent, BuildContext context, ColorScheme cs) =>
      switch (intent) {
        ChipIntent.success => context.tokens.successText,
        ChipIntent.warning => context.tokens.warningText,
        ChipIntent.danger => context.tokens.dangerText,
        ChipIntent.info => context.tokens.infoText,
        ChipIntent.brand => cs.primary,
        ChipIntent.neutral => cs.onSurfaceVariant,
      };
}
