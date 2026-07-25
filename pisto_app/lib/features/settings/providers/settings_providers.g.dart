// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Todo lo que la pantalla de configuración necesita, en paralelo.

@ProviderFor(settingsOverview)
final settingsOverviewProvider = SettingsOverviewProvider._();

/// Todo lo que la pantalla de configuración necesita, en paralelo.

final class SettingsOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({
              Map<String, dynamic>? business,
              List<Map<String, dynamic>> paymentMethods,
              List<Map<String, dynamic>> taxes,
            })
          >,
          ({
            Map<String, dynamic>? business,
            List<Map<String, dynamic>> paymentMethods,
            List<Map<String, dynamic>> taxes,
          }),
          FutureOr<
            ({
              Map<String, dynamic>? business,
              List<Map<String, dynamic>> paymentMethods,
              List<Map<String, dynamic>> taxes,
            })
          >
        >
    with
        $FutureModifier<
          ({
            Map<String, dynamic>? business,
            List<Map<String, dynamic>> paymentMethods,
            List<Map<String, dynamic>> taxes,
          })
        >,
        $FutureProvider<
          ({
            Map<String, dynamic>? business,
            List<Map<String, dynamic>> paymentMethods,
            List<Map<String, dynamic>> taxes,
          })
        > {
  /// Todo lo que la pantalla de configuración necesita, en paralelo.
  SettingsOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsOverviewHash();

  @$internal
  @override
  $FutureProviderElement<
    ({
      Map<String, dynamic>? business,
      List<Map<String, dynamic>> paymentMethods,
      List<Map<String, dynamic>> taxes,
    })
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<
    ({
      Map<String, dynamic>? business,
      List<Map<String, dynamic>> paymentMethods,
      List<Map<String, dynamic>> taxes,
    })
  >
  create(Ref ref) {
    return settingsOverview(ref);
  }
}

String _$settingsOverviewHash() => r'96e5f506ad8a0748f2a6b0290b4937b3db3ff670';

@ProviderFor(SettingsMutations)
final settingsMutationsProvider = SettingsMutationsProvider._();

final class SettingsMutationsProvider
    extends $NotifierProvider<SettingsMutations, void> {
  SettingsMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsMutationsHash();

  @$internal
  @override
  SettingsMutations create() => SettingsMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$settingsMutationsHash() => r'737dd0346cded619a2514d1f8308594225b2fce3';

abstract class _$SettingsMutations extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
