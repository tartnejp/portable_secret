import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nfc_toolkit.dart';
import 'nfc_info_button.dart';

/// A smart wrapper widget that handles the platform differences for NFC sessions.
/// - On Android, it automatically starts the required provider mechanism and shows static test.
/// - On iOS, it shows a button to trigger the session explicitly, handles errors/cancellations
///   by showing a SnackBar, and copies the raw error to the clipboard.
class NfcSessionTriggerWidget extends ConsumerStatefulWidget {
  /// The text to display when prompting the user to touch the tag (Android)
  final String instructionText;

  /// The text to display on the button (iOS)
  final String buttonText;

  /// The function to execute to initiate the NFC session (e.g., resetSession or startWrite).
  /// It receives a callback to handle errors and timeouts, which it should pass to the underlying nfc_service.
  final void Function(void Function(String) onError)? onStartSession;
  final bool isHighlighted;
  final bool showIcon;
  final bool centerText;
  final double? fontSize;
  final VoidCallback? onLongPress;

  const NfcSessionTriggerWidget({
    super.key,
    required this.instructionText,
    required this.buttonText,
    required this.onStartSession,
    this.onLongPress,
    this.isHighlighted = false,
    this.showIcon = true,
    this.centerText = false,
    this.fontSize,
  });

  @override
  ConsumerState<NfcSessionTriggerWidget> createState() =>
      _NfcSessionTriggerWidgetState();
}

class _NfcSessionTriggerWidgetState
    extends ConsumerState<NfcSessionTriggerWidget> {
  bool _hasAutoStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasAutoStarted) {
      // On anything but iOS, auto-start immediately
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.onStartSession != null) {
            widget.onStartSession!(_handleError);
          }
        });
      }
      _hasAutoStarted = true;
    }
  }

  void _handleError(String message) {
    if (message == 'USER_CANCELED') {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Safety check to only reset UI state on iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // No longer maintaining local spinner state on iOS
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('NFCエラー: $message'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'コピー',
            textColor: Colors.white,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
            },
          ),
        ),
      );
    });
  }

  void _triggerIosSession() {
    // We notify the parent that the trigger happened
    if (widget.onStartSession != null) {
      widget.onStartSession!(_handleError);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for generic NFC errors exposed on the toolkit
    ref.listenNfcDetection<NfcError>(context, (error) async {
      _handleError(error.message);
      return NfcSessionAction.none();
    });

    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color onAccentColor = Theme.of(context).colorScheme.onPrimary;

    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    // Common Icon decoration used in buttons/containers
    Widget buildIcon() {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: onAccentColor, shape: BoxShape.circle),
        child: Icon(Icons.visibility, color: accentColor, size: 18),
      );
    }

    // iOS: Show instruction text and button with View icon
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isHighlighted
                      ? accentColor.withValues(
                          alpha: 0.5,
                        ) // Must be clickable still
                      : accentColor,
                  foregroundColor: widget.isHighlighted
                      ? onAccentColor.withValues(alpha: 0.5)
                      : onAccentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: _triggerIosSession,
                onLongPress: widget.onLongPress,
                icon: widget.showIcon ? buildIcon() : const SizedBox.shrink(),
                label: Padding(
                  padding: widget.showIcon
                      ? const EdgeInsets.only(left: 16)
                      : EdgeInsets.zero,
                  child: Container(
                    width: widget.centerText ? double.infinity : null,
                    alignment: widget.centerText ? Alignment.center : null,
                    child: Text(
                      widget.buttonText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.fontSize,
                        color: widget.isHighlighted
                            ? onAccentColor.withValues(alpha: 0.5)
                            : onAccentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 0,
            child: SizedBox(width: 40, child: NfcInfoButton()),
          ),
        ],
      );
    }

    // Android / other platforms: Display instruction text without icon or border
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.instructionText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
