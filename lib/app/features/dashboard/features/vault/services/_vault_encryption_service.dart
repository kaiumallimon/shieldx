import 'dart:convert';
import 'package:shieldx/app/data/models/vault_item_model.dart';

/// Service for encrypting and decrypting vault item payloads
class VaultEncryptionService {
  /// Decrypt vault item payload
  /// Currently using base64 decoding, TODO: implement proper encryption
  static VaultItemPayload? decryptPayload(String encryptedPayload) {
    try {
      final decryptedBytes = base64Decode(encryptedPayload);
      final decryptedString = utf8.decode(decryptedBytes);
      final payloadJson = jsonDecode(decryptedString) as Map<String, dynamic>;
      return VaultItemPayload.fromJson(payloadJson);
    } catch (e) {
      // Return null if decryption fails
      return null;
    }
  }

  /// Encrypt vault item payload
  /// Currently using base64 encoding, TODO: implement proper encryption
  static String encryptPayload(VaultItemPayload payload) {
    final jsonString = jsonEncode(payload.toJson());
    final bytes = utf8.encode(jsonString);
    return base64Encode(bytes);
  }
}
