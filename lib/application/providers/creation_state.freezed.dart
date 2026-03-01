// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'creation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreationState {

 CreationStep get step; List<SecretItem> get items;// Lock Configuration
 String get lockInput;// The raw pin/password input
 LockType? get selectedType;// Confirmation Logic
 bool get isConfirming; String get firstInput;// Tag Capacity
 int get maxCapacity;// Validation/Error
 String? get error; bool get isSuccess;// Draft Status
 bool get isDraftSaved;// Preferences
 bool get isManualUnlockRequired;// For Pattern+PIN: Second stage (PIN input after Pattern)
 bool get isLockSecondStage; String get tempFirstLockInput;// Edit Mode (from SVS)
 bool get isEditMode;
/// Create a copy of CreationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreationStateCopyWith<CreationState> get copyWith => _$CreationStateCopyWithImpl<CreationState>(this as CreationState, _$identity);

  /// Serializes this CreationState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreationState&&(identical(other.step, step) || other.step == step)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.lockInput, lockInput) || other.lockInput == lockInput)&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.isConfirming, isConfirming) || other.isConfirming == isConfirming)&&(identical(other.firstInput, firstInput) || other.firstInput == firstInput)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.error, error) || other.error == error)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.isDraftSaved, isDraftSaved) || other.isDraftSaved == isDraftSaved)&&(identical(other.isManualUnlockRequired, isManualUnlockRequired) || other.isManualUnlockRequired == isManualUnlockRequired)&&(identical(other.isLockSecondStage, isLockSecondStage) || other.isLockSecondStage == isLockSecondStage)&&(identical(other.tempFirstLockInput, tempFirstLockInput) || other.tempFirstLockInput == tempFirstLockInput)&&(identical(other.isEditMode, isEditMode) || other.isEditMode == isEditMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,step,const DeepCollectionEquality().hash(items),lockInput,selectedType,isConfirming,firstInput,maxCapacity,error,isSuccess,isDraftSaved,isManualUnlockRequired,isLockSecondStage,tempFirstLockInput,isEditMode);

@override
String toString() {
  return 'CreationState(step: $step, items: $items, lockInput: $lockInput, selectedType: $selectedType, isConfirming: $isConfirming, firstInput: $firstInput, maxCapacity: $maxCapacity, error: $error, isSuccess: $isSuccess, isDraftSaved: $isDraftSaved, isManualUnlockRequired: $isManualUnlockRequired, isLockSecondStage: $isLockSecondStage, tempFirstLockInput: $tempFirstLockInput, isEditMode: $isEditMode)';
}


}

