import 'package:intl/intl.dart';

final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final dateFmt = DateFormat('yyyy-MM-dd');
final dateDisplayFmt = DateFormat('dd/MM/yyyy');

/// Formato corto en español para mostrar fechas en listas: "7 may", "20 oct".
/// Acepta ISO 8601, "yyyy-MM-dd" o cualquier string parseable.
/// Devuelve cadena vacía si la entrada es null/inválida.
String formatDateShortEs(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${dt.day} ${months[dt.month - 1]}';
}

/// Formato `dd/MM/yyyy` con tolerancia a entradas inválidas.
String formatDateDisplay(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  return dateDisplayFmt.format(dt);
}
