// =====================================================
// ShieldX Zero-Knowledge Encryption Service
// File: encryption_service.dart
// =====================================================
// Description: Client-side encryption/decryption service using AES-256-GCM
// with Argon2/PBKDF2 key derivation. Server never has access to keys.
// =====================================================

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';
import '../../data/models/vault_item_model.dart';

// =====================================================
// SERVICE: EncryptionService
// =====================================================

class EncryptionService {
  static const int _keyLength = 32; // 256 bits for AES-256
  static const int _nonceLength = 12; // 96 bits for GCM (recommended)
  static const int _saltLength = 32; // 256 bits for salt
  static const int _iterationCount = 100000; // PBKDF2 iterations
  static const int _argon2Iterations = 3; // Argon2 time cost
  static const int _argon2Memory = 65536; // Argon2 memory cost (64 MB)
  static const int _argon2Parallelism = 4; // Argon2 parallelism

  // =====================================================
  // KEY DERIVATION: Argon2id (Recommended)
  // =====================================================

  /// Derives encryption key from master password using Argon2id
  /// Most secure option, resistant to GPU/ASIC attacks
  static Future<Uint8List> deriveKeyArgon2({
    required String masterPassword,
    required Uint8List salt,
    int iterations = _argon2Iterations,
    int memory = _argon2Memory,
    int parallelism = _argon2Parallelism,
  }) async {
    final argon2 = Argon2BytesGenerator()
      ..init(
        Argon2Parameters(
          Argon2Parameters.ARGON2_id,
          salt,
          desiredKeyLength: _keyLength,
          iterations: iterations,
          memory: memory,
          lanes: parallelism,
        ),
      );

    final passwordBytes = Uint8List.fromList(utf8.encode(masterPassword));
    return argon2.process(passwordBytes);
  }

  // =====================================================
  // KEY DERIVATION: PBKDF2 (Fallback)
  // =====================================================

