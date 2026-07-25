import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

/// Shared layout for the auth screens.
///
/// Wide (>= [Breakpoints.medium]): brand panel on the left (pastel,
/// theme tokens) and form over surface on the right.
/// Narrow: centered column with the wordmark above the card.
class AuthSplitLayout extends ConsumerWidget {
  final Widget form;

  const AuthSplitLayout({super.key, required this.form});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= Breakpoints.medium;
    final cs = Theme.of(context).colorScheme;

    final body = isWide
        ? Row(
            children: [
              const Expanded(flex: 5, child: _BrandPanel()),
              Expanded(
                flex: 6,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: form,
                    ),
                  ),
                ),
              ),
            ],
          )
        : SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _MobileWordmark(),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderSubtle(context)),
                        ),
                        child: form,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

    return Scaffold(
      backgroundColor: isWide ? cs.surface : null,
      body: Stack(
        children: [
          body,
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(child: _ThemeToggle()),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;

    final (icon, label) = switch (mode) {
      ThemeMode.system => (LucideIcons.monitor, 'Tema: sistema'),
      ThemeMode.light => (LucideIcons.sun, 'Tema: claro'),
      ThemeMode.dark => (LucideIcons.moon, 'Tema: oscuro'),
    };

    return IconButton(
      tooltip: label,
      onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
      icon: Icon(icon, size: 18, color: cs.onSurfaceVariant),
    );
  }
}

class _Wordmark extends StatelessWidget {
  final Color chipColor;
  final Color chipIconColor;
  final Color textColor;

  const _Wordmark({
    required this.chipColor,
    required this.chipIconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(LucideIcons.landmark, size: 18, color: chipIconColor),
        ),
        const SizedBox(width: 10),
        Text(
          'Pisto',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _MobileWordmark extends StatelessWidget {
  const _MobileWordmark();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: _Wordmark(
        chipColor: cs.primary,
        chipIconColor: cs.onPrimary,
        textColor: cs.onSurface,
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = cs.onPrimaryContainer;

    const features = [
      (LucideIcons.receipt, 'Facturá y cobrá sin enredos'),
      (LucideIcons.package, 'Tu inventario siempre al día'),
      (LucideIcons.chartColumn, 'Mirá cómo va tu negocio, en un vistazo'),
    ];

    return Container(
      color: cs.primaryContainer,
      child: LayoutBuilder(
        builder: (context, viewport) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewport.maxHeight - 88),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Wordmark(
                    chipColor: cs.primary,
                    chipIconColor: cs.onPrimary,
                    textColor: fg,
                  ),
                  const Spacer(),
                  Text(
                    'Las cuentas claras\nde tu negocio.',
                    style: AppTheme.serif(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: fg,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Ventas, inventario y cobros en un solo lugar,\nsin Excel ni cuadernos.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: fg.withValues(alpha: 0.8),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 340),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.borderSubtle(context)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/illustrations/login_hero.png',
                        height: 240,
                        width: 340,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  for (final f in features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Icon(f.$1, size: 17, color: cs.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              f.$2,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: fg.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    'Hecho para las PYMES de El Salvador',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: fg.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
