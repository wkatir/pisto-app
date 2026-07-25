import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// One [PTabs] entry: a label and an optional quiet mono count suffix.
class PTabItem {
  final String label;
  final int? count;
  const PTabItem(this.label, {this.count});
}

/// Custom tab row replacing stock `TabBar` chrome (docs/DESIGN-VOICE.md §1):
/// active = w600 `onSurface` text + animated 2px primary underline (120ms),
/// inactive = w500 `onSurfaceVariant`, no ink splash. Driven by an external
/// `index`/`onChanged`: works whether the screen owns a `TabController` (call
/// `onChanged: (i) => tabController.animateTo(i)`) or plain `int` state.
/// Usage: `PTabs(tabs: [PTabItem('Todas', count: 12), PTabItem('Vencidas')],
/// index: tab, onChanged: (i) => setState(() => tab = i))`.
class PTabs extends StatelessWidget {
  final List<PTabItem> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  const PTabs({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 24),
          _PTab(item: tabs[i], selected: i == index, onTap: () => onChanged(i)),
        ],
      ],
    );
  }
}

class _PTab extends StatelessWidget {
  final PTabItem item;
  final bool selected;
  final VoidCallback onTap;

  const _PTab({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                  if (item.count != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${item.count}',
                      style: AppTheme.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                height: 2,
                color: selected ? cs.primary : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
