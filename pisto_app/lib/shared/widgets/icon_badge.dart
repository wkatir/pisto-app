import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Sizes for [IconBadge]: `s` = 28px, `m` = 32px.
enum IconBadgeSize { s, m }

/// The ONLY sanctioned pastel accent in the app: a tinted container (10%
/// alpha of [color]) with a dark Lucide icon, radius 12. Usage:
/// `IconBadge(icon: LucideIcons.sparkles, color: cs.primary)`. Never use a
/// full pastel container fill on a card body: that's banned by docs/DESIGN.md §1.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final IconBadgeSize size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = IconBadgeSize.m,
  });

  @override
  Widget build(BuildContext context) {
    final box = size == IconBadgeSize.s ? 28.0 : 32.0;
    final iconSize = size == IconBadgeSize.s ? 14.0 : 16.0;
    return Container(
      width: box,
      height: box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, color),
        borderRadius: BorderRadius.circular(PistoTokens.radiusTile),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}
