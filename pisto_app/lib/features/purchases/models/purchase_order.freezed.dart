// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PurchaseOrder {

 String get id; String get supplierId; String get warehouseId; String get orderNumber; String get orderDate; String? get expectedDate; String get status; String get subtotal; String get taxAmount; String get total; String? get notes; DateTime get createdAt;/// Solo presentes en el detalle (`GET /purchases/orders/:id`).
 List<PurchaseOrderItem>? get lines;
/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderCopyWith<PurchaseOrder> get copyWith => _$PurchaseOrderCopyWithImpl<PurchaseOrder>(this as PurchaseOrder, _$identity);

  /// Serializes this PurchaseOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDate, expectedDate) || other.expectedDate == expectedDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.total, total) || other.total == total)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.lines, lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,supplierId,warehouseId,orderNumber,orderDate,expectedDate,status,subtotal,taxAmount,total,notes,createdAt,const DeepCollectionEquality().hash(lines));

@override
String toString() {
  return 'PurchaseOrder(id: $id, supplierId: $supplierId, warehouseId: $warehouseId, orderNumber: $orderNumber, orderDate: $orderDate, expectedDate: $expectedDate, status: $status, subtotal: $subtotal, taxAmount: $taxAmount, total: $total, notes: $notes, createdAt: $createdAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderCopyWith<$Res>  {
  factory $PurchaseOrderCopyWith(PurchaseOrder value, $Res Function(PurchaseOrder) _then) = _$PurchaseOrderCopyWithImpl;
@useResult
$Res call({
 String id, String supplierId, String warehouseId, String orderNumber, String orderDate, String? expectedDate, String status, String subtotal, String taxAmount, String total, String? notes, DateTime createdAt, List<PurchaseOrderItem>? lines
});




}
/// @nodoc
class _$PurchaseOrderCopyWithImpl<$Res>
    implements $PurchaseOrderCopyWith<$Res> {
  _$PurchaseOrderCopyWithImpl(this._self, this._then);

  final PurchaseOrder _self;
  final $Res Function(PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? supplierId = null,Object? warehouseId = null,Object? orderNumber = null,Object? orderDate = null,Object? expectedDate = freezed,Object? status = null,Object? subtotal = null,Object? taxAmount = null,Object? total = null,Object? notes = freezed,Object? createdAt = null,Object? lines = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String,expectedDate: freezed == expectedDate ? _self.expectedDate : expectedDate // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: freezed == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrder].
extension PurchaseOrderPatterns on PurchaseOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrder value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrder value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String supplierId,  String warehouseId,  String orderNumber,  String orderDate,  String? expectedDate,  String status,  String subtotal,  String taxAmount,  String total,  String? notes,  DateTime createdAt,  List<PurchaseOrderItem>? lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.supplierId,_that.warehouseId,_that.orderNumber,_that.orderDate,_that.expectedDate,_that.status,_that.subtotal,_that.taxAmount,_that.total,_that.notes,_that.createdAt,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String supplierId,  String warehouseId,  String orderNumber,  String orderDate,  String? expectedDate,  String status,  String subtotal,  String taxAmount,  String total,  String? notes,  DateTime createdAt,  List<PurchaseOrderItem>? lines)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder():
return $default(_that.id,_that.supplierId,_that.warehouseId,_that.orderNumber,_that.orderDate,_that.expectedDate,_that.status,_that.subtotal,_that.taxAmount,_that.total,_that.notes,_that.createdAt,_that.lines);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String supplierId,  String warehouseId,  String orderNumber,  String orderDate,  String? expectedDate,  String status,  String subtotal,  String taxAmount,  String total,  String? notes,  DateTime createdAt,  List<PurchaseOrderItem>? lines)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.supplierId,_that.warehouseId,_that.orderNumber,_that.orderDate,_that.expectedDate,_that.status,_that.subtotal,_that.taxAmount,_that.total,_that.notes,_that.createdAt,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseOrder extends PurchaseOrder {
  const _PurchaseOrder({required this.id, required this.supplierId, required this.warehouseId, required this.orderNumber, required this.orderDate, this.expectedDate, required this.status, required this.subtotal, required this.taxAmount, required this.total, this.notes, required this.createdAt, final  List<PurchaseOrderItem>? lines}): _lines = lines,super._();
  factory _PurchaseOrder.fromJson(Map<String, dynamic> json) => _$PurchaseOrderFromJson(json);

@override final  String id;
@override final  String supplierId;
@override final  String warehouseId;
@override final  String orderNumber;
@override final  String orderDate;
@override final  String? expectedDate;
@override final  String status;
@override final  String subtotal;
@override final  String taxAmount;
@override final  String total;
@override final  String? notes;
@override final  DateTime createdAt;
/// Solo presentes en el detalle (`GET /purchases/orders/:id`).
 final  List<PurchaseOrderItem>? _lines;
/// Solo presentes en el detalle (`GET /purchases/orders/:id`).
@override List<PurchaseOrderItem>? get lines {
  final value = _lines;
  if (value == null) return null;
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderCopyWith<_PurchaseOrder> get copyWith => __$PurchaseOrderCopyWithImpl<_PurchaseOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.expectedDate, expectedDate) || other.expectedDate == expectedDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.total, total) || other.total == total)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,supplierId,warehouseId,orderNumber,orderDate,expectedDate,status,subtotal,taxAmount,total,notes,createdAt,const DeepCollectionEquality().hash(_lines));

