// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lock_method.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LockMethod {

 LockType get type;/// Salt used for hashing the secret (if applicable)
 String? get salt;/// Hashed verification value to verify input before unlocking
 String? get verificationHash;
/// Create a copy of LockMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockMethodCopyWith<LockMethod> get copyWith => _$LockMethodCopyWithImpl<LockMethod>(this as LockMethod, _$identity);

  /// Serializes this LockMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LockMethod&&(identical(other.type, type) || other.type == type)&&(identical(other.salt, salt) || other.salt == salt)&&(identical(other.verificationHash, verificationHash) || other.verificationHash == verificationHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,salt,verificationHash);

@override
String toString() {
  return 'LockMethod(type: $type, salt: $salt, verificationHash: $verificationHash)';
}


}

/// @nodoc
abstract mixin class $LockMethodCopyWith<$Res>  {
  factory $LockMethodCopyWith(LockMethod value, $Res Function(LockMethod) _then) = _$LockMethodCopyWithImpl;
@useResult
$Res call({
 LockType type, String? salt, String? verificationHash
});




}
/// @nodoc
class _$LockMethodCopyWithImpl<$Res>
    implements $LockMethodCopyWith<$Res> {
  _$LockMethodCopyWithImpl(this._self, this._then);

  final LockMethod _self;
  final $Res Function(LockMethod) _then;

/// Create a copy of LockMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? salt = freezed,Object? verificationHash = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LockType,salt: freezed == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String?,verificationHash: freezed == verificationHash ? _self.verificationHash : verificationHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LockMethod].
extension LockMethodPatterns on LockMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LockMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LockMethod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LockMethod value)  $default,){
final _that = this;
switch (_that) {
case _LockMethod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LockMethod value)?  $default,){
final _that = this;
switch (_that) {
case _LockMethod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LockType type,  String? salt,  String? verificationHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LockMethod() when $default != null:
return $default(_that.type,_that.salt,_that.verificationHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LockType type,  String? salt,  String? verificationHash)  $default,) {final _that = this;
switch (_that) {
case _LockMethod():
return $default(_that.type,_that.salt,_that.verificationHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LockType type,  String? salt,  String? verificationHash)?  $default,) {final _that = this;
switch (_that) {
case _LockMethod() when $default != null:
return $default(_that.type,_that.salt,_that.verificationHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LockMethod implements LockMethod {
  const _LockMethod({required this.type, this.salt, this.verificationHash});
  factory _LockMethod.fromJson(Map<String, dynamic> json) => _$LockMethodFromJson(json);

@override final  LockType type;
/// Salt used for hashing the secret (if applicable)
@override final  String? salt;
/// Hashed verification value to verify input before unlocking
@override final  String? verificationHash;

/// Create a copy of LockMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockMethodCopyWith<_LockMethod> get copyWith => __$LockMethodCopyWithImpl<_LockMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LockMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LockMethod&&(identical(other.type, type) || other.type == type)&&(identical(other.salt, salt) || other.salt == salt)&&(identical(other.verificationHash, verificationHash) || other.verificationHash == verificationHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,salt,verificationHash);

@override
String toString() {
  return 'LockMethod(type: $type, salt: $salt, verificationHash: $verificationHash)';
}


}

/// @nodoc
abstract mixin class _$LockMethodCopyWith<$Res> implements $LockMethodCopyWith<$Res> {
  factory _$LockMethodCopyWith(_LockMethod value, $Res Function(_LockMethod) _then) = __$LockMethodCopyWithImpl;
@override @useResult
$Res call({
 LockType type, String? salt, String? verificationHash
});




}
/// @nodoc
class __$LockMethodCopyWithImpl<$Res>
    implements _$LockMethodCopyWith<$Res> {
  __$LockMethodCopyWithImpl(this._self, this._then);

  final _LockMethod _self;
  final $Res Function(_LockMethod) _then;

/// Create a copy of LockMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? salt = freezed,Object? verificationHash = freezed,}) {
  return _then(_LockMethod(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LockType,salt: freezed == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String?,verificationHash: freezed == verificationHash ? _self.verificationHash : verificationHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
