import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptDecrypt {
  static const String secretKey = "saptagiri"; // Base secret key
  static const int saltLength = 8; // Fixed salt length

  /// Generate a stronger key using SHA-256 + Salt
  static String generateKey(String salt) {
    final bytes = utf8.encode(secretKey + salt);
    final hash = sha256.convert(bytes).toString();
    return hash.substring(0, 32); // Use a 32-character key
  }

  /// XOR Encrypt/Decrypt Function (Reversible)
  static String xorEncrypt(String data, String key) {
    int keyLen = key.length;
    List<int> encryptedBytes = List.generate(
      data.length,
      (i) => data.codeUnitAt(i) ^ key.codeUnitAt(i % keyLen),
    );
    return String.fromCharCodes(encryptedBytes);
  }

  /// Convert string to hex
  static String toHex(String input) {
    return input.runes.map((r) => r.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Convert hex back to string
  static String fromHex(String input) {
    return String.fromCharCodes(
      List.generate(input.length ~/ 2,
          (i) => int.parse(input.substring(i * 2, i * 2 + 2), radix: 16)),
    );
  }

  /// Generate a random salt (Fixed Length)
  static String generateSalt() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
        saltLength, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Encrypt Function
  static String encrypt(String input) {
    String salt = generateSalt(); // Generate a random salt
    String key = generateKey(salt); // Generate a dynamic key
    String encrypted = xorEncrypt(input, key); // XOR encrypt the data
    return salt + toHex(encrypted); // Merge salt and encrypted text
  }

  /// Decrypt Function (Extracts salt correctly)
  static String decrypt(String input) {
    if (input.length <= saltLength) return "";

    String salt = input.substring(0, saltLength); // Extract salt
    String encryptedHex = input.substring(saltLength); // Extract encrypted data

    String key = generateKey(salt); // Recreate the same key
    String decrypted = xorEncrypt(fromHex(encryptedHex), key); // XOR decrypt
    return decrypted;
  }
}

class EncryptDecryptUint8List {
  static const String secretKey = "dolphin"; // Base secret key
  static const int saltLength = 8; // Fixed salt length

  /// Generate a stronger key using SHA-256 + Salt
  static Uint8List generateKey(String salt) {
    final bytes = utf8.encode(secretKey + salt);
    final hash = sha256.convert(bytes).bytes;
    return Uint8List.fromList(hash.sublist(0, 32)); // 32-byte key
  }

  /// XOR Encrypt/Decrypt for Uint8List
  static Uint8List xorEncrypt(Uint8List data, Uint8List key) {
    final encrypted = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ key[i % key.length];
    }
    return encrypted;
  }

  /// Convert Uint8List to hex string
  static String toHex(Uint8List input) {
    return input.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Convert hex string to Uint8List
  static Uint8List fromHex(String hex) {
    final length = hex.length;
    final result = Uint8List(length ~/ 2);
    for (int i = 0; i < length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  /// Generate a random salt
  static String generateSalt() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      saltLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Encrypt Uint8List → returns hex string with salt
  static String encrypt(Uint8List data) {
    String salt = generateSalt();
    Uint8List key = generateKey(salt);
    Uint8List encrypted = xorEncrypt(data, key);
    return salt + toHex(encrypted); // Prefix salt + hex string
  }

  /// Decrypt from hex string with salt → returns Uint8List
  static Uint8List decrypt(String input) {
    if (input.length <= saltLength) return Uint8List(0);
    String salt = input.substring(0, saltLength);
    String hexData = input.substring(saltLength);
    Uint8List encrypted = fromHex(hexData);
    Uint8List key = generateKey(salt);
    return xorEncrypt(encrypted, key);
  }
}
