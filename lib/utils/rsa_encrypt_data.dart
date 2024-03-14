import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:nova/utils/hive_preferences.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart' as pointcastle;

class RSAEncryptData {

  static Future<String> encryptText(String decryptedText, String publicKey) async {
    try {
      final parser = RSAKeyParser();
      final PUBLIC_KEY = parser.parse(publicKey);
      final encrypter = Encrypter(RSA(publicKey: PUBLIC_KEY));
      final encrypted = encrypter.encrypt(decryptedText);
      return encrypted.base64;
    } catch (exception) {
      return decryptedText;
    }
  }

  static Future<String> decryptText(String encryptedText) async {
      try {
        final prefs = await HivePreferences.getInstance();
        final parser = RSAKeyParser();
        final private = prefs.getPrivateKey();
        final PRIVATE_KEY = parser.parse(private);
        final encrypter = Encrypter(RSA(privateKey: PRIVATE_KEY));
        final decrypted = encrypter.decrypt64(encryptedText);
        return decrypted;
      } catch (exception) {
        return encryptedText;
      }
  }

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      pointcastle.SecureRandom secureRandom,
      {int bitLength = 2048}) {
    final keyGen = RSAKeyGenerator();

    keyGen.init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom));

    final pair = keyGen.generateKeyPair();

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  static pointcastle.SecureRandom secureRandom() {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }
}
