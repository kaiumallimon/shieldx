-- =====================================================
-- ShieldX Zero-Knowledge Vault Schema
-- Migration: Usage History & Security Alerts
-- =====================================================
-- Description: Tracks autofill usage patterns and security monitoring
-- for password health without server ever accessing decrypted content.
-- =====================================================

-- =====================================================
-- TABLE: usage_history
-- =====================================================
-- Tracks where and when credentials were autofilled/used
-- Privacy-preserving: only stores package names and domains,
-- never captures actual form data or user input
-- =====================================================

CREATE TABLE usage_history (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vault_item_id UUID NOT NULL REFERENCES vault_items(id) ON DELETE CASCADE,

    -- Usage context (plain-text for analytics)
    app_package_name VARCHAR(255),  -- Android: com.example.app
    app_bundle_id VARCHAR(255),     -- iOS: com.example.app
    website_domain TEXT,            -- Web: example.com
    page_url TEXT,                  -- Full URL where autofill occurred

    -- Usage metadata
    action_type VARCHAR(50) NOT NULL DEFAULT 'autofill',  -- autofill, manual_copy, view
    device_info JSONB,              -- Device type, OS version (for sync analytics)

    -- Timestamps
    used_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT usage_history_user_id_check CHECK (user_id IS NOT NULL),
    CONSTRAINT usage_history_action_type_check CHECK (action_type IN ('autofill', 'manual_copy', 'view', 'share'))
);

-- =====================================================
-- INDEXES: Usage History Performance
-- =====================================================

-- Query by vault item (show usage history for specific credential)
CREATE INDEX idx_usage_history_vault_item ON usage_history(vault_item_id, used_at DESC);

-- Query by user (user's complete usage history)
CREATE INDEX idx_usage_history_user ON usage_history(user_id, used_at DESC);

-- Query by domain (find all credentials used on specific website)
CREATE INDEX idx_usage_history_domain ON usage_history(user_id, website_domain, used_at DESC) WHERE website_domain IS NOT NULL;

-- Recent usage (for "recently used" sorting)
CREATE INDEX idx_usage_history_recent ON usage_history(user_id, used_at DESC);

-- =====================================================
-- TABLE: security_alerts
-- =====================================================
-- Tracks password health issues and breach notifications
-- Status-based approach: client computes health, server triggers alerts
-- Server never analyzes actual password content
-- =====================================================

CREATE TYPE alert_severity AS ENUM ('info', 'warning', 'critical');
CREATE TYPE alert_type AS ENUM (
    'weak_password',
    'reused_password',
    'breached_password',
    'expired_password',
    'compromised_website',
    'suspicious_login',
    'password_unchanged_long',
    'missing_2fa'
);
CREATE TYPE alert_status AS ENUM ('active', 'acknowledged', 'resolved', 'dismissed');

CREATE TABLE security_alerts (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vault_item_id UUID REFERENCES vault_items(id) ON DELETE CASCADE,  -- NULL for account-wide alerts

    -- Alert classification
    alert_type alert_type NOT NULL,
    severity alert_severity NOT NULL DEFAULT 'warning',
    status alert_status NOT NULL DEFAULT 'active',

    -- Alert content (never contains decrypted passwords)
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    recommendation TEXT,  -- Suggested action for user

    -- Metadata (client-generated, privacy-preserving)
    metadata JSONB,  -- Additional context (e.g., breach source, affected count)

    -- Action tracking
    acknowledged_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,  -- Auto-dismiss after date (for time-sensitive alerts)

    -- Constraints
    CONSTRAINT security_alerts_user_id_check CHECK (user_id IS NOT NULL)
);

-- =====================================================
-- INDEXES: Security Alerts Performance
-- =====================================================

-- Active alerts for user dashboard
CREATE INDEX idx_security_alerts_active ON security_alerts(user_id, created_at DESC) WHERE status = 'active';

-- Alerts by severity (critical alerts first)
CREATE INDEX idx_security_alerts_severity ON security_alerts(user_id, severity, created_at DESC) WHERE status = 'active';

-- Alerts for specific vault item
CREATE INDEX idx_security_alerts_vault_item ON security_alerts(vault_item_id, status) WHERE vault_item_id IS NOT NULL;

-- Alert type filtering
CREATE INDEX idx_security_alerts_type ON security_alerts(user_id, alert_type, status);

-- Expired alerts cleanup
CREATE INDEX idx_security_alerts_expired ON security_alerts(expires_at) WHERE expires_at IS NOT NULL AND status = 'active';

-- =====================================================
-- TABLE: password_breach_cache
-- =====================================================
-- Local cache for Have I Been Pwned API results
-- Stores SHA-1 hash prefixes (k-anonymity model)
-- Never stores actual passwords or full hashes
-- =====================================================

CREATE TABLE password_breach_cache (
    -- Hash prefix (first 5 chars of SHA-1)
    hash_prefix VARCHAR(5) PRIMARY KEY,

    -- Breach data (count of occurrences)
    breach_count INTEGER NOT NULL DEFAULT 0,

    -- Cache metadata
    last_checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),

    -- Constraints
    CONSTRAINT password_breach_cache_hash_prefix_check CHECK (LENGTH(hash_prefix) = 5),
    CONSTRAINT password_breach_cache_breach_count_check CHECK (breach_count >= 0)
);

