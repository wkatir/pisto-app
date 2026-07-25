import 'package:freezed_annotation/freezed_annotation.dart';

part 'aging_bucket.freezed.dart';
part 'aging_bucket.g.dart';

/// Row from `GET /collections/receivables/aging`: an aging range.
@freezed
sealed class AgingBucket with _$AgingBucket {
  const AgingBucket._();

  const factory AgingBucket({
    required String range,
    required int count,
    required String total,
  }) = _AgingBucket;

  factory AgingBucket.fromJson(Map<String, dynamic> json) =>
      _$AgingBucketFromJson(json);

  double get totalValue => double.parse(total);
}
