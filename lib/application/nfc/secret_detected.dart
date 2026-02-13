import 'dart:async';
import 'dart:convert';
import 'package:nfc_toolkit/nfc_toolkit.dart';
import '../../domain/value_objects/lock_method.dart';

/// Detection logic for "Secret" NFC tags.
///
/// This serves as both the Logic (detect method) and the Event (data holder).
class SecretDetection extends NfcDetection {
  /// Logic Constructor
  const SecretDetection()
    : encryptedText = null,
      foundLockMethod = null,
      timestamp = null,
      capacity = 0;

  /// Event Constructor
  const SecretDetection._({
    required this.encryptedText,
    required this.foundLockMethod,
    required this.timestamp,
    required this.capacity,
  });

  final String? encryptedText;
  final LockMethod? foundLockMethod;
  final DateTime? timestamp;
  final int capacity;

  @override
  FutureOr<NfcDetection?> detect(NfcData data) async {
    // Fail-fast checks
    final message = await data.getOrReadMessage();
    if (message == null || message.records.isEmpty) return null;

    try {
      // Look for specific application record
      final record = message.records.firstWhere((r) {
        final typeStr = utf8.decode(r.type);
        return typeStr == 'application/portablesec';
      });

      final fullPayload = record.payload;

      if (fullPayload.length >= 33) {
        final hintByte = fullPayload[0];
        final encryptedBytes = fullPayload.sublist(1);
        final encryptedText = base64Encode(encryptedBytes);

        LockMethod? foundLockMethod;
        if (hintByte > 0 && hintByte <= LockType.values.length) {
          final type = LockType.values[hintByte - 1];
          foundLockMethod = LockMethod(
            type: type,
            verificationHash: null,
            salt: null,
          );
        } else {
          foundLockMethod = null;
        }

        // Return NEW instance populated with data
        return SecretDetection._(
          encryptedText: encryptedText,
          foundLockMethod: foundLockMethod,
          timestamp: DateTime.now(),
          capacity: data.ndef?.maxSize ?? 0,
        );
      }
    } catch (_) {
      // Fallthrough if not a valid secret tag
    }

    return null;
  }
}
