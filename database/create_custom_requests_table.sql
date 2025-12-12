-- ============================================
-- Custom Requests Table
-- ============================================
-- This table stores custom workflow requests from customers

CREATE TABLE IF NOT EXISTS custom_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    workflow_description TEXT NOT NULL,
    use_case TEXT NOT NULL,
    budget VARCHAR(100),
    timeline VARCHAR(100),

    -- Status tracking
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'rejected', 'cancelled')),
    admin_notes TEXT,
    estimated_price DECIMAL(10, 2),

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_custom_requests_email ON custom_requests(email);
CREATE INDEX idx_custom_requests_status ON custom_requests(status);
CREATE INDEX idx_custom_requests_created_at ON custom_requests(created_at DESC);

-- Trigger for auto-update timestamps
CREATE TRIGGER update_custom_requests_updated_at BEFORE UPDATE ON custom_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE custom_requests IS 'Stores custom workflow requests from customers';
COMMENT ON COLUMN custom_requests.status IS 'Request status: pending, in_progress, completed, rejected, or cancelled';
