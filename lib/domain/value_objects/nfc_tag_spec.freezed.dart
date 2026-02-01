// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nfc_tag_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NfcTagSpec {

 NfcTagType get type; int get maxBytes;
/// Create a copy of NfcTagSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NfcTagSpecCopyWith<NfcTagSpec> get copyWith => _$NfcTagSpecCopyWithImpl<NfcTagSpec>(this as NfcTagSpec, _$identity);

  /// Serializes this NfcTagSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NfcTagSpec&&(identical(other.type, type) || other.type == type)&&(identical(other.maxBytes, maxBytes) || other.maxBytes == maxBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,maxBytes);

@override
String toString() {
  return 'NfcTagSpec(type: $type, maxBytes: $maxBytes)';
}


}

/// @nodoc
abstract mixin class $NfcTagSpecCopyWith<$Res>  {
  factory $NfcTagSpecCopyWith(NfcTagSpec value, $Res Function(NfcTagSpec) _then) = _$NfcTagSpecCopyWithImpl;
@useResult
$Res call({
 NfcTagType type, int maxBytes
});




}
/// @nodoc
class _$NfcTagSpecCopyWithImpl<$Res>
    implements $NfcTagSpecCopyWith<$Res> {
  _$NfcTagSpecCopyWithImpl(this._self, this._then);

  final NfcTagSpec _self;
  final $Res Function(NfcTagSpec) _then;

/// Create a copy of NfcTagSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? maxBytes = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NfcTagType,maxBytes: null == maxBytes ? _self.maxBytes : maxBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NfcTagSpec].
extension NfcTagSpecPatterns on NfcTagSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NfcTagSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NfcTagSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NfcTagSpec value)  $default,){
final _that = this;
switch (_that) {
case _NfcTagSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NfcTagSpec value)?  $default,){
final _that = this;
switch (_that) {
case _NfcTagSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NfcTagType type,  int maxBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NfcTagSpec() when $default != null:
return $default(_that.type,_that.maxBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NfcTagType type,  int maxBytes)  $default,) {final _that = this;
switch (_that) {
case _NfcTagSpec():
return $default(_that.type,_that.maxBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NfcTagType type,  int maxBytes)?  $default,) {final _that = this;
switch (_that) {
case _NfcTagSpec() when $default != null:
return $default(_that.type,_that.maxBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NfcTagSpec implements NfcTagSpec {
  const _NfcTagSpec({required this.type, required this.maxBytes});
  factory _NfcTagSpec.fromJson(Map<String, dynamic> json) => _$NfcTagSpecFromJson(json);

@override final  NfcTagType type;
@override final  int maxBytes;

/// Create a copy of NfcTagSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NfcTagSpecCopyWith<_NfcTagSpec> get copyWith => __$NfcTagSpecCopyWithImpl<_NfcTagSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NfcTagSpecToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NfcTagSpec&&(identical(other.type, type) || other.type == type)&&(identical(other.maxBytes, maxBytes) || other.maxBytes == maxBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,maxBytes);

@override
String toString() {
  return 'NfcTagSpec(type: $type, maxBytes: $maxBytes)';
}


}

/// @nodoc
abstract mixin class _$NfcTagSpecCopyWith<$Res> implements $NfcTagSpecCopyWith<$Res> {
  factory _$NfcTagSpecCopyWith(_NfcTagSpec value, $Res Function(_NfcTagSpec) _then) = __$NfcTagSpecCopyWithImpl;
@override @useResult
$Res call({
 NfcTagType type, int maxBytes
});




}
/// @nodoc
class __$NfcTagSpecCopyWithImpl<$Res>
    implements _$NfcTagSpecCopyWith<$Res> {
  __$NfcTagSpecCopyWithImpl(this._self, this._then);

  final _NfcTagSpec _self;
  final $Res Function(_NfcTagSpec) _then;

/// Create a copy of NfcTagSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? maxBytes = null,}) {
  return _then(_NfcTagSpec(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NfcTagType,maxBytes: null == maxBytes ? _self.maxBytes : maxBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
