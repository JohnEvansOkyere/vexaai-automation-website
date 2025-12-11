-- Step 1: Check what columns currently exist in your workflows table
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'workflows'
ORDER BY ordinal_position;

-- Step 2: Add ALL missing columns to workflows table
-- Run this after reviewing the output from Step 1

-- Core columns
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS id SERIAL PRIMARY KEY;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS name VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS slug VARCHAR(255);
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS category VARCHAR(100) NOT NULL DEFAULT 'General';
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS icon VARCHAR(10) DEFAULT '🔧';
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS long_description TEXT;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS price DECIMAL(10, 2) DEFAULT 149.00;

-- CRITICAL: workflow_json column (this stores the actual workflow)
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS workflow_json JSONB;

-- Metadata columns
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS version VARCHAR(20) DEFAULT '1.0.0';
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS downloads INT DEFAULT 0;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS revenue DECIMAL(10, 2) DEFAULT 0;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS rating DECIMAL(3, 2) DEFAULT 0.00;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS review_count INT DEFAULT 0;

-- Feature columns
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS tags TEXT[];
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS difficulty VARCHAR(20) CHECK (difficulty IN ('beginner', 'intermediate', 'advanced'));
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS estimated_time INT;

-- Status columns
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE;

-- Timestamp columns
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Step 3: Create necessary indexes
CREATE INDEX IF NOT EXISTS idx_workflows_slug ON workflows(slug);
CREATE INDEX IF NOT EXISTS idx_workflows_category ON workflows(category);
CREATE INDEX IF NOT EXISTS idx_workflows_is_active ON workflows(is_active);
CREATE INDEX IF NOT EXISTS idx_workflows_is_featured ON workflows(is_featured);
CREATE INDEX IF NOT EXISTS idx_workflows_tags ON workflows USING GIN(tags);

-- Step 4: Create unique constraint on slug if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'workflows_slug_key'
    ) THEN
        ALTER TABLE workflows ADD CONSTRAINT workflows_slug_key UNIQUE (slug);
    END IF;
END $$;

-- Step 5: Verify all columns are now present
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'workflows'
ORDER BY ordinal_position;

-- Step 6: Show any existing data
SELECT id, name, category, price, downloads, is_active
FROM workflows
LIMIT 5;
