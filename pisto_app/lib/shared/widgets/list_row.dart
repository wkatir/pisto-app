import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'focus_ring.dart';

/// Financial list row — replaces ListTile in lists of invoices, sales,
/// collections, customers, etc.
///
/// Visual hierarchy:
///   ┌──────────────────────────────────────────────────────┐
///   │ [leading]  Título principal               $24,500.00 │
///   │            subtítulo · meta · chip                   │
///   └──────────────────────────────────────────────────────┘
///
/// Differences vs ListTile:
/// - Trailing is a heavy mono figure, not an IconButton.
/// - Subtitle supports multiple slots (date + customer + chip).
/// - Leading is optional — no leading icon by default, cleaner layout.
/// - Subtle border over outlineVariant (respects the flat rule).
class FinancialListRow extends StatefulWidget {
  /// Optional leading widget (icon, avatar, checkbox).
  final Widget? leading;

  /// Main title.
  final String title;

  /// Lines below the title — date, customer, etc.
  /// Concatenated with a "·" separator.
  final List<String> subtitleParts;

  /// Chips/badges on the bottom line (below the subtitle).
  final List<Widget> chips;

  /// Main figure on the right (in mono).
  final String? trailingValue;

  /// Trailing color (e.g. danger for credit notes).
  final Color? trailingColor;

  /// Small text below the trailing value (e.g. "vence en 3 días").
  final String? trailingSubtitle;

  /// Action on tap.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Marked as selected (bulk mode).
  final bool selected;

  /// If true, doesn't show the border — useful inside a larger card.
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
  State<FinancialListRow> createState() => _FinancialListRowState();
}

class _FinancialListRowState extends State<FinancialListRow> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final subtitleText = widget.subtitleParts.where((s) => s.isNotEmpty).join(' · ');

    return Padding(
      padding: EdgeInsets.only(bottom: widget.dense ? 0 : 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onFocusChange: (v) => setState(() => _focused = v),
          borderRadius: BorderRadius.circular(14),
          splashFactory: NoSplash.splashFactory,
          hoverColor: cs.surfaceContainerHigh,
          child: FocusRing(
            focused: _focused,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: widget.selected
                    ? cs.primary.withValues(alpha: 0.05)
                    : cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
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
                        if (widget.chips.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: widget.chips,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailingValue != null) ...[
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.trailingValue!,
                          style: AppTheme.mono(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: widget.trailingColor ?? cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.trailingSubtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.trailingSubtitle!,
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
      ),
    );
  }
}

/// Consistent leading avatar/icon for FinancialListRow.
/// Uses intent color + 10%-tinted background (M3 standard, no glow).
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

/// Initials avatar — for customers/suppliers without an image.
///
/// Generates a deterministic color based on the text so each
/// customer/supplier has a consistent yet varied color.
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

  @override
  Widget build(BuildContext context) {
    final c = color ??
        AppTheme.avatarPalette[text.hashCode.abs() % AppTheme.avatarPalette.length];
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
