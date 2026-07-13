-- Create vessels table
CREATE TABLE IF NOT EXISTS vessels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vessel_name TEXT NOT NULL,
  imo_number TEXT NOT NULL UNIQUE,
  flag_state TEXT NOT NULL,
  vessel_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on vessel_name for faster queries
CREATE INDEX IF NOT EXISTS idx_vessels_vessel_name ON vessels(vessel_name);

-- Create index on imo_number for faster lookups
CREATE INDEX IF NOT EXISTS idx_vessels_imo_number ON vessels(imo_number);

-- Enable Row Level Security
ALTER TABLE vessels ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for authenticated users
CREATE POLICY "Allow all operations for authenticated users"
  ON vessels
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create policy to allow read access for anonymous users
CREATE POLICY "Allow read access for anonymous users"
  ON vessels
  FOR SELECT
  TO anon
  USING (true);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_vessels_updated_at
  BEFORE UPDATE ON vessels
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO vessels (vessel_name, imo_number, flag_state, vessel_type) VALUES
  ('MSC GÜLSÜN', 'IMO9811000', 'Panama', 'Container Ship'),
  ('EVER GIVEN', 'IMO9811891', 'Panama', 'Container Ship'),
  ('CMA CGM ANTOINE DE SAINT EXUPERY', 'IMO9454436', 'Malta', 'Container Ship'),
  ('OOCL HONG KONG', 'IMO9714335', 'Hong Kong', 'Container Ship'),
  ('COSCO SHIPPING UNIVERSE', 'IMO9795320', 'China', 'Container Ship')
ON CONFLICT (imo_number) DO NOTHING;
