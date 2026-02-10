import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/core/services/encryption_service.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';

/// Widget that displays a decrypted title for a vault item
class DecryptedTitleWidget extends StatefulWidget {
  final VaultItem item;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const DecryptedTitleWidget({
    super.key,
    required this.item,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  State<DecryptedTitleWidget> createState() => _DecryptedTitleWidgetState();
}

class _DecryptedTitleWidgetState extends State<DecryptedTitleWidget> {
  final AuthStorageService _authStorage = AuthStorageService();
  String? _decryptedTitle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _decryptTitle();
  }

  @override
  void didUpdateWidget(DecryptedTitleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-decrypt if the item changed
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.title != widget.item.title ||
        oldWidget.item.updatedAt != widget.item.updatedAt) {
      setState(() {
        _isLoading = true;
      });
      _decryptTitle();
    }
  }

  Future<void> _decryptTitle() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('DecryptTitle: User not authenticated');
        setState(() {
          _decryptedTitle = 'Encrypted Item';
          _isLoading = false;
        });
        return;
      }

      print('DecryptTitle: Starting decryption for item ${widget.item.id}');
      print('DecryptTitle: Title length: ${widget.item.title.length}, Nonce length: ${widget.item.nonce.length}');

      // Check if this is old base64-only encrypted data (no proper nonce)
      if (widget.item.nonce.isEmpty || widget.item.nonce.length < 16) {
        print('DecryptTitle: Old format detected, using base64 fallback for: ${widget.item.id}');
        try {
          final decodedTitle = utf8.decode(base64Decode(widget.item.title));
          if (mounted) {
            setState(() {
              _decryptedTitle = decodedTitle;
              _isLoading = false;
            });
          }
          return;
        } catch (e) {
          // If base64 fails, try as plain text
          if (mounted) {
            setState(() {
              _decryptedTitle = widget.item.title;
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Try proper AES-256-GCM decryption
      try {
        final session = await _authStorage.getUserSession();
        final masterPassword = session?['userId'] ?? userId; // TODO: Use actual master password

        // The stored nonce is actually the salt used for key derivation
        final salt = EncryptionService.base64ToBytes(widget.item.nonce);
        final encryptionKey = await EncryptionService.deriveKeyArgon2(
          masterPassword: masterPassword,
          salt: salt,
        );

        // Use the same salt as nonce for AES-GCM (as done during encryption)
        final nonce = salt;

        // Decrypt title
        final titleKey = encrypt.Key(encryptionKey);
        final titleIv = encrypt.IV(nonce);
        final titleEncrypter = encrypt.Encrypter(
          encrypt.AES(titleKey, mode: encrypt.AESMode.gcm),
        );

        final encryptedTitleData = encrypt.Encrypted.fromBase64(widget.item.title);
        final decryptedBytes = titleEncrypter.decryptBytes(encryptedTitleData, iv: titleIv);
        final decryptedTitle = utf8.decode(decryptedBytes);

        print('DecryptTitle: Successfully decrypted - $decryptedTitle');

        if (mounted) {
          setState(() {
            _decryptedTitle = decryptedTitle;
            _isLoading = false;
          });
        }
        return;
      } catch (aesError) {
        print('DecryptTitle: AES decryption failed for ${widget.item.id}: $aesError');

        // Fallback: Try old base64 decoding for backwards compatibility
        try {
          final decodedTitle = utf8.decode(base64Decode(widget.item.title));
          if (mounted) {
            setState(() {
              _decryptedTitle = decodedTitle;
              _isLoading = false;
            });
          }
          return;
        } catch (base64Error) {
          // If both fail, just show the title as-is (might be plain text)
          if (mounted) {
            setState(() {
              _decryptedTitle = widget.item.title;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error decrypting title for ${widget.item.id}: $e');
      if (mounted) {
        setState(() {
          _decryptedTitle = widget.item.title.length > 20 ? 'Encrypted Item' : widget.item.title;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: widget.style?.fontSize ?? 16,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    return Text(
      _decryptedTitle ?? 'Encrypted Item',
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
