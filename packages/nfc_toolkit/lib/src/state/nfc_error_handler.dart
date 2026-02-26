import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Internal notification mechanism for NFC error overlays on Android.
///
/// When [NfcSessionAction.error] is returned on Android, the error message
/// is placed here to be displayed as an overlay by [NfcDetectionScope].
///
/// On iOS, errors are displayed natively on the scan sheet, so this handler
/// is not used.
class NfcErrorHandler extends Notifier<String?> {
  @override
  String? build() => null;

  void notify(String errorMessage) {
    state = errorMessage;
  }

  void clear() {
    state = null;
  }
}

final nfcErrorHandlerProvider = NotifierProvider<NfcErrorHandler, String?>(() {
  return NfcErrorHandler();
});
