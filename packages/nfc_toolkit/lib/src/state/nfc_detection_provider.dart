import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/nfc_detection.dart';
import '../nfc_service.dart';
import '../nfc_data.dart';
import 'nfc_session.dart';
import 'nfc_interest_registry.dart';
import 'nfc_generic_handler.dart';
import 'nfc_debug_log.dart';

import '../providers/nfc_detection_registry.dart';
import '../riverpod/nfc_providers.dart';

/// Global provider that listens to NFC tags and yields relevant [NfcDetection] events.
///
/// This provider uses the "1 Scan = 1 Event" strategy:
/// 1. Listens to the background tag stream from [NfcService].
/// 2. Runs `detect()` on all registered [NfcDetection] prototypes in parallel.
/// 3. Consults [NfcInterestRegistry] to select the best matching type.
/// 4. Yields exactly ONE event per scan (the best match with the highest priority).
/// 5. If no interested type matches, notifies [nfcGenericHandlerProvider] instead.
final StreamProvider<NfcDetection> nfcDetectionStreamProvider =
    StreamProvider<NfcDetection>((ref) async* {
      final registry = ref.watch(nfcDetectionRegistryProvider);
      final nfcService = ref.watch(nfcServiceProvider);
      final interestRegistry = ref.read(nfcInterestRegistryProvider.notifier);

      // Set internal logger for debugging
      nfcService.debugLogger = (msg) {
        ref.read(nfcDebugLogProvider.notifier).add('[SVC] $msg');
      };

      // Check for initial tag (App Launch)
      final initialTag = await nfcService.getInitialTag();

      if (initialTag != null) {
        final result = await _detectAndDispatch(
          registry,
          interestRegistry,
          ref,
          initialTag,
        );
        if (result != null) {
          yield result;
        }
      } else {
        yield const IdleDetection();
      }

      // Listen to the stream of raw NFC data
      await for (final nfcData in nfcService.backgroundTagStream) {
        if (nfcData == null) {
          yield const IdleDetection();
          continue;
        }

        // DEBUG: Log NfcData state before dispatch
        ref
            .read(nfcDebugLogProvider.notifier)
            .add(
              'TAG: ndef=${nfcData.ndef != null}, '
              'cached=${nfcData.cachedMessage != null}',
            );

        // Check for read errors set during eager read in _handleBackgroundTag
        if (nfcData.readError != null) {
          ref
              .read(nfcDebugLogProvider.notifier)
              .add('TAG readError before dispatch: ${nfcData.readError}');
          yield NfcError(message: "読み取りエラー: ${nfcData.readError}");
          continue;
        }

        final result = await _detectAndDispatch(
          registry,
          interestRegistry,
          ref,
          nfcData,
        );

        // DEBUG: Check if readError was set DURING detect()
        if (nfcData.readError != null) {
          ref
              .read(nfcDebugLogProvider.notifier)
              .add('TAG readError after dispatch: ${nfcData.readError}');
        }

        if (result != null) {
          ref
              .read(nfcDebugLogProvider.notifier)
              .add('DISPATCH result: ${result.runtimeType}');
          yield result;
        } else {
          ref
              .read(nfcDebugLogProvider.notifier)
              .add('DISPATCH: no result (Generic or suppressed)');
        }
      }
    });

