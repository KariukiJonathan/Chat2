import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  final encrypt.Key key;
  final encrypt.IV iv;

  EncryptionService(String keyString, String ivString)
      : key = encrypt.Key.fromUtf8(keyString),
        iv = encrypt.IV.fromUtf8(ivString);

  String encryptText(String text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  String decryptText(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
