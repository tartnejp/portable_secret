import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/value_objects/lock_method.dart';
import '../../infrastructure/services/nfc_components/nfc_data.dart';
import 'di/services_provider.dart';

part 'nfc_detection_provider.freezed.dart';
part 'nfc_detection_provider.g.dart';

@freezed
abstract class NfcDetectionEvent with _$NfcDetectionEvent {
  const factory NfcDetectionEvent.generic({required DateTime timestamp}) =
      _Generic;
  //todo delete
  // const factory NfcDetectionEvent.locationFound(
  //   Location location, {
  //   required DateTime timestamp,
  // }) = _LocationFound;
  const factory NfcDetectionEvent.secretFound({
    required String encryptedText,
    required LockMethod? foundLockMethod,
  }) = _Secret;
}

/// Strategy for detecting NFC events from raw data
abstract class NfcDetectionStrategy {
  FutureOr<NfcDetectionEvent> detect(NfcData data);
}

class SecretNfcDetectionStrategy implements NfcDetectionStrategy {
  final NfcDetectionStrategy _fallbackStrategy;

  SecretNfcDetectionStrategy({NfcDetectionStrategy? fallback})
    : _fallbackStrategy = fallback ?? const GenericNfcDetectionStrategy();

  @override
  FutureOr<NfcDetectionEvent> detect(NfcData data) async {
    final message = await data.getOrReadMessage();
    if (message != null && message.records.isNotEmpty) {
      try {
        final record = message.records.firstWhere((r) {
          final typeStr = utf8.decode(r.type);
          return typeStr == 'application/portablesec';
        });

        // Raw Blob with Hint
        final fullPayload = record.payload;

        // Check minimal length (Hint(1) + EncBlob)
        // 1 + 32 min (implied from previous logic)
        if (fullPayload.length >= 33) {
          final hintByte = fullPayload[0];
          // Blob starts at 1
          final encryptedBytes = fullPayload.sublist(1);
          final encryptedText = base64Encode(encryptedBytes);

          LockMethod? foundLockMethod;
          if (hintByte > 0 && hintByte <= LockType.values.length) {
            // hintByte is 1-based index for LockType
            final type = LockType.values[hintByte - 1];
            foundLockMethod = LockMethod(
              type: type,
              verificationHash: null,
              salt: null,
            );
          } else {
            // hintByte is 0 or invalid -> Treat as encrypted lock method (null)
            foundLockMethod = null;
          }

          return NfcDetectionEvent.secretFound(
            encryptedText: encryptedText,
            foundLockMethod: foundLockMethod,
          );
        }
      } catch (e) {
        // Not found or parse error, fall through to fallback
      }
    }
    return _fallbackStrategy.detect(data);
  }
}

class GenericNfcDetectionStrategy implements NfcDetectionStrategy {
  const GenericNfcDetectionStrategy();

  @override
  FutureOr<NfcDetectionEvent> detect(NfcData data) async {
    return NfcDetectionEvent.generic(timestamp: DateTime.now());
  }
}

@Riverpod(keepAlive: true)
class NfcDetectionStrategyNotifier extends _$NfcDetectionStrategyNotifier {
  @override
  NfcDetectionStrategy build() => SecretNfcDetectionStrategy();

  void setStrategy(NfcDetectionStrategy strategy) {
    state = strategy;
  }
}

@Riverpod(keepAlive: true)
class NfcDetectionEventNotifier extends _$NfcDetectionEventNotifier {
  @override
  Stream<NfcDetectionEvent> build() {
    final strategy = ref.watch(nfcDetectionStrategyProvider);
    final nfcService = ref.watch(nfcServiceProvider);
    return nfcService.backgroundTagStream.asyncMap((data) async {
      return strategy.detect(data);
    }).asBroadcastStream();
  }
}
