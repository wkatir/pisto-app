// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invoice {

 String get id; String? get customerId; String get documentTypeId; String get warehouseId; String get saleNumber; String get saleDate; String? get dueDate; String get status; String get paymentStatus; String get subtotal; String get taxAmount; String get discountAmount; String get total; String? get notes; DateTime get createdAt;/// Solo presente en el listado (`GET /sales/invoices`), viene del join.
 String? get customerName;/// Solo presentes en el detalle (`GET /sales/invoices/:id`).
 List<InvoiceItem>? get lines; List<SalePayment>? get payments;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.documentTypeId, documentTypeId) || other.documentTypeId == documentTypeId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber)&&(identical(other.saleDate, saleDate) || other.saleDate == saleDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.total, total) || other.total == total)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&const DeepCollectionEquality().equals(other.lines, lines)&&const DeepCollectionEquality().equals(other.payments, payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,documentTypeId,warehouseId,saleNumber,saleDate,dueDate,status,paymentStatus,subtotal,taxAmount,discountAmount,total,notes,createdAt,customerName,const DeepCollectionEquality().hash(lines),const DeepCollectionEquality().hash(payments));

@override
String toString() {
  return 'Invoice(id: $id, customerId: $customerId, documentTypeId: $documentTypeId, warehouseId: $warehouseId, saleNumber: $saleNumber, saleDate: $saleDate, dueDate: $dueDate, status: $status, paymentStatus: $paymentStatus, subtotal: $subtotal, taxAmount: $taxAmount, discountAmount: $discountAmount, total: $total, notes: $notes, createdAt: $createdAt, customerName: $customerName, lines: $lines, payments: $payments)';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 String id, String? customerId, String documentTypeId, String warehouseId, String saleNumber, String saleDate, String? dueDate, String status, String paymentStatus, String subtotal, String taxAmount, String discountAmount, String total, String? notes, DateTime createdAt, String? customerName, List<InvoiceItem>? lines, List<SalePayment>? payments
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = freezed,Object? documentTypeId = null,Object? warehouseId = null,Object? saleNumber = null,Object? saleDate = null,Object? dueDate = freezed,Object? status = null,Object? paymentStatus = null,Object? subtotal = null,Object? taxAmount = null,Object? discountAmount = null,Object? total = null,Object? notes = freezed,Object? createdAt = null,Object? customerName = freezed,Object? lines = freezed,Object? payments = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,documentTypeId: null == documentTypeId ? _self.documentTypeId : documentTypeId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,saleNumber: null == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String,saleDate: null == saleDate ? _self.saleDate : saleDate // ignore: cast_nullable_to_non_nullable
as String,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,lines: freezed == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<InvoiceItem>?,payments: freezed == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<SalePayment>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? customerId,  String documentTypeId,  String warehouseId,  String saleNumber,  String saleDate,  String? dueDate,  String status,  String paymentStatus,  String subtotal,  String taxAmount,  String discountAmount,  String total,  String? notes,  DateTime createdAt,  String? customerName,  List<InvoiceItem>? lines,  List<SalePayment>? payments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.customerId,_that.documentTypeId,_that.warehouseId,_that.saleNumber,_that.saleDate,_that.dueDate,_that.status,_that.paymentStatus,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.total,_that.notes,_that.createdAt,_that.customerName,_that.lines,_that.payments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? customerId,  String documentTypeId,  String warehouseId,  String saleNumber,  String saleDate,  String? dueDate,  String status,  String paymentStatus,  String subtotal,  String taxAmount,  String discountAmount,  String total,  String? notes,  DateTime createdAt,  String? customerName,  List<InvoiceItem>? lines,  List<SalePayment>? payments)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.customerId,_that.documentTypeId,_that.warehouseId,_that.saleNumber,_that.saleDate,_that.dueDate,_that.status,_that.paymentStatus,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.total,_that.notes,_that.createdAt,_that.customerName,_that.lines,_that.payments);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? customerId,  String documentTypeId,  String warehouseId,  String saleNumber,  String saleDate,  String? dueDate,  String status,  String paymentStatus,  String subtotal,  String taxAmount,  String discountAmount,  String total,  String? notes,  DateTime createdAt,  String? customerName,  List<InvoiceItem>? lines,  List<SalePayment>? payments)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.customerId,_that.documentTypeId,_that.warehouseId,_that.saleNumber,_that.saleDate,_that.dueDate,_that.status,_that.paymentStatus,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.total,_that.notes,_that.createdAt,_that.customerName,_that.lines,_that.payments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice extends Invoice {
  const _Invoice({required this.id, this.customerId, required this.documentTypeId, required this.warehouseId, required this.saleNumber, required this.saleDate, this.dueDate, required this.status, required this.paymentStatus, required this.subtotal, required this.taxAmount, required this.discountAmount, required this.total, this.notes, required this.createdAt, this.customerName, final  List<InvoiceItem>? lines, final  List<SalePayment>? payments}): _lines = lines,_payments = payments,super._();
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  String id;
@override final  String? customerId;
@override final  String documentTypeId;
@override final  String warehouseId;
@override final  String saleNumber;
@override final  String saleDate;
@override final  String? dueDate;
@override final  String status;
@override final  String paymentStatus;
@override final  String subtotal;
@override final  String taxAmount;
@override final  String discountAmount;
@override final  String total;
@override final  String? notes;
@override final  DateTime createdAt;
/// Solo presente en el listado (`GET /sales/invoices`), viene del join.
@override final  String? customerName;
/// Solo presentes en el detalle (`GET /sales/invoices/:id`).
 final  List<InvoiceItem>? _lines;
/// Solo presentes en el detalle (`GET /sales/invoices/:id`).
@override List<InvoiceItem>? get lines {
  final value = _lines;
  if (value == null) return null;
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<SalePayment>? _payments;
@override List<SalePayment>? get payments {
  final value = _payments;
  if (value == null) return null;
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.documentTypeId, documentTypeId) || other.documentTypeId == documentTypeId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber)&&(identical(other.saleDate, saleDate) || other.saleDate == saleDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.total, total) || other.total == total)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&const DeepCollectionEquality().equals(other._lines, _lines)&&const DeepCollectionEquality().equals(other._payments, _payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,documentTypeId,warehouseId,saleNumber,saleDate,dueDate,status,paymentStatus,subtotal,taxAmount,discountAmount,total,notes,createdAt,customerName,const DeepCollectionEquality().hash(_lines),const DeepCollectionEquality().hash(_payments));

