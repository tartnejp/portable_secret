// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LockMethod _$LockMethodFromJson(Map<String, dynamic> json) => _LockMethod(
  type: $enumDecode(_$LockTypeEnumMap, json['type']),
  salt: json['salt'] as String?,
  verificationHash: json['verificationHash'] as String?,
);

Map<String, dynamic> _$LockMethodToJson(_LockMethod instance) =>
    <String, dynamic>{
      'type': _$LockTypeEnumMap[instance.type]!,
      'salt': instance.salt,
      'verificationHash': instance.verificationHash,
    };

const _$LockTypeEnumMap = {
  LockType.pattern: 'pattern',
  LockType.pin: 'pin',
  LockType.password: 'password',
  LockType.patternAndPin: 'patternAndPin',
};
