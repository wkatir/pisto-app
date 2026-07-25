// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreditNote {

 String get id; String get saleId; String get customerId; String get noteNumber; String get reason; String get total; String get status; DateTime get createdAt;
/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteCopyWith<CreditNote> get copyWith => _$CreditNoteCopyWithImpl<CreditNote>(this as CreditNote, _$identity);

  /// Serializes this CreditNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.noteNumber, noteNumber) || other.noteNumber == noteNumber)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,customerId,noteNumber,reason,total,status,createdAt);

@override
String toString() {
  return 'CreditNote(id: $id, saleId: $saleId, customerId: $customerId, noteNumber: $noteNumber, reason: $reason, total: $total, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CreditNoteCopyWith<$Res>  {
  factory $CreditNoteCopyWith(CreditNote value, $Res Function(CreditNote) _then) = _$CreditNoteCopyWithImpl;
@useResult
$Res call({
 String id, String saleId, String customerId, String noteNumber, String reason, String total, String status, DateTime createdAt
});




}
/// @nodoc
class _$CreditNoteCopyWithImpl<$Res>
    implements $CreditNoteCopyWith<$Res> {
  _$CreditNoteCopyWithImpl(this._self, this._then);

  final CreditNote _self;
  final $Res Function(CreditNote) _then;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? customerId = null,Object? noteNumber = null,Object? reason = null,Object? total = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,noteNumber: null == noteNumber ? _self.noteNumber : noteNumber // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNote].
extension CreditNotePatterns on CreditNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNote value)  $default,){
final _that = this;
switch (_that) {
case _CreditNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNote value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String saleId,  String customerId,  String noteNumber,  String reason,  String total,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.saleId,_that.customerId,_that.noteNumber,_that.reason,_that.total,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String saleId,  String customerId,  String noteNumber,  String reason,  String total,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CreditNote():
return $default(_that.id,_that.saleId,_that.customerId,_that.noteNumber,_that.reason,_that.total,_that.status,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String saleId,  String customerId,  String noteNumber,  String reason,  String total,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.saleId,_that.customerId,_that.noteNumber,_that.reason,_that.total,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNote extends CreditNote {
  const _CreditNote({required this.id, required this.saleId, required this.customerId, required this.noteNumber, required this.reason, required this.total, required this.status, required this.createdAt}): super._();
  factory _CreditNote.fromJson(Map<String, dynamic> json) => _$CreditNoteFromJson(json);

@override final  String id;
@override final  String saleId;
@override final  String customerId;
@override final  String noteNumber;
@override final  String reason;
@override final  String total;
@override final  String status;
@override final  DateTime createdAt;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteCopyWith<_CreditNote> get copyWith => __$CreditNoteCopyWithImpl<_CreditNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.noteNumber, noteNumber) || other.noteNumber == noteNumber)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,customerId,noteNumber,reason,total,status,createdAt);

@override
String toString() {
  return 'CreditNote(id: $id, saleId: $saleId, customerId: $customerId, noteNumber: $noteNumber, reason: $reason, total: $total, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteCopyWith<$Res> implements $CreditNoteCopyWith<$Res> {
  factory _$CreditNoteCopyWith(_CreditNote value, $Res Function(_CreditNote) _then) = __$CreditNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String saleId, String customerId, String noteNumber, String reason, String total, String status, DateTime createdAt
});




}
/// @nodoc
class __$CreditNoteCopyWithImpl<$Res>
    implements _$CreditNoteCopyWith<$Res> {
  __$CreditNoteCopyWithImpl(this._self, this._then);

  final _CreditNote _self;
  final $Res Function(_CreditNote) _then;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? customerId = null,Object? noteNumber = null,Object? reason = null,Object? total = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_CreditNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,noteNumber: null == noteNumber ? _self.noteNumber : noteNumber // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
