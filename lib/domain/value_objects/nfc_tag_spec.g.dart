// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_tag_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NfcTagSpec _$NfcTagSpecFromJson(Map<String, dynamic> json) => _NfcTagSpec(
  type: $enumDecode(_$NfcTagTypeEnumMap, json['type']),
  maxBytes: (json['maxBytes'] as num).toInt(),
);

Map<String, dynamic> _$NfcTagSpecToJson(_NfcTagSpec instance) =>
    <String, dynamic>{
      'type': _$NfcTagTypeEnumMap[instance.type]!,
      'maxBytes': instance.maxBytes,
    };

const _$NfcTagTypeEnumMap = {
  NfcTagType.ntag213: 'ntag213',
  NfcTagType.ntag215: 'ntag215',
  NfcTagType.ntag216: 'ntag216',
  NfcTagType.unknown: 'unknown',
};
