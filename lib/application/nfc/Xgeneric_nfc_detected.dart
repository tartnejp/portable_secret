/*
import 'dart:async';
import 'package:nfc_toolkit/nfc_toolkit.dart';
import '../../router_provider.dart';

/// An action that detects any NFC tag and shows a default overlay.
class GenericNfcDetected extends NfcAction with OverlayDisplay {
  /// Prototype Constructor
  const GenericNfcDetected();

  @override
  // Explicitly disabled on Home (because SecretDetected handles Home)
  Set<String> get disabledRoutes => {AppRoute.home.name};

  @override
  FutureOr<NfcAction?> detect(NfcData data) {
    // Always detect (return new instance)
    return const GenericNfcDetected();
  }

  @override
  String? get overlayMessage => 'NFCタグを検知しました';
}
*/
