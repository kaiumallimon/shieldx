// =====================================================
// ShieldX Supabase Vault Service
// File: supabase_vault_service.dart
// =====================================================
// Description: Server-side operations with Supabase
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vault_item_model.dart';

class SupabaseVaultService {
  final SupabaseClient _supabase;

  SupabaseVaultService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  // =====================================================
  // CRUD Operations
  // =====================================================

  /// Create a new vault item in Supabase
  Future<VaultItem> createVaultItem(VaultItem item) async {
    try {
      final response = await _supabase
          .from('vault_items')
          .insert({
            'id': item.id,
            'user_id': item.userId,
            'title': item.title,
            'category': item.category.toJson(),
            'encrypted_payload': item.encryptedPayload,
            'website_url': item.websiteUrl,
            'notes_preview': item.notesPreview,
            'encryption_algorithm': item.encryptionAlgorithm,
            'encryption_key_hint': item.encryptionKeyHint,
            'nonce': item.nonce,
            'is_favorite': item.isFavorite,
            'is_deleted': item.isDeleted,
            'password_health': item.passwordHealth.toJson(),
            'icon_url': item.iconUrl,
            'icon_cached_at': item.iconCachedAt?.toIso8601String(),
            'created_at': item.createdAt.toIso8601String(),
            'updated_at': item.updatedAt.toIso8601String(),
            'last_used_at': item.lastUsedAt?.toIso8601String(),
            'deleted_at': item.deletedAt?.toIso8601String(),
            'version': item.version,
          })
          .select()
          .single();

      return VaultItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create vault item: $e');
    }
  }

  /// Get all vault items for current user
  Future<List<VaultItem>> getAllVaultItems() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((item) => VaultItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vault items: $e');
    }
  }

  /// Get vault item by ID
  Future<VaultItem?> getVaultItemById(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .maybeSingle();

      if (response == null) return null;
      return VaultItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch vault item: $e');
    }
  }

  /// Update vault item
  Future<VaultItem> updateVaultItem(VaultItem item) async {
    try {
      final response = await _supabase
          .from('vault_items')
          .update({
            'title': item.title,
            'category': item.category.toJson(),
            'encrypted_payload': item.encryptedPayload,
            'website_url': item.websiteUrl,
            'notes_preview': item.notesPreview,
            'nonce': item.nonce,
            'is_favorite': item.isFavorite,
            'password_health': item.passwordHealth.toJson(),
            'icon_url': item.iconUrl,
            'updated_at': DateTime.now().toIso8601String(),
            'last_used_at': item.lastUsedAt?.toIso8601String(),
            'version': item.version + 1,
          })
          .eq('id', item.id)
          .select()
          .single();

      return VaultItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vault item: $e');
    }
  }

  /// Soft delete vault item
  Future<void> deleteVaultItem(String id) async {
    try {
      await _supabase.from('vault_items').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vault item: $e');
    }
  }

  /// Permanently delete vault item
  Future<void> permanentlyDeleteVaultItem(String id) async {
    try {
      await _supabase.from('vault_items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to permanently delete vault item: $e');
    }
  }

  // =====================================================
  // Query Operations
  // =====================================================

  /// Search vault items
  Future<List<VaultItem>> searchVaultItems(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .or('title.ilike.%$query%,website_url.ilike.%$query%,notes_preview.ilike.%$query%')
          .order('updated_at', ascending: false);

      return (response as List)
          .map((item) => VaultItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search vault items: $e');
    }
  }

  /// Get vault items by category
  Future<List<VaultItem>> getVaultItemsByCategory(CredentialCategory category) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', userId)
          .eq('category', category.toJson())
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((item) => VaultItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vault items by category: $e');
    }
  }

  /// Get favorite vault items
  Future<List<VaultItem>> getFavoriteVaultItems() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((item) => VaultItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite vault items: $e');
    }
  }

  // =====================================================
  // Statistics & Analytics
  // =====================================================

  /// Get password health statistics
  Future<Map<String, int>> getPasswordHealthStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select('password_health')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      final stats = <String, int>{
        'strong': 0,
        'weak': 0,
        'reused': 0,
        'breached': 0,
        'expired': 0,
        'unknown': 0,
      };

      for (final item in response as List) {
        final health = item['password_health'] as String;
        stats[health] = (stats[health] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get password health stats: $e');
    }
  }

  /// Get category statistics
  Future<Map<String, int>> getCategoryStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select('category')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      final stats = <String, int>{};

      for (final item in response as List) {
        final category = item['category'] as String;
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get category stats: $e');
    }
  }

  /// Get total vault items count
  Future<int> getTotalItemsCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get total items count: $e');
    }
  }

  /// Get recently used items
  Future<List<VaultItem>> getRecentlyUsedItems({int limit = 10}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .not('last_used_at', 'is', null)
          .order('last_used_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => VaultItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recently used items: $e');
    }
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(String id) async {
    try {
      await _supabase.from('vault_items').update({
        'last_used_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update last used: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _supabase.from('vault_items').update({
        'is_favorite': isFavorite,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }
}
