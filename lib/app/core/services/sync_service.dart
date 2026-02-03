// =====================================================
// ShieldX Sync Service
// File: sync_service.dart
// =====================================================
// Description: Offline-first bidirectional sync between
// local SQLite and Supabase with conflict resolution
// =====================================================

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/local_database.dart';
import '../../data/local/local_vault_repository.dart';
import '../../data/models/vault_item_model.dart';
import 'connection_monitor.dart';

/// Sync conflict resolution strategy
enum ConflictResolution {
  localWins,
  remoteWins,
  newestWins,
  manual,
}

/// Sync status
enum SyncStatus {
  idle,
  syncing,
  error,
}

/// Sync service for offline-first architecture
class SyncService {
  final SupabaseClient _supabase;
  final LocalVaultRepository _localRepo;
  final ConnectionMonitor _connectionMonitor;

  SyncStatus _syncStatus = SyncStatus.idle;
  Timer? _syncTimer;
  StreamSubscription? _realtimeSubscription;
  final ConflictResolution _conflictResolution = ConflictResolution.newestWins;

  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  SyncService({
    required SupabaseClient supabase,
    required LocalVaultRepository localRepo,
    required ConnectionMonitor connectionMonitor,
  })  : _supabase = supabase,
        _localRepo = localRepo,
        _connectionMonitor = connectionMonitor;

  /// Current sync status
  SyncStatus get syncStatus => _syncStatus;

  /// Sync status stream
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Error stream
  Stream<String> get errorStream => _errorController.stream;

  // =====================================================
  // Sync Initialization
  // =====================================================

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to connection changes
    _connectionMonitor.statusStream.listen((status) {
      if (status == ConnectionStatus.online) {
        _performSync();
      }
    });

