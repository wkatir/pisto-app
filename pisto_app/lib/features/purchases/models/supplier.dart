import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier.freezed.dart';
part 'supplier.g.dart';

@freezed
sealed class Supplier with _$Supplier {
  const Supplier._();

  const factory Supplier({
    required String id,
    required String companyName,
    String? contactName,
    String? taxId,
    String? phone,
    String? email,
    String? address,
    required int paymentTerms,
    required bool isActive,
    required DateTime createdAt,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);

  String get contact =>
      contactName?.isNotEmpty == true ? contactName! : (email ?? '');
}
