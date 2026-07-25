// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(forecastResult)
final forecastResultProvider = ForecastResultProvider._();

final class ForecastResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<ForecastResult>,
          ForecastResult,
          FutureOr<ForecastResult>
        >
    with $FutureModifier<ForecastResult>, $FutureProvider<ForecastResult> {
  ForecastResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forecastResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forecastResultHash();

  @$internal
  @override
  $FutureProviderElement<ForecastResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ForecastResult> create(Ref ref) {
    return forecastResult(ref);
  }
}

String _$forecastResultHash() => r'03c3ef96902fa906571d40c84a58baae3d9313a5';
