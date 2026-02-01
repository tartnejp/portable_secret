// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SecretItem _$SecretItemFromJson(Map<String, dynamic> json) =>
    _SecretItem(key: json['key'] as String, value: json['value'] as String);

Map<String, dynamic> _$SecretItemToJson(_SecretItem instance) =>
    <String, dynamic>{'key': instance.key, 'value': instance.value};

_SecretData _$SecretDataFromJson(Map<String, dynamic> json) => _SecretData(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SecretItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SecretDataToJson(_SecretData instance) =>
    <String, dynamic>{'items': instance.items};
