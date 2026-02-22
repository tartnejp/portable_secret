import 'package:flutter/widgets.dart'; // Added for WidgetsBinding
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/nfc_detection.dart';
import '../nfc_service.dart';
import '../nfc_data.dart'; // Add for NfcError
import 'nfc_session.dart';

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
      yield NfcError(message: "読み取りエラー: ${nfcData.readError}");
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
  /// The provided callback MUST return a `Future<NfcSessionAction>`.
  ///
  /// During execution, the session is claimed to prevent generic fallbacks.
  /// Once the Future completes, the underlying session is closed with the specified action result.
  void listenNfcDetection<T extends NfcDetection>(
    Future<NfcSessionAction> Function(T detection) onData, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (detection) {
          if (detection is T) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final controller = read(nfcSessionControllerProvider.notifier);
              if (!controller.takeOwnership()) return;

              try {
                final action = await onData(detection);

                final nfcService = read(nfcServiceProvider);
                if (action.isSuccess) {
                  await nfcService.stopSession(
                    alertMessage: action.message ?? '完了しました',
                  );
                  // TODO: Trigger Android success overlay
                } else if (action.isNone) {
                  await nfcService.stopSession();
                } else {
                  await nfcService.stopSession(
                    errorMessage: action.message ?? 'エラーが発生しました',
                  );
                  // TODO: Trigger Android error overlay
                }
              } catch (e, stackTrace) {
                if (onError != null) {
                  onError(e, stackTrace);
                }
                await read(
                  nfcServiceProvider,
                ).stopSession(errorMessage: e.toString());
              } finally {
                controller.releaseOwnership();
              }
            });
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

// Compatibility for WidgetRef
extension NfcDetectionWidgetRefExtension on WidgetRef {
  void listenNfcDetection<T extends NfcDetection>(
    Future<NfcSessionAction> Function(T detection) onData, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (detection) {
          if (detection is T) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final controller = read(nfcSessionControllerProvider.notifier);
              if (!controller.takeOwnership()) return;

              try {
                final action = await onData(detection);

                final nfcService = read(nfcServiceProvider);
                if (action.isSuccess) {
                  await nfcService.stopSession(
                    alertMessage: action.message ?? '完了しました',
                  );
                } else if (action.isNone) {
                  await nfcService.stopSession();
                } else {
                  await nfcService.stopSession(
                    errorMessage: action.message ?? 'エラーが発生しました',
                  );
                }
              } catch (e, stackTrace) {
                if (onError != null) {
                  onError(e, stackTrace);
                }
                await read(
                  nfcServiceProvider,
                ).stopSession(errorMessage: e.toString());
              } finally {
                controller.releaseOwnership();
              }
            });
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
