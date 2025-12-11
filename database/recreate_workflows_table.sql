-- OPTION 2: Completely recreate the workflows table
-- WARNING: This will delete all existing workflows data!
-- Only use this if the previous migration didn't work

-- Step 1: Backup existing data (if any)
CREATE TABLE IF NOT EXISTS workflows_backup AS
SELECT * FROM workflows;

-- Step 2: Drop the existing table
DROP TABLE IF EXISTS workflows CASCADE;

-- Step 3: Recreate the workflows table with correct structure
CREATE TABLE workflows (
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
    tags TEXT[],
    difficulty VARCHAR(20) CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    estimated_time INT,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 4: Create indexes
CREATE INDEX idx_workflows_slug ON workflows(slug);
CREATE INDEX idx_workflows_category ON workflows(category);
CREATE INDEX idx_workflows_is_active ON workflows(is_active);
CREATE INDEX idx_workflows_is_featured ON workflows(is_featured);
CREATE INDEX idx_workflows_tags ON workflows USING GIN(tags);

-- Step 5: Create trigger for auto-update timestamps
CREATE OR REPLACE FUNCTION update_workflows_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workflows_updated_at
    BEFORE UPDATE ON workflows
    FOR EACH ROW
    EXECUTE FUNCTION update_workflows_updated_at();

-- Step 6: Insert sample workflows
INSERT INTO workflows (name, slug, category, icon, description, workflow_json, price, tags, difficulty, estimated_time, is_featured) VALUES
    ('Email Marketing Automation', 'email-marketing-automation', 'Marketing', '📧', 'Automated email sequences with personalization and analytics', '{"nodes": [], "connections": {}}', 149.00, ARRAY['email', 'marketing', 'automation'], 'intermediate', 30, TRUE),
    ('Sales Pipeline Manager', 'sales-pipeline-manager', 'Sales', '💰', 'Track leads, automate follow-ups, close more deals', '{"nodes": [], "connections": {}}', 149.00, ARRAY['sales', 'crm', 'pipeline'], 'intermediate', 45, TRUE),
    ('Social Media Scheduler', 'social-media-scheduler', 'Marketing', '📱', 'Schedule posts across all platforms automatically', '{"nodes": [], "connections": {}}', 149.00, ARRAY['social-media', 'scheduling', 'content'], 'beginner', 20, TRUE)
ON CONFLICT (slug) DO NOTHING;

-- Step 7: Verify the table structure
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'workflows'
ORDER BY ordinal_position;

-- Step 8: Show sample data
SELECT id, name, category, price, tags, is_active FROM workflows;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Workflows table recreated successfully!';
    RAISE NOTICE '📊 Sample workflows inserted';
    RAISE NOTICE '🚀 Ready to upload new workflows';
END $$;
