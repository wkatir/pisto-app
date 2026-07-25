// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Expense {

 String get id; String? get categoryId; String get description; String get amount; String get expenseDate; String? get paymentMethodId; String? get notes; String? get receiptUrl;// Ausente en la respuesta de creación (el API responde el input, no la fila).
 DateTime? get createdAt;
/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseCopyWith<Expense> get copyWith => _$ExpenseCopyWithImpl<Expense>(this as Expense, _$identity);

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expenseDate, expenseDate) || other.expenseDate == expenseDate)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,description,amount,expenseDate,paymentMethodId,notes,receiptUrl,createdAt);

@override
String toString() {
  return 'Expense(id: $id, categoryId: $categoryId, description: $description, amount: $amount, expenseDate: $expenseDate, paymentMethodId: $paymentMethodId, notes: $notes, receiptUrl: $receiptUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExpenseCopyWith<$Res>  {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) _then) = _$ExpenseCopyWithImpl;
@useResult
$Res call({
 String id, String? categoryId, String description, String amount, String expenseDate, String? paymentMethodId, String? notes, String? receiptUrl, DateTime? createdAt
});




}
/// @nodoc
class _$ExpenseCopyWithImpl<$Res>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._self, this._then);

  final Expense _self;
  final $Res Function(Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = freezed,Object? description = null,Object? amount = null,Object? expenseDate = null,Object? paymentMethodId = freezed,Object? notes = freezed,Object? receiptUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,expenseDate: null == expenseDate ? _self.expenseDate : expenseDate // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Expense].
extension ExpensePatterns on Expense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Expense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Expense value)  $default,){
final _that = this;
switch (_that) {
case _Expense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Expense value)?  $default,){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? categoryId,  String description,  String amount,  String expenseDate,  String? paymentMethodId,  String? notes,  String? receiptUrl,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.categoryId,_that.description,_that.amount,_that.expenseDate,_that.paymentMethodId,_that.notes,_that.receiptUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? categoryId,  String description,  String amount,  String expenseDate,  String? paymentMethodId,  String? notes,  String? receiptUrl,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Expense():
return $default(_that.id,_that.categoryId,_that.description,_that.amount,_that.expenseDate,_that.paymentMethodId,_that.notes,_that.receiptUrl,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? categoryId,  String description,  String amount,  String expenseDate,  String? paymentMethodId,  String? notes,  String? receiptUrl,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.categoryId,_that.description,_that.amount,_that.expenseDate,_that.paymentMethodId,_that.notes,_that.receiptUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Expense extends Expense {
  const _Expense({required this.id, this.categoryId, required this.description, required this.amount, required this.expenseDate, this.paymentMethodId, this.notes, this.receiptUrl, this.createdAt}): super._();
  factory _Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

@override final  String id;
@override final  String? categoryId;
@override final  String description;
@override final  String amount;
@override final  String expenseDate;
@override final  String? paymentMethodId;
@override final  String? notes;
@override final  String? receiptUrl;
// Ausente en la respuesta de creación (el API responde el input, no la fila).
@override final  DateTime? createdAt;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseCopyWith<_Expense> get copyWith => __$ExpenseCopyWithImpl<_Expense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expenseDate, expenseDate) || other.expenseDate == expenseDate)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,description,amount,expenseDate,paymentMethodId,notes,receiptUrl,createdAt);

@override
String toString() {
  return 'Expense(id: $id, categoryId: $categoryId, description: $description, amount: $amount, expenseDate: $expenseDate, paymentMethodId: $paymentMethodId, notes: $notes, receiptUrl: $receiptUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExpenseCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$ExpenseCopyWith(_Expense value, $Res Function(_Expense) _then) = __$ExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, String? categoryId, String description, String amount, String expenseDate, String? paymentMethodId, String? notes, String? receiptUrl, DateTime? createdAt
});




}
/// @nodoc
class __$ExpenseCopyWithImpl<$Res>
    implements _$ExpenseCopyWith<$Res> {
  __$ExpenseCopyWithImpl(this._self, this._then);

  final _Expense _self;
  final $Res Function(_Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = freezed,Object? description = null,Object? amount = null,Object? expenseDate = null,Object? paymentMethodId = freezed,Object? notes = freezed,Object? receiptUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_Expense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,expenseDate: null == expenseDate ? _self.expenseDate : expenseDate // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ExpenseSummary {

 String get total; int get count;
/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseSummaryCopyWith<ExpenseSummary> get copyWith => _$ExpenseSummaryCopyWithImpl<ExpenseSummary>(this as ExpenseSummary, _$identity);

  /// Serializes this ExpenseSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseSummary&&(identical(other.total, total) || other.total == total)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,count);

@override
String toString() {
  return 'ExpenseSummary(total: $total, count: $count)';
}


}

/// @nodoc
abstract mixin class $ExpenseSummaryCopyWith<$Res>  {
  factory $ExpenseSummaryCopyWith(ExpenseSummary value, $Res Function(ExpenseSummary) _then) = _$ExpenseSummaryCopyWithImpl;
@useResult
$Res call({
 String total, int count
});




}
/// @nodoc
class _$ExpenseSummaryCopyWithImpl<$Res>
    implements $ExpenseSummaryCopyWith<$Res> {
  _$ExpenseSummaryCopyWithImpl(this._self, this._then);

  final ExpenseSummary _self;
  final $Res Function(ExpenseSummary) _then;

/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? count = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseSummary].
extension ExpenseSummaryPatterns on ExpenseSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseSummary value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String total,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
return $default(_that.total,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String total,  int count)  $default,) {final _that = this;
switch (_that) {
case _ExpenseSummary():
return $default(_that.total,_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String total,  int count)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
return $default(_that.total,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseSummary extends ExpenseSummary {
  const _ExpenseSummary({required this.total, required this.count}): super._();
  factory _ExpenseSummary.fromJson(Map<String, dynamic> json) => _$ExpenseSummaryFromJson(json);

@override final  String total;
@override final  int count;

/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseSummaryCopyWith<_ExpenseSummary> get copyWith => __$ExpenseSummaryCopyWithImpl<_ExpenseSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseSummary&&(identical(other.total, total) || other.total == total)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,count);

@override
String toString() {
  return 'ExpenseSummary(total: $total, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ExpenseSummaryCopyWith<$Res> implements $ExpenseSummaryCopyWith<$Res> {
  factory _$ExpenseSummaryCopyWith(_ExpenseSummary value, $Res Function(_ExpenseSummary) _then) = __$ExpenseSummaryCopyWithImpl;
@override @useResult
$Res call({
 String total, int count
});




}
/// @nodoc
class __$ExpenseSummaryCopyWithImpl<$Res>
    implements _$ExpenseSummaryCopyWith<$Res> {
  __$ExpenseSummaryCopyWithImpl(this._self, this._then);

  final _ExpenseSummary _self;
  final $Res Function(_ExpenseSummary) _then;

/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? count = null,}) {
  return _then(_ExpenseSummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
