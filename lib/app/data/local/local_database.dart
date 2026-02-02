// =====================================================
// ShieldX Local Database
// File: local_database.dart
// =====================================================
// Description: SQLite database with SQLCipher encryption
// for offline-first password storage
// =====================================================

import 'dart:async';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

/// Local database manager with SQLCipher encryption
class LocalDatabase {
  static LocalDatabase? _instance;
  static Database? _database;

  LocalDatabase._();

  factory LocalDatabase() {
    _instance ??= LocalDatabase._();
    return _instance!;
  }

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with encryption
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'shieldx_vault.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: 'your-secure-database-password', // TODO: Derive from user's master password
    );
  }

  /// Create database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vault_items (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        encrypted_payload TEXT NOT NULL,
        website_url TEXT,
        notes_preview TEXT,
        encryption_algorithm TEXT DEFAULT 'AES-256-GCM',
        encryption_key_hint TEXT,
        nonce TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        password_health TEXT DEFAULT 'unknown',
        icon_url TEXT,
        icon_cached_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_used_at TEXT,
        deleted_at TEXT,
        sync_status TEXT DEFAULT 'pending',
        last_synced_at TEXT,
        version INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE usage_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        vault_item_id TEXT NOT NULL,
        app_package_name TEXT,
        app_bundle_id TEXT,
        website_domain TEXT,
        page_url TEXT,
        action_type TEXT NOT NULL,
        device_info TEXT,
        used_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (vault_item_id) REFERENCES vault_items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE security_alerts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        vault_item_id TEXT,
        alert_type TEXT NOT NULL,
        severity TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        metadata TEXT,
        status TEXT DEFAULT 'unread',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        resolved_at TEXT,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (vault_item_id) REFERENCES vault_items (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_vault_user_id ON vault_items(user_id)');
    await db.execute('CREATE INDEX idx_vault_category ON vault_items(category)');
    await db.execute('CREATE INDEX idx_vault_url ON vault_items(website_url)');
    await db.execute('CREATE INDEX idx_vault_sync_status ON vault_items(sync_status)');
    await db.execute('CREATE INDEX idx_usage_vault_item ON usage_history(vault_item_id)');
    await db.execute('CREATE INDEX idx_alerts_user_id ON security_alerts(user_id)');
    await db.execute('CREATE INDEX idx_alerts_status ON security_alerts(status)');
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue(table_name, record_id)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle schema migrations here
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Reset database (for testing/development)
  Future<void> reset() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'shieldx_vault.db');
    await deleteDatabase(path);
    _database = null;
  }
}