/// Runs all registered detection factories against [nfcData] and selects
/// the best event to dispatch based on [NfcInterestRegistry] priorities.
///
/// Returns the selected [NfcDetection] event, or `null` if no interested
/// type matched (in which case [nfcGenericHandlerProvider] is notified).
Future<NfcDetection?> _detectAndDispatch(
  NfcDetectionRegistry registry,
  NfcInterestRegistry interestRegistry,
  Ref ref,
  NfcData nfcData,
) async {
  // 1. Run detect() on all registered factories in parallel
  final detectionResults = await Future.wait(
    registry.detectionFactories.map((factory) async {
      try {
        final detection = factory();
        return await detection.detect(nfcData);
      } catch (e, stack) {
        debugPrint('Error in NfcDetection factory: $e\n$stack');
        ref.read(nfcDebugLogProvider.notifier).add('FACTORY ERR: $e');
        return null;
      }
    }),
  );

  // 2. Collect matched detections with their types
  final matchedDetections = <NfcDetection>[];
  final matchedTypes = <Type>[];
  for (final detection in detectionResults) {
    if (detection != null) {
      matchedDetections.add(detection);
      matchedTypes.add(detection.runtimeType);
    }
  }

  // 3. Filter matchedTypes to only those registered by a frontmost screen.
  //    This prevents a background screen's interest (e.g. HOM-'s SecretDetection)
  //    from intercepting tags meant for a foreground screen (e.g. CCA's GenericNfcDetected).
  final frontScreenIds = <int>{};
  for (final entry in _activeRegistrations.entries) {
    final ctx = entry.value.context;
    if (ctx is Element && ctx.mounted) {
      final isCurrent = ModalRoute.of(ctx)?.isCurrent ?? false;
      if (isCurrent) {
        frontScreenIds.add(entry.key);
      }
    }
  }

  // Build a filtered list: only types that have at least one frontmost screenId registered
  final frontMatchedTypes = <Type>[];
  for (final type in matchedTypes) {
    final registeredScreenIds = interestRegistry.getScreenIds(type);
    if (registeredScreenIds != null &&
        registeredScreenIds.any(frontScreenIds.contains)) {
      frontMatchedTypes.add(type);
    }
  }

  // 4. Ask Interest Registry which type to dispatch (using frontmost-filtered list)
  final bestType = interestRegistry.selectBestType(frontMatchedTypes);

  if (bestType != null) {
    // 4a. Found an interested type → yield the corresponding detection
    final bestDetection = matchedDetections.firstWhere(
      (d) => d.runtimeType == bestType,
    );

    return bestDetection;
  } else {
    // 4b. No specific type matched by frontmost screen → Generic handling
    final generic = GenericNfcDetected(nfcMaxSize: nfcData.ndef?.maxSize);

    // Check if any frontmost screen is listening for GenericNfcDetected
    final genericScreenIds = interestRegistry.getScreenIds(GenericNfcDetected);
    final hasFrontGenericInterest =
        genericScreenIds != null &&
        genericScreenIds.any(frontScreenIds.contains);

    if (hasFrontGenericInterest) {
      // A frontmost screen is explicitly listening via listenNfcDetection<GenericNfcDetected>
      // → yield to the main stream so the UI can call stopSession() with a message
      return generic;
    } else {
      // No frontmost listener → fall back to NfcDetectionScope overlay (no stopSession needed)
      ref.read(nfcGenericHandlerProvider.notifier).notify(generic);
      return null;
    }
  }
}

// --- Helper extensions ---

/// Set of screenIds that have been registered with the Interest Registry.
/// Used by [_detectAndDispatch] to filter by frontmost screens, and
/// cleaned up on widget dispose via [WidgetRef.onDispose].
final _activeRegistrations = <int, _RegistrationInfo>{};

class _RegistrationInfo {
  final Type type;
  final BuildContext context;
  _RegistrationInfo(this.type, this.context);
}

/// Extensions for [WidgetRef] to easily listen to specific NFC detections.
///
/// This is the primary API for UI screens to handle NFC events.
/// The extension automatically:
/// - Registers interest in type [T] with the [NfcInterestRegistry].
/// - Checks if this screen is the frontmost route before executing.
/// - Calls [NfcService.stopSession] with the appropriate message after processing.
/// - Unregisters interest when the widget is disposed via [onDispose].
extension NfcDetectionWidgetRefExtension on WidgetRef {
  void listenNfcDetection<T extends NfcDetection>(
    BuildContext context,
    Future<NfcSessionAction> Function(T detection) onData, {
    void Function(Object error, StackTrace stackTrace)? onError,
    int priority = 1,
  }) {
    final screenId = identityHashCode(context);
    final interestRegistry = read(nfcInterestRegistryProvider.notifier);

    // Defer registration to after the build phase to comply with
    // Riverpod's constraint: providers cannot be modified during build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context is Element && !context.mounted) return;

      interestRegistry.register(T, screenId, priority);
      _activeRegistrations[screenId] = _RegistrationInfo(T, context);
    });

    listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      // Check if context is still valid (widget still mounted)
      if (context is Element && !context.mounted) {
        // Context is no longer valid — clean up registration
        interestRegistry.unregister(T, screenId);
        _activeRegistrations.remove(screenId);
        return;
      }

      next.when(
        data: (detection) {
          if (detection is T) {
            // Frontmost check
            final isFront = ModalRoute.of(context)?.isCurrent ?? false;

            if (!isFront) return;

            Future.microtask(() async {
              try {
                final action = await onData(detection);

                final nfcService = read(nfcServiceProvider);
                if (action.isSuccess) {
                  await nfcService.stopSession(
                    alertMessage: action.message ?? '完了しました',
                  );
                  action.onComplete?.call();
                } else if (action.isNone) {
                  await nfcService.stopSession();
                  action.onComplete?.call();
                } else {
                  await nfcService.stopSession(
                    errorMessage: action.message ?? 'エラーが発生しました',
                  );
                  action.onComplete?.call();
                }
              } catch (e, stackTrace) {
                if (onError != null) {
                  onError(e, stackTrace);
                }
                await read(
                  nfcServiceProvider,
                ).stopSession(errorMessage: e.toString());
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
