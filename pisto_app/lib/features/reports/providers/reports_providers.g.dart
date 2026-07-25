// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Todo lo que la pantalla de reportes necesita, en paralelo.

@ProviderFor(reportsOverview)
final reportsOverviewProvider = ReportsOverviewProvider._();

/// Todo lo que la pantalla de reportes necesita, en paralelo.

final class ReportsOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({
              dynamic grossProfit,
              List<dynamic> inventoryValuation,
              Map<String, dynamic> salesSummary,
              List<dynamic> topProducts,
            })
          >,
          ({
            dynamic grossProfit,
            List<dynamic> inventoryValuation,
            Map<String, dynamic> salesSummary,
            List<dynamic> topProducts,
          }),
          FutureOr<
            ({
              dynamic grossProfit,
              List<dynamic> inventoryValuation,
              Map<String, dynamic> salesSummary,
              List<dynamic> topProducts,
            })
          >
        >
    with
        $FutureModifier<
          ({
            dynamic grossProfit,
            List<dynamic> inventoryValuation,
            Map<String, dynamic> salesSummary,
            List<dynamic> topProducts,
          })
        >,
        $FutureProvider<
          ({
            dynamic grossProfit,
            List<dynamic> inventoryValuation,
            Map<String, dynamic> salesSummary,
            List<dynamic> topProducts,
          })
        > {
  /// Todo lo que la pantalla de reportes necesita, en paralelo.
  ReportsOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsOverviewHash();

  @$internal
  @override
  $FutureProviderElement<
    ({
      dynamic grossProfit,
      List<dynamic> inventoryValuation,
      Map<String, dynamic> salesSummary,
      List<dynamic> topProducts,
    })
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<
    ({
      dynamic grossProfit,
      List<dynamic> inventoryValuation,
      Map<String, dynamic> salesSummary,
      List<dynamic> topProducts,
    })
  >
  create(Ref ref) {
    return reportsOverview(ref);
  }
}

String _$reportsOverviewHash() => r'6dddae59ec903e3abd5617e305bf966c15a7b2cc';
