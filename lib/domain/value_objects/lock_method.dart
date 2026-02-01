import 'package:freezed_annotation/freezed_annotation.dart';

part 'lock_method.freezed.dart';
part 'lock_method.g.dart';

enum LockType { pattern, pin, password, patternAndPin }

@freezed
abstract class LockMethod with _$LockMethod {
  const factory LockMethod({
    required LockType type,

    /// Salt used for hashing the secret (if applicable)
    String? salt,

    /// Hashed verification value to verify input before unlocking
    String? verificationHash,
  }) = _LockMethod;

  factory LockMethod.fromJson(Map<String, dynamic> json) =>
      _$LockMethodFromJson(json);
}
