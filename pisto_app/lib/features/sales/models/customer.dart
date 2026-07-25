import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
sealed class Customer with _$Customer {
  const Customer._();

  const factory Customer({
    required String id,
    required String customerType,
    String? firstName,
    String? lastName,
    String? companyName,
    String? taxId,
    String? taxReg,
    String? email,
    String? phone,
    String? address,
    required String creditLimit,
    required int creditDays,
    required bool isActive,
    required DateTime createdAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  bool get isCompany => customerType == 'company';

  String get displayName {
    if (isCompany) return companyName ?? '';
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  String get contact => email?.isNotEmpty == true ? email! : (phone ?? '');

  double get creditLimitValue => double.parse(creditLimit);
}
