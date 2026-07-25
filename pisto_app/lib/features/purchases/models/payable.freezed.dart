// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Payable {

 String get id; String get supplierId; String get purchaseOrderId; String get originalAmount; String get balance; String get dueDate; String get status; DateTime get createdAt;
/// Create a copy of Payable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayableCopyWith<Payable> get copyWith => _$PayableCopyWithImpl<Payable>(this as Payable, _$identity);

  /// Serializes this Payable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payable&&(identical(other.id, id) || other.id == id)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,supplierId,purchaseOrderId,originalAmount,balance,dueDate,status,createdAt);

@override
String toString() {
  return 'Payable(id: $id, supplierId: $supplierId, purchaseOrderId: $purchaseOrderId, originalAmount: $originalAmount, balance: $balance, dueDate: $dueDate, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PayableCopyWith<$Res>  {
  factory $PayableCopyWith(Payable value, $Res Function(Payable) _then) = _$PayableCopyWithImpl;
@useResult
$Res call({
 String id, String supplierId, String purchaseOrderId, String originalAmount, String balance, String dueDate, String status, DateTime createdAt
});




}
/// @nodoc
class _$PayableCopyWithImpl<$Res>
    implements $PayableCopyWith<$Res> {
  _$PayableCopyWithImpl(this._self, this._then);

  final Payable _self;
  final $Res Function(Payable) _then;

/// Create a copy of Payable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? supplierId = null,Object? purchaseOrderId = null,Object? originalAmount = null,Object? balance = null,Object? dueDate = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,originalAmount: null == originalAmount ? _self.originalAmount : originalAmount // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Payable].
extension PayablePatterns on Payable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payable value)  $default,){
final _that = this;
switch (_that) {
case _Payable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payable value)?  $default,){
final _that = this;
switch (_that) {
case _Payable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String supplierId,  String purchaseOrderId,  String originalAmount,  String balance,  String dueDate,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payable() when $default != null:
return $default(_that.id,_that.supplierId,_that.purchaseOrderId,_that.originalAmount,_that.balance,_that.dueDate,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String supplierId,  String purchaseOrderId,  String originalAmount,  String balance,  String dueDate,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Payable():
return $default(_that.id,_that.supplierId,_that.purchaseOrderId,_that.originalAmount,_that.balance,_that.dueDate,_that.status,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String supplierId,  String purchaseOrderId,  String originalAmount,  String balance,  String dueDate,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Payable() when $default != null:
return $default(_that.id,_that.supplierId,_that.purchaseOrderId,_that.originalAmount,_that.balance,_that.dueDate,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payable extends Payable {
  const _Payable({required this.id, required this.supplierId, required this.purchaseOrderId, required this.originalAmount, required this.balance, required this.dueDate, required this.status, required this.createdAt}): super._();
  factory _Payable.fromJson(Map<String, dynamic> json) => _$PayableFromJson(json);

@override final  String id;
@override final  String supplierId;
@override final  String purchaseOrderId;
@override final  String originalAmount;
@override final  String balance;
@override final  String dueDate;
@override final  String status;
@override final  DateTime createdAt;

/// Create a copy of Payable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayableCopyWith<_Payable> get copyWith => __$PayableCopyWithImpl<_Payable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payable&&(identical(other.id, id) || other.id == id)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,supplierId,purchaseOrderId,originalAmount,balance,dueDate,status,createdAt);

@override
String toString() {
  return 'Payable(id: $id, supplierId: $supplierId, purchaseOrderId: $purchaseOrderId, originalAmount: $originalAmount, balance: $balance, dueDate: $dueDate, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PayableCopyWith<$Res> implements $PayableCopyWith<$Res> {
  factory _$PayableCopyWith(_Payable value, $Res Function(_Payable) _then) = __$PayableCopyWithImpl;
@override @useResult
$Res call({
 String id, String supplierId, String purchaseOrderId, String originalAmount, String balance, String dueDate, String status, DateTime createdAt
});




}
/// @nodoc
class __$PayableCopyWithImpl<$Res>
    implements _$PayableCopyWith<$Res> {
  __$PayableCopyWithImpl(this._self, this._then);

  final _Payable _self;
  final $Res Function(_Payable) _then;

/// Create a copy of Payable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? supplierId = null,Object? purchaseOrderId = null,Object? originalAmount = null,Object? balance = null,Object? dueDate = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_Payable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,originalAmount: null == originalAmount ? _self.originalAmount : originalAmount // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PayableRow {

 Payable get payable; String? get supplierName;
/// Create a copy of PayableRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayableRowCopyWith<PayableRow> get copyWith => _$PayableRowCopyWithImpl<PayableRow>(this as PayableRow, _$identity);

  /// Serializes this PayableRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayableRow&&(identical(other.payable, payable) || other.payable == payable)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payable,supplierName);

@override
String toString() {
  return 'PayableRow(payable: $payable, supplierName: $supplierName)';
}


}

/// @nodoc
abstract mixin class $PayableRowCopyWith<$Res>  {
  factory $PayableRowCopyWith(PayableRow value, $Res Function(PayableRow) _then) = _$PayableRowCopyWithImpl;
@useResult
$Res call({
 Payable payable, String? supplierName
});


$PayableCopyWith<$Res> get payable;

}
/// @nodoc
class _$PayableRowCopyWithImpl<$Res>
    implements $PayableRowCopyWith<$Res> {
  _$PayableRowCopyWithImpl(this._self, this._then);

  final PayableRow _self;
  final $Res Function(PayableRow) _then;

/// Create a copy of PayableRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payable = null,Object? supplierName = freezed,}) {
  return _then(_self.copyWith(
payable: null == payable ? _self.payable : payable // ignore: cast_nullable_to_non_nullable
as Payable,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PayableRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PayableCopyWith<$Res> get payable {
  
  return $PayableCopyWith<$Res>(_self.payable, (value) {
    return _then(_self.copyWith(payable: value));
  });
}
}


/// Adds pattern-matching-related methods to [PayableRow].
extension PayableRowPatterns on PayableRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayableRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayableRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayableRow value)  $default,){
final _that = this;
switch (_that) {
case _PayableRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayableRow value)?  $default,){
final _that = this;
switch (_that) {
case _PayableRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Payable payable,  String? supplierName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayableRow() when $default != null:
return $default(_that.payable,_that.supplierName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Payable payable,  String? supplierName)  $default,) {final _that = this;
switch (_that) {
case _PayableRow():
return $default(_that.payable,_that.supplierName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Payable payable,  String? supplierName)?  $default,) {final _that = this;
switch (_that) {
case _PayableRow() when $default != null:
return $default(_that.payable,_that.supplierName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayableRow implements PayableRow {
  const _PayableRow({required this.payable, this.supplierName});
  factory _PayableRow.fromJson(Map<String, dynamic> json) => _$PayableRowFromJson(json);

@override final  Payable payable;
@override final  String? supplierName;

/// Create a copy of PayableRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayableRowCopyWith<_PayableRow> get copyWith => __$PayableRowCopyWithImpl<_PayableRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayableRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayableRow&&(identical(other.payable, payable) || other.payable == payable)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payable,supplierName);

@override
String toString() {
  return 'PayableRow(payable: $payable, supplierName: $supplierName)';
}


}

/// @nodoc
abstract mixin class _$PayableRowCopyWith<$Res> implements $PayableRowCopyWith<$Res> {
  factory _$PayableRowCopyWith(_PayableRow value, $Res Function(_PayableRow) _then) = __$PayableRowCopyWithImpl;
@override @useResult
$Res call({
 Payable payable, String? supplierName
});


@override $PayableCopyWith<$Res> get payable;

}
/// @nodoc
class __$PayableRowCopyWithImpl<$Res>
    implements _$PayableRowCopyWith<$Res> {
  __$PayableRowCopyWithImpl(this._self, this._then);

  final _PayableRow _self;
  final $Res Function(_PayableRow) _then;

/// Create a copy of PayableRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payable = null,Object? supplierName = freezed,}) {
  return _then(_PayableRow(
payable: null == payable ? _self.payable : payable // ignore: cast_nullable_to_non_nullable
as Payable,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PayableRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PayableCopyWith<$Res> get payable {
  
  return $PayableCopyWith<$Res>(_self.payable, (value) {
    return _then(_self.copyWith(payable: value));
  });
}
}

// dart format on
