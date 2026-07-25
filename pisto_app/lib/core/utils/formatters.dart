import 'package:intl/intl.dart';

final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final dateFmt = DateFormat('yyyy-MM-dd');
final dateDisplayFmt = DateFormat('dd/MM/yyyy');

/// Short Spanish date format for list displays: "7 may", "20 oct".
/// Accepts ISO 8601, "yyyy-MM-dd", or any parseable string.
/// Returns an empty string if the input is null/invalid.
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

/// Stock quantities: integer if it has no decimals ("110"), otherwise with
/// the significant decimals ("2.5"). The API sends numeric as "110.00".
String formatQty(num value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value.toString();
}

/// `dd/MM/yyyy` format tolerant of invalid inputs.
String formatDateDisplay(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  return dateDisplayFmt.format(dt);
}
