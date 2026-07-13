-- Create vessels table in Supabase
-- This table stores vessel (ship) information

CREATE TABLE IF NOT EXISTS vessels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vessel_name TEXT NOT NULL,
  imo_number TEXT NOT NULL UNIQUE,
  flag_state TEXT NOT NULL,
  vessel_type TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_vessels_imo_number ON vessels(imo_number);
CREATE INDEX IF NOT EXISTS idx_vessels_vessel_name ON vessels(vessel_name);
CREATE INDEX IF NOT EXISTS idx_vessels_vessel_type ON vessels(vessel_type);

-- Enable Row Level Security (RLS)
ALTER TABLE vessels ENABLE ROW LEVEL SECURITY;

-- Create policies (adjust based on your authentication requirements)
-- Example: Allow authenticated users to read all vessels
CREATE POLICY "Allow authenticated users to read vessels"
  ON vessels
  FOR SELECT
  TO authenticated
  USING (true);

-- Example: Allow authenticated users to insert vessels
CREATE POLICY "Allow authenticated users to insert vessels"
  ON vessels
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Example: Allow authenticated users to update vessels
CREATE POLICY "Allow authenticated users to update vessels"
  ON vessels
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Example: Allow authenticated users to delete vessels
CREATE POLICY "Allow authenticated users to delete vessels"
  ON vessels
  FOR DELETE
  TO authenticated
  USING (true);

-- Add comments for documentation
COMMENT ON TABLE vessels IS 'Stores vessel (ship) information';
COMMENT ON COLUMN vessels.vessel_name IS 'Name of the vessel';
COMMENT ON COLUMN vessels.imo_number IS 'International Maritime Organization number (unique identifier)';
COMMENT ON COLUMN vessels.flag_state IS 'Country of vessel registration';
COMMENT ON COLUMN vessels.vessel_type IS 'Type of vessel (e.g., Container Ship, Bulk Carrier, Tanker)';
