import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import '../../application/services/encryption_service.dart';
import '../../domain/value_objects/secret_data.dart';
import '../../domain/value_objects/lock_method.dart';
import 'package:crypto/crypto.dart';

class EncryptionServiceImpl implements EncryptionService {
  static const _magic = [0x50, 0x53, 0x45, 0x43]; // 'PSEC'
  static const _version = 1;

  @override
  Future<List<int>> encrypt(SecretData data, LockMethod lock) async {
    // 1. Prepare Metadata & Payload
    final jsonStr = jsonEncode(data.toJson());
    final jsonBytes = utf8.encode(jsonStr);

    // Layout: [Magic (4)] [Ver (1)] [Type (1)] [Hash (32)] [Payload (N)]
    // Note: We include a Hash of the input to verifying it quickly (double check)
    // but the Magic check is usually sufficient to valid key.
    // However, user asked to include "these info" in the encrypted code.
    final input = lock.verificationHash ?? '';
    final inputHash = sha256.convert(utf8.encode(input)).bytes;

    final payloadBuffer = BytesBuilder();
    payloadBuffer.add(_magic);
    payloadBuffer.addByte(_version);
    payloadBuffer.addByte(lock.type.index); // LockType as index
    payloadBuffer.add(inputHash);
    payloadBuffer.add(jsonBytes);

    final plaintext = payloadBuffer.toBytes();

    // 2. Encrypt
    // Generate Salt for Key Derivation
    final salt = enc.IV.fromSecureRandom(16).bytes;
    final key = _deriveKey(input, salt);
    final iv = enc.IV.fromSecureRandom(16);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(plaintext, iv: iv);

    // 3. Final Blob: [Salt (16)] [IV (16)] [Ciphertext (N)]
    final finalBlob = BytesBuilder();
    finalBlob.add(salt);
    finalBlob.add(iv.bytes);
    finalBlob.add(encrypted.bytes);

    return finalBlob.toBytes();
  }

  @override
  Future<SecretData> decrypt(List<int> encryptedBytes, String inputKey) async {
    if (encryptedBytes.length < 32) {
      // Salt(16) + IV(16) + min ciphertext
      throw Exception('Invalid data length');
    }

    try {
      final bytes = Uint8List.fromList(encryptedBytes);
      final salt = bytes.sublist(0, 16);
      final ivBytes = bytes.sublist(16, 32);
      final cipherBytes = bytes.sublist(32);

      final key = _deriveKey(inputKey, salt);
      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final decryptedBytes = encrypter.decryptBytes(
        enc.Encrypted(cipherBytes),
        iv: iv,
      );

      // Validate Header
      // [Magic (4)] [Ver (1)] [Type (1)] [Hash (32)] [Payload (N)]
      if (decryptedBytes.length < 38) {
        throw Exception('Decrypted data too short');
      }

      // Check Magic 'PSEC'
      for (int i = 0; i < 4; i++) {
        if (decryptedBytes[i] != _magic[i]) {
          throw Exception('Invalid Magic Bytes (Wrong Key?)');
        }
      }

      // Check Version
      if (decryptedBytes[4] != _version) {
        throw Exception('Unsupported Version');
      }

      // We could check Type [5] and Hash [6..37], but Magic check implies success.
      // Parse JSON Payload [38..]
      final jsonBytes = decryptedBytes.sublist(38);
      final jsonStr = utf8.decode(jsonBytes);
      final jsonMap = jsonDecode(jsonStr);

      return SecretData.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  enc.Key _deriveKey(String input, List<int> salt) {
    // PBKDF2 would be better, but for now we use SHA256(Input + Salt).
    final sink = listToBytes([...utf8.encode(input), ...salt]);
    final digest = sha256.convert(sink);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  List<int> listToBytes(List<int> list) =>
      list; // Helper if needed or just use spread
}
