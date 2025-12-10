-- ============================================
-- VexaAI Workflow Sales Platform
-- Neon PostgreSQL Database Schema
-- ============================================
-- Neon is a serverless PostgreSQL database
-- This schema is optimized for Neon's features
-- ============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing tables if recreating (use with caution!)
-- DROP TABLE IF EXISTS download_history CASCADE;
-- DROP TABLE IF EXISTS all_access_members CASCADE;
-- DROP TABLE IF EXISTS sales CASCADE;
-- DROP TABLE IF EXISTS workflows CASCADE;
-- DROP TABLE IF EXISTS customers CASCADE;
-- DROP TABLE IF EXISTS admin_users CASCADE;
-- DROP TABLE IF EXISTS settings CASCADE;

-- ============================================
-- 1. CUSTOMERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    phone VARCHAR(50),
    purchase_type VARCHAR(50) CHECK (purchase_type IN ('single', 'all-access')),
    total_spent DECIMAL(10, 2) DEFAULT 0,
    total_purchases INT DEFAULT 0,
    country VARCHAR(100) DEFAULT 'Ghana',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_purchase_type ON customers(purchase_type);
CREATE INDEX idx_customers_created_at ON customers(created_at DESC);

COMMENT ON TABLE customers IS 'Stores all customer information and purchase history';
COMMENT ON COLUMN customers.purchase_type IS 'Type of last purchase: single or all-access';

-- ============================================
-- 2. WORKFLOWS TABLE (Stores workflow metadata and JSON)
-- ============================================
CREATE TABLE IF NOT EXISTS workflows (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    category VARCHAR(100) NOT NULL,
    icon VARCHAR(10) DEFAULT '🔧',
    description TEXT,
    long_description TEXT,
    price DECIMAL(10, 2) DEFAULT 149.00,

    -- Store workflow JSON directly in the database
    workflow_json JSONB NOT NULL,

    -- Metadata
    version VARCHAR(20) DEFAULT '1.0.0',
    downloads INT DEFAULT 0,
    revenue DECIMAL(10, 2) DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    review_count INT DEFAULT 0,

    -- Features
    tags TEXT[], -- Array of tags like ['email', 'automation', 'marketing']
    difficulty VARCHAR(20) CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    estimated_time INT, -- Setup time in minutes

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_workflows_slug ON workflows(slug);
CREATE INDEX idx_workflows_category ON workflows(category);
CREATE INDEX idx_workflows_is_active ON workflows(is_active);
CREATE INDEX idx_workflows_is_featured ON workflows(is_featured);
CREATE INDEX idx_workflows_tags ON workflows USING GIN(tags);

COMMENT ON TABLE workflows IS 'Stores n8n workflow definitions and metadata';
COMMENT ON COLUMN workflows.workflow_json IS 'Complete n8n workflow JSON stored as JSONB';
COMMENT ON COLUMN workflows.tags IS 'Array of searchable tags';

-- ============================================
-- 3. SALES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE NOT NULL,

    -- Customer info
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    customer_email VARCHAR(255) NOT NULL,
    customer_name VARCHAR(255),

    -- Purchase details
    purchase_type VARCHAR(50) NOT NULL CHECK (purchase_type IN ('single', 'all-access')),
    workflow_id INT REFERENCES workflows(id) ON DELETE SET NULL,
    workflow_name VARCHAR(255),

    -- Payment details
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'GHS',
    payment_channel VARCHAR(50), -- 'mobile_money', 'card', 'bank_transfer'
    payment_provider VARCHAR(50) DEFAULT 'paystack',
    payment_status VARCHAR(50) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'success', 'failed', 'refunded')),

    -- Paystack specific
    paystack_reference VARCHAR(255),
    paystack_access_code VARCHAR(255),
    paystack_authorization JSONB,

    -- Additional data
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    paid_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_sales_customer_email ON sales(customer_email);
CREATE INDEX idx_sales_reference ON sales(reference);
CREATE INDEX idx_sales_payment_status ON sales(payment_status);
CREATE INDEX idx_sales_created_at ON sales(created_at DESC);
CREATE INDEX idx_sales_purchase_type ON sales(purchase_type);

