-- ============================================
-- WORKFLOW TABLE DIAGNOSTIC SCRIPT
-- Copy and paste this entire script into Neon SQL Editor
-- ============================================

-- 1. Check if workflows table exists
SELECT
    CASE
        WHEN EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_name = 'workflows'
        )
        THEN '✅ Table EXISTS'
        ELSE '❌ Table DOES NOT EXIST'
    END as table_status;

-- 2. Show ALL columns in workflows table
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'workflows'
ORDER BY ordinal_position;

-- 3. Count rows in workflows table
SELECT
    COUNT(*) as total_workflows,
    COUNT(*) FILTER (WHERE is_active = TRUE) as active_workflows,
    COUNT(*) FILTER (WHERE workflow_json IS NOT NULL) as workflows_with_json,
    COUNT(*) FILTER (WHERE tags IS NOT NULL) as workflows_with_tags
FROM workflows;

-- 4. Show sample data (if any exists)
SELECT
    id,
    name,
    category,
    price,
    CASE WHEN workflow_json IS NOT NULL THEN 'Yes' ELSE 'No' END as has_json,
    CASE WHEN tags IS NOT NULL THEN array_length(tags, 1) ELSE 0 END as tag_count,
    created_at
FROM workflows
LIMIT 5;

-- 5. Check for required columns
SELECT
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'id') THEN '✅' ELSE '❌' END as id_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'name') THEN '✅' ELSE '❌' END as name_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'slug') THEN '✅' ELSE '❌' END as slug_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'category') THEN '✅' ELSE '❌' END as category_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'workflow_json') THEN '✅' ELSE '❌' END as workflow_json_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'tags') THEN '✅' ELSE '❌' END as tags_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'price') THEN '✅' ELSE '❌' END as price_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'downloads') THEN '✅' ELSE '❌' END as downloads_column,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workflows' AND column_name = 'revenue') THEN '✅' ELSE '❌' END as revenue_column;

-- 6. Check indexes
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'workflows'
ORDER BY indexname;

-- 7. Show table constraints
SELECT
    conname as constraint_name,
    contype as constraint_type,
    CASE contype
        WHEN 'p' THEN 'Primary Key'
        WHEN 'u' THEN 'Unique'
        WHEN 'c' THEN 'Check'
        WHEN 'f' THEN 'Foreign Key'
    END as type_description
FROM pg_constraint
WHERE conrelid = 'workflows'::regclass;

-- ============================================
-- RESULTS INTERPRETATION
-- ============================================
-- Section 1: Should say "✅ Table EXISTS"
-- Section 2: Should show AT LEAST these columns:
--   - id, name, slug, category, workflow_json, tags, price, downloads, revenue
-- Section 3: Shows how many workflows you have
-- Section 4: Shows actual workflow data
-- Section 5: All should show ✅ (checkmark)
-- Section 6: Should show indexes for performance
-- Section 7: Shows table constraints
-- ============================================