  /// Derives encryption key from master password using PBKDF2-SHA512
  /// Fallback option for platforms without Argon2 support
  static Uint8List deriveKeyPBKDF2({
    required String masterPassword,
    required Uint8List salt,
    int iterations = _iterationCount,
  }) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128))
      ..init(Pbkdf2Parameters(salt, iterations, _keyLength));

    final passwordBytes = Uint8List.fromList(utf8.encode(masterPassword));
    return pbkdf2.process(passwordBytes);
  }

  // =====================================================
  // ENCRYPTION: AES-256-GCM
  // =====================================================

  /// Encrypts payload using AES-256-GCM with authenticated encryption
  /// Returns base64-encoded ciphertext
  static String encryptPayload({
    required VaultItemPayload payload,
    required Uint8List encryptionKey,
    required Uint8List nonce,
  }) {
    // Serialize payload to JSON
    final jsonString = jsonEncode(payload.toJson());
    final plaintext = utf8.encode(jsonString);

    // Create AES-GCM cipher
    final key = encrypt.Key(encryptionKey);
    final iv = encrypt.IV(nonce);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );

    // Encrypt with authentication
    final encrypted = encrypter.encryptBytes(plaintext, iv: iv);

    // Return base64-encoded ciphertext (includes auth tag)
    return encrypted.base64;
  }

  // =====================================================
  // DECRYPTION: AES-256-GCM
  // =====================================================

  /// Decrypts payload using AES-256-GCM with authentication verification
  /// Throws exception if authentication fails (tampered data)
  static VaultItemPayload decryptPayload({
    required String encryptedPayload,
    required Uint8List encryptionKey,
    required Uint8List nonce,
  }) {
    try {
      // Create AES-GCM cipher
      final key = encrypt.Key(encryptionKey);
      final iv = encrypt.IV(nonce);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      // Decrypt with authentication verification
      final encrypted = encrypt.Encrypted.fromBase64(encryptedPayload);
      final decrypted = encrypter.decryptBytes(encrypted, iv: iv);

      // Parse JSON
      final jsonString = utf8.decode(decrypted);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return VaultItemPayload.fromJson(json);
    } catch (e) {
      throw EncryptionException(
        'Failed to decrypt payload: Authentication failed or corrupted data',
        originalError: e,
      );
    }
  }

  // =====================================================
  // UTILITIES: Random Generation
  // =====================================================

  /// Generates cryptographically secure random nonce (12 bytes)
  static Uint8List generateNonce() {
    final random = FortunaRandom();
    final seed = _generateSeed();
    random.seed(KeyParameter(seed));

    final nonce = Uint8List(_nonceLength);
    for (int i = 0; i < _nonceLength; i++) {
      nonce[i] = random.nextUint8();
    }
    return nonce;
  }

  /// Generates cryptographically secure random salt (32 bytes)
  static Uint8List generateSalt() {
    final random = FortunaRandom();
    final seed = _generateSeed();
    random.seed(KeyParameter(seed));

    final salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      salt[i] = random.nextUint8();
    }
    return salt;
  }

  /// Generates secure random seed for RNG
  static Uint8List _generateSeed() {
    final random = Random.secure();
    final seed = Uint8List(32);
    for (int i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    return seed;
  }

  // =====================================================
  // UTILITIES: Encoding/Decoding
  // =====================================================

  /// Converts byte array to base64 string
  static String bytesToBase64(Uint8List bytes) {
    return base64.encode(bytes);
  }

  /// Converts base64 string to byte array
  static Uint8List base64ToBytes(String base64String) {
    return base64.decode(base64String);
  }

  /// Converts byte array to hex string
  static String bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Converts hex string to byte array
  static Uint8List hexToBytes(String hex) {
    return Uint8List.fromList(
      List.generate(
        hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
  }

  // =====================================================
  // PASSWORD UTILITIES: Strength Analysis
  // =====================================================

  /// Analyzes password strength (client-side only, never sent to server)
  static PasswordHealthStatus analyzePasswordStrength(String password) {
    if (password.isEmpty) return PasswordHealthStatus.unknown;

    int score = 0;

    // Length check
    if (password.length >= 12) score += 2;
    if (password.length >= 16) score += 1;
    if (password.length < 8) return PasswordHealthStatus.weak;

    // Character diversity
    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    if (RegExp(r'\d').hasMatch(password)) score += 1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 2;

    // Common patterns (weakness indicators)
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score -= 2; // Repeated chars
    if (RegExp(r'(abc|123|qwerty)', caseSensitive: false).hasMatch(password)) {
      score -= 3; // Common sequences
    }

    // Score to status
    if (score >= 7) return PasswordHealthStatus.strong;
    if (score >= 4) return PasswordHealthStatus.unknown;
    return PasswordHealthStatus.weak;
  }

  /// Generates cryptographically secure password
  static String generateSecurePassword({
    int length = 20,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String charset = '';
    if (includeLowercase) charset += lowercase;
    if (includeUppercase) charset += uppercase;
    if (includeNumbers) charset += numbers;
    if (includeSymbols) charset += symbols;

    if (charset.isEmpty) charset = lowercase;

    final random = Random.secure();
    final password = List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();

    return password;
  }

  // =====================================================
  // HASH UTILITIES: Password Breach Checking (HIBP)
  // =====================================================

  /// Computes SHA-1 hash of password for HIBP k-anonymity model
  /// Returns first 5 chars (prefix) for API query
  static String computePasswordHashPrefix(String password) {
    final bytes = utf8.encode(password);
    final hash = sha1.convert(bytes);
    final hashString = hash.toString().toUpperCase();
    return hashString.substring(0, 5);
  }

  /// Computes full SHA-1 hash suffix for local matching
  static String computePasswordHashSuffix(String password) {
    final bytes = utf8.encode(password);
    final hash = sha1.convert(bytes);
    final hashString = hash.toString().toUpperCase();
    return hashString.substring(5);
  }
}

// =====================================================
// EXCEPTION: EncryptionException
// =====================================================

class EncryptionException implements Exception {
  final String message;
  final Object? originalError;

  EncryptionException(this.message, {this.originalError});

  @override
  String toString() => 'EncryptionException: $message';
}

// =====================================================
// MODEL: EncryptionMetadata
// =====================================================
// Stores encryption-related metadata for vault items

class EncryptionMetadata {
  final String algorithm;
  final String nonce;
  final String? keyHint;
  final DateTime encryptedAt;

  EncryptionMetadata({
    this.algorithm = 'AES-256-GCM',
    required this.nonce,
    this.keyHint,
    DateTime? encryptedAt,
  }) : encryptedAt = encryptedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'algorithm': algorithm,
        'nonce': nonce,
        'key_hint': keyHint,
        'encrypted_at': encryptedAt.toIso8601String(),
      };

  factory EncryptionMetadata.fromJson(Map<String, dynamic> json) {
    return EncryptionMetadata(
      algorithm: json['algorithm'] as String? ?? 'AES-256-GCM',
      nonce: json['nonce'] as String,
      keyHint: json['key_hint'] as String?,
      encryptedAt: json['encrypted_at'] != null
          ? DateTime.parse(json['encrypted_at'] as String)
          : DateTime.now(),
    );
  }
}
