-- Create ports table in Supabase
-- This table stores port information

CREATE TABLE IF NOT EXISTS ports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  port_code TEXT NOT NULL UNIQUE,
  port_name TEXT NOT NULL,
  location TEXT NOT NULL,
  country TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_ports_port_code ON ports(port_code);
CREATE INDEX IF NOT EXISTS idx_ports_port_name ON ports(port_name);
CREATE INDEX IF NOT EXISTS idx_ports_country ON ports(country);

-- Enable Row Level Security (RLS)
ALTER TABLE ports ENABLE ROW LEVEL SECURITY;

-- Create policies (adjust based on your authentication requirements)
-- Example: Allow authenticated users to read all ports
CREATE POLICY "Allow authenticated users to read ports"
  ON ports
  FOR SELECT
  TO authenticated
  USING (true);

-- Example: Allow authenticated users to insert ports
CREATE POLICY "Allow authenticated users to insert ports"
  ON ports
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Example: Allow authenticated users to update ports
CREATE POLICY "Allow authenticated users to update ports"
  ON ports
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Example: Allow authenticated users to delete ports
CREATE POLICY "Allow authenticated users to delete ports"
  ON ports
  FOR DELETE
  TO authenticated
  USING (true);

-- Add comments for documentation
COMMENT ON TABLE ports IS 'Stores port information';
COMMENT ON COLUMN ports.port_code IS 'Unique port code (e.g., USNYC for New York)';
COMMENT ON COLUMN ports.port_name IS 'Name of the port';
COMMENT ON COLUMN ports.location IS 'City or location of the port';
COMMENT ON COLUMN ports.country IS 'Country where the port is located';
