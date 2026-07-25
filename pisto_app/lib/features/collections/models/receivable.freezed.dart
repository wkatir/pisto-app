// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receivable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Receivable {

 String get id; String get customerId; String get saleId; String get originalAmount; String get balance; String get dueDate; String get status; DateTime get createdAt;
/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivableCopyWith<Receivable> get copyWith => _$ReceivableCopyWithImpl<Receivable>(this as Receivable, _$identity);

  /// Serializes this Receivable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receivable&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,saleId,originalAmount,balance,dueDate,status,createdAt);

@override
String toString() {
  return 'Receivable(id: $id, customerId: $customerId, saleId: $saleId, originalAmount: $originalAmount, balance: $balance, dueDate: $dueDate, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReceivableCopyWith<$Res>  {
  factory $ReceivableCopyWith(Receivable value, $Res Function(Receivable) _then) = _$ReceivableCopyWithImpl;
@useResult
$Res call({
 String id, String customerId, String saleId, String originalAmount, String balance, String dueDate, String status, DateTime createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? saleId = null,Object? originalAmount = null,Object? balance = null,Object? dueDate = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,originalAmount: null == originalAmount ? _self.originalAmount : originalAmount // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerId,  String saleId,  String originalAmount,  String balance,  String dueDate,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that.id,_that.customerId,_that.saleId,_that.originalAmount,_that.balance,_that.dueDate,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerId,  String saleId,  String originalAmount,  String balance,  String dueDate,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Receivable():
return $default(_that.id,_that.customerId,_that.saleId,_that.originalAmount,_that.balance,_that.dueDate,_that.status,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerId,  String saleId,  String originalAmount,  String balance,  String dueDate,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that.id,_that.customerId,_that.saleId,_that.originalAmount,_that.balance,_that.dueDate,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receivable extends Receivable {
  const _Receivable({required this.id, required this.customerId, required this.saleId, required this.originalAmount, required this.balance, required this.dueDate, required this.status, required this.createdAt}): super._();
  factory _Receivable.fromJson(Map<String, dynamic> json) => _$ReceivableFromJson(json);

@override final  String id;
@override final  String customerId;
@override final  String saleId;
@override final  String originalAmount;
@override final  String balance;
@override final  String dueDate;
@override final  String status;
@override final  DateTime createdAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receivable&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,saleId,originalAmount,balance,dueDate,status,createdAt);

@override
String toString() {
  return 'Receivable(id: $id, customerId: $customerId, saleId: $saleId, originalAmount: $originalAmount, balance: $balance, dueDate: $dueDate, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReceivableCopyWith<$Res> implements $ReceivableCopyWith<$Res> {
  factory _$ReceivableCopyWith(_Receivable value, $Res Function(_Receivable) _then) = __$ReceivableCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerId, String saleId, String originalAmount, String balance, String dueDate, String status, DateTime createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? saleId = null,Object? originalAmount = null,Object? balance = null,Object? dueDate = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_Receivable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
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
mixin _$ReceivableListItem {

 Receivable get receivable; String? get customerName; String? get customerPhone; String? get saleNumber;
/// Create a copy of ReceivableListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivableListItemCopyWith<ReceivableListItem> get copyWith => _$ReceivableListItemCopyWithImpl<ReceivableListItem>(this as ReceivableListItem, _$identity);

  /// Serializes this ReceivableListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceivableListItem&&(identical(other.receivable, receivable) || other.receivable == receivable)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,receivable,customerName,customerPhone,saleNumber);

@override
String toString() {
  return 'ReceivableListItem(receivable: $receivable, customerName: $customerName, customerPhone: $customerPhone, saleNumber: $saleNumber)';
}


}

/// @nodoc
abstract mixin class $ReceivableListItemCopyWith<$Res>  {
  factory $ReceivableListItemCopyWith(ReceivableListItem value, $Res Function(ReceivableListItem) _then) = _$ReceivableListItemCopyWithImpl;
@useResult
$Res call({
 Receivable receivable, String? customerName, String? customerPhone, String? saleNumber
});


$ReceivableCopyWith<$Res> get receivable;

}
/// @nodoc
class _$ReceivableListItemCopyWithImpl<$Res>
    implements $ReceivableListItemCopyWith<$Res> {
  _$ReceivableListItemCopyWithImpl(this._self, this._then);

  final ReceivableListItem _self;
  final $Res Function(ReceivableListItem) _then;

/// Create a copy of ReceivableListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? receivable = null,Object? customerName = freezed,Object? customerPhone = freezed,Object? saleNumber = freezed,}) {
  return _then(_self.copyWith(
receivable: null == receivable ? _self.receivable : receivable // ignore: cast_nullable_to_non_nullable
as Receivable,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,saleNumber: freezed == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ReceivableListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReceivableCopyWith<$Res> get receivable {
  
  return $ReceivableCopyWith<$Res>(_self.receivable, (value) {
    return _then(_self.copyWith(receivable: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReceivableListItem].
extension ReceivableListItemPatterns on ReceivableListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceivableListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceivableListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceivableListItem value)  $default,){
final _that = this;
switch (_that) {
case _ReceivableListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceivableListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReceivableListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Receivable receivable,  String? customerName,  String? customerPhone,  String? saleNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceivableListItem() when $default != null:
return $default(_that.receivable,_that.customerName,_that.customerPhone,_that.saleNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Receivable receivable,  String? customerName,  String? customerPhone,  String? saleNumber)  $default,) {final _that = this;
switch (_that) {
case _ReceivableListItem():
return $default(_that.receivable,_that.customerName,_that.customerPhone,_that.saleNumber);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Receivable receivable,  String? customerName,  String? customerPhone,  String? saleNumber)?  $default,) {final _that = this;
switch (_that) {
case _ReceivableListItem() when $default != null:
return $default(_that.receivable,_that.customerName,_that.customerPhone,_that.saleNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceivableListItem implements ReceivableListItem {
  const _ReceivableListItem({required this.receivable, this.customerName, this.customerPhone, this.saleNumber});
  factory _ReceivableListItem.fromJson(Map<String, dynamic> json) => _$ReceivableListItemFromJson(json);

@override final  Receivable receivable;
@override final  String? customerName;
@override final  String? customerPhone;
@override final  String? saleNumber;

/// Create a copy of ReceivableListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceivableListItemCopyWith<_ReceivableListItem> get copyWith => __$ReceivableListItemCopyWithImpl<_ReceivableListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceivableListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceivableListItem&&(identical(other.receivable, receivable) || other.receivable == receivable)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,receivable,customerName,customerPhone,saleNumber);

@override
String toString() {
  return 'ReceivableListItem(receivable: $receivable, customerName: $customerName, customerPhone: $customerPhone, saleNumber: $saleNumber)';
}


}

/// @nodoc
abstract mixin class _$ReceivableListItemCopyWith<$Res> implements $ReceivableListItemCopyWith<$Res> {
  factory _$ReceivableListItemCopyWith(_ReceivableListItem value, $Res Function(_ReceivableListItem) _then) = __$ReceivableListItemCopyWithImpl;
@override @useResult
$Res call({
 Receivable receivable, String? customerName, String? customerPhone, String? saleNumber
});


@override $ReceivableCopyWith<$Res> get receivable;

}
/// @nodoc
class __$ReceivableListItemCopyWithImpl<$Res>
    implements _$ReceivableListItemCopyWith<$Res> {
  __$ReceivableListItemCopyWithImpl(this._self, this._then);

  final _ReceivableListItem _self;
  final $Res Function(_ReceivableListItem) _then;

/// Create a copy of ReceivableListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? receivable = null,Object? customerName = freezed,Object? customerPhone = freezed,Object? saleNumber = freezed,}) {
  return _then(_ReceivableListItem(
receivable: null == receivable ? _self.receivable : receivable // ignore: cast_nullable_to_non_nullable
as Receivable,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,saleNumber: freezed == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ReceivableListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReceivableCopyWith<$Res> get receivable {
  
  return $ReceivableCopyWith<$Res>(_self.receivable, (value) {
    return _then(_self.copyWith(receivable: value));
  });
}
}

// dart format on
