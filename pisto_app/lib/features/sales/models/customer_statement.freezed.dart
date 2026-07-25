// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_statement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerStatement {

 List<ReceivableEntry> get receivables;
/// Create a copy of CustomerStatement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerStatementCopyWith<CustomerStatement> get copyWith => _$CustomerStatementCopyWithImpl<CustomerStatement>(this as CustomerStatement, _$identity);

  /// Serializes this CustomerStatement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerStatement&&const DeepCollectionEquality().equals(other.receivables, receivables));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(receivables));

@override
String toString() {
  return 'CustomerStatement(receivables: $receivables)';
}


}

/// @nodoc
abstract mixin class $CustomerStatementCopyWith<$Res>  {
  factory $CustomerStatementCopyWith(CustomerStatement value, $Res Function(CustomerStatement) _then) = _$CustomerStatementCopyWithImpl;
@useResult
$Res call({
 List<ReceivableEntry> receivables
});




}
/// @nodoc
class _$CustomerStatementCopyWithImpl<$Res>
    implements $CustomerStatementCopyWith<$Res> {
  _$CustomerStatementCopyWithImpl(this._self, this._then);

  final CustomerStatement _self;
  final $Res Function(CustomerStatement) _then;

/// Create a copy of CustomerStatement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? receivables = null,}) {
  return _then(_self.copyWith(
receivables: null == receivables ? _self.receivables : receivables // ignore: cast_nullable_to_non_nullable
as List<ReceivableEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerStatement].
extension CustomerStatementPatterns on CustomerStatement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerStatement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerStatement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerStatement value)  $default,){
final _that = this;
switch (_that) {
case _CustomerStatement():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerStatement value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerStatement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ReceivableEntry> receivables)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerStatement() when $default != null:
return $default(_that.receivables);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ReceivableEntry> receivables)  $default,) {final _that = this;
switch (_that) {
case _CustomerStatement():
return $default(_that.receivables);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ReceivableEntry> receivables)?  $default,) {final _that = this;
switch (_that) {
case _CustomerStatement() when $default != null:
return $default(_that.receivables);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerStatement extends CustomerStatement {
  const _CustomerStatement({required final  List<ReceivableEntry> receivables}): _receivables = receivables,super._();
  factory _CustomerStatement.fromJson(Map<String, dynamic> json) => _$CustomerStatementFromJson(json);

 final  List<ReceivableEntry> _receivables;
@override List<ReceivableEntry> get receivables {
  if (_receivables is EqualUnmodifiableListView) return _receivables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_receivables);
}


/// Create a copy of CustomerStatement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerStatementCopyWith<_CustomerStatement> get copyWith => __$CustomerStatementCopyWithImpl<_CustomerStatement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerStatementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerStatement&&const DeepCollectionEquality().equals(other._receivables, _receivables));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_receivables));

@override
String toString() {
  return 'CustomerStatement(receivables: $receivables)';
}


}

/// @nodoc
abstract mixin class _$CustomerStatementCopyWith<$Res> implements $CustomerStatementCopyWith<$Res> {
  factory _$CustomerStatementCopyWith(_CustomerStatement value, $Res Function(_CustomerStatement) _then) = __$CustomerStatementCopyWithImpl;
@override @useResult
$Res call({
 List<ReceivableEntry> receivables
});




}
/// @nodoc
class __$CustomerStatementCopyWithImpl<$Res>
    implements _$CustomerStatementCopyWith<$Res> {
  __$CustomerStatementCopyWithImpl(this._self, this._then);

  final _CustomerStatement _self;
  final $Res Function(_CustomerStatement) _then;

/// Create a copy of CustomerStatement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? receivables = null,}) {
  return _then(_CustomerStatement(
receivables: null == receivables ? _self._receivables : receivables // ignore: cast_nullable_to_non_nullable
as List<ReceivableEntry>,
  ));
}


}


