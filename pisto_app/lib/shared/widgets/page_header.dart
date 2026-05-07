import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Header consistente para todas las pantallas internas.
///
/// Reemplaza el patrón repetido `Icon + headlineMedium + Wrap de botones` que
/// hacía cada pantalla sentirse a "panel administrativo CRUD".
///
/// Layout:
///   [EYEBROW · OPCIONAL]
///   Título grande (serif Lora)
///   Subtítulo/meta opcional         [acción primaria]
///                                   [acciones secundarias]
class PageHeader extends StatelessWidget {
  /// Texto pequeño en mono uppercase encima del título — contexto rápido.
  /// Ej: "VENTAS · ESTE MES", "INVENTARIO".
  final String? eyebrow;

  /// Título principal — usa serif Lora para personality editorial.
  final String title;

  /// Subtítulo o meta dato debajo del título. Renderiza en mono si es numérico
  /// y en sans si es texto descriptivo (controlado por [metaIsMono]).
  final String? meta;

  /// Si true, [meta] se renderiza con DM Mono (útil para "122 productos · 14 alertas").
  final bool metaIsMono;

  /// Acciones a la derecha (ej. botones primario + secundario).
  final List<Widget> actions;

  /// Acciones secundarias en una segunda fila (ej. filtros, períodos).
  /// Se renderizan debajo del header en un Wrap con spacing 8.
  final List<Widget>? toolbar;

  const PageHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.meta,
    this.metaIsMono = false,
    this.actions = const [],
    this.toolbar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < Breakpoints.compact;

    final titleStyle = AppTheme.serif(
      fontSize: isCompact ? 28 : 34,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
      letterSpacing: -0.6,
      height: 1.1,
    );

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: AppTheme.eyebrow(context, color: cs.primary),
          ),
          const SizedBox(height: 8),
        ],
        Text(title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (meta != null && meta!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            meta!,
            style: metaIsMono
                ? AppTheme.mono(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    final headerRow = isCompact || actions.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleColumn,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: actions,
                ),
              ],
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleColumn),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: actions,
                ),
              ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        headerRow,
        if (toolbar != null && toolbar!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: toolbar!),
        ],
      ],
    );
  }
}

/// Saludo dinámico por hora del día. Devuelve "Buenos días", "Buenas tardes",
/// "Buenas noches" — útil para el dashboard.
String greetingForHour([DateTime? when]) {
  final h = (when ?? DateTime.now()).hour;
  if (h < 6) return 'Buenas noches';
  if (h < 13) return 'Buenos días';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

/// Formato de fecha corto en español: "Lunes 7 de mayo".
String formatLongDateEs(DateTime d) {
  const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  const months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  return '${days[d.weekday - 1]} ${d.day} de ${months[d.month - 1]}';
}
