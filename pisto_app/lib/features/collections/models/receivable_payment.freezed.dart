// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receivable_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReceivablePayment {

 String get id; String get accountReceivableId; String get paymentMethodId; String? get receiptNumber; String get amount; String get paymentDate; String? get reference; String? get notes; DateTime get createdAt;
/// Create a copy of ReceivablePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivablePaymentCopyWith<ReceivablePayment> get copyWith => _$ReceivablePaymentCopyWithImpl<ReceivablePayment>(this as ReceivablePayment, _$identity);

  /// Serializes this ReceivablePayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceivablePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.accountReceivableId, accountReceivableId) || other.accountReceivableId == accountReceivableId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountReceivableId,paymentMethodId,receiptNumber,amount,paymentDate,reference,notes,createdAt);

@override
String toString() {
  return 'ReceivablePayment(id: $id, accountReceivableId: $accountReceivableId, paymentMethodId: $paymentMethodId, receiptNumber: $receiptNumber, amount: $amount, paymentDate: $paymentDate, reference: $reference, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReceivablePaymentCopyWith<$Res>  {
  factory $ReceivablePaymentCopyWith(ReceivablePayment value, $Res Function(ReceivablePayment) _then) = _$ReceivablePaymentCopyWithImpl;
@useResult
$Res call({
 String id, String accountReceivableId, String paymentMethodId, String? receiptNumber, String amount, String paymentDate, String? reference, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$ReceivablePaymentCopyWithImpl<$Res>
    implements $ReceivablePaymentCopyWith<$Res> {
  _$ReceivablePaymentCopyWithImpl(this._self, this._then);

  final ReceivablePayment _self;
  final $Res Function(ReceivablePayment) _then;

/// Create a copy of ReceivablePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountReceivableId = null,Object? paymentMethodId = null,Object? receiptNumber = freezed,Object? amount = null,Object? paymentDate = null,Object? reference = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountReceivableId: null == accountReceivableId ? _self.accountReceivableId : accountReceivableId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceivablePayment].
extension ReceivablePaymentPatterns on ReceivablePayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceivablePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceivablePayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceivablePayment value)  $default,){
final _that = this;
switch (_that) {
case _ReceivablePayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceivablePayment value)?  $default,){
final _that = this;
switch (_that) {
case _ReceivablePayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountReceivableId,  String paymentMethodId,  String? receiptNumber,  String amount,  String paymentDate,  String? reference,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceivablePayment() when $default != null:
return $default(_that.id,_that.accountReceivableId,_that.paymentMethodId,_that.receiptNumber,_that.amount,_that.paymentDate,_that.reference,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountReceivableId,  String paymentMethodId,  String? receiptNumber,  String amount,  String paymentDate,  String? reference,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReceivablePayment():
return $default(_that.id,_that.accountReceivableId,_that.paymentMethodId,_that.receiptNumber,_that.amount,_that.paymentDate,_that.reference,_that.notes,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountReceivableId,  String paymentMethodId,  String? receiptNumber,  String amount,  String paymentDate,  String? reference,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReceivablePayment() when $default != null:
return $default(_that.id,_that.accountReceivableId,_that.paymentMethodId,_that.receiptNumber,_that.amount,_that.paymentDate,_that.reference,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceivablePayment extends ReceivablePayment {
  const _ReceivablePayment({required this.id, required this.accountReceivableId, required this.paymentMethodId, this.receiptNumber, required this.amount, required this.paymentDate, this.reference, this.notes, required this.createdAt}): super._();
  factory _ReceivablePayment.fromJson(Map<String, dynamic> json) => _$ReceivablePaymentFromJson(json);

@override final  String id;
@override final  String accountReceivableId;
@override final  String paymentMethodId;
@override final  String? receiptNumber;
@override final  String amount;
@override final  String paymentDate;
@override final  String? reference;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of ReceivablePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceivablePaymentCopyWith<_ReceivablePayment> get copyWith => __$ReceivablePaymentCopyWithImpl<_ReceivablePayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceivablePaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceivablePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.accountReceivableId, accountReceivableId) || other.accountReceivableId == accountReceivableId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountReceivableId,paymentMethodId,receiptNumber,amount,paymentDate,reference,notes,createdAt);

@override
String toString() {
  return 'ReceivablePayment(id: $id, accountReceivableId: $accountReceivableId, paymentMethodId: $paymentMethodId, receiptNumber: $receiptNumber, amount: $amount, paymentDate: $paymentDate, reference: $reference, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReceivablePaymentCopyWith<$Res> implements $ReceivablePaymentCopyWith<$Res> {
  factory _$ReceivablePaymentCopyWith(_ReceivablePayment value, $Res Function(_ReceivablePayment) _then) = __$ReceivablePaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountReceivableId, String paymentMethodId, String? receiptNumber, String amount, String paymentDate, String? reference, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$ReceivablePaymentCopyWithImpl<$Res>
    implements _$ReceivablePaymentCopyWith<$Res> {
  __$ReceivablePaymentCopyWithImpl(this._self, this._then);

  final _ReceivablePayment _self;
  final $Res Function(_ReceivablePayment) _then;

/// Create a copy of ReceivablePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountReceivableId = null,Object? paymentMethodId = null,Object? receiptNumber = freezed,Object? amount = null,Object? paymentDate = null,Object? reference = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_ReceivablePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountReceivableId: null == accountReceivableId ? _self.accountReceivableId : accountReceivableId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