    // Start periodic sync (when online)
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_connectionMonitor.isOnline) {
        _performSync();
      }
    });

    // Subscribe to realtime changes
    _subscribeToRealtimeChanges();

    // Perform initial sync
    if (_connectionMonitor.isOnline) {
      await _performSync();
    }
  }

  /// Dispose sync service
  void dispose() {
    _syncTimer?.cancel();
    _realtimeSubscription?.cancel();
    _statusController.close();
    _errorController.close();
  }

  // =====================================================
  // Sync Operations
  // =====================================================

  /// Perform full sync (local -> remote and remote -> local)
  Future<void> _performSync() async {
    if (_syncStatus == SyncStatus.syncing) return;

    try {
      _updateSyncStatus(SyncStatus.syncing);

      // Step 1: Push local changes to remote
      await _pushLocalChanges();

      // Step 2: Pull remote changes to local
      await _pullRemoteChanges();

      _updateSyncStatus(SyncStatus.idle);
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      _errorController.add('Sync failed: ${e.toString()}');
    }
  }

  /// Push local changes to Supabase
  Future<void> _pushLocalChanges() async {
    final pendingItems = await _localRepo.getPendingSyncItems();

    for (final item in pendingItems) {
      try {
        if (item.isDeleted) {
          // Delete from remote
          await _supabase.from('vault_items').delete().eq('id', item.id);
        } else {
          // Check if item exists on remote
          final existingData = await _supabase
              .from('vault_items')
              .select()
              .eq('id', item.id)
              .maybeSingle();

          if (existingData == null) {
            // Insert new item
            await _supabase.from('vault_items').insert(item.toJson());
          } else {
            // Update existing item with conflict resolution
            final remoteItem = VaultItem.fromJson(existingData);
            final resolvedItem = _resolveConflict(item, remoteItem);
            await _supabase.from('vault_items').update(resolvedItem.toJson()).eq('id', item.id);
          }
        }

        // Mark as synced
        await _localRepo.markAsSynced(item.id);
      } catch (e) {
        // Log error but continue with other items
        _errorController.add('Failed to sync item ${item.id}: ${e.toString()}');
      }
    }

    // Process sync queue
    await _processSyncQueue();
  }

  /// Pull remote changes to local
  Future<void> _pullRemoteChanges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get all remote items
      final remoteData = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      for (final data in remoteData) {
        final remoteItem = VaultItem.fromJson(data);
        final localItem = await _localRepo.getVaultItemById(remoteItem.id);

        if (localItem == null) {
          // New item from remote, insert locally
          await _localRepo.createVaultItem(remoteItem);
        } else {
          // Item exists locally, check for conflicts
          if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
            final resolvedItem = _resolveConflict(localItem, remoteItem);
            await _localRepo.updateVaultItem(resolvedItem);
          }
        }
      }
    } catch (e) {
      _errorController.add('Failed to pull remote changes: ${e.toString()}');
    }
  }

  /// Process sync queue operations
  Future<void> _processSyncQueue() async {
    final operations = await _localRepo.getPendingSyncOperations();

    for (final op in operations) {
      try {
        final tableName = op['table_name'] as String;
        final recordId = op['record_id'] as String;
        final operation = op['operation'] as String;

        switch (operation) {
          case 'insert':
          case 'update':
            // Already handled in _pushLocalChanges
            break;
          case 'delete':
            await _supabase.from(tableName).delete().eq('id', recordId);
            break;
        }

        await _localRepo.removeSyncOperation(op['id'] as int);
      } catch (e) {
        await _localRepo.updateSyncRetryCount(op['id'] as int, e.toString());
      }
    }
  }

  // =====================================================
  // Conflict Resolution
  // =====================================================

  /// Resolve sync conflict between local and remote items
  VaultItem _resolveConflict(VaultItem local, VaultItem remote) {
    switch (_conflictResolution) {
      case ConflictResolution.localWins:
        return local;
      case ConflictResolution.remoteWins:
        return remote;
      case ConflictResolution.newestWins:
        return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
      case ConflictResolution.manual:
        // TODO: Implement manual conflict resolution UI
        return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
    }
  }

  // =====================================================
  // Realtime Sync
  // =====================================================

  /// Subscribe to realtime changes from Supabase
  void _subscribeToRealtimeChanges() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _realtimeSubscription = _supabase
        .from('vault_items:user_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          _handleRealtimeUpdate(data);
        });
  }

  /// Handle realtime updates from Supabase
  Future<void> _handleRealtimeUpdate(List<Map<String, dynamic>> data) async {
    for (final itemData in data) {
      try {
        final remoteItem = VaultItem.fromJson(itemData);
        final localItem = await _localRepo.getVaultItemById(remoteItem.id);

        if (localItem == null) {
          // New item from remote
          await _localRepo.createVaultItem(remoteItem);
        } else {
          // Update existing item if remote is newer
          if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
            await _localRepo.updateVaultItem(remoteItem);
          }
        }
      } catch (e) {
        _errorController.add('Realtime update failed: ${e.toString()}');
      }
    }
  }

  // =====================================================
  // Manual Sync Controls
  // =====================================================

  /// Force sync now (manual trigger)
  Future<void> forceSyncNow() async {
    if (_connectionMonitor.isOffline) {
      _errorController.add('Cannot sync while offline');
      return;
    }
    await _performSync();
  }

  /// Clear all local data and re-sync from remote
  Future<void> resetAndResync() async {
    if (_connectionMonitor.isOffline) {
      _errorController.add('Cannot reset while offline');
      return;
    }

    try {
      _updateSyncStatus(SyncStatus.syncing);

      // Clear local database
      final db = await LocalDatabase().database;
      await db.delete('vault_items');
      await db.delete('sync_queue');

      // Pull all data from remote
      await _pullRemoteChanges();

      _updateSyncStatus(SyncStatus.idle);
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      _errorController.add('Reset failed: ${e.toString()}');
    }
  }

  // =====================================================
  // Helper Methods
  // =====================================================

  void _updateSyncStatus(SyncStatus status) {
    _syncStatus = status;
    _statusController.add(status);
  }
}
