import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/nfc_detection.dart';
import '../state/nfc_detection_provider.dart';
import '../state/nfc_session.dart';

/// A wrapper widget that listens to [NfcDetectionStreamProvider] and displays
/// overlay messages for detected tags.
///
/// Features:
/// - **Message Queueing**: If multiple detections occur, messages are displayed sequentially.
/// - **Route Filtering**: Can disable generic "Tag Detected" messages on specific routes.
class NfcDetectionScope extends ConsumerStatefulWidget {
  const NfcDetectionScope({
    super.key,
    this.disableGenericDetectionRoutes = const {},
    this.routeDetectionSuppressions = const {},
    required this.child,
    this.overlayDuration = const Duration(seconds: 2),
    this.routeNameGetter,
  });

  /// Routes where [GenericNfcDetected] overlays should be suppressed.
  final Set<String> disableGenericDetectionRoutes;

  /// Map of Route Name -> List of Detection Types to suppress.
  ///
  /// Example: `{'HOM-': [SecretDetection]}` will suppress [SecretDetection] overlay on 'HOM-'.
  final Map<String, List<Type>> routeDetectionSuppressions;

  /// Duration for which each overlay message is shown.
  final Duration overlayDuration;

  /// Optional callback to determine the current route name.
  final String? Function(BuildContext context)? routeNameGetter;

  final Widget child;

  @override
  ConsumerState<NfcDetectionScope> createState() => _NfcDetectionScopeState();
}

class _NfcDetectionScopeState extends ConsumerState<NfcDetectionScope> {
  // Queue state
  final List<String> _messageQueue = [];
  bool _isProcessQueueRunning = false;
  String? _activeMessage;
  Timer? _overlayTimer;

  // Helper to get current route name safely
  String? _getCurrentRoute(BuildContext context) {
    if (widget.routeNameGetter != null) {
      return widget.routeNameGetter!(context);
    }
    return ModalRoute.of(context)?.settings.name;
  }

  void _onDetection(NfcDetection detection) {
    if (detection is OverlayDisplay) {
      final message = detection.overlayMessage;
      final currentRoute = _getCurrentRoute(context);

      // 1. Session Ownership Suppression (Global)
      // If the session has been claimed (e.g. by another screen processing a Secret),
      // we suppress Generic fallbacks entirely to avoid interfering with their custom sheet closure.
      if (detection is GenericNfcDetected) {
        final sessionState = ref.read(nfcSessionControllerProvider);
        if (sessionState == NfcSessionState.claimed) {
          debugPrint(
            "NfcDetectionScope: Suppressing GenericNfcDetected because session is Claimed",
          );
          return;
        }
      }

      // 2. Generic Suppression (Legacy/Simple)
      if (detection is GenericNfcDetected) {
        if (currentRoute != null &&
            widget.disableGenericDetectionRoutes.contains(currentRoute)) {
          return; // Suppress
        }
      }

      // 3. Type-based Suppression
      if (currentRoute != null &&
          widget.routeDetectionSuppressions.containsKey(currentRoute)) {
        final suppressedTypes =
            widget.routeDetectionSuppressions[currentRoute]!;
        if (suppressedTypes.contains(detection.runtimeType)) {
          return; // Suppress
        }
      }

      _addToQueue(message);
    }
  }

  void _addToQueue(String message) {
    _messageQueue.add(message);
    if (!_isProcessQueueRunning) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_messageQueue.isEmpty) {
      _isProcessQueueRunning = false;
      return;
    }

    _isProcessQueueRunning = true;
    final message = _messageQueue.removeAt(0);

    // Show message
    if (mounted) {
      setState(() {
        _activeMessage = message;
      });
    }

    // Wait for display duration
    await Future.delayed(widget.overlayDuration);

    // Hide message
    if (mounted) {
      setState(() {
        _activeMessage = null;
      });
    }

    // Small gap for visual transition (optional, but requested "disappear then next")
    await Future.delayed(const Duration(milliseconds: 300));

    // Process next
    if (mounted) {
      _processQueue();
    }
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ALL detections
    ref.listen<AsyncValue<NfcDetection>>(
      nfcDetectionStreamProvider,
      (previous, next) {
        next.whenData(_onDetection);
      },
      onError: (err, stack) => debugPrint('NFC Detection Error: $err'),
    );

    return Stack(
      children: [
        widget.child,
        if (_activeMessage != null)
          Positioned(
            left: 24,
            right: 24,
            bottom: 50,
            child: _buildOverlay(_activeMessage!),
          ),
      ],
    );
  }

  Widget _buildOverlay(String message) {
    return IgnorePointer(
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: ValueKey(message),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
