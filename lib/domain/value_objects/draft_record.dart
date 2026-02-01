import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/secret_data.dart';
import '../value_objects/lock_method.dart';

part 'draft_record.freezed.dart';
part 'draft_record.g.dart';

@freezed
abstract class DraftRecord with _$DraftRecord {
  const factory DraftRecord({
    required String id,
    required DateTime createdAt,
    required DateTime modifiedAt,
    required SecretData data,
    required LockMethod lockMethod,
  }) = _DraftRecord;

  factory DraftRecord.fromJson(Map<String, dynamic> json) =>
      _$DraftRecordFromJson(json);
}
