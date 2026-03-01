import 'dart:convert';
import '../../consts.dart';
import '../../domain/value_objects/secret_data.dart';

class CapacityCalculator {
  // PSEC Header: Magic(4) + Version(1) + Type(1) + Hash(32) = 38 bytes
  static const int _psecHeaderSize = 38;

  // Dictionary Wrapper: Salt(16) + IV(16) + Hint(1) = 33 bytes
  // Note: The hint byte is outside the encrypted blob in the NDEF payload,
  // but let's count it here as part of the "app payload" structure we write.
  // Actually, the structure in CreationNotifier.writeToNfc is:
  // [Hint (1)] + [Salt (16)] + [IV (16)] + [Encrypted Content]
  static const int _wrapperOverhead = 1 + 16 + 16;

  // NDEF Record Overhead for "application/portablesec"
  // TNF(1) + TypeLen(1) + PayloadLen(Short=1 or Long=4) + Type(23) + IDLen(1)? + ID(0)
  // We use NfcWriteDataMime which uses:
  // NdefRecord(typeNameFormat: media, type: ..., payload: ...)
  // Mime type length: "application/portablesec".length = 23
  // Short record (SR=1): Header(1) + TypeLen(1) + PayloadLen(1) + Type(23) = 26 bytes
  // Long record (SR=0): Header(1) + TypeLen(1) + PayloadLen(4) + Type(23) = 29 bytes
  static const int _ndefMimeTypeLen = 23;

  // URI Record Overhead calculation
  // SR=1, TNF=1 (1) + TypeLen=1 + PayloadLen=1 + Type="U" (1) + Prefix=0x04 (1)
  // URI without "https://" length is total length - 8.
  // Total overhead = 5 + (length - 8) = length - 3
  static int get uriRecordSize {
    final length = utf8.encode(Consts.nfcUnlockUrl).length;
    return length - 3;
  }

  static int calculateTotalBytes(List<SecretItem> items) {
    if (items.isEmpty) return 0;

    // 1. Serialize Data
    final data = SecretData(items: items);
    final jsonStr = jsonEncode(data.toJson());
    final jsonBytes = utf8.encode(jsonStr);

    // 2. Encryption Input Payload (Plaintext for AES)
    // [Header (38)] + [JSON]
    final plaintextLen = _psecHeaderSize + jsonBytes.length;

    // 3. AES Padding (PKCS7, block size 16)
    // Padding is always added, even if length is multiple of 16 (adds 16 bytes in that case)
    final blockSize = 16;
    final padding = blockSize - (plaintextLen % blockSize);
    final encryptedLen = plaintextLen + padding;

    // 4. App Payload (The bytes we actually put into NDEF payload)
    // [Hint(1)] + [Salt(16)] + [IV(16)] + [EncryptedBody]
    final payloadLen = _wrapperOverhead + encryptedLen;

    // 5. NDEF Overhead
    // If payload <= 255, we can use Short Record (SR). Otherwise Normal Record.
    int ndefHeaderLen;
    if (payloadLen <= 255) {
      // SR=1: Flags(1) + TypeLen(1) + PayloadLen(1)
      ndefHeaderLen = 1 + 1 + 1;
    } else {
      // SR=0: Flags(1) + TypeLen(1) + PayloadLen(4)
      ndefHeaderLen = 1 + 1 + 4;
    }

    // MIME Record Size = Header + TypeName + ID(0) + Payload
    final mimeRecordLen = ndefHeaderLen + _ndefMimeTypeLen + payloadLen;

    // Total NDEF Message Size = URI Record + MIME Record
    final ndefMessageSize = uriRecordSize + mimeRecordLen;

    // NDEF TLV Overhead for Type 2 Tag
    // Tag (0x03) + Length (1 or 3 bytes) + Terminator (0xFE)
    int tlvOverhead;
    if (ndefMessageSize < 255) {
      tlvOverhead = 3;
    } else {
      tlvOverhead = 5;
    }

    return ndefMessageSize + tlvOverhead;
  }
}
