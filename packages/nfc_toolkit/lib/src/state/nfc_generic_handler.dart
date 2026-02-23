import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/nfc_detection.dart';

/// Internal notification mechanism for Generic NFC detections.
///
/// When the dispatch logic determines that no UI screen is interested in the
/// detected tag (i.e., no specific [NfcDetection] type matched with an
/// interested listener), a [GenericNfcDetected] event is placed here instead
/// of being yielded into the main detection stream.
///
/// [NfcDetectionScope] watches this provider to display overlay notifications
/// for unrecognized tags, while keeping the native iOS scan sheet open for
/// the user to try another tag.
class NfcGenericHandler extends Notifier<GenericNfcDetected?> {
  @override
  GenericNfcDetected? build() => null;

  void notify(GenericNfcDetected event) {
    state = event;
  }

  void clear() {
    state = null;
  }
}

final nfcGenericHandlerProvider =
    NotifierProvider<NfcGenericHandler, GenericNfcDetected?>(() {
      return NfcGenericHandler();
    });