@override
String toString() {
  return 'Invoice(id: $id, customerId: $customerId, documentTypeId: $documentTypeId, warehouseId: $warehouseId, saleNumber: $saleNumber, saleDate: $saleDate, dueDate: $dueDate, status: $status, paymentStatus: $paymentStatus, subtotal: $subtotal, taxAmount: $taxAmount, discountAmount: $discountAmount, total: $total, notes: $notes, createdAt: $createdAt, customerName: $customerName, lines: $lines, payments: $payments)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String? customerId, String documentTypeId, String warehouseId, String saleNumber, String saleDate, String? dueDate, String status, String paymentStatus, String subtotal, String taxAmount, String discountAmount, String total, String? notes, DateTime createdAt, String? customerName, List<InvoiceItem>? lines, List<SalePayment>? payments
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = freezed,Object? documentTypeId = null,Object? warehouseId = null,Object? saleNumber = null,Object? saleDate = null,Object? dueDate = freezed,Object? status = null,Object? paymentStatus = null,Object? subtotal = null,Object? taxAmount = null,Object? discountAmount = null,Object? total = null,Object? notes = freezed,Object? createdAt = null,Object? customerName = freezed,Object? lines = freezed,Object? payments = freezed,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,documentTypeId: null == documentTypeId ? _self.documentTypeId : documentTypeId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,saleNumber: null == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String,saleDate: null == saleDate ? _self.saleDate : saleDate // ignore: cast_nullable_to_non_nullable
as String,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,lines: freezed == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<InvoiceItem>?,payments: freezed == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<SalePayment>?,
  ));
}


}


