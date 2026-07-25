import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer.freezed.dart';
part 'transfer.g.dart';

/// Row from `GET /inventory/transfers` — header only; the lines only come
/// from `GET /inventory/transfers/:id`.
@freezed
sealed class Transfer with _$Transfer {
  const Transfer._();

  const factory Transfer({
    required String id,
    required String fromWarehouseId,
    required String toWarehouseId,
    required String status,
    String? notes,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Transfer;

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);

  String get statusLabel => switch (status) {
        'pending' => 'Pendiente',
        'completed' => 'Completada',
        'cancelled' => 'Cancelada',
        _ => status,
      };
}

/// Line for `POST /inventory/transfers` — quantity in API decimal format.
class TransferLineInput {
  final String productId;
  final String quantity;

  const TransferLineInput({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}
