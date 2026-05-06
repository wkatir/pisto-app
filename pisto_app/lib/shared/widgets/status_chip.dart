import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;
    final (color, label) = _getColorAndLabel(cs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getColorAndLabel(ColorScheme cs) {
    return switch (type) {
      StatusType.sale => switch (status) {
          'completed' => (cs.primary, 'Completada'),
          'cancelled' => (cs.error, 'Cancelada'),
          _ => (cs.tertiary, status),
        },
      StatusType.payment => switch (status) {
          'paid' => (cs.secondary, 'Pagada'),
          'credit' => (cs.tertiary, 'Credito'),
          _ => (cs.onSurfaceVariant, status),
        },
      StatusType.order => switch (status) {
          'draft' => (cs.onSurfaceVariant, 'Borrador'),
          'approved' => (cs.primary, 'Aprobada'),
          'partial' => (cs.tertiary, 'Parcial'),
          'received' => (cs.secondary, 'Recibida'),
          'cancelled' => (cs.error, 'Cancelada'),
          _ => (cs.onSurfaceVariant, status),
        },
      StatusType.transfer => switch (status) {
          'pending' => (cs.onSurfaceVariant, 'Pendiente'),
          'completed' => (cs.primary, 'Completada'),
          'cancelled' => (cs.error, 'Cancelada'),
          _ => (cs.onSurfaceVariant, status),
        },
      StatusType.receivable => switch (status) {
          'pending' => (cs.onSurfaceVariant, 'Pendiente'),
          'paid' => (cs.secondary, 'Pagada'),
          _ => (cs.onSurfaceVariant, status),
        },
    };
  }
}

class PaymentChip extends StatelessWidget {
  final String status;

  const PaymentChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, label) = switch (status) {
      'paid' => (cs.secondary, 'Pagada'),
      'credit' => (cs.tertiary, 'Credito'),
      _ => (cs.onSurfaceVariant, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
