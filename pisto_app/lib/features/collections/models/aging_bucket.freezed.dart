// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aging_bucket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AgingBucket {

 String get range; int get count; String get total;
/// Create a copy of AgingBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgingBucketCopyWith<AgingBucket> get copyWith => _$AgingBucketCopyWithImpl<AgingBucket>(this as AgingBucket, _$identity);

  /// Serializes this AgingBucket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgingBucket&&(identical(other.range, range) || other.range == range)&&(identical(other.count, count) || other.count == count)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,range,count,total);

@override
String toString() {
  return 'AgingBucket(range: $range, count: $count, total: $total)';
}


}

/// @nodoc
abstract mixin class $AgingBucketCopyWith<$Res>  {
  factory $AgingBucketCopyWith(AgingBucket value, $Res Function(AgingBucket) _then) = _$AgingBucketCopyWithImpl;
@useResult
$Res call({
 String range, int count, String total
});




}
/// @nodoc
class _$AgingBucketCopyWithImpl<$Res>
    implements $AgingBucketCopyWith<$Res> {
  _$AgingBucketCopyWithImpl(this._self, this._then);

  final AgingBucket _self;
  final $Res Function(AgingBucket) _then;

/// Create a copy of AgingBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? count = null,Object? total = null,}) {
  return _then(_self.copyWith(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AgingBucket].
extension AgingBucketPatterns on AgingBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgingBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgingBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgingBucket value)  $default,){
final _that = this;
switch (_that) {
case _AgingBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgingBucket value)?  $default,){
final _that = this;
switch (_that) {
case _AgingBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String range,  int count,  String total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgingBucket() when $default != null:
return $default(_that.range,_that.count,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String range,  int count,  String total)  $default,) {final _that = this;
switch (_that) {
case _AgingBucket():
return $default(_that.range,_that.count,_that.total);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String range,  int count,  String total)?  $default,) {final _that = this;
switch (_that) {
case _AgingBucket() when $default != null:
return $default(_that.range,_that.count,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgingBucket extends AgingBucket {
  const _AgingBucket({required this.range, required this.count, required this.total}): super._();
  factory _AgingBucket.fromJson(Map<String, dynamic> json) => _$AgingBucketFromJson(json);

@override final  String range;
@override final  int count;
@override final  String total;

/// Create a copy of AgingBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgingBucketCopyWith<_AgingBucket> get copyWith => __$AgingBucketCopyWithImpl<_AgingBucket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgingBucketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgingBucket&&(identical(other.range, range) || other.range == range)&&(identical(other.count, count) || other.count == count)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,range,count,total);

@override
String toString() {
  return 'AgingBucket(range: $range, count: $count, total: $total)';
}


}

/// @nodoc
abstract mixin class _$AgingBucketCopyWith<$Res> implements $AgingBucketCopyWith<$Res> {
  factory _$AgingBucketCopyWith(_AgingBucket value, $Res Function(_AgingBucket) _then) = __$AgingBucketCopyWithImpl;
@override @useResult
$Res call({
 String range, int count, String total
});




}
/// @nodoc
class __$AgingBucketCopyWithImpl<$Res>
    implements _$AgingBucketCopyWith<$Res> {
  __$AgingBucketCopyWithImpl(this._self, this._then);

  final _AgingBucket _self;
  final $Res Function(_AgingBucket) _then;

/// Create a copy of AgingBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = null,Object? count = null,Object? total = null,}) {
  return _then(_AgingBucket(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
