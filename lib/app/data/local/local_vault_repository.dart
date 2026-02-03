// =====================================================
// ShieldX Local Vault Repository
// File: local_vault_repository.dart
// =====================================================
// Description: Local CRUD operations for vault items
// with offline-first support
// =====================================================

import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../models/vault_item_model.dart';
import 'local_database.dart';

/// Local repository for vault items (offline-first)
class LocalVaultRepository {
  final LocalDatabase _localDb;

  LocalVaultRepository(this._localDb);

  // =====================================================
  // CRUD Operations
  // =====================================================

  /// Create a new vault item locally
  Future<void> createVaultItem(VaultItem item) async {
    final db = await _localDb.database;
    await db.insert(
      'vault_items',
      _vaultItemToMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all vault items for a user
  Future<List<VaultItem>> getAllVaultItems(String userId) async {
    final db = await _localDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_items',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => _vaultItemFromMap(map)).toList();
  }

  /// Get a single vault item by ID
  Future<VaultItem?> getVaultItemById(String id) async {
    final db = await _localDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_items',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _vaultItemFromMap(maps.first);
  }

  /// Update a vault item
  Future<void> updateVaultItem(VaultItem item) async {
    final db = await _localDb.database;
    await db.update(
      'vault_items',
      _vaultItemToMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Soft delete a vault item
  Future<void> deleteVaultItem(String id) async {
    final db = await _localDb.database;
    await db.update(
      'vault_items',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard delete a vault item (permanently remove)
  Future<void> permanentlyDeleteVaultItem(String id) async {
    final db = await _localDb.database;
    await db.delete(
      'vault_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Search vault items
  Future<List<VaultItem>> searchVaultItems(String userId, String query) async {
    final db = await _localDb.database;
    final searchQuery = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_items',
      where: 'user_id = ? AND is_deleted = 0 AND (title LIKE ? OR website_url LIKE ? OR notes_preview LIKE ?)',
      whereArgs: [userId, searchQuery, searchQuery, searchQuery],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => _vaultItemFromMap(map)).toList();
  }

  /// Get vault items by category
  Future<List<VaultItem>> getVaultItemsByCategory(String userId, CredentialCategory category) async {
    final db = await _localDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_items',
      where: 'user_id = ? AND category = ? AND is_deleted = 0',
      whereArgs: [userId, category.toJson()],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => _vaultItemFromMap(map)).toList();
  }

  /// Get favorite vault items
  Future<List<VaultItem>> getFavoriteVaultItems(String userId) async {
    final db = await _localDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_items',
      where: 'user_id = ? AND is_favorite = 1 AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => _vaultItemFromMap(map)).toList();
  }

  /// Get vault items by domain
  Future<List<VaultItem>> getVaultItemsByDomain(String userId, String domain) async {
    final db = await _localDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_items',
      where: 'user_id = ? AND website_url LIKE ? AND is_deleted = 0',
      whereArgs: [userId, '%$domain%'],
      orderBy: 'last_used_at DESC',
    );
    return maps.map((map) => _vaultItemFromMap(map)).toList();
  }

  /// Get items pending sync
  Future<List<VaultItem>> getPendingSyncItems() async {
    final db = await _localDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_items',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'updated_at ASC',
    );
    return maps.map((map) => _vaultItemFromMap(map)).toList();
  }

  /// Mark item as synced
  Future<void> markAsSynced(String id) async {
    final db = await _localDb.database;
    await db.update(
      'vault_items',
      {
        'sync_status': 'synced',
        'last_synced_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(String id) async {
    final db = await _localDb.database;
    await db.rawUpdate(
      'UPDATE vault_items SET last_used_at = ?, use_count = use_count + 1 WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  // =====================================================
  // Sync Queue Operations
  // =====================================================

  /// Add operation to sync queue
  Future<void> addToSyncQueue(String tableName, String recordId, String operation, Map<String, dynamic>? data) async {
    final db = await _localDb.database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  /// Get pending sync operations
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    final db = await _localDb.database;
    return await db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
      limit: 50,
    );
  }

  /// Remove sync operation
  Future<void> removeSyncOperation(int id) async {
    final db = await _localDb.database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update sync operation retry count
  Future<void> updateSyncRetryCount(int id, String error) async {
    final db = await _localDb.database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1, last_error = ? WHERE id = ?',
      [error, id],
    );
  }

  // =====================================================
  // Helper Methods
  // =====================================================

  Map<String, dynamic> _vaultItemToMap(VaultItem item) {
    return {
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
      'is_favorite': item.isFavorite ? 1 : 0,
      'is_deleted': item.isDeleted ? 1 : 0,
      'password_health': item.passwordHealth.toJson(),
      'icon_url': item.iconUrl,
      'icon_cached_at': item.iconCachedAt?.toIso8601String(),
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
      'last_used_at': item.lastUsedAt?.toIso8601String(),
      'deleted_at': item.deletedAt?.toIso8601String(),
      'sync_status': 'pending',
      'version': item.version,
    };
  }

  VaultItem _vaultItemFromMap(Map<String, dynamic> map) {
    return VaultItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      category: CredentialCategory.fromJson(map['category'] as String),
      encryptedPayload: map['encrypted_payload'] as String,
      websiteUrl: map['website_url'] as String?,
      notesPreview: map['notes_preview'] as String?,
      encryptionAlgorithm: map['encryption_algorithm'] as String? ?? 'AES-256-GCM',
      encryptionKeyHint: map['encryption_key_hint'] as String?,
      nonce: map['nonce'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
      isDeleted: (map['is_deleted'] as int) == 1,
      passwordHealth: PasswordHealthStatus.fromJson(map['password_health'] as String? ?? 'unknown'),
      iconUrl: map['icon_url'] as String?,
      iconCachedAt: map['icon_cached_at'] != null ? DateTime.parse(map['icon_cached_at'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastUsedAt: map['last_used_at'] != null ? DateTime.parse(map['last_used_at'] as String) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      version: map['version'] as int? ?? 1,
    );
  }
}
