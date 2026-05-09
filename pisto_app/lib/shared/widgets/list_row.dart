import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Fila de lista financiera — reemplaza ListTile en listas de facturas, ventas,
/// cobros, clientes, etc.
///
/// Jerarquía visual:
///   ┌──────────────────────────────────────────────────────┐
///   │ [leading]  Título principal               $24,500.00 │
///   │            subtítulo · meta · chip                   │
///   └──────────────────────────────────────────────────────┘
///
/// Diferencias vs ListTile:
/// - Trailing es una cifra pesada en mono, no un IconButton.
/// - Subtítulo soporta múltiples slots (fecha + cliente + chip).
/// - Leading es opcional — sin leading icono por defecto, layout más limpio.
/// - Borde sutil sobre outlineVariant (respeta regla flat).
class FinancialListRow extends StatelessWidget {
  /// Widget leading opcional (ícono, avatar, checkbox).
  final Widget? leading;

  /// Título principal.
  final String title;

  /// Líneas debajo del título — fecha, cliente, etc.
  /// Se concatenan con separador "·".
  final List<String> subtitleParts;

  /// Chips/badges en la línea inferior (debajo del subtítulo).
  final List<Widget> chips;

  /// Cifra principal a la derecha (en mono).
  final String? trailingValue;

  /// Color del trailing (ej. danger para notas de crédito).
  final Color? trailingColor;

  /// Texto pequeño debajo del trailing (ej. "vence en 3 días").
  final String? trailingSubtitle;

  /// Acción al tocar.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Marcado como seleccionado (modo bulk).
  final bool selected;

  /// Si true, no muestra el borde — útil dentro de un card más grande.
  final bool dense;

  const FinancialListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitleParts = const [],
    this.chips = const [],
    this.trailingValue,
    this.trailingColor,
    this.trailingSubtitle,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final subtitleText = subtitleParts.where((s) => s.isNotEmpty).join(' · ');

    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 0 : 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary.withValues(alpha: 0.05)
                  : cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitleText.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitleText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (chips.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: chips,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingValue != null) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trailingValue!,
                        style: AppTheme.mono(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: trailingColor ?? cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (trailingSubtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          trailingSubtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar/icono leading consistente para FinancialListRow.
/// Usa color de intent + bg tintado al 10% (M3 estándar, no glow).
class RowLeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const RowLeadingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, color),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// Avatar inicial — para clientes/proveedores sin imagen.
///
/// Genera un color determinístico basado en el texto para que cada
/// cliente/proveedor tenga un color consistente pero variado.
class RowAvatar extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const RowAvatar({
    super.key,
    required this.text,
    this.color,
    this.size = 38,
  });

  /// Paleta de colores para avatares — variados pero todos en el mismo
  /// rango de luminosidad para que se vean bien en light y dark.
  static const _avatarColors = [
    Color(0xFF2D8F6F), // forest green
    Color(0xFF7E6BBF), // soft violet
    Color(0xFF8B7EC8), // lavender
    Color(0xFFE35D5D), // warm red
    Color(0xFFE8835A), // terracotta
    Color(0xFF34A853), // warm green
    Color(0xFF5B8DEF), // soft blue
    Color(0xFFA78BDB), // soft purple
    Color(0xFF2D8F6F), // forest green
    Color(0xFFF0A07C), // peach coral
  ];

  @override
  Widget build(BuildContext context) {
    final c = color ?? _avatarColors[text.hashCode.abs() % _avatarColors.length];
    final initial = text.isEmpty ? '?' : text.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, c),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
          height: 1,
        ),
      ),
    );
  }
}