COMMENT ON TABLE sales IS 'All sales transactions and payment records';

-- ============================================
-- 4. ALL ACCESS MEMBERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS all_access_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,

    -- Access details
    access_token VARCHAR(255) UNIQUE,
    notion_access_granted BOOLEAN DEFAULT FALSE,
    notion_user_id VARCHAR(255),
    whatsapp_group_joined BOOLEAN DEFAULT FALSE,

    -- Custom requests
    custom_requests_used INT DEFAULT 0,
    custom_requests_limit INT DEFAULT 2,
    last_request_reset TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE, -- NULL = lifetime access

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_all_access_email ON all_access_members(email);
CREATE INDEX idx_all_access_token ON all_access_members(access_token);

COMMENT ON TABLE all_access_members IS 'Customers with All Access Pass membership';

-- ============================================
-- 5. DOWNLOAD HISTORY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS download_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    workflow_id INT REFERENCES workflows(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,

    -- Download details
    download_count INT DEFAULT 1,
    ip_address INET,
    user_agent TEXT,

    -- Timestamps
    last_downloaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_download_history_customer ON download_history(customer_id);
CREATE INDEX idx_download_history_workflow ON download_history(workflow_id);
CREATE INDEX idx_download_history_email ON download_history(email);

COMMENT ON TABLE download_history IS 'Track workflow download history';

-- ============================================
-- 6. ADMIN USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin', 'viewer')),

    -- Permissions
    can_manage_workflows BOOLEAN DEFAULT TRUE,
    can_manage_customers BOOLEAN DEFAULT TRUE,
    can_view_sales BOOLEAN DEFAULT TRUE,
    can_manage_settings BOOLEAN DEFAULT FALSE,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    login_count INT DEFAULT 0,

    -- Security
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_admin_email ON admin_users(email);

COMMENT ON TABLE admin_users IS 'Admin users for dashboard access';

-- ============================================
-- 7. SETTINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    category VARCHAR(50) DEFAULT 'general',
    is_public BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE settings IS 'Application configuration and settings';

-- ============================================
-- 8. ANALYTICS TABLE (Optional - for detailed analytics)
-- ============================================
CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type VARCHAR(100) NOT NULL, -- 'page_view', 'workflow_view', 'purchase_attempt', etc.
    event_data JSONB,
    user_id UUID,
    session_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    referrer TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at DESC);

COMMENT ON TABLE analytics_events IS 'Track user behavior and analytics events';

-- ============================================
-- TRIGGERS FOR AUTO-UPDATE TIMESTAMPS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflows_updated_at BEFORE UPDATE ON workflows
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_all_access_updated_at BEFORE UPDATE ON all_access_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admin_users_updated_at BEFORE UPDATE ON admin_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STORED FUNCTIONS
-- ============================================

