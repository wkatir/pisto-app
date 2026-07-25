import 'package:flutter/material.dart';
import '../widgets/app_toast.dart';

/// Form scaffold: validates, collects values from P* fields, and manages
/// submit state and API errors (via AppToast.guard).
///
/// Fields ([PTextField], [PMoneyField], ...) store their value in
/// [PFormState.values] keyed by their `name`; the caller receives the
/// complete map in [onSubmit] and builds the typed repository call from it.
class PForm extends StatefulWidget {
  final Future<void> Function(Map<String, Object?> values) onSubmit;

  /// Called after a successful submit (typically pop/invalidate).
  final VoidCallback? onSuccess;
  final String? successMessage;
  final Widget Function(BuildContext context, PFormState form) builder;

  /// Called whenever any inner field changes: used by [SidePanelForm]
  /// for the unsaved-changes guard.
  final VoidCallback? onChanged;

  const PForm({
    super.key,
    required this.onSubmit,
    this.onSuccess,
    this.successMessage,
    required this.builder,
    this.onChanged,
  });

  static PFormState of(BuildContext context) {
    final state = context.findAncestorStateOfType<PFormState>();
    assert(state != null, 'P* field used outside a PForm');
    return state!;
  }

  @override
  State<PForm> createState() => PFormState();
}

class PFormState extends State<PForm> {
  final _formKey = GlobalKey<FormState>();
  final values = <String, Object?>{};
  bool _submitting = false;

  bool get submitting => _submitting;

  Future<void> submit() async {
    if (_submitting) return;
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();
    setState(() => _submitting = true);
    final ok = await AppToast.guard(
      context,
      () => widget.onSubmit(Map.of(values)),
      successMessage: widget.successMessage,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: widget.onChanged,
      child: Builder(builder: (context) => widget.builder(context, this)),
    );
  }
}
