import 'package:nfc_manager/nfc_manager.dart';
// ignore: unused_import
import 'package:nfc_manager/ndef_record.dart'; // Needed for NdefMessage in some versions?
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
// If this import was working in service_impl, maybe it's needed here?
// But it looks suspicious. Usually NdefMessage is in nfc_manager.
// However, the user reported NdefMessage undefined.
// Let's try to assume it handles it if we don't mess up imports.
// Wait, nfc_manager should export it.

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
