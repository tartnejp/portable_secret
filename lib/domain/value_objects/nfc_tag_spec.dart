import 'package:freezed_annotation/freezed_annotation.dart';

part 'nfc_tag_spec.freezed.dart';
part 'nfc_tag_spec.g.dart';

enum NfcTagType { ntag213, ntag215, ntag216, unknown }

@freezed
abstract class NfcTagSpec with _$NfcTagSpec {
  const factory NfcTagSpec({required NfcTagType type, required int maxBytes}) =
      _NfcTagSpec;

  factory NfcTagSpec.fromJson(Map<String, dynamic> json) =>
      _$NfcTagSpecFromJson(json);

  /// Helper to get specs for known definitions
  static NfcTagSpec fromType(NfcTagType type) {
    switch (type) {
      case NfcTagType.ntag213:
        return const NfcTagSpec(type: NfcTagType.ntag213, maxBytes: 137);
      case NfcTagType.ntag215:
        return const NfcTagSpec(type: NfcTagType.ntag215, maxBytes: 492);
      case NfcTagType.ntag216:
        return const NfcTagSpec(type: NfcTagType.ntag216, maxBytes: 868);
      case NfcTagType.unknown:
        return const NfcTagSpec(type: NfcTagType.unknown, maxBytes: 0);
    }
  }
}