@override
String toString() {
  return 'PurchaseOrder(id: $id, supplierId: $supplierId, warehouseId: $warehouseId, orderNumber: $orderNumber, orderDate: $orderDate, expectedDate: $expectedDate, status: $status, subtotal: $subtotal, taxAmount: $taxAmount, total: $total, notes: $notes, createdAt: $createdAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderCopyWith<$Res> implements $PurchaseOrderCopyWith<$Res> {
  factory _$PurchaseOrderCopyWith(_PurchaseOrder value, $Res Function(_PurchaseOrder) _then) = __$PurchaseOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String supplierId, String warehouseId, String orderNumber, String orderDate, String? expectedDate, String status, String subtotal, String taxAmount, String total, String? notes, DateTime createdAt, List<PurchaseOrderItem>? lines
});




}
/// @nodoc
class __$PurchaseOrderCopyWithImpl<$Res>
    implements _$PurchaseOrderCopyWith<$Res> {
  __$PurchaseOrderCopyWithImpl(this._self, this._then);

  final _PurchaseOrder _self;
  final $Res Function(_PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? supplierId = null,Object? warehouseId = null,Object? orderNumber = null,Object? orderDate = null,Object? expectedDate = freezed,Object? status = null,Object? subtotal = null,Object? taxAmount = null,Object? total = null,Object? notes = freezed,Object? createdAt = null,Object? lines = freezed,}) {
  return _then(_PurchaseOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String,expectedDate: freezed == expectedDate ? _self.expectedDate : expectedDate // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: freezed == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderItem>?,
  ));
}


}


