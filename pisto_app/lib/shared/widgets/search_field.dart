import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


/// Campo de búsqueda consistente para listas.
///
/// Incluye debounce de 300ms, ícono de lupa, botón de limpiar, y un diseño
/// que se integra con el lenguaje visual de la app sin parecer un
/// TextFormField genérico.
class SearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final Duration debounce;
  final TextEditingController? controller;

  const SearchField({
    super.key,
    this.hint = 'Buscar...',
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 300),
    this.controller,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _ctrl;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onChanged(value.trim());
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: TextField(
        controller: _ctrl,
        onChanged: _onChanged,
        style: TextStyle(
          fontSize: 13.5,
          color: cs.onSurface,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontSize: 13.5,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              LucideIcons.search,
              size: 16,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                  icon: Icon(LucideIcons.x, size: 14, color: cs.onSurfaceVariant),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                )
              : null,
          filled: true,
          fillColor: cs.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
