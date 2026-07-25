import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/api_client.dart';

/// Standard renderer for the three states of an AsyncValue.
///
/// Replaces the `bool _loading` + try/catch + snackbar pattern. The error is
/// parsed with [ApiClient.parseError] in this single place.
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// Typically `() => ref.invalidate(provider)`.
  final VoidCallback? onRetry;

  /// Custom loading widget (e.g. skeleton). Default: centered spinner.
  final Widget? loading;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncErrorState(error: error, onRetry: onRetry),
    );
  }
}

/// Sliver variant: wraps loading/error in SliverFillRemaining.
class SliverAsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  const SliverAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: AsyncErrorState(error: error, onRetry: onRetry),
      ),
    );
  }
}

/// Error state with retry: same visual language as EmptyState.
class AsyncErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const AsyncErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.circleAlert, size: 36, color: cs.onSurfaceVariant),
              const SizedBox(height: 14),
              Text(
                'Algo salió mal',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                ApiClient.parseError(error),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Reintentar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
