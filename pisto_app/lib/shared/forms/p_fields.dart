import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';
import '../../core/utils/formatters.dart';
import 'p_form.dart';

/// Shared form kit validators. Return null when the value is valid; optional
/// fields accept empty.
class PValidators {
  PValidators._();

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requerido' : null;

  static String? email(String? v) {
    if (v == null || v.isEmpty) return null;
    final ok = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(v);
    return ok ? null : 'Email inválido';
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return null;
    final ok = RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(v);
    return ok ? null : 'Teléfono inválido (7-15 dígitos)';
  }

  /// Decimal with up to 2 places — the format the API requires for money.
  static String? money(String? v) {
    if (v == null || v.isEmpty) return null;
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(v)) return 'Monto inválido';
    return null;
  }

  static String? percent(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null || n < 0 || n > 100) return 'Entre 0 y 100';
    return null;
  }
}

String? _compose(String? v, List<String? Function(String?)> validators) {
  for (final validator in validators) {
    final error = validator(v);
    if (error != null) return error;
  }
  return null;
}

/// Standard text field. Stores `String?` (null if left empty).
class PTextField extends StatelessWidget {
  final String name;
  final String label;
  final String? initialValue;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool autofocus;

  const PTextField({
    super.key,
    required this.name,
    required this.label,
    this.initialValue,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final form = PForm.of(context);
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      autofocus: autofocus,
      decoration: InputDecoration(labelText: label),
      validator: (v) => _compose(v, [
        if (required) PValidators.required,
        ?validator,
      ]),
      onSaved: (v) {
        final trimmed = v?.trim();
        form.values[name] =
            (trimmed == null || trimmed.isEmpty) ? null : trimmed;
      },
    );
  }
}

/// Money field — Spline Sans Mono, `$` prefix, decimal with 2 places.
/// Stores `String?` in API format (`"12.50"`), null if left empty.
class PMoneyField extends StatelessWidget {
  final String name;
  final String label;
  final String? initialValue;
  final bool required;

  /// Requires a value strictly greater than zero.
  final bool positive;

  const PMoneyField({
    super.key,
    required this.name,
    required this.label,
    this.initialValue,
    this.required = false,
    this.positive = false,
  });

  @override
  Widget build(BuildContext context) {
    final form = PForm.of(context);
    return TextFormField(
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: AppTheme.mono(fontSize: 14),
      decoration: InputDecoration(labelText: label, prefixText: '\$ '),
      validator: (v) => _compose(v, [
        if (required) PValidators.required,
        PValidators.money,
        if (positive)
          (v) => (v != null && v.isNotEmpty && double.parse(v) <= 0)
              ? 'Debe ser mayor a 0'
              : null,
      ]),
      onSaved: (v) =>
          form.values[name] = (v == null || v.isEmpty) ? null : v,
    );
  }
}

class PSelectOption<T> {
  final T value;
  final String label;
  const PSelectOption(this.value, this.label);
}

/// Typed dropdown. Stores `T?`.
class PSelectField<T> extends StatelessWidget {
  final String name;
  final String label;
  final List<PSelectOption<T>> options;
  final T? initialValue;
  final bool required;
  final ValueChanged<T?>? onChanged;

  const PSelectField({
    super.key,
    required this.name,
    required this.label,
    required this.options,
    this.initialValue,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final form = PForm.of(context);
    return DropdownButtonFormField<T>(
      isExpanded: true,
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final o in options)
          DropdownMenuItem(
            value: o.value,
            child: Text(o.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      validator: required ? (v) => v == null ? 'Requerido' : null : null,
      onChanged: onChanged ?? (_) {},
      onSaved: (v) => form.values[name] = v,
    );
  }
}

/// Date picker. Stores `String?` in `yyyy-MM-dd` (API format).
class PDateField extends StatelessWidget {
  final String name;
  final String label;
  final DateTime? initialValue;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const PDateField({
    super.key,
    required this.name,
    required this.label,
    this.initialValue,
    this.required = false,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final form = PForm.of(context);
    return FormField<DateTime>(
      initialValue: initialValue,
      validator:
          required ? (v) => v == null ? 'Requerido' : null : null,
      onSaved: (v) =>
          form.values[name] = v == null ? null : dateFmt.format(v),
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: state.context,
              initialDate: state.value ?? now,
              firstDate: firstDate ?? DateTime(now.year - 5),
              lastDate: lastDate ?? DateTime(now.year + 5),
            );
            if (picked != null) state.didChange(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: state.errorText,
              suffixIcon: const Icon(LucideIcons.calendar, size: 18),
            ),
            isEmpty: state.value == null,
            child: state.value == null
                ? null
                : Text(dateDisplayFmt.format(state.value!)),
          ),
        );
      },
    );
  }
}
