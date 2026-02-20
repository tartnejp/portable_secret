import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';
import '../../nfc_toolkit.dart';

/// A smart wrapper widget that handles the platform differences for NFC sessions.
/// - On Android, it automatically starts the required provider mechanism and shows static test.
/// - On iOS, it shows a button to trigger the session explicitly, handles errors/cancellations
///   by showing a SnackBar, and copies the raw error to the clipboard.
class NfcSessionTriggerWidget extends ConsumerStatefulWidget {
  /// The text to display when prompting the user to touch the tag (Android)
  final String instructionText;

  /// The text to display on the button (iOS)
  final String buttonText;

  /// The function to execute to initiate the NFC session (e.g., resetSession or startWrite)
  final VoidCallback onStartSession;

  const NfcSessionTriggerWidget({
    super.key,
    required this.instructionText,
    required this.buttonText,
    required this.onStartSession,
  });

  @override
  ConsumerState<NfcSessionTriggerWidget> createState() =>
      _NfcSessionTriggerWidgetState();
}

class _NfcSessionTriggerWidgetState
    extends ConsumerState<NfcSessionTriggerWidget> {
  bool _isSessionActive = false;
  bool _hasAutoStarted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasAutoStarted) {
      // On anything but iOS, auto-start immediately
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onStartSession();
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
        setState(() {
          _isSessionActive = false;
        });
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
    setState(() {
      _isSessionActive = true;
    });
    widget.onStartSession();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for generic NFC errors exposed on the toolkit
    ref.listenNfcDetection<NfcError>((error) {
      _handleError(error.message);
    });

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_isSessionActive) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.instructionText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _triggerIosSession,
            child: Text(widget.buttonText),
          ),
        ],
      );
    }

    // Android / other platforms: Display instruction text only
    return Text(
      widget.instructionText,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16),
    );
  }
}
