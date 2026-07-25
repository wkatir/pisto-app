import 'package:flutter/material.dart';

/// 2px `primary` keyboard focus ring, 2px offset — reserves the offset space
/// always (fixed layout) and only colors the border when [focused]. Usage:
/// wrap a row's content inside an `InkWell(focusNode: node, onFocusChange: ...,
/// child: FocusRing(focused: hasFocus, child: ...))`.
class FocusRing extends StatelessWidget {
  final bool focused;
  final Widget child;
  final BorderRadius borderRadius;

  const FocusRing({
    super.key,
    required this.focused,
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: focused ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: child,
    );
  }
}
