import 'package:freezed_annotation/freezed_annotation.dart';

part 'secret_data.freezed.dart';
part 'secret_data.g.dart';

@freezed
abstract class SecretItem with _$SecretItem {
  const factory SecretItem({required String key, required String value}) =
      _SecretItem;

  factory SecretItem.fromJson(Map<String, dynamic> json) =>
      _$SecretItemFromJson(json);
}

@freezed
abstract class SecretData with _$SecretData {
  const factory SecretData({@Default([]) List<SecretItem> items}) = _SecretData;

  factory SecretData.fromJson(Map<String, dynamic> json) =>
      _$SecretDataFromJson(json);
}
