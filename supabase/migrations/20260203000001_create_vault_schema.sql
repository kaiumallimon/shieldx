-- =====================================================
-- ShieldX Zero-Knowledge Vault Schema
-- Migration: Core Vault Items Table
-- =====================================================
-- Description: This migration creates the foundational vault_items table
-- that stores encrypted credentials with zero-knowledge architecture.
-- Plain-text metadata enables fast searching/filtering while sensitive
-- data remains encrypted on client-side only.
-- =====================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ENUMS: Type Definitions
-- =====================================================

-- Credential category types (plain-text for UI/filtering)
CREATE TYPE credential_category AS ENUM (
    'login',
    'credit_card',
    'identity',
    'secure_note',
    'api_key',
    'bank_account',
    'crypto_wallet',
    'ssh_key',
    'license',
    'custom'
);

-- Password health status (computed client-side, stored for monitoring)
CREATE TYPE password_health_status AS ENUM (
    'strong',
    'weak',
    'reused',
    'breached',
    'expired',
    'unknown'
);

-- =====================================================
-- TABLE: vault_items
-- =====================================================
-- Core table storing encrypted credentials with ZKE principles:
-- - Plain-text: title, website_url, category (for indexing/UI)
-- - Encrypted: encrypted_payload (Base64 AES-256-GCM blob)
-- - Client generates all encryption keys from master password
-- - Server never sees decrypted content
-- =====================================================

CREATE TABLE vault_items (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Plain-text metadata (for searching, sorting, UI display)
    title VARCHAR(255) NOT NULL,
    category credential_category NOT NULL DEFAULT 'login',
    website_url TEXT,  -- URL for autofill matching & Brandfetch icons
    notes_preview TEXT,  -- First 100 chars of notes (non-sensitive)

    -- Encrypted payload (Base64-encoded AES-256-GCM ciphertext)
    -- Contains JSON with username, password, custom fields, full notes
    encrypted_payload TEXT NOT NULL,

    -- Encryption metadata (client-generated, never includes actual keys)
    encryption_algorithm VARCHAR(50) NOT NULL DEFAULT 'AES-256-GCM',
    encryption_key_hint VARCHAR(100),  -- Optional hint for key derivation version
    nonce TEXT NOT NULL,  -- Initialization vector for AES-GCM

    -- Security & monitoring metadata
    password_health password_health_status DEFAULT 'unknown',
    is_favorite BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,  -- Soft delete for trash functionality

    -- Icon caching (Brandfetch API optimization)
    icon_url TEXT,  -- Cached icon URL from Brandfetch
    icon_cached_at TIMESTAMPTZ,  -- When icon was last fetched

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_used_at TIMESTAMPTZ,  -- Track usage for sorting by "recently used"
    deleted_at TIMESTAMPTZ,  -- When item was soft-deleted

    -- Version control for sync conflict resolution
    version INTEGER NOT NULL DEFAULT 1,

    -- Constraints
    CONSTRAINT vault_items_user_id_check CHECK (user_id IS NOT NULL),
    CONSTRAINT vault_items_encrypted_payload_check CHECK (LENGTH(encrypted_payload) > 0)
);

-- =====================================================
-- INDEXES: Performance Optimization
-- =====================================================

-- Primary lookup indexes (optimized for common queries)
CREATE INDEX idx_vault_items_user_id ON vault_items(user_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_vault_items_category ON vault_items(user_id, category) WHERE is_deleted = FALSE;
CREATE INDEX idx_vault_items_created_at ON vault_items(user_id, created_at DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_vault_items_updated_at ON vault_items(user_id, updated_at DESC) WHERE is_deleted = FALSE;

-- Full-text search on plain-text metadata
CREATE INDEX idx_vault_items_title_search ON vault_items USING gin(to_tsvector('english', title)) WHERE is_deleted = FALSE;
CREATE INDEX idx_vault_items_website_url ON vault_items(user_id, website_url) WHERE is_deleted = FALSE AND website_url IS NOT NULL;

-- Favorite items (frequently accessed)
CREATE INDEX idx_vault_items_favorites ON vault_items(user_id, is_favorite) WHERE is_deleted = FALSE AND is_favorite = TRUE;

-- Recently used items (for autofill priority)
CREATE INDEX idx_vault_items_last_used ON vault_items(user_id, last_used_at DESC NULLS LAST) WHERE is_deleted = FALSE;

-- Trash/deleted items
CREATE INDEX idx_vault_items_deleted ON vault_items(user_id, deleted_at) WHERE is_deleted = TRUE;

-- Security monitoring (items needing attention)
CREATE INDEX idx_vault_items_password_health ON vault_items(user_id, password_health) WHERE is_deleted = FALSE AND password_health IN ('weak', 'reused', 'breached');

-- =====================================================
-- FUNCTIONS: Automatic Timestamp Updates
-- =====================================================

CREATE OR REPLACE FUNCTION update_vault_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_vault_items_updated_at
    BEFORE UPDATE ON vault_items
    FOR EACH ROW
    EXECUTE FUNCTION update_vault_items_updated_at();

-- =====================================================
-- FUNCTIONS: Soft Delete Management
-- =====================================================

CREATE OR REPLACE FUNCTION soft_delete_vault_item()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE THEN
        NEW.deleted_at = NOW();
    ELSIF NEW.is_deleted = FALSE AND OLD.is_deleted = TRUE THEN
        NEW.deleted_at = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_vault_items_soft_delete
    BEFORE UPDATE OF is_deleted ON vault_items
    FOR EACH ROW
    EXECUTE FUNCTION soft_delete_vault_item();

-- =====================================================
-- COMMENTS: Documentation
-- =====================================================

COMMENT ON TABLE vault_items IS 'Zero-knowledge encrypted credential storage. Sensitive data stored in encrypted_payload, plain-text metadata for indexing only.';
COMMENT ON COLUMN vault_items.encrypted_payload IS 'Base64-encoded AES-256-GCM ciphertext containing JSON with sensitive fields (username, password, custom fields). Server never decrypts this.';
COMMENT ON COLUMN vault_items.nonce IS 'AES-GCM initialization vector (IV) for decryption. Generated client-side, unique per encryption operation.';
COMMENT ON COLUMN vault_items.website_url IS 'Plain-text URL for autofill matching and Brandfetch icon fetching. Does not contain sensitive data.';
COMMENT ON COLUMN vault_items.password_health IS 'Client-computed security score. Server stores status but never analyzes actual password content.';