/// @nodoc
mixin _$PurchaseOrderItem {

 String get id; String get purchaseOrderId; String get productId; String get quantityOrdered; String get quantityReceived; String get unitCost; String? get taxId; String get taxAmount; String get lineTotal;
/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderItemCopyWith<PurchaseOrderItem> get copyWith => _$PurchaseOrderItemCopyWithImpl<PurchaseOrderItem>(this as PurchaseOrderItem, _$identity);

  /// Serializes this PurchaseOrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantityOrdered, quantityOrdered) || other.quantityOrdered == quantityOrdered)&&(identical(other.quantityReceived, quantityReceived) || other.quantityReceived == quantityReceived)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,purchaseOrderId,productId,quantityOrdered,quantityReceived,unitCost,taxId,taxAmount,lineTotal);

@override
String toString() {
  return 'PurchaseOrderItem(id: $id, purchaseOrderId: $purchaseOrderId, productId: $productId, quantityOrdered: $quantityOrdered, quantityReceived: $quantityReceived, unitCost: $unitCost, taxId: $taxId, taxAmount: $taxAmount, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderItemCopyWith<$Res>  {
  factory $PurchaseOrderItemCopyWith(PurchaseOrderItem value, $Res Function(PurchaseOrderItem) _then) = _$PurchaseOrderItemCopyWithImpl;
@useResult
$Res call({
 String id, String purchaseOrderId, String productId, String quantityOrdered, String quantityReceived, String unitCost, String? taxId, String taxAmount, String lineTotal
});




}
/// @nodoc
class _$PurchaseOrderItemCopyWithImpl<$Res>
    implements $PurchaseOrderItemCopyWith<$Res> {
  _$PurchaseOrderItemCopyWithImpl(this._self, this._then);

  final PurchaseOrderItem _self;
  final $Res Function(PurchaseOrderItem) _then;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? purchaseOrderId = null,Object? productId = null,Object? quantityOrdered = null,Object? quantityReceived = null,Object? unitCost = null,Object? taxId = freezed,Object? taxAmount = null,Object? lineTotal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantityOrdered: null == quantityOrdered ? _self.quantityOrdered : quantityOrdered // ignore: cast_nullable_to_non_nullable
as String,quantityReceived: null == quantityReceived ? _self.quantityReceived : quantityReceived // ignore: cast_nullable_to_non_nullable
as String,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderItem].
extension PurchaseOrderItemPatterns on PurchaseOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String purchaseOrderId,  String productId,  String quantityOrdered,  String quantityReceived,  String unitCost,  String? taxId,  String taxAmount,  String lineTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
return $default(_that.id,_that.purchaseOrderId,_that.productId,_that.quantityOrdered,_that.quantityReceived,_that.unitCost,_that.taxId,_that.taxAmount,_that.lineTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String purchaseOrderId,  String productId,  String quantityOrdered,  String quantityReceived,  String unitCost,  String? taxId,  String taxAmount,  String lineTotal)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderItem():
return $default(_that.id,_that.purchaseOrderId,_that.productId,_that.quantityOrdered,_that.quantityReceived,_that.unitCost,_that.taxId,_that.taxAmount,_that.lineTotal);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String purchaseOrderId,  String productId,  String quantityOrdered,  String quantityReceived,  String unitCost,  String? taxId,  String taxAmount,  String lineTotal)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
return $default(_that.id,_that.purchaseOrderId,_that.productId,_that.quantityOrdered,_that.quantityReceived,_that.unitCost,_that.taxId,_that.taxAmount,_that.lineTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseOrderItem extends PurchaseOrderItem {
  const _PurchaseOrderItem({required this.id, required this.purchaseOrderId, required this.productId, required this.quantityOrdered, required this.quantityReceived, required this.unitCost, this.taxId, required this.taxAmount, required this.lineTotal}): super._();
  factory _PurchaseOrderItem.fromJson(Map<String, dynamic> json) => _$PurchaseOrderItemFromJson(json);

@override final  String id;
@override final  String purchaseOrderId;
@override final  String productId;
@override final  String quantityOrdered;
@override final  String quantityReceived;
@override final  String unitCost;
@override final  String? taxId;
@override final  String taxAmount;
@override final  String lineTotal;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderItemCopyWith<_PurchaseOrderItem> get copyWith => __$PurchaseOrderItemCopyWithImpl<_PurchaseOrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseOrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantityOrdered, quantityOrdered) || other.quantityOrdered == quantityOrdered)&&(identical(other.quantityReceived, quantityReceived) || other.quantityReceived == quantityReceived)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,purchaseOrderId,productId,quantityOrdered,quantityReceived,unitCost,taxId,taxAmount,lineTotal);

@override
String toString() {
  return 'PurchaseOrderItem(id: $id, purchaseOrderId: $purchaseOrderId, productId: $productId, quantityOrdered: $quantityOrdered, quantityReceived: $quantityReceived, unitCost: $unitCost, taxId: $taxId, taxAmount: $taxAmount, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderItemCopyWith<$Res> implements $PurchaseOrderItemCopyWith<$Res> {
  factory _$PurchaseOrderItemCopyWith(_PurchaseOrderItem value, $Res Function(_PurchaseOrderItem) _then) = __$PurchaseOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String purchaseOrderId, String productId, String quantityOrdered, String quantityReceived, String unitCost, String? taxId, String taxAmount, String lineTotal
});




}
/// @nodoc
class __$PurchaseOrderItemCopyWithImpl<$Res>
    implements _$PurchaseOrderItemCopyWith<$Res> {
  __$PurchaseOrderItemCopyWithImpl(this._self, this._then);

  final _PurchaseOrderItem _self;
  final $Res Function(_PurchaseOrderItem) _then;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? purchaseOrderId = null,Object? productId = null,Object? quantityOrdered = null,Object? quantityReceived = null,Object? unitCost = null,Object? taxId = freezed,Object? taxAmount = null,Object? lineTotal = null,}) {
  return _then(_PurchaseOrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchaseOrderId: null == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantityOrdered: null == quantityOrdered ? _self.quantityOrdered : quantityOrdered // ignore: cast_nullable_to_non_nullable
as String,quantityReceived: null == quantityReceived ? _self.quantityReceived : quantityReceived // ignore: cast_nullable_to_non_nullable
as String,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
