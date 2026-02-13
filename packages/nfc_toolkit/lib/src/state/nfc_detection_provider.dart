import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../core/nfc_detection.dart';
import '../nfc_service.dart';

import '../providers/nfc_detection_registry.dart';
import '../riverpod/nfc_providers.dart';

/// Global provider that listens to NFC tags and yields relevant [NfcDetection] events.
///
/// This provider uses the "Parallel Detection" strategy:
/// 1. Listens to the background tag stream from [NfcService].
/// 2. Instantiates all registered [NfcDetection] prototypes from [NfcDetectionRegistry].
/// 3. Runs `detect()` on all of them in parallel (using [Future.wait]).
/// 4. Yields all successful detections.
/// 5. If no detection matches, yields [GenericNfcDetected].
final StreamProvider<NfcDetection>
nfcDetectionStreamProvider = StreamProvider<NfcDetection>((ref) async* {
  final registry = ref.watch(nfcDetectionRegistryProvider);
  final nfcService = ref.watch(nfcServiceProvider);

  // Check for initial tag (App Launch)
  final initialTag = await nfcService.getInitialTag();

  if (initialTag != null) {
    // Process initial tag
    final results = <NfcDetection?>[];
    for (final factory in registry.detectionFactories) {
      final detection = await factory().detect(initialTag); // <--- await here!
      results.add(detection);
    }

    final matchedDetections = results.whereType<NfcDetection>().toList();
    if (matchedDetections.isNotEmpty) {
      for (final detection in matchedDetections) {
        yield detection;
      }
    }
    // Always yield Generic
    yield const GenericNfcDetected();
  } else {
    yield const IdleDetection();
  }

  // Listen to the stream of raw NFC data
  await for (final nfcData in nfcService.backgroundTagStream) {
    if (nfcData == null) {
      yield const IdleDetection();
      continue;
    }

    // 0. Check for read errors
    if (nfcData.readError != null) {
      yield NfcError("読み取りエラー: ${nfcData.readError}");
      continue;
    }

    // 1. Instantiate factories
    // 2. Run detect() in parallel
    final results = await Future.wait(
      registry.detectionFactories.map((factory) async {
        try {
          final detection = factory();
          return await detection.detect(nfcData);
        } catch (e, stack) {
          debugPrint('Error in NfcDetection factory: $e\n$stack');
          return null;
        }
      }),
    );

    // Filter out nulls (non-matches)
    final matchedDetections = results.whereType<NfcDetection>().toList();

    if (matchedDetections.isNotEmpty) {
      // Yield all matches
      for (final detection in matchedDetections) {
        yield detection;
      }
    }

    // Always yield Generic (standard scope behavior)
    // This ensures overlay appears on non-listening screens (for Secret tags)
    // and for unknown tags.
    yield const GenericNfcDetected();
  }
});

// Helper extensions

/// Extensions for [Ref] (and [WidgetRef]) to easily listen to specific NFC detections.
extension NfcDetectionRefExtension on Ref {
  /// Listens for a specific [NfcDetection] type and triggers [onData] when it occurs.
  ///
  /// This is a typesafe wrapper around `ref.listen`.
  ///
  /// Example:
  /// ```dart
  /// ref.listenNfcDetection<SecretDetection>((detection) {
  ///   // Do something with detection.secretData
  /// });
  /// ```
  void listenNfcDetection<T extends NfcDetection>(
    void Function(T detection) onData, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (detection) {
          if (detection is T) {
            onData(detection);
          }
        },
        error:
            onError ??
            (error, stack) {
              // debugPrint('NfcDetection error: $error');
              // Only report if relevant? Or generic listener handles it.
            },
        loading: () {},
      );
    });
  }
}

// Compatibility for WidgetRef
extension NfcDetectionWidgetRefExtension on WidgetRef {
  void listenNfcDetection<T extends NfcDetection>(
    void Function(T detection) onData, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (detection) {
          if (detection is T) {
            onData(detection);
          }
        },
        error:
            onError ??
            (error, stack) {
              // debugPrint('NfcDetection error: $error');
            },
        loading: () {},
      );
    });
  }
}
