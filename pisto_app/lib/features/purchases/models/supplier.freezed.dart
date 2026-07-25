// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Supplier {

 String get id; String get companyName; String? get contactName; String? get taxId; String? get phone; String? get email; String? get address; int get paymentTerms; bool get isActive; DateTime get createdAt;
/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierCopyWith<Supplier> get copyWith => _$SupplierCopyWithImpl<Supplier>(this as Supplier, _$identity);

  /// Serializes this Supplier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Supplier&&(identical(other.id, id) || other.id == id)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyName,contactName,taxId,phone,email,address,paymentTerms,isActive,createdAt);

@override
String toString() {
  return 'Supplier(id: $id, companyName: $companyName, contactName: $contactName, taxId: $taxId, phone: $phone, email: $email, address: $address, paymentTerms: $paymentTerms, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SupplierCopyWith<$Res>  {
  factory $SupplierCopyWith(Supplier value, $Res Function(Supplier) _then) = _$SupplierCopyWithImpl;
@useResult
$Res call({
 String id, String companyName, String? contactName, String? taxId, String? phone, String? email, String? address, int paymentTerms, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$SupplierCopyWithImpl<$Res>
    implements $SupplierCopyWith<$Res> {
  _$SupplierCopyWithImpl(this._self, this._then);

  final Supplier _self;
  final $Res Function(Supplier) _then;

/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyName = null,Object? contactName = freezed,Object? taxId = freezed,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? paymentTerms = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Supplier].
extension SupplierPatterns on Supplier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Supplier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Supplier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Supplier value)  $default,){
final _that = this;
switch (_that) {
case _Supplier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Supplier value)?  $default,){
final _that = this;
switch (_that) {
case _Supplier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyName,  String? contactName,  String? taxId,  String? phone,  String? email,  String? address,  int paymentTerms,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Supplier() when $default != null:
return $default(_that.id,_that.companyName,_that.contactName,_that.taxId,_that.phone,_that.email,_that.address,_that.paymentTerms,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyName,  String? contactName,  String? taxId,  String? phone,  String? email,  String? address,  int paymentTerms,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Supplier():
return $default(_that.id,_that.companyName,_that.contactName,_that.taxId,_that.phone,_that.email,_that.address,_that.paymentTerms,_that.isActive,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyName,  String? contactName,  String? taxId,  String? phone,  String? email,  String? address,  int paymentTerms,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Supplier() when $default != null:
return $default(_that.id,_that.companyName,_that.contactName,_that.taxId,_that.phone,_that.email,_that.address,_that.paymentTerms,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Supplier extends Supplier {
  const _Supplier({required this.id, required this.companyName, this.contactName, this.taxId, this.phone, this.email, this.address, required this.paymentTerms, required this.isActive, required this.createdAt}): super._();
  factory _Supplier.fromJson(Map<String, dynamic> json) => _$SupplierFromJson(json);

@override final  String id;
@override final  String companyName;
@override final  String? contactName;
@override final  String? taxId;
@override final  String? phone;
@override final  String? email;
@override final  String? address;
@override final  int paymentTerms;
@override final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierCopyWith<_Supplier> get copyWith => __$SupplierCopyWithImpl<_Supplier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupplierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Supplier&&(identical(other.id, id) || other.id == id)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyName,contactName,taxId,phone,email,address,paymentTerms,isActive,createdAt);

@override
String toString() {
  return 'Supplier(id: $id, companyName: $companyName, contactName: $contactName, taxId: $taxId, phone: $phone, email: $email, address: $address, paymentTerms: $paymentTerms, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SupplierCopyWith<$Res> implements $SupplierCopyWith<$Res> {
  factory _$SupplierCopyWith(_Supplier value, $Res Function(_Supplier) _then) = __$SupplierCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyName, String? contactName, String? taxId, String? phone, String? email, String? address, int paymentTerms, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$SupplierCopyWithImpl<$Res>
    implements _$SupplierCopyWith<$Res> {
  __$SupplierCopyWithImpl(this._self, this._then);

  final _Supplier _self;
  final $Res Function(_Supplier) _then;

/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyName = null,Object? contactName = freezed,Object? taxId = freezed,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? paymentTerms = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_Supplier(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
