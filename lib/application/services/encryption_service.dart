import '../../domain/value_objects/lock_method.dart';
import '../../domain/value_objects/secret_data.dart';

abstract class EncryptionService {
  /// Encrypts the [data] using the [lock] method/secret.
  /// Returns the raw bytes (Salt + IV + Ciphertext) to be stored on NFC.
  Future<List<int>> encrypt(SecretData data, LockMethod lock);

  /// Decrypts the [encryptedBytes] using the [inputSecret] (PIN/Password/Pattern).
  /// Returns the reconstructed [SecretData] on success.
  /// Throws exception if decryption fails (wrong key or invalid data).
  Future<SecretData> decrypt(List<int> encryptedBytes, String inputSecret);
}
