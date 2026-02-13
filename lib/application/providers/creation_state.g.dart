// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creation_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreationState _$CreationStateFromJson(Map<String, dynamic> json) =>
    _CreationState(
      step:
          $enumDecodeNullable(_$CreationStepEnumMap, json['step']) ??
          CreationStep.methodSelection,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => SecretItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lockInput: json['lockInput'] as String? ?? "",
      selectedType:
          $enumDecodeNullable(_$LockTypeEnumMap, json['selectedType']) ??
          LockType.pin,
      isConfirming: json['isConfirming'] as bool? ?? false,
      firstInput: json['firstInput'] as String? ?? "",
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
      isSuccess: json['isSuccess'] as bool? ?? false,
      isDraftSaved: json['isDraftSaved'] as bool? ?? false,
      isManualUnlockRequired: json['isManualUnlockRequired'] as bool? ?? true,
      isLockSecondStage: json['isLockSecondStage'] as bool? ?? false,
      tempFirstLockInput: json['tempFirstLockInput'] as String? ?? "",
      isEditMode: json['isEditMode'] as bool? ?? false,
    );

Map<String, dynamic> _$CreationStateToJson(_CreationState instance) =>
    <String, dynamic>{
      'step': _$CreationStepEnumMap[instance.step]!,
      'items': instance.items,
      'lockInput': instance.lockInput,
      'selectedType': _$LockTypeEnumMap[instance.selectedType]!,
      'isConfirming': instance.isConfirming,
      'firstInput': instance.firstInput,
      'maxCapacity': instance.maxCapacity,
      'error': instance.error,
      'isSuccess': instance.isSuccess,
      'isDraftSaved': instance.isDraftSaved,
      'isManualUnlockRequired': instance.isManualUnlockRequired,
      'isLockSecondStage': instance.isLockSecondStage,
      'tempFirstLockInput': instance.tempFirstLockInput,
      'isEditMode': instance.isEditMode,
    };

const _$CreationStepEnumMap = {
  CreationStep.methodSelection: 'methodSelection',
  CreationStep.capacityCheck: 'capacityCheck',
  CreationStep.inputData: 'inputData',
  CreationStep.lockConfig: 'lockConfig',
  CreationStep.write: 'write',
};

const _$LockTypeEnumMap = {
  LockType.pattern: 'pattern',
  LockType.pin: 'pin',
  LockType.password: 'password',
  LockType.patternAndPin: 'patternAndPin',
};
