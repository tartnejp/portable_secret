import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart'; // Explicit import for NfcAAndroid etc.
// ignore: unused_import
import 'package:nfc_manager/ndef_record.dart'; // Needed for NdefMessage in some versions?
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
// However, nfc_manager 4.1.1 might export types differently.
// Let's assume proper types are available via nfc_manager since I cannot check file list.
// If not, I will trust the User's snippet which had explicit android import.
// import 'package:nfc_manager/platform_tags.dart'; // This failed providing this doesn't exist.
// import 'package:nfc_manager/platform_tags.dart'; // This failed providing this doesn't exist.

import 'core/nfc_detection.dart';

enum NfcErrorType { unknown, userCanceled, systemError }

class NfcError extends NfcDetection with OverlayDisplay {
  final NfcErrorType type;
  final String message;
  final dynamic details;

  const NfcError({
    this.type = NfcErrorType.unknown,
    required this.message,
    this.details,
  }) : super();

  @override
  FutureOr<NfcDetection?> detect(NfcData data) => null;

  @override
  String get overlayMessage => message;
}

class NfcData {
  final NfcTag? _tag;
  final Ndef? _ndef;
  final NdefMessage? _manualMessage;

  NfcData(NfcTag tag)
    : _tag = tag,
      _ndef = Ndef.from(tag),
      _manualMessage = null;

  NfcData.fromManual(this._manualMessage) : _tag = null, _ndef = null;

  // Provide access to ndef if needed, but prefer cachedMessage
  Ndef? get ndef => _ndef;

  // Unified access to cached message
  NdefMessage? get cachedMessage => _ndef?.cachedMessage ?? _manualMessage;

  String? _readError;
  String? get readError => _readError;

  /// Cached result from a previous [getOrReadMessage] call.
  NdefMessage? _eagerReadCache;

  /// Returns the cached message if available, or attempts to read from the tag.
  ///
  /// On iOS, the NFC tag connection may be lost after the `onDiscovered`
  /// callback returns. This method should be called eagerly (inside the
  /// callback) to cache the NDEF message while the tag is still connected.
  /// Subsequent calls return the cached result without contacting the tag.
  Future<NdefMessage?> getOrReadMessage() async {
    // 1. Return cached message if available
    if (cachedMessage != null) return cachedMessage;

    // 2. Return eagerly-read cached message
    if (_eagerReadCache != null) return _eagerReadCache;

    // 3. Try to read from tag if connection exists (2-second safety timeout)
    if (_ndef != null) {
      try {
        _eagerReadCache = await _ndef.read().timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );
        return _eagerReadCache;
      } catch (e) {
        _readError = e.toString();
        // Read failed (tag lost, timeout, etc)
      }
    }
    return null;
  }

  List<int> get identifier => _tag != null ? _getIdentifier(_tag) : [];

  String get tagType =>
      _tag != null ? _getTagType(_tag) : 'Launch Intent (Cached)';

  String get manufacturer => _getManufacturer(identifier);

  String formatIdentifier() {
    return identifier
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  // --- Private Helpers (Logic moved from TagViewPage) ---

  List<int> _getIdentifier(NfcTag tag) {
    try {
      final nfca = NfcAAndroid.from(tag);
      if (nfca != null) return nfca.tag.id;
    } catch (_) {}

    try {
      final mifare = MifareClassicAndroid.from(tag);
      if (mifare != null) return mifare.tag.id;
    } catch (_) {}

    try {
      final isoDep = IsoDepAndroid.from(tag);
      if (isoDep != null) return isoDep.tag.id;
    } catch (_) {}

    try {
      final mifareUltralight = MifareUltralightAndroid.from(tag);
      if (mifareUltralight != null) return mifareUltralight.tag.id;
    } catch (_) {}

    return [];
  }

  String _getTagType(NfcTag tag) {
    try {
      final nfca = NfcAAndroid.from(tag);
      if (nfca != null) {
        final sak = nfca.sak;
        if (sak == 0x00) return 'Mifare Ultralight / NTAG';
        if (sak == 0x08) return 'Mifare Classic 1K';
        if (sak == 0x18) return 'Mifare Classic 4K';
        if (sak == 0x20) return 'Mifare DESFire';
        return 'IsoDep / NfcA (SAK: 0x${sak.toRadixString(16)})';
      }
    } catch (_) {}

    try {
      if (MifareUltralightAndroid.from(tag) != null) return 'Mifare Ultralight';
    } catch (_) {}

    try {
      if (MifareClassicAndroid.from(tag) != null) return 'Mifare Classic';
    } catch (_) {}

    try {
      if (IsoDepAndroid.from(tag) != null) return 'ISO-DEP (ISO 14443-4)';
    } catch (_) {}

    return 'Unknown NFC Tag';
  }

  String _getManufacturer(List<int> identifier) {
    if (identifier.isEmpty) return 'Unknown';
    final firstByte = identifier[0];
    if (firstByte == 0x04) return 'NXP Semiconductors';
    if (firstByte == 0x05) return 'Infineon';
    if (firstByte == 0x07) return 'Texas Instruments';
    if (firstByte == 0x1D) return 'Shanghai Fudan Microelectronics';
    return 'Unknown (ID: 0x${firstByte.toRadixString(16).padLeft(2, '0')})';
  }
}