/// @nodoc
mixin _$InvoiceItem {

 String get id; String get saleId; String get productId; String get quantity; String get unitPrice; String get discountPct; String get discountAmount; String? get taxId; String get taxAmount; String get lineTotal;
/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceItemCopyWith<InvoiceItem> get copyWith => _$InvoiceItemCopyWithImpl<InvoiceItem>(this as InvoiceItem, _$identity);

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,productId,quantity,unitPrice,discountPct,discountAmount,taxId,taxAmount,lineTotal);

@override
String toString() {
  return 'InvoiceItem(id: $id, saleId: $saleId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, discountPct: $discountPct, discountAmount: $discountAmount, taxId: $taxId, taxAmount: $taxAmount, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class $InvoiceItemCopyWith<$Res>  {
  factory $InvoiceItemCopyWith(InvoiceItem value, $Res Function(InvoiceItem) _then) = _$InvoiceItemCopyWithImpl;
@useResult
$Res call({
 String id, String saleId, String productId, String quantity, String unitPrice, String discountPct, String discountAmount, String? taxId, String taxAmount, String lineTotal
});




}
/// @nodoc
class _$InvoiceItemCopyWithImpl<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._self, this._then);

  final InvoiceItem _self;
  final $Res Function(InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? productId = null,Object? quantity = null,Object? unitPrice = null,Object? discountPct = null,Object? discountAmount = null,Object? taxId = freezed,Object? taxAmount = null,Object? lineTotal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as String,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceItem].
extension InvoiceItemPatterns on InvoiceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceItem value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceItem value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String saleId,  String productId,  String quantity,  String unitPrice,  String discountPct,  String discountAmount,  String? taxId,  String taxAmount,  String lineTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.id,_that.saleId,_that.productId,_that.quantity,_that.unitPrice,_that.discountPct,_that.discountAmount,_that.taxId,_that.taxAmount,_that.lineTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String saleId,  String productId,  String quantity,  String unitPrice,  String discountPct,  String discountAmount,  String? taxId,  String taxAmount,  String lineTotal)  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem():
return $default(_that.id,_that.saleId,_that.productId,_that.quantity,_that.unitPrice,_that.discountPct,_that.discountAmount,_that.taxId,_that.taxAmount,_that.lineTotal);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String saleId,  String productId,  String quantity,  String unitPrice,  String discountPct,  String discountAmount,  String? taxId,  String taxAmount,  String lineTotal)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.id,_that.saleId,_that.productId,_that.quantity,_that.unitPrice,_that.discountPct,_that.discountAmount,_that.taxId,_that.taxAmount,_that.lineTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceItem extends InvoiceItem {
  const _InvoiceItem({required this.id, required this.saleId, required this.productId, required this.quantity, required this.unitPrice, required this.discountPct, required this.discountAmount, this.taxId, required this.taxAmount, required this.lineTotal}): super._();
  factory _InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);

@override final  String id;
@override final  String saleId;
@override final  String productId;
@override final  String quantity;
@override final  String unitPrice;
@override final  String discountPct;
@override final  String discountAmount;
@override final  String? taxId;
@override final  String taxAmount;
@override final  String lineTotal;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceItemCopyWith<_InvoiceItem> get copyWith => __$InvoiceItemCopyWithImpl<_InvoiceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,productId,quantity,unitPrice,discountPct,discountAmount,taxId,taxAmount,lineTotal);

