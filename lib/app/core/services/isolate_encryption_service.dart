// =====================================================
// ShieldX Isolate Encryption Service
// File: isolate_encryption_service.dart
// =====================================================
// Description: Background encryption/decryption using
// isolates to prevent UI blocking
// =====================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/vault_item_model.dart';
import 'encryption_service.dart';

/// Result of encryption operation
class _EncryptionResult {
  final String encryptedPayload;
  final String nonce;

  _EncryptionResult(this.encryptedPayload, this.nonce);
}

/// Isolate-based encryption service for background processing
class IsolateEncryptionService {
  // =====================================================
  // Encryption Operations (Background)
  // =====================================================

  /// Encrypt payload in background isolate
  Future<_EncryptionResult> encryptPayloadInBackground({
    required String masterPassword,
    required VaultItemPayload payload,
  }) async {
    final result = await compute(_encryptPayloadIsolate, {
      'masterPassword': masterPassword,
      'payload': payload.toJson(),
    });
    return _EncryptionResult(result['encrypted'] as String, result['nonce'] as String);
  }

  /// Decrypt payload in background isolate
  Future<VaultItemPayload> decryptPayloadInBackground({
    required String masterPassword,
    required String encryptedPayload,
    required String nonce,
  }) async {
    final result = await compute(_decryptPayloadIsolate, {
      'masterPassword': masterPassword,
      'encryptedPayload': encryptedPayload,
      'nonce': nonce,
    });
    return VaultItemPayload.fromJson(result);
  }

  /// Encrypt multiple items in batch (background)
  Future<List<_EncryptionResult>> encryptBatchInBackground({
    required String masterPassword,
    required List<VaultItemPayload> payloads,
  }) async {
    final results = await compute(_encryptBatchIsolate, {
      'masterPassword': masterPassword,
      'payloads': payloads.map((p) => p.toJson()).toList(),
    });
    return (results as List).map((r) => _EncryptionResult(r['encrypted'] as String, r['nonce'] as String)).toList();
  }

  /// Decrypt multiple items in batch (background)
  Future<List<VaultItemPayload>> decryptBatchInBackground({
    required String masterPassword,
    required List<Map<String, String>> encryptedItems,
  }) async {
    final results = await compute(_decryptBatchIsolate, {
      'masterPassword': masterPassword,
      'items': encryptedItems,
    });
    return (results as List).map((r) => VaultItemPayload.fromJson(r)).toList();
  }

  // =====================================================
  // Synchronous Operations (Direct)
  // =====================================================

  /// Generate salt (fast operation, no isolate needed)
  String generateSalt() {
    return base64.encode(EncryptionService.generateSalt());
  }

  /// Generate nonce (fast operation, no isolate needed)
  String generateNonce() {
    return base64.encode(EncryptionService.generateNonce());
  }

  /// Generate secure password (fast operation)
  String generateSecurePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    return EncryptionService.generateSecurePassword(
      length: length,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSymbols: includeSymbols,
    );
  }

  // =====================================================
  // Static Isolate Entry Points
  // =====================================================

  static Future<Map<String, String>> _encryptPayloadIsolate(Map<String, dynamic> params) async {
    try {
      final masterPassword = params['masterPassword'] as String;
      final payloadJson = params['payload'] as Map<String, dynamic>;
      final payload = VaultItemPayload.fromJson(payloadJson);

      // Generate salt and derive key
      final salt = EncryptionService.generateSalt();
      final encryptionKey = await EncryptionService.deriveKeyArgon2(
        masterPassword: masterPassword,
        salt: salt,
      );

      // Generate nonce
      final nonce = EncryptionService.generateNonce();

      // Encrypt
      final encrypted = EncryptionService.encryptPayload(
        payload: payload,
        encryptionKey: encryptionKey,
        nonce: nonce,
      );

      return {
        'encrypted': encrypted,
        'nonce': base64.encode(nonce),
      };
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  static Future<Map<String, dynamic>> _decryptPayloadIsolate(Map<String, dynamic> params) async {
    try {
      final masterPassword = params['masterPassword'] as String;
      final encryptedPayload = params['encryptedPayload'] as String;
      final nonceBase64 = params['nonce'] as String;

      // Decode nonce
      final nonce = base64.decode(nonceBase64);

      // Derive key (need to use same salt from encryption)
      // For now, we'll extract salt from a hint or use a deterministic approach
      final salt = EncryptionService.generateSalt(); // TODO: Store salt with encrypted data
      final encryptionKey = await EncryptionService.deriveKeyArgon2(
        masterPassword: masterPassword,
        salt: salt,
      );

      // Decrypt
      final payload = EncryptionService.decryptPayload(
        encryptedPayload: encryptedPayload,
        encryptionKey: encryptionKey,
        nonce: nonce,
      );

      return payload.toJson();
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  static Future<List<Map<String, String>>> _encryptBatchIsolate(Map<String, dynamic> params) async {
    final masterPassword = params['masterPassword'] as String;
    final payloadsJson = params['payloads'] as List;
    final results = <Map<String, String>>[];

    // Generate salt once for batch
    final salt = EncryptionService.generateSalt();
    final encryptionKey = await EncryptionService.deriveKeyArgon2(
      masterPassword: masterPassword,
      salt: salt,
    );

    for (final payloadJson in payloadsJson) {
      final payload = VaultItemPayload.fromJson(payloadJson as Map<String, dynamic>);
      final nonce = EncryptionService.generateNonce();

      final encrypted = EncryptionService.encryptPayload(
        payload: payload,
        encryptionKey: encryptionKey,
        nonce: nonce,
      );

      results.add({
        'encrypted': encrypted,
        'nonce': base64.encode(nonce),
      });
    }

    return results;
  }

  static Future<List<Map<String, dynamic>>> _decryptBatchIsolate(Map<String, dynamic> params) async {
    final masterPassword = params['masterPassword'] as String;
    final items = params['items'] as List;
    final results = <Map<String, dynamic>>[];

    // Generate salt once for batch
    final salt = EncryptionService.generateSalt();
    final encryptionKey = await EncryptionService.deriveKeyArgon2(
      masterPassword: masterPassword,
      salt: salt,
    );

    for (final item in items) {
      final itemMap = item as Map<String, dynamic>;
      final encrypted = itemMap['encrypted'] as String;
      final nonceBase64 = itemMap['nonce'] as String;
      final nonce = base64.decode(nonceBase64);

      final payload = EncryptionService.decryptPayload(
        encryptedPayload: encrypted,
        encryptionKey: encryptionKey,
        nonce: nonce,
      );

      results.add(payload.toJson());
    }

    return results;
  }
}