/// @nodoc
mixin _$ReceivableEntry {

 Receivable get receivable; String? get saleNumber;
/// Create a copy of ReceivableEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivableEntryCopyWith<ReceivableEntry> get copyWith => _$ReceivableEntryCopyWithImpl<ReceivableEntry>(this as ReceivableEntry, _$identity);

  /// Serializes this ReceivableEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceivableEntry&&(identical(other.receivable, receivable) || other.receivable == receivable)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,receivable,saleNumber);

@override
String toString() {
  return 'ReceivableEntry(receivable: $receivable, saleNumber: $saleNumber)';
}


}

/// @nodoc
abstract mixin class $ReceivableEntryCopyWith<$Res>  {
  factory $ReceivableEntryCopyWith(ReceivableEntry value, $Res Function(ReceivableEntry) _then) = _$ReceivableEntryCopyWithImpl;
@useResult
$Res call({
 Receivable receivable, String? saleNumber
});


$ReceivableCopyWith<$Res> get receivable;

}
/// @nodoc
class _$ReceivableEntryCopyWithImpl<$Res>
    implements $ReceivableEntryCopyWith<$Res> {
  _$ReceivableEntryCopyWithImpl(this._self, this._then);

  final ReceivableEntry _self;
  final $Res Function(ReceivableEntry) _then;

/// Create a copy of ReceivableEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? receivable = null,Object? saleNumber = freezed,}) {
  return _then(_self.copyWith(
receivable: null == receivable ? _self.receivable : receivable // ignore: cast_nullable_to_non_nullable
as Receivable,saleNumber: freezed == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ReceivableEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReceivableCopyWith<$Res> get receivable {
  
  return $ReceivableCopyWith<$Res>(_self.receivable, (value) {
    return _then(_self.copyWith(receivable: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReceivableEntry].
extension ReceivableEntryPatterns on ReceivableEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceivableEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceivableEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceivableEntry value)  $default,){
final _that = this;
switch (_that) {
case _ReceivableEntry():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceivableEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ReceivableEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Receivable receivable,  String? saleNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceivableEntry() when $default != null:
return $default(_that.receivable,_that.saleNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Receivable receivable,  String? saleNumber)  $default,) {final _that = this;
switch (_that) {
case _ReceivableEntry():
return $default(_that.receivable,_that.saleNumber);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Receivable receivable,  String? saleNumber)?  $default,) {final _that = this;
switch (_that) {
case _ReceivableEntry() when $default != null:
return $default(_that.receivable,_that.saleNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceivableEntry implements ReceivableEntry {
  const _ReceivableEntry({required this.receivable, this.saleNumber});
  factory _ReceivableEntry.fromJson(Map<String, dynamic> json) => _$ReceivableEntryFromJson(json);

@override final  Receivable receivable;
@override final  String? saleNumber;

/// Create a copy of ReceivableEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceivableEntryCopyWith<_ReceivableEntry> get copyWith => __$ReceivableEntryCopyWithImpl<_ReceivableEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceivableEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceivableEntry&&(identical(other.receivable, receivable) || other.receivable == receivable)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,receivable,saleNumber);

@override
String toString() {
  return 'ReceivableEntry(receivable: $receivable, saleNumber: $saleNumber)';
}


}

/// @nodoc
abstract mixin class _$ReceivableEntryCopyWith<$Res> implements $ReceivableEntryCopyWith<$Res> {
  factory _$ReceivableEntryCopyWith(_ReceivableEntry value, $Res Function(_ReceivableEntry) _then) = __$ReceivableEntryCopyWithImpl;
@override @useResult
$Res call({
 Receivable receivable, String? saleNumber
});


@override $ReceivableCopyWith<$Res> get receivable;

}
/// @nodoc
class __$ReceivableEntryCopyWithImpl<$Res>
    implements _$ReceivableEntryCopyWith<$Res> {
  __$ReceivableEntryCopyWithImpl(this._self, this._then);

  final _ReceivableEntry _self;
  final $Res Function(_ReceivableEntry) _then;

/// Create a copy of ReceivableEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? receivable = null,Object? saleNumber = freezed,}) {
  return _then(_ReceivableEntry(
receivable: null == receivable ? _self.receivable : receivable // ignore: cast_nullable_to_non_nullable
as Receivable,saleNumber: freezed == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ReceivableEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReceivableCopyWith<$Res> get receivable {
  
  return $ReceivableCopyWith<$Res>(_self.receivable, (value) {
    return _then(_self.copyWith(receivable: value));
  });
}
}


/// @nodoc
mixin _$Receivable {

 String get id; String get saleId; String get originalAmount; String get balance; String get dueDate; String get status;
/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivableCopyWith<Receivable> get copyWith => _$ReceivableCopyWithImpl<Receivable>(this as Receivable, _$identity);

  /// Serializes this Receivable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receivable&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,originalAmount,balance,dueDate,status);

@override
String toString() {
  return 'Receivable(id: $id, saleId: $saleId, originalAmount: $originalAmount, balance: $balance, dueDate: $dueDate, status: $status)';
}


}

/// @nodoc
abstract mixin class $ReceivableCopyWith<$Res>  {
  factory $ReceivableCopyWith(Receivable value, $Res Function(Receivable) _then) = _$ReceivableCopyWithImpl;
@useResult
$Res call({
 String id, String saleId, String originalAmount, String balance, String dueDate, String status
});




}
/// @nodoc
class _$ReceivableCopyWithImpl<$Res>
    implements $ReceivableCopyWith<$Res> {
  _$ReceivableCopyWithImpl(this._self, this._then);

  final Receivable _self;
  final $Res Function(Receivable) _then;

/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? originalAmount = null,Object? balance = null,Object? dueDate = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,originalAmount: null == originalAmount ? _self.originalAmount : originalAmount // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Receivable].
extension ReceivablePatterns on Receivable {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Receivable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Receivable value)  $default,){
final _that = this;
switch (_that) {
case _Receivable():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Receivable value)?  $default,){
final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String saleId,  String originalAmount,  String balance,  String dueDate,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that.id,_that.saleId,_that.originalAmount,_that.balance,_that.dueDate,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String saleId,  String originalAmount,  String balance,  String dueDate,  String status)  $default,) {final _that = this;
switch (_that) {
case _Receivable():
return $default(_that.id,_that.saleId,_that.originalAmount,_that.balance,_that.dueDate,_that.status);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String saleId,  String originalAmount,  String balance,  String dueDate,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that.id,_that.saleId,_that.originalAmount,_that.balance,_that.dueDate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receivable implements Receivable {
  const _Receivable({required this.id, required this.saleId, required this.originalAmount, required this.balance, required this.dueDate, required this.status});
  factory _Receivable.fromJson(Map<String, dynamic> json) => _$ReceivableFromJson(json);

@override final  String id;
@override final  String saleId;
@override final  String originalAmount;
@override final  String balance;
@override final  String dueDate;
@override final  String status;

/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceivableCopyWith<_Receivable> get copyWith => __$ReceivableCopyWithImpl<_Receivable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceivableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receivable&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,originalAmount,balance,dueDate,status);

@override
String toString() {
  return 'Receivable(id: $id, saleId: $saleId, originalAmount: $originalAmount, balance: $balance, dueDate: $dueDate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ReceivableCopyWith<$Res> implements $ReceivableCopyWith<$Res> {
  factory _$ReceivableCopyWith(_Receivable value, $Res Function(_Receivable) _then) = __$ReceivableCopyWithImpl;
@override @useResult
$Res call({
 String id, String saleId, String originalAmount, String balance, String dueDate, String status
});




}
/// @nodoc
class __$ReceivableCopyWithImpl<$Res>
    implements _$ReceivableCopyWith<$Res> {
  __$ReceivableCopyWithImpl(this._self, this._then);

  final _Receivable _self;
  final $Res Function(_Receivable) _then;

/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? originalAmount = null,Object? balance = null,Object? dueDate = null,Object? status = null,}) {
  return _then(_Receivable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,originalAmount: null == originalAmount ? _self.originalAmount : originalAmount // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
