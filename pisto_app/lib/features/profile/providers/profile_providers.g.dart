// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Datos del usuario autenticado (`GET /auth/me`).

@ProviderFor(profileMe)
final profileMeProvider = ProfileMeProvider._();

/// Datos del usuario autenticado (`GET /auth/me`).

final class ProfileMeProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Datos del usuario autenticado (`GET /auth/me`).
  ProfileMeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileMeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileMeHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return profileMe(ref);
  }
}

String _$profileMeHash() => r'5c16c78ef170e107745c790a684fee969fc9cdad';

@ProviderFor(ProfileMutations)
final profileMutationsProvider = ProfileMutationsProvider._();

final class ProfileMutationsProvider
    extends $NotifierProvider<ProfileMutations, void> {
  ProfileMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileMutationsHash();

  @$internal
  @override
  ProfileMutations create() => ProfileMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$profileMutationsHash() => r'f4b18128b00205521113e5d711fab43e5375d8a5';

abstract class _$ProfileMutations extends $Notifier<void> {
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
