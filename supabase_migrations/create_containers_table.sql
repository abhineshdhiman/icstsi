-- =====================================================
-- ICSTSI Container Management System
-- Table: containers
-- Description: Stores container inventory with booking references
-- =====================================================

-- Create containers table
CREATE TABLE IF NOT EXISTS public.containers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    container_number VARCHAR(11) NOT NULL UNIQUE, -- Standard format: ABCD1234567
    type VARCHAR(50) NOT NULL, -- dry, reefer, open_top, flat_rack, tank
    size VARCHAR(10) NOT NULL, -- 20ft, 40ft, 40ft_hc, 45ft
    status VARCHAR(20) NOT NULL DEFAULT 'available', -- available, in_use, maintenance, damaged, reserved
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comments for documentation
COMMENT ON TABLE public.containers IS 'Container inventory with booking references';
COMMENT ON COLUMN public.containers.container_number IS 'ISO 6346 container number (4 letters + 7 digits)';
COMMENT ON COLUMN public.containers.type IS 'Container type: dry, reefer, open_top, flat_rack, tank';
COMMENT ON COLUMN public.containers.size IS 'Container size: 20ft, 40ft, 40ft_hc, 45ft';
COMMENT ON COLUMN public.containers.status IS 'Current status: available, in_use, maintenance, damaged, reserved';
COMMENT ON COLUMN public.containers.booking_id IS 'Foreign key to bookings table (nullable)';

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_containers_container_number ON public.containers(container_number);
CREATE INDEX IF NOT EXISTS idx_containers_status ON public.containers(status);
CREATE INDEX IF NOT EXISTS idx_containers_booking_id ON public.containers(booking_id);
CREATE INDEX IF NOT EXISTS idx_containers_type ON public.containers(type);
CREATE INDEX IF NOT EXISTS idx_containers_size ON public.containers(size);
CREATE INDEX IF NOT EXISTS idx_containers_created_at ON public.containers(created_at DESC);

-- Create composite index for common queries
CREATE INDEX IF NOT EXISTS idx_containers_status_type ON public.containers(status, type);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_containers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_containers_timestamp
    BEFORE UPDATE ON public.containers
    FOR EACH ROW
    EXECUTE FUNCTION update_containers_updated_at();

-- =====================================================
-- Row Level Security (RLS) Policies
-- =====================================================

-- Enable RLS
ALTER TABLE public.containers ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all authenticated users to read containers
CREATE POLICY "Allow authenticated users to read containers"
    ON public.containers
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Allow authenticated users to insert containers
CREATE POLICY "Allow authenticated users to insert containers"
    ON public.containers
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: Allow authenticated users to update containers
CREATE POLICY "Allow authenticated users to update containers"
    ON public.containers
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy: Allow authenticated users to delete containers
CREATE POLICY "Allow authenticated users to delete containers"
    ON public.containers
    FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- Sample Data (Optional - for testing)
-- =====================================================

-- Insert sample containers
-- Note: Run this AFTER you have bookings in the database
-- Uncomment the lines below to insert sample data:

/*
INSERT INTO public.containers (container_number, type, size, status, booking_id) VALUES
    ('MSCU1234567', 'dry', '20ft', 'available', NULL),
    ('MSCU2345678', 'dry', '40ft', 'available', NULL),
    ('MSCU3456789', 'reefer', '40ft_hc', 'available', NULL),
    ('MSCU4567890', 'dry', '40ft', 'in_use', NULL), -- Link to booking after creation
    ('MSCU5678901', 'open_top', '20ft', 'available', NULL),
    ('MSCU6789012', 'flat_rack', '40ft', 'available', NULL),
    ('MSCU7890123', 'tank', '20ft', 'maintenance', NULL),
    ('MSCU8901234', 'dry', '40ft_hc', 'available', NULL),
    ('MSCU9012345', 'reefer', '40ft', 'reserved', NULL),
    ('MSCU0123456', 'dry', '20ft', 'damaged', NULL);
*/

-- =====================================================
-- Validation Constraints
-- =====================================================

-- Add check constraint for container number format (ISO 6346)
ALTER TABLE public.containers
ADD CONSTRAINT check_container_number_format
CHECK (container_number ~ '^[A-Z]{4}[0-9]{7}$');

-- Add check constraint for valid container types
ALTER TABLE public.containers
ADD CONSTRAINT check_container_type
CHECK (type IN ('dry', 'reefer', 'open_top', 'flat_rack', 'tank'));

-- Add check constraint for valid container sizes
ALTER TABLE public.containers
ADD CONSTRAINT check_container_size
CHECK (size IN ('20ft', '40ft', '40ft_hc', '45ft'));

-- Add check constraint for valid statuses
ALTER TABLE public.containers
ADD CONSTRAINT check_container_status
CHECK (status IN ('available', 'in_use', 'maintenance', 'damaged', 'reserved'));

-- =====================================================
-- Grant Permissions
-- =====================================================

-- Grant usage on the table to authenticated users
GRANT ALL ON public.containers TO authenticated;
GRANT ALL ON public.containers TO service_role;

-- =====================================================
-- Migration Complete
-- =====================================================
-- Run this migration AFTER:
--   1. create_vessels_table.sql
--   2. create_ports_table.sql
--   3. create_bookings_table.sql
-- =====================================================