-- Index for cache expiration cleanup
CREATE INDEX idx_password_breach_cache_expires ON password_breach_cache(expires_at);

-- =====================================================
-- TABLE: icon_cache
-- =====================================================
-- Cache for Brandfetch API icons to minimize API calls
-- Reduces costs and improves performance
-- =====================================================

CREATE TABLE icon_cache (
    -- Primary identification (domain-based)
    domain VARCHAR(255) PRIMARY KEY,

    -- Icon data
    icon_url TEXT NOT NULL,
    icon_type VARCHAR(50),  -- svg, png, jpg
    brand_name VARCHAR(255),
    brand_color VARCHAR(7),  -- Hex color code

    -- Cache metadata
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 days'),
    fetch_count INTEGER NOT NULL DEFAULT 1,
    last_accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- API response caching
    raw_response JSONB,  -- Full Brandfetch response for fallback

    -- Constraints
    CONSTRAINT icon_cache_domain_check CHECK (LENGTH(domain) > 0)
);

-- Index for cache cleanup and access patterns
CREATE INDEX idx_icon_cache_expires ON icon_cache(expires_at);
CREATE INDEX idx_icon_cache_accessed ON icon_cache(last_accessed_at);

-- =====================================================
-- FUNCTIONS: Automatic Alert Status Management
-- =====================================================

CREATE OR REPLACE FUNCTION update_security_alert_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Set timestamps based on status changes
    IF NEW.status = 'acknowledged' AND OLD.status != 'acknowledged' THEN
        NEW.acknowledged_at = NOW();
    ELSIF NEW.status = 'resolved' AND OLD.status != 'resolved' THEN
        NEW.resolved_at = NOW();
    ELSIF NEW.status = 'dismissed' AND OLD.status != 'dismissed' THEN
        NEW.dismissed_at = NOW();
    END IF;

    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_security_alerts_status
    BEFORE UPDATE OF status ON security_alerts
    FOR EACH ROW
    EXECUTE FUNCTION update_security_alert_status();

-- =====================================================
-- FUNCTIONS: Usage History Cleanup (Privacy)
-- =====================================================
-- Automatically delete usage history older than 90 days
-- Balances analytics with privacy

CREATE OR REPLACE FUNCTION cleanup_old_usage_history()
RETURNS void AS $$
BEGIN
    DELETE FROM usage_history
    WHERE used_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- Schedule cleanup (requires pg_cron extension or external scheduler)
-- Example: SELECT cron.schedule('cleanup-usage-history', '0 2 * * *', 'SELECT cleanup_old_usage_history()');

-- =====================================================
-- FUNCTIONS: Auto-expire Alerts
-- =====================================================

CREATE OR REPLACE FUNCTION auto_expire_alerts()
RETURNS void AS $$
BEGIN
    UPDATE security_alerts
    SET status = 'dismissed',
        dismissed_at = NOW()
    WHERE expires_at IS NOT NULL
        AND expires_at < NOW()
        AND status = 'active';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTIONS: Update Last Used Timestamp
-- =====================================================
-- Automatically update vault_items.last_used_at when usage_history is created

CREATE OR REPLACE FUNCTION update_vault_item_last_used()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE vault_items
    SET last_used_at = NEW.used_at
    WHERE id = NEW.vault_item_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_vault_item_last_used
    AFTER INSERT ON usage_history
    FOR EACH ROW
    EXECUTE FUNCTION update_vault_item_last_used();

-- =====================================================
-- COMMENTS: Documentation
-- =====================================================

COMMENT ON TABLE usage_history IS 'Privacy-preserving usage tracking for autofill and credential access patterns. Never logs actual form data or user input.';
COMMENT ON TABLE security_alerts IS 'Status-based security monitoring system. Client computes password health, server stores alerts without accessing decrypted content.';
COMMENT ON TABLE password_breach_cache IS 'Local cache for HIBP API using k-anonymity model (hash prefixes only). Reduces API calls and improves privacy.';
COMMENT ON TABLE icon_cache IS 'Brandfetch API response cache to minimize API costs and improve icon loading performance.';