/// @nodoc
abstract mixin class $CreationStateCopyWith<$Res>  {
  factory $CreationStateCopyWith(CreationState value, $Res Function(CreationState) _then) = _$CreationStateCopyWithImpl;
@useResult
$Res call({
 CreationStep step, List<SecretItem> items, String lockInput, LockType? selectedType, bool isConfirming, String firstInput, int maxCapacity, String? error, bool isSuccess, bool isDraftSaved, bool isManualUnlockRequired, bool isLockSecondStage, String tempFirstLockInput, bool isEditMode
});




}
/// @nodoc
class _$CreationStateCopyWithImpl<$Res>
    implements $CreationStateCopyWith<$Res> {
  _$CreationStateCopyWithImpl(this._self, this._then);

  final CreationState _self;
  final $Res Function(CreationState) _then;

/// Create a copy of CreationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? items = null,Object? lockInput = null,Object? selectedType = freezed,Object? isConfirming = null,Object? firstInput = null,Object? maxCapacity = null,Object? error = freezed,Object? isSuccess = null,Object? isDraftSaved = null,Object? isManualUnlockRequired = null,Object? isLockSecondStage = null,Object? tempFirstLockInput = null,Object? isEditMode = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as CreationStep,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SecretItem>,lockInput: null == lockInput ? _self.lockInput : lockInput // ignore: cast_nullable_to_non_nullable
as String,selectedType: freezed == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as LockType?,isConfirming: null == isConfirming ? _self.isConfirming : isConfirming // ignore: cast_nullable_to_non_nullable
as bool,firstInput: null == firstInput ? _self.firstInput : firstInput // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,isDraftSaved: null == isDraftSaved ? _self.isDraftSaved : isDraftSaved // ignore: cast_nullable_to_non_nullable
as bool,isManualUnlockRequired: null == isManualUnlockRequired ? _self.isManualUnlockRequired : isManualUnlockRequired // ignore: cast_nullable_to_non_nullable
as bool,isLockSecondStage: null == isLockSecondStage ? _self.isLockSecondStage : isLockSecondStage // ignore: cast_nullable_to_non_nullable
as bool,tempFirstLockInput: null == tempFirstLockInput ? _self.tempFirstLockInput : tempFirstLockInput // ignore: cast_nullable_to_non_nullable
as String,isEditMode: null == isEditMode ? _self.isEditMode : isEditMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreationState].
extension CreationStatePatterns on CreationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreationState value)  $default,){
final _that = this;
switch (_that) {
case _CreationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreationState value)?  $default,){
final _that = this;
switch (_that) {
case _CreationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CreationStep step,  List<SecretItem> items,  String lockInput,  LockType? selectedType,  bool isConfirming,  String firstInput,  int maxCapacity,  String? error,  bool isSuccess,  bool isDraftSaved,  bool isManualUnlockRequired,  bool isLockSecondStage,  String tempFirstLockInput,  bool isEditMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreationState() when $default != null:
return $default(_that.step,_that.items,_that.lockInput,_that.selectedType,_that.isConfirming,_that.firstInput,_that.maxCapacity,_that.error,_that.isSuccess,_that.isDraftSaved,_that.isManualUnlockRequired,_that.isLockSecondStage,_that.tempFirstLockInput,_that.isEditMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CreationStep step,  List<SecretItem> items,  String lockInput,  LockType? selectedType,  bool isConfirming,  String firstInput,  int maxCapacity,  String? error,  bool isSuccess,  bool isDraftSaved,  bool isManualUnlockRequired,  bool isLockSecondStage,  String tempFirstLockInput,  bool isEditMode)  $default,) {final _that = this;
switch (_that) {
case _CreationState():
return $default(_that.step,_that.items,_that.lockInput,_that.selectedType,_that.isConfirming,_that.firstInput,_that.maxCapacity,_that.error,_that.isSuccess,_that.isDraftSaved,_that.isManualUnlockRequired,_that.isLockSecondStage,_that.tempFirstLockInput,_that.isEditMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CreationStep step,  List<SecretItem> items,  String lockInput,  LockType? selectedType,  bool isConfirming,  String firstInput,  int maxCapacity,  String? error,  bool isSuccess,  bool isDraftSaved,  bool isManualUnlockRequired,  bool isLockSecondStage,  String tempFirstLockInput,  bool isEditMode)?  $default,) {final _that = this;
switch (_that) {
case _CreationState() when $default != null:
return $default(_that.step,_that.items,_that.lockInput,_that.selectedType,_that.isConfirming,_that.firstInput,_that.maxCapacity,_that.error,_that.isSuccess,_that.isDraftSaved,_that.isManualUnlockRequired,_that.isLockSecondStage,_that.tempFirstLockInput,_that.isEditMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreationState implements CreationState {
  const _CreationState({this.step = CreationStep.methodSelection, final  List<SecretItem> items = const [], this.lockInput = "", this.selectedType, this.isConfirming = false, this.firstInput = "", this.maxCapacity = 0, this.error, this.isSuccess = false, this.isDraftSaved = false, this.isManualUnlockRequired = true, this.isLockSecondStage = false, this.tempFirstLockInput = "", this.isEditMode = false}): _items = items;
  factory _CreationState.fromJson(Map<String, dynamic> json) => _$CreationStateFromJson(json);

@override@JsonKey() final  CreationStep step;
 final  List<SecretItem> _items;
@override@JsonKey() List<SecretItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

// Lock Configuration
@override@JsonKey() final  String lockInput;
// The raw pin/password input
@override final  LockType? selectedType;
// Confirmation Logic
@override@JsonKey() final  bool isConfirming;
@override@JsonKey() final  String firstInput;
// Tag Capacity
@override@JsonKey() final  int maxCapacity;
// Validation/Error
@override final  String? error;
@override@JsonKey() final  bool isSuccess;
// Draft Status
@override@JsonKey() final  bool isDraftSaved;
// Preferences
@override@JsonKey() final  bool isManualUnlockRequired;
// For Pattern+PIN: Second stage (PIN input after Pattern)
@override@JsonKey() final  bool isLockSecondStage;
@override@JsonKey() final  String tempFirstLockInput;
// Edit Mode (from SVS)
@override@JsonKey() final  bool isEditMode;

/// Create a copy of CreationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreationStateCopyWith<_CreationState> get copyWith => __$CreationStateCopyWithImpl<_CreationState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreationStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreationState&&(identical(other.step, step) || other.step == step)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.lockInput, lockInput) || other.lockInput == lockInput)&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.isConfirming, isConfirming) || other.isConfirming == isConfirming)&&(identical(other.firstInput, firstInput) || other.firstInput == firstInput)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.error, error) || other.error == error)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.isDraftSaved, isDraftSaved) || other.isDraftSaved == isDraftSaved)&&(identical(other.isManualUnlockRequired, isManualUnlockRequired) || other.isManualUnlockRequired == isManualUnlockRequired)&&(identical(other.isLockSecondStage, isLockSecondStage) || other.isLockSecondStage == isLockSecondStage)&&(identical(other.tempFirstLockInput, tempFirstLockInput) || other.tempFirstLockInput == tempFirstLockInput)&&(identical(other.isEditMode, isEditMode) || other.isEditMode == isEditMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,step,const DeepCollectionEquality().hash(_items),lockInput,selectedType,isConfirming,firstInput,maxCapacity,error,isSuccess,isDraftSaved,isManualUnlockRequired,isLockSecondStage,tempFirstLockInput,isEditMode);

@override
String toString() {
  return 'CreationState(step: $step, items: $items, lockInput: $lockInput, selectedType: $selectedType, isConfirming: $isConfirming, firstInput: $firstInput, maxCapacity: $maxCapacity, error: $error, isSuccess: $isSuccess, isDraftSaved: $isDraftSaved, isManualUnlockRequired: $isManualUnlockRequired, isLockSecondStage: $isLockSecondStage, tempFirstLockInput: $tempFirstLockInput, isEditMode: $isEditMode)';
}


}

/// @nodoc
abstract mixin class _$CreationStateCopyWith<$Res> implements $CreationStateCopyWith<$Res> {
  factory _$CreationStateCopyWith(_CreationState value, $Res Function(_CreationState) _then) = __$CreationStateCopyWithImpl;
@override @useResult
$Res call({
 CreationStep step, List<SecretItem> items, String lockInput, LockType? selectedType, bool isConfirming, String firstInput, int maxCapacity, String? error, bool isSuccess, bool isDraftSaved, bool isManualUnlockRequired, bool isLockSecondStage, String tempFirstLockInput, bool isEditMode
});




}
/// @nodoc
class __$CreationStateCopyWithImpl<$Res>
    implements _$CreationStateCopyWith<$Res> {
  __$CreationStateCopyWithImpl(this._self, this._then);

  final _CreationState _self;
  final $Res Function(_CreationState) _then;

/// Create a copy of CreationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? items = null,Object? lockInput = null,Object? selectedType = freezed,Object? isConfirming = null,Object? firstInput = null,Object? maxCapacity = null,Object? error = freezed,Object? isSuccess = null,Object? isDraftSaved = null,Object? isManualUnlockRequired = null,Object? isLockSecondStage = null,Object? tempFirstLockInput = null,Object? isEditMode = null,}) {
  return _then(_CreationState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as CreationStep,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SecretItem>,lockInput: null == lockInput ? _self.lockInput : lockInput // ignore: cast_nullable_to_non_nullable
as String,selectedType: freezed == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as LockType?,isConfirming: null == isConfirming ? _self.isConfirming : isConfirming // ignore: cast_nullable_to_non_nullable
as bool,firstInput: null == firstInput ? _self.firstInput : firstInput // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,isDraftSaved: null == isDraftSaved ? _self.isDraftSaved : isDraftSaved // ignore: cast_nullable_to_non_nullable
as bool,isManualUnlockRequired: null == isManualUnlockRequired ? _self.isManualUnlockRequired : isManualUnlockRequired // ignore: cast_nullable_to_non_nullable
as bool,isLockSecondStage: null == isLockSecondStage ? _self.isLockSecondStage : isLockSecondStage // ignore: cast_nullable_to_non_nullable
as bool,tempFirstLockInput: null == tempFirstLockInput ? _self.tempFirstLockInput : tempFirstLockInput // ignore: cast_nullable_to_non_nullable
as String,isEditMode: null == isEditMode ? _self.isEditMode : isEditMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
