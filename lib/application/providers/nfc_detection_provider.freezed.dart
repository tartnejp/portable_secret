// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nfc_detection_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NfcDetectionEvent implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NfcDetectionEvent'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NfcDetectionEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NfcDetectionEvent()';
}


}

/// @nodoc
class $NfcDetectionEventCopyWith<$Res>  {
$NfcDetectionEventCopyWith(NfcDetectionEvent _, $Res Function(NfcDetectionEvent) __);
}


/// Adds pattern-matching-related methods to [NfcDetectionEvent].
extension NfcDetectionEventPatterns on NfcDetectionEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Generic value)?  generic,TResult Function( _Secret value)?  secretFound,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Generic() when generic != null:
return generic(_that);case _Secret() when secretFound != null:
return secretFound(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Generic value)  generic,required TResult Function( _Secret value)  secretFound,}){
final _that = this;
switch (_that) {
case _Generic():
return generic(_that);case _Secret():
return secretFound(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Generic value)?  generic,TResult? Function( _Secret value)?  secretFound,}){
final _that = this;
switch (_that) {
case _Generic() when generic != null:
return generic(_that);case _Secret() when secretFound != null:
return secretFound(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime timestamp)?  generic,TResult Function( String encryptedText,  LockMethod? foundLockMethod)?  secretFound,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Generic() when generic != null:
return generic(_that.timestamp);case _Secret() when secretFound != null:
return secretFound(_that.encryptedText,_that.foundLockMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime timestamp)  generic,required TResult Function( String encryptedText,  LockMethod? foundLockMethod)  secretFound,}) {final _that = this;
switch (_that) {
case _Generic():
return generic(_that.timestamp);case _Secret():
return secretFound(_that.encryptedText,_that.foundLockMethod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime timestamp)?  generic,TResult? Function( String encryptedText,  LockMethod? foundLockMethod)?  secretFound,}) {final _that = this;
switch (_that) {
case _Generic() when generic != null:
return generic(_that.timestamp);case _Secret() when secretFound != null:
return secretFound(_that.encryptedText,_that.foundLockMethod);case _:
  return null;

}
}

}

/// @nodoc


class _Generic with DiagnosticableTreeMixin implements NfcDetectionEvent {
  const _Generic({required this.timestamp});
  

 final  DateTime timestamp;

/// Create a copy of NfcDetectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenericCopyWith<_Generic> get copyWith => __$GenericCopyWithImpl<_Generic>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NfcDetectionEvent.generic'))
    ..add(DiagnosticsProperty('timestamp', timestamp));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Generic&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,timestamp);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NfcDetectionEvent.generic(timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$GenericCopyWith<$Res> implements $NfcDetectionEventCopyWith<$Res> {
  factory _$GenericCopyWith(_Generic value, $Res Function(_Generic) _then) = __$GenericCopyWithImpl;
@useResult
$Res call({
 DateTime timestamp
});




}
/// @nodoc
class __$GenericCopyWithImpl<$Res>
    implements _$GenericCopyWith<$Res> {
  __$GenericCopyWithImpl(this._self, this._then);

  final _Generic _self;
  final $Res Function(_Generic) _then;

/// Create a copy of NfcDetectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? timestamp = null,}) {
  return _then(_Generic(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _Secret with DiagnosticableTreeMixin implements NfcDetectionEvent {
  const _Secret({required this.encryptedText, required this.foundLockMethod});
  

 final  String encryptedText;
 final  LockMethod? foundLockMethod;

/// Create a copy of NfcDetectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecretCopyWith<_Secret> get copyWith => __$SecretCopyWithImpl<_Secret>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'NfcDetectionEvent.secretFound'))
    ..add(DiagnosticsProperty('encryptedText', encryptedText))..add(DiagnosticsProperty('foundLockMethod', foundLockMethod));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Secret&&(identical(other.encryptedText, encryptedText) || other.encryptedText == encryptedText)&&(identical(other.foundLockMethod, foundLockMethod) || other.foundLockMethod == foundLockMethod));
}


@override
int get hashCode => Object.hash(runtimeType,encryptedText,foundLockMethod);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'NfcDetectionEvent.secretFound(encryptedText: $encryptedText, foundLockMethod: $foundLockMethod)';
}


}

/// @nodoc
abstract mixin class _$SecretCopyWith<$Res> implements $NfcDetectionEventCopyWith<$Res> {
  factory _$SecretCopyWith(_Secret value, $Res Function(_Secret) _then) = __$SecretCopyWithImpl;
@useResult
$Res call({
 String encryptedText, LockMethod? foundLockMethod
});


$LockMethodCopyWith<$Res>? get foundLockMethod;

}
/// @nodoc
class __$SecretCopyWithImpl<$Res>
    implements _$SecretCopyWith<$Res> {
  __$SecretCopyWithImpl(this._self, this._then);

  final _Secret _self;
  final $Res Function(_Secret) _then;

/// Create a copy of NfcDetectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? encryptedText = null,Object? foundLockMethod = freezed,}) {
  return _then(_Secret(
encryptedText: null == encryptedText ? _self.encryptedText : encryptedText // ignore: cast_nullable_to_non_nullable
as String,foundLockMethod: freezed == foundLockMethod ? _self.foundLockMethod : foundLockMethod // ignore: cast_nullable_to_non_nullable
as LockMethod?,
  ));
}

/// Create a copy of NfcDetectionEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LockMethodCopyWith<$Res>? get foundLockMethod {
    if (_self.foundLockMethod == null) {
    return null;
  }

  return $LockMethodCopyWith<$Res>(_self.foundLockMethod!, (value) {
    return _then(_self.copyWith(foundLockMethod: value));
  });
}
}

// dart format on
