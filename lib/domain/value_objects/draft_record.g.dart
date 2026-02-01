// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DraftRecord _$DraftRecordFromJson(Map<String, dynamic> json) => _DraftRecord(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  modifiedAt: DateTime.parse(json['modifiedAt'] as String),
  data: SecretData.fromJson(json['data'] as Map<String, dynamic>),
  lockMethod: LockMethod.fromJson(json['lockMethod'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DraftRecordToJson(_DraftRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'data': instance.data,
      'lockMethod': instance.lockMethod,
    };
