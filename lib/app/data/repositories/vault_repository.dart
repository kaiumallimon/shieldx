// =====================================================
// ShieldX Zero-Knowledge Vault Repository
// File: vault_repository.dart
// =====================================================
// Description: Supabase repository layer for CRUD operations on vault items
// with client-side encryption/decryption. Server remains blind to content.
// =====================================================

import 'package:shieldx/app/core/services/encryption_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vault_item_model.dart';
import 'dart:typed_data';

// =====================================================
// REPOSITORY: VaultRepository
// =====================================================

class VaultRepository {
  final SupabaseClient _supabase;

  VaultRepository({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  // Table names
  static const String _vaultItemsTable = 'vault_items';

  // =====================================================
  // CREATE: Insert Encrypted Vault Item
  // =====================================================

  /// Creates a new vault item with client-side encryption
  Future<VaultItem> createVaultItem({
    required VaultItemPayload payload,
    required String title,
    required CredentialCategory category,
    required Uint8List encryptionKey,
    String? websiteUrl,
    String? notesPreview,
    PasswordHealthStatus? passwordHealth,
    bool? isFavorite,
  }) async {
    try {
      // Generate nonce for encryption
      final nonce = EncryptionService.generateNonce();

      // Encrypt payload client-side
      final encryptedPayload = EncryptionService.encryptPayload(
        payload: payload,
        encryptionKey: encryptionKey,
        nonce: nonce,
      );

      // Prepare data for server (only metadata + encrypted blob)
      final data = {
        'title': title,
        'category': category.name,
        'website_url': websiteUrl,
        'notes_preview': notesPreview,
        'encrypted_payload': encryptedPayload,
        'nonce': EncryptionService.bytesToBase64(nonce),
        'password_health': passwordHealth?.name ?? 'unknown',
        'is_favorite': isFavorite ?? false,
      };

      // Insert into Supabase (RLS ensures user can only insert own items)
      final response = await _supabase
          .from(_vaultItemsTable)
          .insert(data)
          .select()
          .single();

      return VaultItem.fromJson(response);
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to create vault item: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error creating vault item: $e',
      );
    }
  }

  // =====================================================
  // READ: Get All Vault Items (Encrypted)
  // =====================================================

  /// Retrieves all non-deleted vault items for current user
  /// Returns encrypted items (decryption happens client-side)
  Future<List<VaultItem>> getAllVaultItems({
    CredentialCategory? category,
    bool includeDeleted = false,
  }) async {
    try {
      // Build query with filters
      var queryBuilder = _supabase.from(_vaultItemsTable).select();

      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category.toJson());
      }

      if (!includeDeleted) {
        queryBuilder = queryBuilder.eq('is_deleted', false);
      }

      final response = await queryBuilder.order('updated_at', ascending: false);

      return (response as List)
          .map((json) => VaultItem.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to fetch vault items: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error fetching vault items: $e',
      );
    }
  }

  // =====================================================
  // READ: Get Single Vault Item by ID
  // =====================================================

  /// Retrieves a specific vault item by ID
  Future<VaultItem?> getVaultItemById(String id) async {
    try {
      final response = await _supabase
          .from(_vaultItemsTable)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return VaultItem.fromJson(response);
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to fetch vault item: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error fetching vault item: $e',
      );
    }
  }

  // =====================================================
  // READ: Search Vault Items by Title/URL
  // =====================================================

  /// Searches vault items by title or website URL (plain-text metadata)
  /// Full-text search using PostgreSQL's to_tsvector
  Future<List<VaultItem>> searchVaultItems(String query) async {
    try {
      // Search in title and website_url (plain-text metadata only)
      final response = await _supabase
          .from(_vaultItemsTable)
          .select()
          .or('title.ilike.%$query%,website_url.ilike.%$query%')
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => VaultItem.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to search vault items: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error searching vault items: $e',
      );
    }
  }

  // =====================================================
  // READ: Get Vault Items by Domain (Autofill)
  // =====================================================

  /// Retrieves vault items matching a specific domain for autofill
  Future<List<VaultItem>> getVaultItemsByDomain(String domain) async {
    try {
      final response = await _supabase
          .from(_vaultItemsTable)
          .select()
          .ilike('website_url', '%$domain%')
          .eq('is_deleted', false)
          .order('last_used_at', ascending: false);

      return (response as List)
          .map((json) => VaultItem.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to fetch vault items by domain: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error fetching vault items by domain: $e',
      );
    }
  }

  // =====================================================
  // READ: Get Favorite Vault Items
  // =====================================================

  /// Retrieves all favorite vault items
  Future<List<VaultItem>> getFavoriteVaultItems() async {
    try {
      final response = await _supabase
          .from(_vaultItemsTable)
          .select()
          .eq('is_favorite', true)
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => VaultItem.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to fetch favorite vault items: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error fetching favorite vault items: $e',
      );
    }
  }

  // =====================================================
  // READ: Get Recently Used Vault Items
  // =====================================================

  /// Retrieves recently used vault items (last 30 days)
  Future<List<VaultItem>> getRecentlyUsedVaultItems({int limit = 10}) async {
    try {
      final response = await _supabase
          .from(_vaultItemsTable)
          .select()
          .not('last_used_at', 'is', null)
          .eq('is_deleted', false)
          .order('last_used_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => VaultItem.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to fetch recently used vault items: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error fetching recently used vault items: $e',
      );
    }
  }

  // =====================================================
  // UPDATE: Update Encrypted Vault Item
  // =====================================================

  /// Updates a vault item with optional re-encryption
  Future<VaultItem> updateVaultItem({
    required String id,
    VaultItemPayload? newPayload,
    Uint8List? encryptionKey,
    String? title,
    CredentialCategory? category,
    String? websiteUrl,
    String? notesPreview,
    PasswordHealthStatus? passwordHealth,
    bool? isFavorite,
    bool? isDeleted,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      // Update plain-text metadata
      if (title != null) updates['title'] = title;
      if (category != null) updates['category'] = category.name;
      if (websiteUrl != null) updates['website_url'] = websiteUrl;
      if (notesPreview != null) updates['notes_preview'] = notesPreview;
      if (passwordHealth != null) {
        updates['password_health'] = passwordHealth.name;
      }
      if (isFavorite != null) updates['is_favorite'] = isFavorite;
      if (isDeleted != null) updates['is_deleted'] = isDeleted;

      // Re-encrypt payload if new content provided
      if (newPayload != null && encryptionKey != null) {
        final nonce = EncryptionService.generateNonce();
        final encryptedPayload = EncryptionService.encryptPayload(
          payload: newPayload,
          encryptionKey: encryptionKey,
          nonce: nonce,
        );
        updates['encrypted_payload'] = encryptedPayload;
        updates['nonce'] = EncryptionService.bytesToBase64(nonce);
      }

      // Update in Supabase (RLS ensures user can only update own items)
      final response = await _supabase
          .from(_vaultItemsTable)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return VaultItem.fromJson(response);
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to update vault item: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error updating vault item: $e',
      );
    }
  }

  // =====================================================
  // UPDATE: Toggle Favorite Status
  // =====================================================

  /// Toggles favorite status for a vault item
  Future<VaultItem> toggleFavorite(String id, bool isFavorite) async {
    return updateVaultItem(id: id, isFavorite: isFavorite);
  }

  // =====================================================
  // DELETE: Soft Delete Vault Item
  // =====================================================

  /// Soft deletes a vault item (moves to trash)
  Future<VaultItem> softDeleteVaultItem(String id) async {
    return updateVaultItem(id: id, isDeleted: true);
  }

  // =====================================================
  // DELETE: Restore Vault Item from Trash
  // =====================================================

  /// Restores a soft-deleted vault item
  Future<VaultItem> restoreVaultItem(String id) async {
    return updateVaultItem(id: id, isDeleted: false);
  }

  // =====================================================
  // DELETE: Permanently Delete Vault Item
  // =====================================================

  /// Permanently deletes a vault item (cannot be undone)
  Future<void> permanentlyDeleteVaultItem(String id) async {
    try {
      await _supabase.from(_vaultItemsTable).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to permanently delete vault item: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error deleting vault item: $e',
      );
    }
  }

  // =====================================================
  // BATCH: Bulk Operations
  // =====================================================

  /// Bulk soft delete vault items
  Future<void> bulkSoftDelete(List<String> ids) async {
    try {
      await _supabase
          .from(_vaultItemsTable)
          .update({'is_deleted': true})
          .inFilter('id', ids);
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to bulk delete vault items: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error bulk deleting vault items: $e',
      );
    }
  }

  /// Bulk update password health status
  Future<void> bulkUpdatePasswordHealth(
    Map<String, PasswordHealthStatus> updates,
  ) async {
    try {
      for (final entry in updates.entries) {
        await _supabase
            .from(_vaultItemsTable)
            .update({'password_health': entry.value.name})
            .eq('id', entry.key);
      }
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to bulk update password health: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error bulk updating password health: $e',
      );
    }
  }

  // =====================================================
  // REALTIME: Subscribe to Vault Changes
  // =====================================================

  /// Subscribes to realtime changes for cross-device sync
  RealtimeChannel subscribeToVaultChanges({
    required void Function(VaultItem) onInsert,
    required void Function(VaultItem) onUpdate,
    required void Function(String) onDelete,
  }) {
    final channel = _supabase
        .channel('vault_items_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _vaultItemsTable,
          callback: (payload) {
            final item = VaultItem.fromJson(payload.newRecord);
            onInsert(item);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _vaultItemsTable,
          callback: (payload) {
            final item = VaultItem.fromJson(payload.newRecord);
            onUpdate(item);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: _vaultItemsTable,
          callback: (payload) {
            final id = payload.oldRecord['id'] as String;
            onDelete(id);
          },
        )
        .subscribe();

    return channel;
  }

  // =====================================================
  // STATISTICS: Vault Analytics
  // =====================================================

  /// Gets vault statistics (item counts by category)
  Future<Map<CredentialCategory, int>> getVaultStatistics() async {
    try {
      final response = await _supabase
          .from(_vaultItemsTable)
          .select('category')
          .eq('is_deleted', false);

      final Map<CredentialCategory, int> stats = {};
      for (final item in response as List) {
        final category = CredentialCategory.values.firstWhere(
          (c) => c.name == item['category'],
          orElse: () => CredentialCategory.custom,
        );
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return stats;
    } on PostgrestException catch (e) {
      throw VaultRepositoryException(
        'Failed to fetch vault statistics: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw VaultRepositoryException(
        'Unexpected error fetching vault statistics: $e',
      );
    }
  }
}

// =====================================================
// EXCEPTION: VaultRepositoryException
// =====================================================

class VaultRepositoryException implements Exception {
  final String message;
  final String? code;

  VaultRepositoryException(this.message, {this.code});

  @override
  String toString() => 'VaultRepositoryException: $message (code: $code)';
}
