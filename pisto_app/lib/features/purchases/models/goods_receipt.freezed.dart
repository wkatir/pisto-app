// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goods_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoodsReceipt {

 String get id; String get purchaseOrderId; String get receiptNumber; String get receiptDate; String? get notes; DateTime get createdAt;
/// Create a copy of GoodsReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoodsReceiptCopyWith<GoodsReceipt> get copyWith => _$GoodsReceiptCopyWithImpl<GoodsReceipt>(this as GoodsReceipt, _$identity);

  /// Serializes this GoodsReceipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,purchaseOrderId,receiptNumber,receiptDate,notes,createdAt);

@override
String toString() {
  return 'GoodsReceipt(id: $id, purchaseOrderId: $purchaseOrderId, receiptNumber: $receiptNumber, receiptDate: $receiptDate, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GoodsReceiptCopyWith<$Res>  {
  factory $GoodsReceiptCopyWith(GoodsReceipt value, $Res Function(GoodsReceipt) _then) = _$GoodsReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String purchaseOrderId, String receiptNumber, String receiptDate, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$GoodsReceiptCopyWithImpl<$Res>
    implements $GoodsReceiptCopyWith<$Res> {
  _$GoodsReceiptCopyWithImpl(this._self, this._then);

  final GoodsReceipt _self;
  final $Res Function(GoodsReceipt) _then;

/// Create a copy of GoodsReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? purchaseOrderId = null,Object? receiptNumber = null,Object? receiptDate = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,receiptDate: null == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GoodsReceipt].
extension GoodsReceiptPatterns on GoodsReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoodsReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoodsReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoodsReceipt value)  $default,){
final _that = this;
switch (_that) {
case _GoodsReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoodsReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _GoodsReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String purchaseOrderId,  String receiptNumber,  String receiptDate,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsReceipt() when $default != null:
return $default(_that.id,_that.purchaseOrderId,_that.receiptNumber,_that.receiptDate,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String purchaseOrderId,  String receiptNumber,  String receiptDate,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GoodsReceipt():
return $default(_that.id,_that.purchaseOrderId,_that.receiptNumber,_that.receiptDate,_that.notes,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String purchaseOrderId,  String receiptNumber,  String receiptDate,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GoodsReceipt() when $default != null:
return $default(_that.id,_that.purchaseOrderId,_that.receiptNumber,_that.receiptDate,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsReceipt implements GoodsReceipt {
  const _GoodsReceipt({required this.id, required this.purchaseOrderId, required this.receiptNumber, required this.receiptDate, this.notes, required this.createdAt});
  factory _GoodsReceipt.fromJson(Map<String, dynamic> json) => _$GoodsReceiptFromJson(json);

@override final  String id;
@override final  String purchaseOrderId;
@override final  String receiptNumber;
@override final  String receiptDate;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of GoodsReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoodsReceiptCopyWith<_GoodsReceipt> get copyWith => __$GoodsReceiptCopyWithImpl<_GoodsReceipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoodsReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,purchaseOrderId,receiptNumber,receiptDate,notes,createdAt);

@override
String toString() {
  return 'GoodsReceipt(id: $id, purchaseOrderId: $purchaseOrderId, receiptNumber: $receiptNumber, receiptDate: $receiptDate, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GoodsReceiptCopyWith<$Res> implements $GoodsReceiptCopyWith<$Res> {
  factory _$GoodsReceiptCopyWith(_GoodsReceipt value, $Res Function(_GoodsReceipt) _then) = __$GoodsReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String purchaseOrderId, String receiptNumber, String receiptDate, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$GoodsReceiptCopyWithImpl<$Res>
    implements _$GoodsReceiptCopyWith<$Res> {
  __$GoodsReceiptCopyWithImpl(this._self, this._then);

  final _GoodsReceipt _self;
  final $Res Function(_GoodsReceipt) _then;

/// Create a copy of GoodsReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? purchaseOrderId = null,Object? receiptNumber = null,Object? receiptDate = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_GoodsReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,receiptDate: null == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
