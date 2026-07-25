import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import 'p_form.dart';

/// Right-side drawer form (480px, full height) hosting `PForm` fields with a
/// sticky footer — use for forms with more than ~5 fields; `PFormDialog`
/// stays for smaller ones. Usage: `SidePanelForm.show(context, title: 'Nuevo
/// producto', fields: [PTextField(...), ...], onSubmit: (values) => ...)`.
/// Barrier tap / back button close the panel, guarded by a discard-changes
/// confirm when the form is dirty (tracked via `PForm.onChanged`).
class SidePanelForm {
  SidePanelForm._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    IconData? icon,
    required List<Widget> fields,

    /// Contenido extra arriba de los campos (contexto, totales, etc.).
    Widget? header,
    String submitLabel = 'Guardar',
    String? successMessage,
    required Future<void> Function(Map<String, Object?> values) onSubmit,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => _SidePanelBody(
        title: title,
        icon: icon,
        header: header,
        fields: fields,
        submitLabel: submitLabel,
        successMessage: successMessage,
        onSubmit: onSubmit,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
          child: child,
        );
      },
    );
    return result ?? false;
  }
}

class _SidePanelBody extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget? header;
  final List<Widget> fields;
  final String submitLabel;
  final String? successMessage;
  final Future<void> Function(Map<String, Object?> values) onSubmit;

  const _SidePanelBody({
    required this.title,
    this.icon,
    this.header,
    required this.fields,
    required this.submitLabel,
    this.successMessage,
    required this.onSubmit,
  });

  @override
  State<_SidePanelBody> createState() => _SidePanelBodyState();
}

class _SidePanelBodyState extends State<_SidePanelBody> {
  bool _dirty = false;

  Future<void> _requestClose() async {
    if (_dirty) {
      final discard = await ConfirmDialog.show(
        context,
        title: 'Descartar cambios',
        description: 'Tenés cambios sin guardar en este formulario. Si salís ahora se pierden.',
        confirmLabel: 'Descartar',
        cancelLabel: 'Seguir editando',
      );
      if (!discard || !mounted) return;
    }
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestClose();
      },
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _requestClose,
              child: const SizedBox.expand(),
            ),
          ),
          Material(
            color: cs.surface,
            child: SizedBox(
              width: 480,
              height: double.infinity,
              child: PForm(
                onChanged: () {
                  if (!_dirty) setState(() => _dirty = true);
                },
                onSubmit: widget.onSubmit,
                successMessage: widget.successMessage,
                onSuccess: () => Navigator.of(context).pop(true),
                builder: (context, form) => Column(
                  children: [
                    _PanelHeader(title: widget.title, icon: widget.icon, onClose: _requestClose),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.header != null) ...[widget.header!, const SizedBox(height: 16)],
                            for (var i = 0; i < widget.fields.length; i++) ...[
                              if (i > 0) const SizedBox(height: 16),
                              widget.fields[i],
                            ],
                          ],
                        ),
                      ),
                    ),
                    _PanelFooter(form: form, submitLabel: widget.submitLabel, onCancel: _requestClose),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onClose;

  const _PanelHeader({required this.title, this.icon, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle(context))),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(LucideIcons.x, size: 18),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

class _PanelFooter extends StatelessWidget {
  final PFormState form;
  final String submitLabel;
  final VoidCallback onCancel;

  const _PanelFooter({required this.form, required this.submitLabel, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderSubtle(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: form.submitting ? null : onCancel,
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: form.submitting ? null : form.submit,
              child: form.submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
