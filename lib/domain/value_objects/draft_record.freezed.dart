// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftRecord {

 String get id; DateTime get createdAt; DateTime get modifiedAt; SecretData get data; LockMethod get lockMethod;
/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftRecordCopyWith<DraftRecord> get copyWith => _$DraftRecordCopyWithImpl<DraftRecord>(this as DraftRecord, _$identity);

  /// Serializes this DraftRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.data, data) || other.data == data)&&(identical(other.lockMethod, lockMethod) || other.lockMethod == lockMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,modifiedAt,data,lockMethod);

@override
String toString() {
  return 'DraftRecord(id: $id, createdAt: $createdAt, modifiedAt: $modifiedAt, data: $data, lockMethod: $lockMethod)';
}


}

/// @nodoc
abstract mixin class $DraftRecordCopyWith<$Res>  {
  factory $DraftRecordCopyWith(DraftRecord value, $Res Function(DraftRecord) _then) = _$DraftRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime modifiedAt, SecretData data, LockMethod lockMethod
});


$SecretDataCopyWith<$Res> get data;$LockMethodCopyWith<$Res> get lockMethod;

}
/// @nodoc
class _$DraftRecordCopyWithImpl<$Res>
    implements $DraftRecordCopyWith<$Res> {
  _$DraftRecordCopyWithImpl(this._self, this._then);

  final DraftRecord _self;
  final $Res Function(DraftRecord) _then;

/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? modifiedAt = null,Object? data = null,Object? lockMethod = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SecretData,lockMethod: null == lockMethod ? _self.lockMethod : lockMethod // ignore: cast_nullable_to_non_nullable
as LockMethod,
  ));
}
/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SecretDataCopyWith<$Res> get data {
  
  return $SecretDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LockMethodCopyWith<$Res> get lockMethod {
  
  return $LockMethodCopyWith<$Res>(_self.lockMethod, (value) {
    return _then(_self.copyWith(lockMethod: value));
  });
}
}


/// Adds pattern-matching-related methods to [DraftRecord].
extension DraftRecordPatterns on DraftRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftRecord value)  $default,){
final _that = this;
switch (_that) {
case _DraftRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftRecord value)?  $default,){
final _that = this;
switch (_that) {
case _DraftRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime modifiedAt,  SecretData data,  LockMethod lockMethod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftRecord() when $default != null:
return $default(_that.id,_that.createdAt,_that.modifiedAt,_that.data,_that.lockMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime modifiedAt,  SecretData data,  LockMethod lockMethod)  $default,) {final _that = this;
switch (_that) {
case _DraftRecord():
return $default(_that.id,_that.createdAt,_that.modifiedAt,_that.data,_that.lockMethod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime modifiedAt,  SecretData data,  LockMethod lockMethod)?  $default,) {final _that = this;
switch (_that) {
case _DraftRecord() when $default != null:
return $default(_that.id,_that.createdAt,_that.modifiedAt,_that.data,_that.lockMethod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftRecord implements DraftRecord {
  const _DraftRecord({required this.id, required this.createdAt, required this.modifiedAt, required this.data, required this.lockMethod});
  factory _DraftRecord.fromJson(Map<String, dynamic> json) => _$DraftRecordFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  DateTime modifiedAt;
@override final  SecretData data;
@override final  LockMethod lockMethod;

/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftRecordCopyWith<_DraftRecord> get copyWith => __$DraftRecordCopyWithImpl<_DraftRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.data, data) || other.data == data)&&(identical(other.lockMethod, lockMethod) || other.lockMethod == lockMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,modifiedAt,data,lockMethod);

@override
String toString() {
  return 'DraftRecord(id: $id, createdAt: $createdAt, modifiedAt: $modifiedAt, data: $data, lockMethod: $lockMethod)';
}


}

/// @nodoc
abstract mixin class _$DraftRecordCopyWith<$Res> implements $DraftRecordCopyWith<$Res> {
  factory _$DraftRecordCopyWith(_DraftRecord value, $Res Function(_DraftRecord) _then) = __$DraftRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime modifiedAt, SecretData data, LockMethod lockMethod
});


@override $SecretDataCopyWith<$Res> get data;@override $LockMethodCopyWith<$Res> get lockMethod;

}
/// @nodoc
class __$DraftRecordCopyWithImpl<$Res>
    implements _$DraftRecordCopyWith<$Res> {
  __$DraftRecordCopyWithImpl(this._self, this._then);

  final _DraftRecord _self;
  final $Res Function(_DraftRecord) _then;

/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? modifiedAt = null,Object? data = null,Object? lockMethod = null,}) {
  return _then(_DraftRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SecretData,lockMethod: null == lockMethod ? _self.lockMethod : lockMethod // ignore: cast_nullable_to_non_nullable
as LockMethod,
  ));
}

/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SecretDataCopyWith<$Res> get data {
  
  return $SecretDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of DraftRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LockMethodCopyWith<$Res> get lockMethod {
  
  return $LockMethodCopyWith<$Res>(_self.lockMethod, (value) {
    return _then(_self.copyWith(lockMethod: value));
  });
}
}

// dart format on
