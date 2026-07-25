// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Customer {

 String get id; String get customerType; String? get firstName; String? get lastName; String? get companyName; String? get taxId; String? get taxReg; String? get email; String? get phone; String? get address; String get creditLimit; int get creditDays; bool get isActive; DateTime get createdAt;
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerCopyWith<Customer> get copyWith => _$CustomerCopyWithImpl<Customer>(this as Customer, _$identity);

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.customerType, customerType) || other.customerType == customerType)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.taxReg, taxReg) || other.taxReg == taxReg)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerType,firstName,lastName,companyName,taxId,taxReg,email,phone,address,creditLimit,creditDays,isActive,createdAt);

@override
String toString() {
  return 'Customer(id: $id, customerType: $customerType, firstName: $firstName, lastName: $lastName, companyName: $companyName, taxId: $taxId, taxReg: $taxReg, email: $email, phone: $phone, address: $address, creditLimit: $creditLimit, creditDays: $creditDays, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CustomerCopyWith<$Res>  {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) _then) = _$CustomerCopyWithImpl;
@useResult
$Res call({
 String id, String customerType, String? firstName, String? lastName, String? companyName, String? taxId, String? taxReg, String? email, String? phone, String? address, String creditLimit, int creditDays, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$CustomerCopyWithImpl<$Res>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._self, this._then);

  final Customer _self;
  final $Res Function(Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerType = null,Object? firstName = freezed,Object? lastName = freezed,Object? companyName = freezed,Object? taxId = freezed,Object? taxReg = freezed,Object? email = freezed,Object? phone = freezed,Object? address = freezed,Object? creditLimit = null,Object? creditDays = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerType: null == customerType ? _self.customerType : customerType // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxReg: freezed == taxReg ? _self.taxReg : taxReg // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Customer].
extension CustomerPatterns on Customer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Customer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Customer value)  $default,){
final _that = this;
switch (_that) {
case _Customer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Customer value)?  $default,){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerType,  String? firstName,  String? lastName,  String? companyName,  String? taxId,  String? taxReg,  String? email,  String? phone,  String? address,  String creditLimit,  int creditDays,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.customerType,_that.firstName,_that.lastName,_that.companyName,_that.taxId,_that.taxReg,_that.email,_that.phone,_that.address,_that.creditLimit,_that.creditDays,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerType,  String? firstName,  String? lastName,  String? companyName,  String? taxId,  String? taxReg,  String? email,  String? phone,  String? address,  String creditLimit,  int creditDays,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Customer():
return $default(_that.id,_that.customerType,_that.firstName,_that.lastName,_that.companyName,_that.taxId,_that.taxReg,_that.email,_that.phone,_that.address,_that.creditLimit,_that.creditDays,_that.isActive,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerType,  String? firstName,  String? lastName,  String? companyName,  String? taxId,  String? taxReg,  String? email,  String? phone,  String? address,  String creditLimit,  int creditDays,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.customerType,_that.firstName,_that.lastName,_that.companyName,_that.taxId,_that.taxReg,_that.email,_that.phone,_that.address,_that.creditLimit,_that.creditDays,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Customer extends Customer {
  const _Customer({required this.id, required this.customerType, this.firstName, this.lastName, this.companyName, this.taxId, this.taxReg, this.email, this.phone, this.address, required this.creditLimit, required this.creditDays, required this.isActive, required this.createdAt}): super._();
  factory _Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

@override final  String id;
@override final  String customerType;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? companyName;
@override final  String? taxId;
@override final  String? taxReg;
@override final  String? email;
@override final  String? phone;
@override final  String? address;
@override final  String creditLimit;
@override final  int creditDays;
@override final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerCopyWith<_Customer> get copyWith => __$CustomerCopyWithImpl<_Customer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.customerType, customerType) || other.customerType == customerType)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.taxReg, taxReg) || other.taxReg == taxReg)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerType,firstName,lastName,companyName,taxId,taxReg,email,phone,address,creditLimit,creditDays,isActive,createdAt);

@override
String toString() {
  return 'Customer(id: $id, customerType: $customerType, firstName: $firstName, lastName: $lastName, companyName: $companyName, taxId: $taxId, taxReg: $taxReg, email: $email, phone: $phone, address: $address, creditLimit: $creditLimit, creditDays: $creditDays, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CustomerCopyWith<$Res> implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) _then) = __$CustomerCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerType, String? firstName, String? lastName, String? companyName, String? taxId, String? taxReg, String? email, String? phone, String? address, String creditLimit, int creditDays, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$CustomerCopyWithImpl<$Res>
    implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(this._self, this._then);

  final _Customer _self;
  final $Res Function(_Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerType = null,Object? firstName = freezed,Object? lastName = freezed,Object? companyName = freezed,Object? taxId = freezed,Object? taxReg = freezed,Object? email = freezed,Object? phone = freezed,Object? address = freezed,Object? creditLimit = null,Object? creditDays = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerType: null == customerType ? _self.customerType : customerType // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxReg: freezed == taxReg ? _self.taxReg : taxReg // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
