import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/nfc_detection.dart';
import '../state/nfc_error_handler.dart';
import '../state/nfc_generic_handler.dart';

/// A wrapper widget that listens to [nfcGenericHandlerProvider] and displays
/// overlay messages for unrecognized (Generic) tags.
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
  // Queue state for generic messages
  final List<String> _messageQueue = [];
  bool _isProcessQueueRunning = false;
  String? _activeMessage;
  Timer? _overlayTimer;

  // Error overlay state
  String? _activeErrorMessage;
  Timer? _errorOverlayTimer;

  // Helper to get current route name safely
  String? _getCurrentRoute(BuildContext context) {
    if (widget.routeNameGetter != null) {
      return widget.routeNameGetter!(context);
    }
    return ModalRoute.of(context)?.settings.name;
  }

  void _onGenericDetection(GenericNfcDetected detection) {
    final message = detection.overlayMessage;
    final currentRoute = _getCurrentRoute(context);

    // Route-based suppression
    if (currentRoute != null && widget.disableGenericDetectionRoutes.contains(currentRoute)) {
      return; // Suppress
    }

    _addToQueue(message);
  }

  void _onError(String errorMessage) {
    // Only show error overlay on Android
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }

    // Cancel any existing error timer
    _errorOverlayTimer?.cancel();

    // Show error message
    if (mounted) {
      setState(() {
        _activeErrorMessage = errorMessage;
      });
    }

    // Auto-dismiss after 2 seconds
    _errorOverlayTimer = Timer(widget.overlayDuration, () {
      if (mounted) {
        setState(() {
          _activeErrorMessage = null;
        });
      }
    });
  }

  void _dismissError() {
    _errorOverlayTimer?.cancel();
    if (mounted) {
      setState(() {
        _activeErrorMessage = null;
      });
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

    // Small gap for visual transition
    await Future.delayed(const Duration(milliseconds: 300));

    // Process next
    if (mounted) {
      _processQueue();
    }
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _errorOverlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to Generic detections (delivered directly, not via the main stream)
    ref.listen<GenericNfcDetected?>(nfcGenericHandlerProvider, (previous, next) {
      if (next != null) {
        _onGenericDetection(next);
      }
    });

    // Listen to error messages for Android overlay
    ref.listen<String?>(nfcErrorHandlerProvider, (previous, next) {
      if (next != null) {
        _onError(next);
        // Clear the provider state after consuming
        ref.read(nfcErrorHandlerProvider.notifier).clear();
      }
    });

    return Stack(
      children: [
        widget.child,
        if (_activeMessage != null)
          Positioned(left: 24, right: 24, bottom: 50, child: _buildOverlay(_activeMessage!)),
        if (_activeErrorMessage != null)
          Positioned(
            left: 24,
            right: 24,
            bottom: 50,
            child: _buildErrorOverlay(_activeErrorMessage!),
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

  Widget _buildErrorOverlay(String message) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: Container(
            key: ValueKey('error_$message'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _dismissError,
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
