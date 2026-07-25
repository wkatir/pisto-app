import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';
import '../../core/models/paginated.dart';
import 'focus_ring.dart';

/// Column definition for [DataList]. `flex` sizes the column in the wide
/// table layout; `isMoney` right-aligns the cell and promotes it to the
/// trailing slot in the narrow compact-row layout.
class DataListColumn<T> {
  final String label;
  final Widget Function(BuildContext context, T item) cell;
  final int flex;
  final TextAlign align;
  final bool isMoney;

  const DataListColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.align = TextAlign.left,
    this.isMoney = false,
  });
}

/// The workhorse list/table primitive. Renders a real data table (aligned
/// columns, 44-52px rows, header row `labelMedium`/`onSurfaceVariant`, row
/// hover, full-row tap) at widths ≥900px, and 52-64px compact rows below.
/// Wraps `Paginated<T>`: pass the accumulated pages in `data.data` and this
/// renders "Mostrando X de Y" + «Cargar más» (Spanish UI copy) via [onLoadMore]. Usage:
/// `DataList(columns: [...], data: invoicesPage, loading: isLoading,
/// emptyState: EmptyState(...), onTap: (i) => openDetail(i))`. Pass
/// `rowAccentColor` for a per-row 3px accent bar (e.g. overdue = danger).
class DataList<T> extends StatelessWidget {
  final List<DataListColumn<T>> columns;
  final Paginated<T>? data;
  final bool loading;
  final Widget emptyState;
  final void Function(T item)? onTap;
  final VoidCallback? onLoadMore;
  final bool loadingMore;
  final int skeletonRows;

  /// Optional 3px left accent bar per row (state matters, e.g. overdue) —
  /// same convention as `InfoCard.accentColor`. Never a row background wash.
  final Color? Function(T item)? rowAccentColor;

  const DataList({
    super.key,
    required this.columns,
    required this.data,
    required this.emptyState,
    this.loading = false,
    this.onTap,
    this.onLoadMore,
    this.loadingMore = false,
    this.skeletonRows = 6,
    this.rowAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return _Skeleton(columns: columns.length, rows: skeletonRows);

    final items = data?.data ?? const [];
    if (items.isEmpty) return emptyState;

    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isWide) _TableHeader<T>(columns: columns),
        for (final item in items)
          isWide
              ? _TableRow<T>(
                  columns: columns,
                  item: item,
                  onTap: onTap == null ? null : () => onTap!(item),
                  accentColor: rowAccentColor?.call(item),
                )
              : _CompactRow<T>(
                  columns: columns,
                  item: item,
                  onTap: onTap == null ? null : () => onTap!(item),
                  accentColor: rowAccentColor?.call(item),
                ),
        if (data != null)
          _Footer(
            meta: data!.meta,
            shown: items.length,
            onLoadMore: onLoadMore,
            loadingMore: loadingMore,
          ),
      ],
    );
  }
}

class _TableHeader<T> extends StatelessWidget {
  final List<DataListColumn<T>> columns;
  const _TableHeader({required this.columns});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle(context))),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(
              flex: columns[i].flex,
              child: Text(
                columns[i].label,
                textAlign: columns[i].align,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TableRow<T> extends StatefulWidget {
  final List<DataListColumn<T>> columns;
  final T item;
  final VoidCallback? onTap;
  final Color? accentColor;

  const _TableRow({
    required this.columns,
    required this.item,
    this.onTap,
    this.accentColor,
  });

  @override
  State<_TableRow<T>> createState() => _TableRowState<T>();
}

class _TableRowState<T> extends State<_TableRow<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (v) => setState(() => _focused = v),
        splashFactory: NoSplash.splashFactory,
        hoverColor: cs.surfaceContainerHigh,
        child: FocusRing(
          focused: _focused,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: EdgeInsets.only(
                left: widget.accentColor == null ? 16 : 13, right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderSubtle(context)),
                left: widget.accentColor == null
                    ? BorderSide.none
                    : BorderSide(color: widget.accentColor!, width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.columns.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: widget.columns[i].flex,
                    child: Align(
                      alignment: widget.columns[i].align == TextAlign.right || widget.columns[i].isMoney
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: widget.columns[i].cell(context, widget.item),
                    ),
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

/// Narrow layout (<900px): lead column as title, middle columns wrapped
/// below it, the last money column (if any) promoted to the trailing slot —
/// same data density as the table, no separate "card" variant.
class _CompactRow<T> extends StatefulWidget {
  final List<DataListColumn<T>> columns;
  final T item;
  final VoidCallback? onTap;
  final Color? accentColor;

  const _CompactRow({
    required this.columns,
    required this.item,
    this.onTap,
    this.accentColor,
  });

  @override
  State<_CompactRow<T>> createState() => _CompactRowState<T>();
}

class _CompactRowState<T> extends State<_CompactRow<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final columns = widget.columns;
    final item = widget.item;
    final accentColor = widget.accentColor;
    final moneyCols = columns.where((c) => c.isMoney).toList();
    final trailingCol = moneyCols.isNotEmpty ? moneyCols.last : null;
    final leadCol = columns.first;
    final middleCols =
        columns.where((c) => c != leadCol && c != trailingCol).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (v) => setState(() => _focused = v),
        splashFactory: NoSplash.splashFactory,
        hoverColor: cs.surfaceContainerHigh,
        child: FocusRing(
          focused: _focused,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: EdgeInsets.only(
                left: accentColor == null ? 14 : 11, right: 14, top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderSubtle(context)),
                left: accentColor == null
                    ? BorderSide.none
                    : BorderSide(color: accentColor, width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      leadCol.cell(context, item),
                      if (middleCols.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [for (final c in middleCols) c.cell(context, item)],
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingCol != null) ...[
                  const SizedBox(width: 12),
                  trailingCol.cell(context, item),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final PageMeta meta;
  final int shown;
  final VoidCallback? onLoadMore;
  final bool loadingMore;

  const _Footer({
    required this.meta,
    required this.shown,
    this.onLoadMore,
    this.loadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasMore = shown < meta.total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando $shown de ${meta.total}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (hasMore && onLoadMore != null)
            TextButton.icon(
              onPressed: loadingMore ? null : onLoadMore,
              icon: loadingMore
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.chevronDown, size: 14),
              label: const Text('Cargar más'),
            ),
        ],
      ),
    );
  }
}

/// Skeleton mirroring the table layout — never fake zeros.
class _Skeleton extends StatelessWidget {
  final int columns;
  final int rows;
  const _Skeleton({required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                for (var j = 0; j < columns; j++) ...[
                  if (j > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