@override
String toString() {
  return 'InvoiceItem(id: $id, saleId: $saleId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, discountPct: $discountPct, discountAmount: $discountAmount, taxId: $taxId, taxAmount: $taxAmount, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class _$InvoiceItemCopyWith<$Res> implements $InvoiceItemCopyWith<$Res> {
  factory _$InvoiceItemCopyWith(_InvoiceItem value, $Res Function(_InvoiceItem) _then) = __$InvoiceItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String saleId, String productId, String quantity, String unitPrice, String discountPct, String discountAmount, String? taxId, String taxAmount, String lineTotal
});




}
/// @nodoc
class __$InvoiceItemCopyWithImpl<$Res>
    implements _$InvoiceItemCopyWith<$Res> {
  __$InvoiceItemCopyWithImpl(this._self, this._then);

  final _InvoiceItem _self;
  final $Res Function(_InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? productId = null,Object? quantity = null,Object? unitPrice = null,Object? discountPct = null,Object? discountAmount = null,Object? taxId = freezed,Object? taxAmount = null,Object? lineTotal = null,}) {
  return _then(_InvoiceItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as String,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as String,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SalePayment {

 String get id; String get saleId; String get paymentMethodId; String get amount; String? get reference; String get paymentDate;
/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalePaymentCopyWith<SalePayment> get copyWith => _$SalePaymentCopyWithImpl<SalePayment>(this as SalePayment, _$identity);

  /// Serializes this SalePayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,paymentMethodId,amount,reference,paymentDate);

@override
String toString() {
  return 'SalePayment(id: $id, saleId: $saleId, paymentMethodId: $paymentMethodId, amount: $amount, reference: $reference, paymentDate: $paymentDate)';
}


}

/// @nodoc
abstract mixin class $SalePaymentCopyWith<$Res>  {
  factory $SalePaymentCopyWith(SalePayment value, $Res Function(SalePayment) _then) = _$SalePaymentCopyWithImpl;
@useResult
$Res call({
 String id, String saleId, String paymentMethodId, String amount, String? reference, String paymentDate
});




}
/// @nodoc
class _$SalePaymentCopyWithImpl<$Res>
    implements $SalePaymentCopyWith<$Res> {
  _$SalePaymentCopyWithImpl(this._self, this._then);

  final SalePayment _self;
  final $Res Function(SalePayment) _then;

/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? paymentMethodId = null,Object? amount = null,Object? reference = freezed,Object? paymentDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SalePayment].
extension SalePaymentPatterns on SalePayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalePayment value)  $default,){
final _that = this;
switch (_that) {
case _SalePayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalePayment value)?  $default,){
final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String saleId,  String paymentMethodId,  String amount,  String? reference,  String paymentDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
return $default(_that.id,_that.saleId,_that.paymentMethodId,_that.amount,_that.reference,_that.paymentDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String saleId,  String paymentMethodId,  String amount,  String? reference,  String paymentDate)  $default,) {final _that = this;
switch (_that) {
case _SalePayment():
return $default(_that.id,_that.saleId,_that.paymentMethodId,_that.amount,_that.reference,_that.paymentDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String saleId,  String paymentMethodId,  String amount,  String? reference,  String paymentDate)?  $default,) {final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
return $default(_that.id,_that.saleId,_that.paymentMethodId,_that.amount,_that.reference,_that.paymentDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalePayment implements SalePayment {
  const _SalePayment({required this.id, required this.saleId, required this.paymentMethodId, required this.amount, this.reference, required this.paymentDate});
  factory _SalePayment.fromJson(Map<String, dynamic> json) => _$SalePaymentFromJson(json);

@override final  String id;
@override final  String saleId;
@override final  String paymentMethodId;
@override final  String amount;
@override final  String? reference;
@override final  String paymentDate;

/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalePaymentCopyWith<_SalePayment> get copyWith => __$SalePaymentCopyWithImpl<_SalePayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalePaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,paymentMethodId,amount,reference,paymentDate);

@override
String toString() {
  return 'SalePayment(id: $id, saleId: $saleId, paymentMethodId: $paymentMethodId, amount: $amount, reference: $reference, paymentDate: $paymentDate)';
}


}

/// @nodoc
abstract mixin class _$SalePaymentCopyWith<$Res> implements $SalePaymentCopyWith<$Res> {
  factory _$SalePaymentCopyWith(_SalePayment value, $Res Function(_SalePayment) _then) = __$SalePaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String saleId, String paymentMethodId, String amount, String? reference, String paymentDate
});




}
/// @nodoc
class __$SalePaymentCopyWithImpl<$Res>
    implements _$SalePaymentCopyWith<$Res> {
  __$SalePaymentCopyWithImpl(this._self, this._then);

  final _SalePayment _self;
  final $Res Function(_SalePayment) _then;

/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? paymentMethodId = null,Object? amount = null,Object? reference = freezed,Object? paymentDate = null,}) {
  return _then(_SalePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
