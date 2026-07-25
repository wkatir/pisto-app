import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_note.freezed.dart';
part 'credit_note.g.dart';

@freezed
sealed class CreditNote with _$CreditNote {
  const CreditNote._();

  const factory CreditNote({
    required String id,
    required String saleId,
    required String customerId,
    required String noteNumber,
    required String reason,
    required String total,
    required String status,
    required DateTime createdAt,
  }) = _CreditNote;

  factory CreditNote.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteFromJson(json);

  double get totalValue => double.parse(total);

  String get statusLabel => switch (status) {
        'active' => 'Activa',
        'cancelled' => 'Cancelada',
        _ => status,
      };
}
