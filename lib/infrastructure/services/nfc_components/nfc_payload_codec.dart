import 'package:encrypt/encrypt.dart' as encryption_lib;

class NfcPayloadCodec {
  // NFC Encryption Constants
  static final _key = encryption_lib.Key.fromBase64(
    'TG9ja1JlY29yZEFwcFNlY3VyZUtleTMyQnl0ZXMhISF=',
  );
  static final _iv = encryption_lib.IV.fromUtf8(
    'PortableSecAppIV1',
  ); // 17 bytes
  static const _appIdentityHeader = 'PORTABLESEC_APP::';

  /// Encrypts
  static String encrypt(String text) {
    final encrypter = encryption_lib.Encrypter(encryption_lib.AES(_key));
    final plainText = '$_appIdentityHeader$text';
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    // Use base64 string
    return encrypted.base64;
  }

  /// Decrypts and validates an NFC payload.
  /// Returns the valid location ID if successful, otherwise null.
  static String? decodeAndValidate(String payload) {
    try {
      final encrypter = encryption_lib.Encrypter(encryption_lib.AES(_key));
      final decrypted = encrypter.decrypt(
        encryption_lib.Encrypted.fromBase64(payload),
        iv: _iv,
      );

      if (!decrypted.startsWith(_appIdentityHeader)) {
        return null;
      }

      return decrypted.substring(_appIdentityHeader.length);
    } catch (_) {
      return null;
    }
  }
}