-- Function to record a sale
CREATE OR REPLACE FUNCTION record_sale(
    p_reference VARCHAR,
    p_email VARCHAR,
    p_name VARCHAR,
    p_purchase_type VARCHAR,
    p_workflow_id INT,
    p_workflow_name VARCHAR,
    p_amount DECIMAL,
    p_payment_channel VARCHAR,
    p_paystack_reference VARCHAR,
    p_ip_address INET DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_customer_id UUID;
    v_sale_id UUID;
BEGIN
    -- Get or create customer
    INSERT INTO customers (email, name, purchase_type, country)
    VALUES (p_email, p_name, p_purchase_type, 'Ghana')
    ON CONFLICT (email) DO UPDATE
    SET
        name = COALESCE(customers.name, EXCLUDED.name),
        purchase_type = CASE
            WHEN p_purchase_type = 'all-access' THEN 'all-access'
            ELSE customers.purchase_type
        END
    RETURNING id INTO v_customer_id;

    -- Create sale record
    INSERT INTO sales (
        reference,
        customer_id,
        customer_email,
        customer_name,
        purchase_type,
        workflow_id,
        workflow_name,
        amount,
        currency,
        payment_channel,
        payment_status,
        paystack_reference,
        ip_address,
        paid_at
    ) VALUES (
        p_reference,
        v_customer_id,
        p_email,
        p_name,
        p_purchase_type,
        p_workflow_id,
        p_workflow_name,
        p_amount,
        'GHS',
        p_payment_channel,
        'success',
        p_paystack_reference,
        p_ip_address,
        NOW()
    )
    RETURNING id INTO v_sale_id;

    -- Update customer stats
    UPDATE customers
    SET
        total_spent = total_spent + p_amount,
        total_purchases = total_purchases + 1
    WHERE id = v_customer_id;

    -- If all access, add to members table
    IF p_purchase_type = 'all-access' THEN
        INSERT INTO all_access_members (customer_id, email, access_token)
        VALUES (v_customer_id, p_email, encode(gen_random_bytes(32), 'hex'))
        ON CONFLICT (email) DO UPDATE
        SET is_active = TRUE;
    END IF;

    -- Update workflow stats if single purchase
    IF p_workflow_id IS NOT NULL THEN
        UPDATE workflows
        SET
            downloads = downloads + 1,
            revenue = revenue + p_amount
        WHERE id = p_workflow_id;
    END IF;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get dashboard stats
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS TABLE (
    total_revenue DECIMAL,
    total_sales BIGINT,
    total_customers BIGINT,
    all_access_sales BIGINT,
    single_sales BIGINT,
    avg_order_value DECIMAL,
    today_revenue DECIMAL,
    today_sales BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(SUM(s.amount), 0) as total_revenue,
        COUNT(s.id) as total_sales,
        COUNT(DISTINCT s.customer_email) as total_customers,
        COUNT(*) FILTER (WHERE s.purchase_type = 'all-access') as all_access_sales,
        COUNT(*) FILTER (WHERE s.purchase_type = 'single') as single_sales,
        COALESCE(AVG(s.amount), 0) as avg_order_value,
        COALESCE(SUM(s.amount) FILTER (WHERE DATE(s.created_at) = CURRENT_DATE), 0) as today_revenue,
        COUNT(*) FILTER (WHERE DATE(s.created_at) = CURRENT_DATE) as today_sales
    FROM sales s
    WHERE s.payment_status = 'success';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VIEWS FOR ANALYTICS
-- ============================================

-- Dashboard overview
CREATE OR REPLACE VIEW dashboard_overview AS
SELECT
    COUNT(DISTINCT customer_email) as total_customers,
    COUNT(*) as total_sales,
    SUM(amount) as total_revenue,
    SUM(CASE WHEN purchase_type = 'all-access' THEN 1 ELSE 0 END) as all_access_sales,
    SUM(CASE WHEN purchase_type = 'single' THEN 1 ELSE 0 END) as single_workflow_sales,
    AVG(amount) as average_order_value,
    SUM(CASE WHEN DATE(created_at) = CURRENT_DATE THEN 1 ELSE 0 END) as sales_today,
    SUM(CASE WHEN DATE(created_at) = CURRENT_DATE THEN amount ELSE 0 END) as revenue_today
FROM sales
WHERE payment_status = 'success';

-- Popular workflows
CREATE OR REPLACE VIEW popular_workflows AS
SELECT
    w.id,
    w.name,
    w.category,
    w.downloads,
    w.revenue,
    w.rating,
    w.review_count,
    COUNT(dh.id) as total_downloads,
    COUNT(DISTINCT dh.customer_id) as unique_customers
FROM workflows w
LEFT JOIN download_history dh ON w.id = dh.workflow_id
WHERE w.is_active = TRUE
GROUP BY w.id, w.name, w.category, w.downloads, w.revenue, w.rating, w.review_count
ORDER BY total_downloads DESC;

-- Recent activity
CREATE OR REPLACE VIEW recent_activity AS
SELECT
    s.id,
    s.reference,
    s.customer_email,
    s.customer_name,
    s.purchase_type,
    s.workflow_name,
    s.amount,
    s.payment_channel,
    s.payment_status,
    s.created_at
FROM sales s
ORDER BY s.created_at DESC
LIMIT 50;

-- ============================================
-- INSERT DEFAULT DATA
-- ============================================

-- Insert default settings
INSERT INTO settings (key, value, description, category) VALUES
    ('site_name', 'VexaAI', 'Website name', 'general'),
    ('single_workflow_price', '149', 'Price for single workflow in GHS', 'pricing'),
    ('all_access_price', '799', 'Price for all access pass in GHS', 'pricing'),
    ('notion_library_url', 'https://notion.so/your-library', 'Private Notion library URL', 'integrations'),
    ('whatsapp_support_number', '+233544954643', 'WhatsApp support number', 'support'),
    ('paystack_public_key', 'pk_test_xxx', 'Paystack public key', 'payment'),
    ('monthly_custom_requests', '2', 'Number of custom requests per month for all access', 'features'),
    ('currency', 'GHS', 'Default currency', 'general'),
    ('company_email', 'johnevansokyere@gmail.com', 'Company contact email', 'general'),
    ('founder_name', 'John Evans Okyere', 'Founder name', 'general')
ON CONFLICT (key) DO NOTHING;

-- Insert sample workflows (you can add more later)
INSERT INTO workflows (name, slug, category, icon, description, workflow_json, price, tags, difficulty, estimated_time, is_featured) VALUES
    ('Email Marketing Automation', 'email-marketing-automation', 'Marketing', '📧', 'Automated email sequences with personalization and analytics', '{"nodes": [], "connections": {}}', 149.00, ARRAY['email', 'marketing', 'automation'], 'intermediate', 30, TRUE),
    ('Sales Pipeline Manager', 'sales-pipeline-manager', 'Sales', '💰', 'Track leads, automate follow-ups, close more deals', '{"nodes": [], "connections": {}}', 149.00, ARRAY['sales', 'crm', 'pipeline'], 'intermediate', 45, TRUE),
    ('Social Media Scheduler', 'social-media-scheduler', 'Marketing', '📱', 'Schedule posts across all platforms automatically', '{"nodes": [], "connections": {}}', 149.00, ARRAY['social-media', 'scheduling', 'content'], 'beginner', 20, TRUE),
    ('Lead Generation & Nurturing', 'lead-generation-nurturing', 'Sales', '🎯', 'Capture and nurture leads automatically', '{"nodes": [], "connections": {}}', 149.00, ARRAY['leads', 'nurturing', 'automation'], 'intermediate', 40, FALSE),
    ('Customer Support Automation', 'customer-support-automation', 'Support', '💬', 'Automate customer support workflows', '{"nodes": [], "connections": {}}', 149.00, ARRAY['support', 'customer-service', 'tickets'], 'beginner', 25, FALSE)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- SECURITY: ROW LEVEL SECURITY (RLS)
-- ============================================
-- Uncomment if you want to enable RLS
-- ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PERFORMANCE OPTIMIZATION
-- ============================================
-- Analyze tables for query optimization
ANALYZE customers;
ANALYZE workflows;
ANALYZE sales;
ANALYZE all_access_members;
ANALYZE download_history;

-- ============================================
-- BACKUP RECOMMENDATIONS
-- ============================================
-- Neon automatically backs up your database
-- But you can also create manual backups:
-- pg_dump -h your-neon-host.neon.tech -U your-user -d your-db > backup.sql

-- ============================================
-- SCHEMA VERSION
-- ============================================
INSERT INTO settings (key, value, description, category) VALUES
    ('schema_version', '1.0.0', 'Database schema version', 'system'),
    ('last_migration', NOW()::TEXT, 'Last migration timestamp', 'system')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✅ VexaAI Database Schema Created Successfully!';
    RAISE NOTICE '📊 Tables: customers, workflows, sales, all_access_members, download_history, admin_users, settings';
    RAISE NOTICE '🔧 Functions: record_sale(), get_dashboard_stats()';
    RAISE NOTICE '📈 Views: dashboard_overview, popular_workflows, recent_activity';
    RAISE NOTICE '🚀 Ready to use with Neon PostgreSQL!';
END $$;
