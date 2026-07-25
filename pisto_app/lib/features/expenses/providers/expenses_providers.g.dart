// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expensesRepository)
final expensesRepositoryProvider = ExpensesRepositoryProvider._();

final class ExpensesRepositoryProvider
    extends
        $FunctionalProvider<
          ExpensesRepository,
          ExpensesRepository,
          ExpensesRepository
        >
    with $Provider<ExpensesRepository> {
  ExpensesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpensesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpensesRepository create(Ref ref) {
    return expensesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpensesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpensesRepository>(value),
    );
  }
}

String _$expensesRepositoryHash() =>
    r'703416ea110ce6d047da0b7283052724e6047c2d';

/// Todo lo que la pantalla de gastos necesita, en paralelo.

@ProviderFor(expensesOverview)
final expensesOverviewProvider = ExpensesOverviewFamily._();

/// Todo lo que la pantalla de gastos necesita, en paralelo.

final class ExpensesOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({
              List<ExpenseCategory> categories,
              List<Expense> expenses,
              ExpenseSummary summary,
            })
          >,
          ({
            List<ExpenseCategory> categories,
            List<Expense> expenses,
            ExpenseSummary summary,
          }),
          FutureOr<
            ({
              List<ExpenseCategory> categories,
              List<Expense> expenses,
              ExpenseSummary summary,
            })
          >
        >
    with
        $FutureModifier<
          ({
            List<ExpenseCategory> categories,
            List<Expense> expenses,
            ExpenseSummary summary,
          })
        >,
        $FutureProvider<
          ({
            List<ExpenseCategory> categories,
            List<Expense> expenses,
            ExpenseSummary summary,
          })
        > {
  /// Todo lo que la pantalla de gastos necesita, en paralelo.
  ExpensesOverviewProvider._({
    required ExpensesOverviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expensesOverviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expensesOverviewHash();

  @override
  String toString() {
    return r'expensesOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
    ({
      List<ExpenseCategory> categories,
      List<Expense> expenses,
      ExpenseSummary summary,
    })
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<
    ({
      List<ExpenseCategory> categories,
      List<Expense> expenses,
      ExpenseSummary summary,
    })
  >
  create(Ref ref) {
    final argument = this.argument as String;
    return expensesOverview(ref, startDate: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensesOverviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expensesOverviewHash() => r'b42adb4ceb5df219f2643065ef4ca2bea624578b';

/// Todo lo que la pantalla de gastos necesita, en paralelo.

final class ExpensesOverviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<
            ({
              List<ExpenseCategory> categories,
              List<Expense> expenses,
              ExpenseSummary summary,
            })
          >,
          String
        > {
  ExpensesOverviewFamily._()
    : super(
        retry: null,
        name: r'expensesOverviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Todo lo que la pantalla de gastos necesita, en paralelo.

  ExpensesOverviewProvider call({required String startDate}) =>
      ExpensesOverviewProvider._(argument: startDate, from: this);

  @override
  String toString() => r'expensesOverviewProvider';
}

@ProviderFor(ExpenseMutations)
final expenseMutationsProvider = ExpenseMutationsProvider._();

final class ExpenseMutationsProvider
    extends $NotifierProvider<ExpenseMutations, void> {
  ExpenseMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseMutationsHash();

  @$internal
  @override
  ExpenseMutations create() => ExpenseMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$expenseMutationsHash() => r'4c8549200a23f7f8d00297dd8a735d5085343d2d';

abstract class _$ExpenseMutations extends $Notifier<void> {
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
