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

  const NfcSessionTriggerWidget({
    super.key,
    required this.instructionText,
    required this.buttonText,
    required this.onStartSession,
  });

  @override
  ConsumerState<NfcSessionTriggerWidget> createState() => _NfcSessionTriggerWidgetState();
}

class _NfcSessionTriggerWidgetState extends ConsumerState<NfcSessionTriggerWidget> {
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

    // iOS: Show instruction text and button with View icon
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  minimumSize: const Size.fromHeight(80),
                ),
                onPressed: _triggerIosSession,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //・Viewアイコン
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.visibility, color: Color(0xFFFFD600), size: 18),
                    ),
                    const SizedBox(width: 16),
                    Text(widget.buttonText),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 40, child: NfcInfoButton()),
          ],
        ),
      );
    }

    // Android / other platforms: Display instruction text with View icon
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container(
        //   padding: const EdgeInsets.all(6),
        //   decoration: const BoxDecoration(color: Color(0xFFFFD600), shape: BoxShape.circle),
        //   child: const Icon(Icons.visibility, color: Color(0xFFFFD600), size: 18),
        // ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            widget.instructionText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
