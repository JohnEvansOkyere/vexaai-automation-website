-- VexaAI Workflow Sales Database Schema for Supabase
-- Execute this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    phone VARCHAR(50),
    purchase_type VARCHAR(50), -- 'single' or 'all-access'
    total_spent DECIMAL(10, 2) DEFAULT 0,
    total_purchases INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);

-- Workflows table
CREATE TABLE IF NOT EXISTS workflows (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    icon VARCHAR(10),
    description TEXT,
    price DECIMAL(10, 2) DEFAULT 149.00,
    json_file_url TEXT, -- URL to stored JSON file
    downloads INT DEFAULT 0,
    revenue DECIMAL(10, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sales/Orders table
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    customer_email VARCHAR(255) NOT NULL,
    purchase_type VARCHAR(50) NOT NULL, -- 'single' or 'all-access'
    workflow_id INT REFERENCES workflows(id) ON DELETE SET NULL,
    workflow_name VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'GHS',
    payment_channel VARCHAR(50), -- 'mobile_money' or 'card'
    payment_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'success', 'failed'
    paystack_reference VARCHAR(255),
    metadata JSONB, -- Store additional payment metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for sales
CREATE INDEX IF NOT EXISTS idx_sales_customer_email ON sales(customer_email);
CREATE INDEX IF NOT EXISTS idx_sales_reference ON sales(reference);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at DESC);

-- All Access Pass members table
CREATE TABLE IF NOT EXISTS all_access_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    notion_access_granted BOOLEAN DEFAULT FALSE,
    whatsapp_group_joined BOOLEAN DEFAULT FALSE,
    custom_requests_used INT DEFAULT 0,
    custom_requests_limit INT DEFAULT 2, -- per month
    last_request_reset TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Download history table (track who downloaded what)
CREATE TABLE IF NOT EXISTS download_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    workflow_id INT REFERENCES workflows(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    download_count INT DEFAULT 1,
    last_downloaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin users table
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Store hashed passwords only
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Settings table (for app configuration)
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default workflows
INSERT INTO workflows (name, category, icon, description, price) VALUES
    ('Email Marketing Automation', 'Marketing', '📧', 'Automated email sequences with personalization and analytics', 149.00),
    ('Sales Pipeline Manager', 'Sales', '💰', 'Track leads, automate follow-ups, close more deals', 149.00),
    ('Social Media Scheduler', 'Marketing', '📱', 'Schedule posts across all platforms automatically', 149.00),
    ('Lead Generation & Nurturing', 'Sales', '🎯', 'Capture and nurture leads automatically', 149.00),
    ('Customer Support Automation', 'Support', '💬', 'Automate customer support workflows', 149.00),
    ('Invoice & Payment Tracker', 'Finance', '💳', 'Track invoices and payments automatically', 149.00),
    ('Content Publishing System', 'Content', '📝', 'Automated content publishing across platforms', 149.00),
    ('Data Sync Across Platforms', 'Integration', '🔄', 'Sync data across multiple platforms seamlessly', 149.00),
    ('WhatsApp Business Automation', 'Communication', '💚', 'Automate WhatsApp business messages', 149.00),
    ('E-commerce Order Processor', 'E-commerce', '🛒', 'Process e-commerce orders automatically', 149.00),
    ('Inventory Management System', 'Operations', '📦', 'Manage inventory levels and alerts', 149.00),
    ('HR Onboarding Automation', 'HR', '👥', 'Automate employee onboarding process', 149.00),
    ('Task & Project Management', 'Productivity', '✅', 'Manage tasks and projects efficiently', 149.00),
    ('Website Analytics Dashboard', 'Analytics', '📊', 'Track website analytics and metrics', 149.00),
    ('Appointment Booking System', 'Scheduling', '📅', 'Automated appointment booking and reminders', 149.00)
ON CONFLICT DO NOTHING;

-- Insert default settings
INSERT INTO settings (key, value, description) VALUES
    ('single_workflow_price', '149', 'Price for single workflow in GHS'),
    ('all_access_price', '799', 'Price for all access pass in GHS'),
    ('notion_library_url', 'https://notion.so/your-library', 'Private Notion library URL'),
    ('whatsapp_support_number', '+233544954643', 'WhatsApp support number'),
    ('paystack_public_key', 'pk_test_xxx', 'Paystack public key'),
    ('monthly_custom_requests', '2', 'Number of custom requests per month for all access')
ON CONFLICT (key) DO NOTHING;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflows_updated_at BEFORE UPDATE ON workflows
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_all_access_members_updated_at BEFORE UPDATE ON all_access_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admin_users_updated_at BEFORE UPDATE ON admin_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
-- Enable RLS on all tables
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE all_access_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE download_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Public read access to workflows (anyone can view available workflows)
CREATE POLICY "Workflows are viewable by everyone"
    ON workflows FOR SELECT
    USING (is_active = TRUE);

-- Customers can only view their own data
CREATE POLICY "Customers can view own data"
    ON customers FOR SELECT
    USING (auth.jwt() ->> 'email' = email);

-- Sales can be viewed by the customer who made the purchase
CREATE POLICY "Customers can view own sales"
    ON sales FOR SELECT
    USING (auth.jwt() ->> 'email' = customer_email);

-- All access members can view their own membership
CREATE POLICY "Members can view own membership"
    ON all_access_members FOR SELECT
    USING (auth.jwt() ->> 'email' = email);

-- View for dashboard statistics (for admin)
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT
    COUNT(DISTINCT customer_email) as total_customers,
    COUNT(*) as total_sales,
    SUM(amount) as total_revenue,
    SUM(CASE WHEN purchase_type = 'all-access' THEN 1 ELSE 0 END) as all_access_sales,
    SUM(CASE WHEN purchase_type = 'single' THEN 1 ELSE 0 END) as single_workflow_sales,
    AVG(amount) as average_order_value
FROM sales
WHERE payment_status = 'success';

-- View for popular workflows
CREATE OR REPLACE VIEW popular_workflows AS
SELECT
    w.id,
    w.name,
    w.category,
    w.downloads,
    w.revenue,
    COUNT(dh.id) as download_count
FROM workflows w
LEFT JOIN download_history dh ON w.id = dh.workflow_id
GROUP BY w.id, w.name, w.category, w.downloads, w.revenue
ORDER BY download_count DESC;

-- Function to record a sale
CREATE OR REPLACE FUNCTION record_sale(
    p_reference VARCHAR,
    p_email VARCHAR,
    p_purchase_type VARCHAR,
    p_workflow_id INT,
    p_workflow_name VARCHAR,
    p_amount DECIMAL,
    p_payment_channel VARCHAR,
    p_paystack_reference VARCHAR
)
RETURNS UUID AS $$
DECLARE
    v_customer_id UUID;
    v_sale_id UUID;
BEGIN
    -- Get or create customer
    INSERT INTO customers (email, purchase_type)
    VALUES (p_email, p_purchase_type)
    ON CONFLICT (email) DO UPDATE
    SET purchase_type = CASE
        WHEN p_purchase_type = 'all-access' THEN 'all-access'
        ELSE customers.purchase_type
    END
    RETURNING id INTO v_customer_id;

    -- Create sale record
    INSERT INTO sales (
        reference,
        customer_id,
        customer_email,
        purchase_type,
        workflow_id,
        workflow_name,
        amount,
        payment_channel,
        payment_status,
        paystack_reference
    ) VALUES (
        p_reference,
        v_customer_id,
        p_email,
        p_purchase_type,
        p_workflow_id,
        p_workflow_name,
        p_amount,
        p_payment_channel,
        'success',
        p_paystack_reference
    )
    RETURNING id INTO v_sale_id;

    -- Update customer stats
    UPDATE customers
    SET total_spent = total_spent + p_amount,
        total_purchases = total_purchases + 1
    WHERE id = v_customer_id;

    -- If all access, add to members table
    IF p_purchase_type = 'all-access' THEN
        INSERT INTO all_access_members (customer_id, email)
        VALUES (v_customer_id, p_email)
        ON CONFLICT (email) DO NOTHING;
    END IF;

    -- Update workflow stats if single purchase
    IF p_workflow_id IS NOT NULL THEN
        UPDATE workflows
        SET downloads = downloads + 1,
            revenue = revenue + p_amount
        WHERE id = p_workflow_id;
    END IF;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;

-- Comments for documentation
COMMENT ON TABLE customers IS 'Stores customer information and purchase history';
COMMENT ON TABLE workflows IS 'Available n8n workflows for purchase';
COMMENT ON TABLE sales IS 'All sales transactions';
COMMENT ON TABLE all_access_members IS 'Customers with all access pass';
COMMENT ON TABLE download_history IS 'Track workflow download history';
COMMENT ON TABLE admin_users IS 'Admin users for dashboard access';
COMMENT ON TABLE settings IS 'Application configuration settings';
