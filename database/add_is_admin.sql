-- Add is_admin column to users table
-- Run this in your Neon SQL Editor

ALTER TABLE users
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Update the admin user to have is_admin = true
-- Replace with your actual admin email
UPDATE users
SET is_admin = TRUE
WHERE email = 'johnevansokyere@gmail.com';

-- Create index for faster admin queries
CREATE INDEX IF NOT EXISTS idx_users_is_admin ON users(is_admin) WHERE is_admin = TRUE;

-- Optional: Create a view for admin users
CREATE OR REPLACE VIEW admin_users_view AS
SELECT
    id,
    email,
    first_name,
    last_name,
    phone,
    is_verified,
    is_active,
    created_at,
    last_login,
    login_count
FROM users
WHERE is_admin = TRUE AND is_active = TRUE;

COMMENT ON COLUMN users.is_admin IS 'Indicates if user has admin dashboard access';
COMMENT ON VIEW admin_users_view IS 'View of all active admin users for dashboard';
