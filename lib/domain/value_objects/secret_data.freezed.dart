// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'secret_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SecretItem {

 String get key; String get value;
/// Create a copy of SecretItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecretItemCopyWith<SecretItem> get copyWith => _$SecretItemCopyWithImpl<SecretItem>(this as SecretItem, _$identity);

  /// Serializes this SecretItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecretItem&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,value);

@override
String toString() {
  return 'SecretItem(key: $key, value: $value)';
}


}

/// @nodoc
abstract mixin class $SecretItemCopyWith<$Res>  {
  factory $SecretItemCopyWith(SecretItem value, $Res Function(SecretItem) _then) = _$SecretItemCopyWithImpl;
@useResult
$Res call({
 String key, String value
});




}
/// @nodoc
class _$SecretItemCopyWithImpl<$Res>
    implements $SecretItemCopyWith<$Res> {
  _$SecretItemCopyWithImpl(this._self, this._then);

  final SecretItem _self;
  final $Res Function(SecretItem) _then;

/// Create a copy of SecretItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SecretItem].
extension SecretItemPatterns on SecretItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecretItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecretItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecretItem value)  $default,){
final _that = this;
switch (_that) {
case _SecretItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecretItem value)?  $default,){
final _that = this;
switch (_that) {
case _SecretItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecretItem() when $default != null:
return $default(_that.key,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String value)  $default,) {final _that = this;
switch (_that) {
case _SecretItem():
return $default(_that.key,_that.value);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String value)?  $default,) {final _that = this;
switch (_that) {
case _SecretItem() when $default != null:
return $default(_that.key,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SecretItem implements SecretItem {
  const _SecretItem({required this.key, required this.value});
  factory _SecretItem.fromJson(Map<String, dynamic> json) => _$SecretItemFromJson(json);

@override final  String key;
@override final  String value;

/// Create a copy of SecretItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecretItemCopyWith<_SecretItem> get copyWith => __$SecretItemCopyWithImpl<_SecretItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SecretItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecretItem&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,value);

@override
String toString() {
  return 'SecretItem(key: $key, value: $value)';
}


}

/// @nodoc
abstract mixin class _$SecretItemCopyWith<$Res> implements $SecretItemCopyWith<$Res> {
  factory _$SecretItemCopyWith(_SecretItem value, $Res Function(_SecretItem) _then) = __$SecretItemCopyWithImpl;
@override @useResult
$Res call({
 String key, String value
});




}
/// @nodoc
class __$SecretItemCopyWithImpl<$Res>
    implements _$SecretItemCopyWith<$Res> {
  __$SecretItemCopyWithImpl(this._self, this._then);

  final _SecretItem _self;
  final $Res Function(_SecretItem) _then;

/// Create a copy of SecretItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,}) {
  return _then(_SecretItem(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SecretData {

 List<SecretItem> get items;
/// Create a copy of SecretData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecretDataCopyWith<SecretData> get copyWith => _$SecretDataCopyWithImpl<SecretData>(this as SecretData, _$identity);

  /// Serializes this SecretData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecretData&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'SecretData(items: $items)';
}


}

/// @nodoc
abstract mixin class $SecretDataCopyWith<$Res>  {
  factory $SecretDataCopyWith(SecretData value, $Res Function(SecretData) _then) = _$SecretDataCopyWithImpl;
@useResult
$Res call({
 List<SecretItem> items
});




}
/// @nodoc
class _$SecretDataCopyWithImpl<$Res>
    implements $SecretDataCopyWith<$Res> {
  _$SecretDataCopyWithImpl(this._self, this._then);

  final SecretData _self;
  final $Res Function(SecretData) _then;

/// Create a copy of SecretData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SecretItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [SecretData].
extension SecretDataPatterns on SecretData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecretData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecretData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecretData value)  $default,){
final _that = this;
switch (_that) {
case _SecretData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecretData value)?  $default,){
final _that = this;
switch (_that) {
case _SecretData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SecretItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecretData() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SecretItem> items)  $default,) {final _that = this;
switch (_that) {
case _SecretData():
return $default(_that.items);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SecretItem> items)?  $default,) {final _that = this;
switch (_that) {
case _SecretData() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SecretData implements SecretData {
  const _SecretData({final  List<SecretItem> items = const []}): _items = items;
  factory _SecretData.fromJson(Map<String, dynamic> json) => _$SecretDataFromJson(json);

 final  List<SecretItem> _items;
@override@JsonKey() List<SecretItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of SecretData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecretDataCopyWith<_SecretData> get copyWith => __$SecretDataCopyWithImpl<_SecretData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SecretDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecretData&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'SecretData(items: $items)';
}


}

/// @nodoc
abstract mixin class _$SecretDataCopyWith<$Res> implements $SecretDataCopyWith<$Res> {
  factory _$SecretDataCopyWith(_SecretData value, $Res Function(_SecretData) _then) = __$SecretDataCopyWithImpl;
@override @useResult
$Res call({
 List<SecretItem> items
});




}
/// @nodoc
class __$SecretDataCopyWithImpl<$Res>
    implements _$SecretDataCopyWith<$Res> {
  __$SecretDataCopyWithImpl(this._self, this._then);

  final _SecretData _self;
  final $Res Function(_SecretData) _then;

/// Create a copy of SecretData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_SecretData(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SecretItem>,
  ));
}


}

// dart format on
