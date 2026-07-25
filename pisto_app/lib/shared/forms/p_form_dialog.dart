import 'package:flutter/material.dart';
import 'p_form.dart';

/// Standard form dialog: title with icon, stacked fields, Cancel/submit
/// with loading state and error handling built in.
///
/// Returns true if the submit succeeded, false/null if it was canceled.
class PFormDialog {
  PFormDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    IconData? icon,
    required List<Widget> fields,

    /// Extra content above the fields (context, totals, etc.).
    Widget? header,
    String submitLabel = 'Guardar',
    String? successMessage,
    required Future<void> Function(Map<String, Object?> values) onSubmit,
    double maxWidth = 420,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PForm(
        onSubmit: onSubmit,
        successMessage: successMessage,
        onSuccess: () => Navigator.pop(dialogContext, true),
        builder: (context, form) {
          final cs = Theme.of(context).colorScheme;
          return AlertDialog(
            title: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 22, color: cs.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (header != null) ...[header, const SizedBox(height: 16)],
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      fields[i],
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: form.submitting
                    ? null
                    : () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: form.submitting ? null : form.submit,
                child: form.submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(submitLabel),
              ),
            ],
          );
        },
      ),
    );
    return result ?? false;
  }
}
