// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String? get sku; String? get barcode; String get name; String get costPrice; String get salePrice; String get minStock; bool get isService; bool get isTaxable; bool get isActive; String? get imageUrl; String? get categoryName; String? get unitCode; String get totalStock;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.isService, isService) || other.isService == isService)&&(identical(other.isTaxable, isTaxable) || other.isTaxable == isTaxable)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sku,barcode,name,costPrice,salePrice,minStock,isService,isTaxable,isActive,imageUrl,categoryName,unitCode,totalStock);

@override
String toString() {
  return 'Product(id: $id, sku: $sku, barcode: $barcode, name: $name, costPrice: $costPrice, salePrice: $salePrice, minStock: $minStock, isService: $isService, isTaxable: $isTaxable, isActive: $isActive, imageUrl: $imageUrl, categoryName: $categoryName, unitCode: $unitCode, totalStock: $totalStock)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String? sku, String? barcode, String name, String costPrice, String salePrice, String minStock, bool isService, bool isTaxable, bool isActive, String? imageUrl, String? categoryName, String? unitCode, String totalStock
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sku = freezed,Object? barcode = freezed,Object? name = null,Object? costPrice = null,Object? salePrice = null,Object? minStock = null,Object? isService = null,Object? isTaxable = null,Object? isActive = null,Object? imageUrl = freezed,Object? categoryName = freezed,Object? unitCode = freezed,Object? totalStock = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,costPrice: null == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as String,isService: null == isService ? _self.isService : isService // ignore: cast_nullable_to_non_nullable
as bool,isTaxable: null == isTaxable ? _self.isTaxable : isTaxable // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sku,  String? barcode,  String name,  String costPrice,  String salePrice,  String minStock,  bool isService,  bool isTaxable,  bool isActive,  String? imageUrl,  String? categoryName,  String? unitCode,  String totalStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.sku,_that.barcode,_that.name,_that.costPrice,_that.salePrice,_that.minStock,_that.isService,_that.isTaxable,_that.isActive,_that.imageUrl,_that.categoryName,_that.unitCode,_that.totalStock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sku,  String? barcode,  String name,  String costPrice,  String salePrice,  String minStock,  bool isService,  bool isTaxable,  bool isActive,  String? imageUrl,  String? categoryName,  String? unitCode,  String totalStock)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.sku,_that.barcode,_that.name,_that.costPrice,_that.salePrice,_that.minStock,_that.isService,_that.isTaxable,_that.isActive,_that.imageUrl,_that.categoryName,_that.unitCode,_that.totalStock);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sku,  String? barcode,  String name,  String costPrice,  String salePrice,  String minStock,  bool isService,  bool isTaxable,  bool isActive,  String? imageUrl,  String? categoryName,  String? unitCode,  String totalStock)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.sku,_that.barcode,_that.name,_that.costPrice,_that.salePrice,_that.minStock,_that.isService,_that.isTaxable,_that.isActive,_that.imageUrl,_that.categoryName,_that.unitCode,_that.totalStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product extends Product {
  const _Product({required this.id, this.sku, this.barcode, required this.name, required this.costPrice, required this.salePrice, required this.minStock, required this.isService, required this.isTaxable, required this.isActive, this.imageUrl, this.categoryName, this.unitCode, required this.totalStock}): super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String? sku;
@override final  String? barcode;
@override final  String name;
@override final  String costPrice;
@override final  String salePrice;
@override final  String minStock;
@override final  bool isService;
@override final  bool isTaxable;
@override final  bool isActive;
@override final  String? imageUrl;
@override final  String? categoryName;
@override final  String? unitCode;
@override final  String totalStock;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.isService, isService) || other.isService == isService)&&(identical(other.isTaxable, isTaxable) || other.isTaxable == isTaxable)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sku,barcode,name,costPrice,salePrice,minStock,isService,isTaxable,isActive,imageUrl,categoryName,unitCode,totalStock);

