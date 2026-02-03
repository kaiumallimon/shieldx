-- =====================================================
-- ShieldX Zero-Knowledge Vault Schema
-- Migration: Row-Level Security (RLS) Policies
-- =====================================================
-- Description: Implements strict RLS policies ensuring zero-knowledge
-- architecture at the database level. Every user can only access their
-- own encrypted data. No cross-user data leakage possible.
-- =====================================================

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================

ALTER TABLE vault_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE password_breach_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE icon_cache ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- VAULT ITEMS: RLS POLICIES
-- =====================================================

-- Policy: Users can only SELECT their own vault items
CREATE POLICY "Users can view own vault items"
    ON vault_items
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Policy: Users can only INSERT vault items for themselves
CREATE POLICY "Users can create own vault items"
    ON vault_items
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only UPDATE their own vault items
CREATE POLICY "Users can update own vault items"
    ON vault_items
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only DELETE their own vault items
CREATE POLICY "Users can delete own vault items"
    ON vault_items
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- =====================================================
-- USAGE HISTORY: RLS POLICIES
-- =====================================================

-- Policy: Users can only SELECT their own usage history
CREATE POLICY "Users can view own usage history"
    ON usage_history
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Policy: Users can only INSERT usage history for themselves
CREATE POLICY "Users can create own usage history"
    ON usage_history
    FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = user_id
        AND EXISTS (
            SELECT 1 FROM vault_items
            WHERE vault_items.id = vault_item_id
            AND vault_items.user_id = auth.uid()
        )
    );

-- Policy: Users can only UPDATE their own usage history (for analytics corrections)
CREATE POLICY "Users can update own usage history"
    ON usage_history
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only DELETE their own usage history
CREATE POLICY "Users can delete own usage history"
    ON usage_history
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- =====================================================
-- SECURITY ALERTS: RLS POLICIES
-- =====================================================

-- Policy: Users can only SELECT their own security alerts
CREATE POLICY "Users can view own security alerts"
    ON security_alerts
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Policy: Users can only INSERT security alerts for themselves
CREATE POLICY "Users can create own security alerts"
    ON security_alerts
    FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = user_id
        AND (
            vault_item_id IS NULL
            OR EXISTS (
                SELECT 1 FROM vault_items
                WHERE vault_items.id = vault_item_id
                AND vault_items.user_id = auth.uid()
            )
        )
    );

-- Policy: Users can only UPDATE their own security alerts (status changes)
CREATE POLICY "Users can update own security alerts"
    ON security_alerts
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only DELETE their own security alerts
CREATE POLICY "Users can delete own security alerts"
    ON security_alerts
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- =====================================================
-- PASSWORD BREACH CACHE: RLS POLICIES
-- =====================================================
-- Shared cache: All authenticated users can read (privacy via k-anonymity)
-- Only service role can write (batch updates from HIBP API)

-- Policy: All authenticated users can read breach cache (k-anonymity model)
CREATE POLICY "Authenticated users can read breach cache"
    ON password_breach_cache
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Only service role can insert/update breach cache
-- (Client apps use service role key for background sync)
CREATE POLICY "Service role can manage breach cache"
    ON password_breach_cache
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- =====================================================
-- ICON CACHE: RLS POLICIES
-- =====================================================
-- Shared cache: All authenticated users can read
-- All authenticated users can write (upsert pattern for distributed caching)

-- Policy: All authenticated users can read icon cache
CREATE POLICY "Authenticated users can read icon cache"
    ON icon_cache
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy: All authenticated users can insert icon cache entries
CREATE POLICY "Authenticated users can create icon cache"
    ON icon_cache
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: All authenticated users can update icon cache (refresh)
CREATE POLICY "Authenticated users can update icon cache"
    ON icon_cache
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- =====================================================
-- ADDITIONAL SECURITY: FUNCTION-BASED POLICIES
-- =====================================================

-- Function: Verify user owns vault item (helper for complex queries)
CREATE OR REPLACE FUNCTION user_owns_vault_item(item_id UUID, uid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM vault_items
        WHERE id = item_id
        AND user_id = uid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get user's vault item count (rate limiting)
CREATE OR REPLACE FUNCTION get_user_vault_item_count(uid UUID)
RETURNS INTEGER AS $$
DECLARE
    item_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO item_count
    FROM vault_items
    WHERE user_id = uid
    AND is_deleted = FALSE;

    RETURN item_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SECURITY: Prevent User ID Tampering
-- =====================================================
-- Ensure user_id cannot be changed after creation (immutable)

CREATE OR REPLACE FUNCTION prevent_user_id_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.user_id IS DISTINCT FROM NEW.user_id THEN
        RAISE EXCEPTION 'user_id cannot be changed after creation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with user_id column
CREATE TRIGGER prevent_vault_items_user_id_change
    BEFORE UPDATE OF user_id ON vault_items
    FOR EACH ROW
    EXECUTE FUNCTION prevent_user_id_change();

CREATE TRIGGER prevent_usage_history_user_id_change
    BEFORE UPDATE OF user_id ON usage_history
    FOR EACH ROW
    EXECUTE FUNCTION prevent_user_id_change();

CREATE TRIGGER prevent_security_alerts_user_id_change
    BEFORE UPDATE OF user_id ON security_alerts
    FOR EACH ROW
    EXECUTE FUNCTION prevent_user_id_change();

-- =====================================================
-- AUDIT: Enable Realtime for Sync
-- =====================================================
-- Enable realtime replication for vault_items (cross-device sync)

ALTER PUBLICATION supabase_realtime ADD TABLE vault_items;
ALTER PUBLICATION supabase_realtime ADD TABLE usage_history;
ALTER PUBLICATION supabase_realtime ADD TABLE security_alerts;

-- =====================================================
-- SECURITY: Rate Limiting (Future Enhancement)
-- =====================================================
-- Placeholder for rate limiting policies (requires custom middleware)
-- Example: Limit vault item creation to 1000 items per user

CREATE OR REPLACE FUNCTION check_vault_item_limit()
RETURNS TRIGGER AS $$
DECLARE
    item_count INTEGER;
BEGIN
    item_count := get_user_vault_item_count(NEW.user_id);

    IF item_count >= 10000 THEN
        RAISE EXCEPTION 'Vault item limit reached (max: 10000)';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_vault_item_limit
    BEFORE INSERT ON vault_items
    FOR EACH ROW
    EXECUTE FUNCTION check_vault_item_limit();

-- =====================================================
-- COMMENTS: Security Documentation
-- =====================================================

COMMENT ON POLICY "Users can view own vault items" ON vault_items IS 'Zero-knowledge isolation: Users can only view their own encrypted vault items via auth.uid() matching.';
COMMENT ON POLICY "Authenticated users can read breach cache" ON password_breach_cache IS 'Shared k-anonymity cache: All users read same breach data, preserving privacy via hash prefixes.';
COMMENT ON FUNCTION user_owns_vault_item(UUID, UUID) IS 'Security helper: Verifies user ownership of vault item for complex authorization logic.';
COMMENT ON FUNCTION check_vault_item_limit() IS 'Rate limiting: Prevents abuse by enforcing maximum vault items per user (10,000 limit).';
