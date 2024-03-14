import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptAESData {
  static Encrypted encrypted;
  static var decrypted;

  static String encryptAES(data) {
    final key = Key.fromUtf8(dotenv.env['privateKEY']);
    final iv = IV.fromUtf8(dotenv.env['privateINV']);
    final encrypter = Encrypter(AES(key));
    encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  static decryptAES(data) {
    final key = Key.fromUtf8(dotenv.env['privateKEY']);
    final iv = IV.fromUtf8(dotenv.env['privateINV']);
    final encrypter = Encrypter(AES(key));
    String decrypted = "";
    if (data != "") {
      try {
        decrypted = encrypter.decrypt(Encrypted.fromBase64(data), iv: iv);
      } catch (exception) {
        decrypted = data;
      }
    }
    return decrypted;
  }
}
