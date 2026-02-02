// =====================================================
// ShieldX Offline-First Vault Repository (Unified)
// File: offline_vault_repository.dart
// =====================================================
// Description: Unified repository that handles both
// local and remote operations with offline-first priority
// =====================================================

import '../local/local_vault_repository.dart';
import '../models/vault_item_model.dart';
import '../../core/services/isolate_encryption_service.dart';

/// Unified offline-first vault repository
class OfflineVaultRepository {
  final LocalVaultRepository _localRepo;
  final IsolateEncryptionService _encryptionService;

  OfflineVaultRepository({
    required LocalVaultRepository localRepo,
    required IsolateEncryptionService encryptionService,
  })  : _localRepo = localRepo,
        _encryptionService = encryptionService;

  // =====================================================
  // CRUD Operations (Offline-First)
  // =====================================================

  /// Create a new vault item (offline-first)
  Future<VaultItem> createVaultItem({
    required String userId,
    required String masterPassword,
    required CreateVaultItemDto dto,
  }) async {
    // Encrypt payload in background
    final encryptionResult = await _encryptionService.encryptPayloadInBackground(
      masterPassword: masterPassword,
      payload: VaultItemPayload(
        username: dto.title, // Placeholder, should be actual payload
        password: '', // Placeholder
      ),
    );

    // Create vault item
    final item = VaultItem(
      id: _generateId(),
      userId: userId,
      title: dto.title,
      category: dto.category,
      encryptedPayload: encryptionResult.encryptedPayload,
      nonce: encryptionResult.nonce,
      websiteUrl: dto.websiteUrl,
      notesPreview: dto.notesPreview,
      isFavorite: dto.isFavorite ?? false,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 1,
    );

    // Save to local database first (offline-first)
    await _localRepo.createVaultItem(item);

    // Add to sync queue
    await _localRepo.addToSyncQueue('vault_items', item.id, 'insert', item.toJson());

    return item;
  }

  /// Get all vault items (from local database)
  Future<List<VaultItem>> getAllVaultItems(String userId) async {
    return await _localRepo.getAllVaultItems(userId);
  }

  /// Get a single vault item by ID
  Future<VaultItem?> getVaultItemById(String id) async {
    return await _localRepo.getVaultItemById(id);
  }

  /// Get vault item with decrypted payload
  Future<VaultItemWithDecrypted?> getVaultItemWithDecrypted({
    required String id,
    required String masterPassword,
  }) async {
    final item = await _localRepo.getVaultItemById(id);
    if (item == null) return null;

    // Decrypt in background
    final payload = await _encryptionService.decryptPayloadInBackground(
      masterPassword: masterPassword,
      encryptedPayload: item.encryptedPayload,
      nonce: item.nonce,
    );

    return VaultItemWithDecrypted(
      vaultItem: item,
      decryptedPayload: payload,
    );
  }

  /// Update a vault item
  /// Note: dto should already contain encrypted payload if provided
  Future<void> updateVaultItem({
    required String itemId,
    required UpdateVaultItemDto dto,
  }) async {
    final existingItem = await _localRepo.getVaultItemById(itemId);
    if (existingItem == null) {
      throw Exception('Vault item not found');
    }

    // Create updated item
    final updatedItem = VaultItem(
      id: existingItem.id,
      userId: existingItem.userId,
      title: dto.title ?? existingItem.title,
      category: dto.category ?? existingItem.category,
      encryptedPayload: dto.encryptedPayload ?? existingItem.encryptedPayload,
      nonce: dto.nonce ?? existingItem.nonce,
      websiteUrl: dto.websiteUrl ?? existingItem.websiteUrl,
      notesPreview: dto.notesPreview ?? existingItem.notesPreview,
      isFavorite: dto.isFavorite ?? existingItem.isFavorite,
      isDeleted: dto.isDeleted ?? existingItem.isDeleted,
      passwordHealth: dto.passwordHealth ?? existingItem.passwordHealth,
      iconUrl: existingItem.iconUrl,
      iconCachedAt: existingItem.iconCachedAt,
      createdAt: existingItem.createdAt,
      updatedAt: DateTime.now(),
      lastUsedAt: existingItem.lastUsedAt,
      deletedAt: dto.isDeleted == true ? DateTime.now() : existingItem.deletedAt,
      version: existingItem.version + 1,
    );

    // Update local database
    await _localRepo.updateVaultItem(updatedItem);

    // Add to sync queue
    await _localRepo.addToSyncQueue('vault_items', itemId, 'update', updatedItem.toJson());
  }

  /// Delete a vault item (soft delete)
  Future<void> deleteVaultItem(String id) async {
    await _localRepo.deleteVaultItem(id);
    await _localRepo.addToSyncQueue('vault_items', id, 'delete', null);
  }

  /// Permanently delete a vault item
  Future<void> permanentlyDeleteVaultItem(String id) async {
    await _localRepo.permanentlyDeleteVaultItem(id);
    await _localRepo.addToSyncQueue('vault_items', id, 'delete', null);
  }

  // =====================================================
  // Search & Filter Operations
  // =====================================================

  /// Search vault items
  Future<List<VaultItem>> searchVaultItems(String userId, String query) async {
    return await _localRepo.searchVaultItems(userId, query);
  }

  /// Get vault items by category
  Future<List<VaultItem>> getVaultItemsByCategory(String userId, CredentialCategory category) async {
    return await _localRepo.getVaultItemsByCategory(userId, category);
  }

  /// Get favorite vault items
  Future<List<VaultItem>> getFavoriteVaultItems(String userId) async {
    return await _localRepo.getFavoriteVaultItems(userId);
  }

  /// Get vault items by domain
  Future<List<VaultItem>> getVaultItemsByDomain(String userId, String domain) async {
    return await _localRepo.getVaultItemsByDomain(userId, domain);
  }

  // =====================================================
  // Batch Operations
  // =====================================================

  /// Get multiple vault items with decrypted payloads
  Future<List<VaultItemWithDecrypted>> getVaultItemsWithDecrypted({
    required List<String> ids,
    required String masterPassword,
  }) async {
    final items = <VaultItem>[];
    for (final id in ids) {
      final item = await _localRepo.getVaultItemById(id);
      if (item != null) items.add(item);
    }

    // Decrypt all payloads in batch (background)
    final encryptedItems = items.map((i) => {'encrypted': i.encryptedPayload, 'nonce': i.nonce}).toList();
    final decryptedPayloads = await _encryptionService.decryptBatchInBackground(
      masterPassword: masterPassword,
      encryptedItems: encryptedItems,
    );

    return List.generate(
      items.length,
      (i) => VaultItemWithDecrypted(
        vaultItem: items[i],
        decryptedPayload: decryptedPayloads[i],
      ),
    );
  }

  // =====================================================
  // Usage Tracking
  // =====================================================

  /// Update last used timestamp
  Future<void> updateLastUsed(String id) async {
    await _localRepo.updateLastUsed(id);
  }

  // =====================================================
  // Helper Methods
  // =====================================================

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
           DateTime.now().microsecondsSinceEpoch.toString();
  }
}
