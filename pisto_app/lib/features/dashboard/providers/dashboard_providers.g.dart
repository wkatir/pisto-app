// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Todo lo que necesita el dashboard para un período dado, en paralelo.

@ProviderFor(dashboardData)
final dashboardDataProvider = DashboardDataFamily._();

/// Todo lo que necesita el dashboard para un período dado, en paralelo.

final class DashboardDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({
              Map<String, dynamic> kpis,
              List<dynamic> salesByCategory,
              List<dynamic> salesTrend,
              List<dynamic> topProducts,
            })
          >,
          ({
            Map<String, dynamic> kpis,
            List<dynamic> salesByCategory,
            List<dynamic> salesTrend,
            List<dynamic> topProducts,
          }),
          FutureOr<
            ({
              Map<String, dynamic> kpis,
              List<dynamic> salesByCategory,
              List<dynamic> salesTrend,
              List<dynamic> topProducts,
            })
          >
        >
    with
        $FutureModifier<
          ({
            Map<String, dynamic> kpis,
            List<dynamic> salesByCategory,
            List<dynamic> salesTrend,
            List<dynamic> topProducts,
          })
        >,
        $FutureProvider<
          ({
            Map<String, dynamic> kpis,
            List<dynamic> salesByCategory,
            List<dynamic> salesTrend,
            List<dynamic> topProducts,
          })
        > {
  /// Todo lo que necesita el dashboard para un período dado, en paralelo.
  DashboardDataProvider._({
    required DashboardDataFamily super.from,
    required DashboardPeriod super.argument,
  }) : super(
         retry: null,
         name: r'dashboardDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardDataHash();

  @override
  String toString() {
    return r'dashboardDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
    ({
      Map<String, dynamic> kpis,
      List<dynamic> salesByCategory,
      List<dynamic> salesTrend,
      List<dynamic> topProducts,
    })
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<
    ({
      Map<String, dynamic> kpis,
      List<dynamic> salesByCategory,
      List<dynamic> salesTrend,
      List<dynamic> topProducts,
    })
  >
  create(Ref ref) {
    final argument = this.argument as DashboardPeriod;
    return dashboardData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardDataHash() => r'e4d5e460d476bba7f063841bc9d71dea1d5c4e09';

/// Todo lo que necesita el dashboard para un período dado, en paralelo.

final class DashboardDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<
            ({
              Map<String, dynamic> kpis,
              List<dynamic> salesByCategory,
              List<dynamic> salesTrend,
              List<dynamic> topProducts,
            })
          >,
          DashboardPeriod
        > {
  DashboardDataFamily._()
    : super(
        retry: null,
        name: r'dashboardDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Todo lo que necesita el dashboard para un período dado, en paralelo.

  DashboardDataProvider call(DashboardPeriod period) =>
      DashboardDataProvider._(argument: period, from: this);

  @override
  String toString() => r'dashboardDataProvider';
}
