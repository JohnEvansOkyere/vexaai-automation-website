-- Fix workflows table to ensure all columns exist
-- Run this in your Neon SQL Editor if you encounter column errors

-- Add tags column if it doesn't exist
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS tags TEXT[];

-- Add other potentially missing columns
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS difficulty VARCHAR(20) CHECK (difficulty IN ('beginner', 'intermediate', 'advanced'));
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS estimated_time INT;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS long_description TEXT;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS version VARCHAR(20) DEFAULT '1.0.0';
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS rating DECIMAL(3, 2) DEFAULT 0.00;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS review_count INT DEFAULT 0;
ALTER TABLE workflows ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE;

-- Create index for tags if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_workflows_tags ON workflows USING GIN(tags);

-- Verify the changes
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'workflows'
ORDER BY ordinal_position;
