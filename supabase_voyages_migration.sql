-- Migration: Create voyages table for tracking vessel movements
-- This SQL should be run in your Supabase SQL Editor

-- Create voyages table
CREATE TABLE IF NOT EXISTS voyages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    voyage_number TEXT NOT NULL UNIQUE,
    vessel_id UUID NOT NULL REFERENCES vessels(id) ON DELETE CASCADE,
    departure_date TIMESTAMPTZ,
    arrival_date TIMESTAMPTZ,
    departure_port TEXT,
    arrival_port TEXT,
    status TEXT NOT NULL DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Delayed', 'Cancelled')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on vessel_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_voyages_vessel_id ON voyages(vessel_id);

-- Create index on departure_date for sorting
CREATE INDEX IF NOT EXISTS idx_voyages_departure_date ON voyages(departure_date DESC);

-- Create index on status for filtering
CREATE INDEX IF NOT EXISTS idx_voyages_status ON voyages(status);

-- Enable Row Level Security
ALTER TABLE voyages ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for authenticated users
-- Adjust these policies based on your security requirements
CREATE POLICY "Allow all operations for authenticated users" ON voyages
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_voyages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
CREATE TRIGGER voyages_updated_at_trigger
    BEFORE UPDATE ON voyages
    FOR EACH ROW
    EXECUTE FUNCTION update_voyages_updated_at();

-- Insert sample data (optional - for testing)
-- Make sure to replace the vessel_id with actual vessel IDs from your vessels table
/*
INSERT INTO voyages (voyage_number, vessel_id, departure_date, arrival_date, departure_port, arrival_port, status, notes)
VALUES 
    ('VOY-2024-001', 'YOUR-VESSEL-UUID-HERE', '2024-01-15 08:00:00+00', '2024-01-25 14:00:00+00', 'Singapore', 'Los Angeles', 'Completed', 'Smooth sailing, no delays'),
    ('VOY-2024-002', 'YOUR-VESSEL-UUID-HERE', '2024-02-01 10:00:00+00', '2024-02-15 16:00:00+00', 'Shanghai', 'Rotterdam', 'In Progress', 'Currently crossing the Indian Ocean'),
    ('VOY-2024-003', 'YOUR-VESSEL-UUID-HERE', '2024-03-01 06:00:00+00', '2024-03-12 12:00:00+00', 'Dubai', 'Hamburg', 'Scheduled', 'Awaiting cargo loading');
*/

-- Grant permissions (adjust based on your needs)
GRANT ALL ON voyages TO authenticated;
GRANT ALL ON voyages TO service_role;