@override
String toString() {
  return 'Product(id: $id, sku: $sku, barcode: $barcode, name: $name, costPrice: $costPrice, salePrice: $salePrice, minStock: $minStock, isService: $isService, isTaxable: $isTaxable, isActive: $isActive, imageUrl: $imageUrl, categoryName: $categoryName, unitCode: $unitCode, totalStock: $totalStock)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sku, String? barcode, String name, String costPrice, String salePrice, String minStock, bool isService, bool isTaxable, bool isActive, String? imageUrl, String? categoryName, String? unitCode, String totalStock
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sku = freezed,Object? barcode = freezed,Object? name = null,Object? costPrice = null,Object? salePrice = null,Object? minStock = null,Object? isService = null,Object? isTaxable = null,Object? isActive = null,Object? imageUrl = freezed,Object? categoryName = freezed,Object? unitCode = freezed,Object? totalStock = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,costPrice: null == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as String,isService: null == isService ? _self.isService : isService // ignore: cast_nullable_to_non_nullable
as bool,isTaxable: null == isTaxable ? _self.isTaxable : isTaxable // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LowStockAlert {

 String get productId; String get productName; String? get sku; String get minStock; String get totalStock;
/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LowStockAlertCopyWith<LowStockAlert> get copyWith => _$LowStockAlertCopyWithImpl<LowStockAlert>(this as LowStockAlert, _$identity);

  /// Serializes this LowStockAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LowStockAlert&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,sku,minStock,totalStock);

@override
String toString() {
  return 'LowStockAlert(productId: $productId, productName: $productName, sku: $sku, minStock: $minStock, totalStock: $totalStock)';
}


}

/// @nodoc
abstract mixin class $LowStockAlertCopyWith<$Res>  {
  factory $LowStockAlertCopyWith(LowStockAlert value, $Res Function(LowStockAlert) _then) = _$LowStockAlertCopyWithImpl;
@useResult
$Res call({
 String productId, String productName, String? sku, String minStock, String totalStock
});




}
/// @nodoc
class _$LowStockAlertCopyWithImpl<$Res>
    implements $LowStockAlertCopyWith<$Res> {
  _$LowStockAlertCopyWithImpl(this._self, this._then);

  final LowStockAlert _self;
  final $Res Function(LowStockAlert) _then;

/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? sku = freezed,Object? minStock = null,Object? totalStock = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as String,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LowStockAlert].
extension LowStockAlertPatterns on LowStockAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LowStockAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LowStockAlert value)  $default,){
final _that = this;
switch (_that) {
case _LowStockAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LowStockAlert value)?  $default,){
final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String productName,  String? sku,  String minStock,  String totalStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
return $default(_that.productId,_that.productName,_that.sku,_that.minStock,_that.totalStock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String productName,  String? sku,  String minStock,  String totalStock)  $default,) {final _that = this;
switch (_that) {
case _LowStockAlert():
return $default(_that.productId,_that.productName,_that.sku,_that.minStock,_that.totalStock);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String productName,  String? sku,  String minStock,  String totalStock)?  $default,) {final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
return $default(_that.productId,_that.productName,_that.sku,_that.minStock,_that.totalStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LowStockAlert extends LowStockAlert {
  const _LowStockAlert({required this.productId, required this.productName, this.sku, required this.minStock, required this.totalStock}): super._();
  factory _LowStockAlert.fromJson(Map<String, dynamic> json) => _$LowStockAlertFromJson(json);

@override final  String productId;
@override final  String productName;
@override final  String? sku;
@override final  String minStock;
@override final  String totalStock;

/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LowStockAlertCopyWith<_LowStockAlert> get copyWith => __$LowStockAlertCopyWithImpl<_LowStockAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LowStockAlertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LowStockAlert&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.totalStock, totalStock) || other.totalStock == totalStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,sku,minStock,totalStock);

@override
String toString() {
  return 'LowStockAlert(productId: $productId, productName: $productName, sku: $sku, minStock: $minStock, totalStock: $totalStock)';
}


}

/// @nodoc
abstract mixin class _$LowStockAlertCopyWith<$Res> implements $LowStockAlertCopyWith<$Res> {
  factory _$LowStockAlertCopyWith(_LowStockAlert value, $Res Function(_LowStockAlert) _then) = __$LowStockAlertCopyWithImpl;
@override @useResult
$Res call({
 String productId, String productName, String? sku, String minStock, String totalStock
});




}
/// @nodoc
class __$LowStockAlertCopyWithImpl<$Res>
    implements _$LowStockAlertCopyWith<$Res> {
  __$LowStockAlertCopyWithImpl(this._self, this._then);

  final _LowStockAlert _self;
  final $Res Function(_LowStockAlert) _then;

/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? sku = freezed,Object? minStock = null,Object? totalStock = null,}) {
  return _then(_LowStockAlert(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as String,totalStock: null == totalStock ? _self.totalStock : totalStock // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
