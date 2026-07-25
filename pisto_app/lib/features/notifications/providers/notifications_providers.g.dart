// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider = NotificationsRepositoryProvider._();

final class NotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationsRepository,
          NotificationsRepository,
          NotificationsRepository
        >
    with $Provider<NotificationsRepository> {
  NotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsRepository create(Ref ref) {
    return notificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsRepository>(value),
    );
  }
}

String _$notificationsRepositoryHash() =>
    r'1f2c37b060faceb0c3669b1a54507578b35d8bcd';

@ProviderFor(notificationsList)
final notificationsListProvider = NotificationsListFamily._();

final class NotificationsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<NotificationItem>>,
          Paginated<NotificationItem>,
          FutureOr<Paginated<NotificationItem>>
        >
    with
        $FutureModifier<Paginated<NotificationItem>>,
        $FutureProvider<Paginated<NotificationItem>> {
  NotificationsListProvider._({
    required NotificationsListFamily super.from,
    required ({int page, bool unreadOnly}) super.argument,
  }) : super(
         retry: null,
         name: r'notificationsListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationsListHash();

  @override
  String toString() {
    return r'notificationsListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<NotificationItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<NotificationItem>> create(Ref ref) {
    final argument = this.argument as ({int page, bool unreadOnly});
    return notificationsList(
      ref,
      page: argument.page,
      unreadOnly: argument.unreadOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationsListHash() => r'd957ea24ad9916e6b0f1c3c18121d871a711ddcc';

final class NotificationsListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Paginated<NotificationItem>>,
          ({int page, bool unreadOnly})
        > {
  NotificationsListFamily._()
    : super(
        retry: null,
        name: r'notificationsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotificationsListProvider call({int page = 1, bool unreadOnly = false}) =>
      NotificationsListProvider._(
        argument: (page: page, unreadOnly: unreadOnly),
        from: this,
      );

  @override
  String toString() => r'notificationsListProvider';
}

/// Contador para el badge del shell. keepAlive + timer que se re-arma en cada
/// rebuild → refresh cada 60s mientras la app está viva (incluye reintento
/// tras error).

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// Contador para el badge del shell. keepAlive + timer que se re-arma en cada
/// rebuild → refresh cada 60s mientras la app está viva (incluye reintento
/// tras error).

final class UnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Contador para el badge del shell. keepAlive + timer que se re-arma en cada
  /// rebuild → refresh cada 60s mientras la app está viva (incluye reintento
  /// tras error).
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadCount(ref);
  }
}

String _$unreadCountHash() => r'0ec88d2a43f4a8189feab6737bba51c3a3f3bdbf';

@ProviderFor(NotificationMutations)
final notificationMutationsProvider = NotificationMutationsProvider._();

final class NotificationMutationsProvider
    extends $NotifierProvider<NotificationMutations, void> {
  NotificationMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationMutationsHash();

  @$internal
  @override
  NotificationMutations create() => NotificationMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationMutationsHash() =>
    r'15ad5068e1fdea8de9ca9e32f7f2d12647fd40fe';

abstract class _$NotificationMutations extends $Notifier<void> {
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
