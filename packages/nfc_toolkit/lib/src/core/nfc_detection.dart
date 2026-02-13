import 'dart:async';
import '../nfc_data.dart';

/// Base class for all NFC detection logic.
///
/// Implementations of this class define how to parse [NfcData] into a specific
/// detection event.
abstract class NfcDetection {
  const NfcDetection();

  /// Attempts to detect this specific type of NFC content from [data].
  ///
  /// specific logic to parsing [NfcData] and returning a new instance of
  /// this class (or subclass) if the data matches.
  ///
  /// Returns `null` if the data does not match this detection type.
  ///
  /// [Performance Note]: implementations should be "fail-fast".
  /// Perform lightweight checks (e.g. checking TNF or type fields) first
  /// before attempting expensive operations (e.g. large payload parsing or crypto).
  FutureOr<NfcDetection?> detect(NfcData data);
}

/// Mixin for [NfcDetection]s that should display an overlay message when detected.
mixin OverlayDisplay on NfcDetection {
  /// The message to display in the overlay.
  String get overlayMessage;
}

/// A default detection event when an NFC tag is detected but no other
/// specific detections matched (or they matched but we still want a generic fallback).
final class GenericNfcDetected extends NfcDetection with OverlayDisplay {
  const GenericNfcDetected({this.message = 'NFCタグを検知しました'});

  final String message;

  @override
  FutureOr<NfcDetection?> detect(NfcData data) => this;

  @override
  String get overlayMessage => message;
}

/// A detection event representing an idle state (no tag detected or session reset).
final class IdleDetection extends NfcDetection {
  const IdleDetection();

  @override
  FutureOr<NfcDetection?> detect(NfcData data) => null;
}

/// A detection event representing a read error (IO exception, etc.).
final class NfcError extends NfcDetection with OverlayDisplay {
  final String message;
  const NfcError(this.message);

  @override
  FutureOr<NfcDetection?> detect(NfcData data) => null;

  @override
  String get overlayMessage => message;
}
