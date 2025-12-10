-- ============================================
-- Authentication & Custom Requests Migration
-- Add this to your existing Neon database
-- ============================================

-- 1. Add authentication table for users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(50),

    -- Account status
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,

    -- Verification
    verification_token VARCHAR(255),
    verification_token_expires TIMESTAMP WITH TIME ZONE,

    -- Password reset
    reset_token VARCHAR(255),
    reset_token_expires TIMESTAMP WITH TIME ZONE,

    -- Login tracking
    last_login TIMESTAMP WITH TIME ZONE,
    login_count INT DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_verification_token ON users(verification_token);
CREATE INDEX idx_users_reset_token ON users(reset_token);

COMMENT ON TABLE users IS 'Frontend users who can purchase workflows';

-- 2. Update customers table to link with users
ALTER TABLE customers ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_customers_user_id ON customers(user_id);

-- 3. Add sessions table for JWT tokens
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_token ON user_sessions(token);
CREATE INDEX idx_sessions_expires_at ON user_sessions(expires_at);

COMMENT ON TABLE user_sessions IS 'Active user sessions with JWT tokens';

-- 4. Create custom workflow requests table
CREATE TABLE IF NOT EXISTS custom_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,

    -- Contact info (in case user not logged in)
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    company VARCHAR(255),

    -- Request details
    workflow_title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    use_case TEXT,
    budget_range VARCHAR(50),
    timeline VARCHAR(50),

    -- Additional info
    preferred_platforms TEXT[], -- Array of platforms (n8n, Zapier, Make, etc.)
    integration_needs TEXT,

    -- Status tracking
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'quoted', 'in_progress', 'completed', 'rejected')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),

    -- Admin notes
    admin_notes TEXT,
    quote_amount DECIMAL(10, 2),
    estimated_hours INT,

    -- Communication
    response_email_sent BOOLEAN DEFAULT FALSE,
    quote_sent_at TIMESTAMP WITH TIME ZONE,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_custom_requests_user_id ON custom_requests(user_id);
CREATE INDEX idx_custom_requests_email ON custom_requests(email);
CREATE INDEX idx_custom_requests_status ON custom_requests(status);
CREATE INDEX idx_custom_requests_created_at ON custom_requests(created_at DESC);

COMMENT ON TABLE custom_requests IS 'Custom workflow requests from customers';

-- 5. Trigger for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_custom_requests_updated_at BEFORE UPDATE ON custom_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. Function to clean expired sessions
CREATE OR REPLACE FUNCTION clean_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_sessions
    WHERE expires_at < NOW()
    OR is_active = FALSE;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 7. Function to get user stats
CREATE OR REPLACE FUNCTION get_user_stats(p_user_id UUID)
RETURNS TABLE (
    total_spent DECIMAL,
    total_purchases INT,
    workflows_owned INT,
    has_all_access BOOLEAN,
    member_since TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(SUM(s.amount), 0) as total_spent,
        COUNT(s.id)::INT as total_purchases,
        COUNT(DISTINCT s.workflow_id)::INT as workflows_owned,
        EXISTS(SELECT 1 FROM all_access_members WHERE customer_id = c.id) as has_all_access,
        u.created_at as member_since
    FROM users u
    LEFT JOIN customers c ON u.id = c.user_id
    LEFT JOIN sales s ON c.id = s.customer_id
    WHERE u.id = p_user_id
    GROUP BY u.id, u.created_at, c.id;
END;
$$ LANGUAGE plpgsql;

-- 8. View for admin - custom requests overview
CREATE OR REPLACE VIEW custom_requests_overview AS
SELECT
    cr.id,
    cr.name,
    cr.email,
    cr.workflow_title,
    cr.status,
    cr.priority,
    cr.budget_range,
    cr.timeline,
    cr.created_at,
    u.email as user_email,
    CASE
        WHEN cr.created_at > NOW() - INTERVAL '1 hour' THEN 'new'
        WHEN cr.created_at > NOW() - INTERVAL '24 hours' THEN 'recent'
        ELSE 'old'
    END as age_category
FROM custom_requests cr
LEFT JOIN users u ON cr.user_id = u.id
ORDER BY
    CASE cr.priority
        WHEN 'urgent' THEN 1
        WHEN 'high' THEN 2
        WHEN 'normal' THEN 3
        ELSE 4
    END,
    cr.created_at DESC;

-- 9. Insert default budget ranges into settings
INSERT INTO settings (key, value, description, category) VALUES
    ('budget_ranges', '["Under GHS 500", "GHS 500 - 1,000", "GHS 1,000 - 2,500", "GHS 2,500 - 5,000", "Above GHS 5,000", "Open to discuss"]', 'Budget range options for custom requests', 'custom_requests'),
    ('timeline_options', '["ASAP", "1-2 weeks", "2-4 weeks", "1-2 months", "Flexible"]', 'Timeline options for custom requests', 'custom_requests'),
    ('jwt_secret', 'CHANGE_THIS_TO_RANDOM_SECRET_KEY', 'JWT secret for token generation', 'auth'),
    ('jwt_expiry_hours', '24', 'JWT token expiry in hours', 'auth'),
    ('require_email_verification', 'false', 'Require email verification before purchase', 'auth')
ON CONFLICT (key) DO NOTHING;

-- 10. Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Authentication & Custom Requests Migration Complete!';
    RAISE NOTICE '📋 New Tables: users, user_sessions, custom_requests';
    RAISE NOTICE '🔐 Authentication ready!';
    RAISE NOTICE '📝 Custom request system ready!';
END $$;
