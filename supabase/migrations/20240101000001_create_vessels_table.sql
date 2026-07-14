-- Create vessels table for comprehensive vessel master data management
-- This table serves as the master data source for vessel information
-- Referenced by bookings and other operational tables

CREATE TABLE IF NOT EXISTS vessels (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Core Identification (Required)
  vessel_name TEXT NOT NULL,
  imo_number TEXT NOT NULL UNIQUE, -- International Maritime Organization number (7 digits)
  
  -- Secondary Identification (Optional)
  mmsi TEXT, -- Maritime Mobile Service Identity (9 digits)
  call_sign TEXT,
  official_number TEXT,
  
  -- Classification & Registration (Required)
  flag_state TEXT NOT NULL, -- Country of registration
  port_of_registry TEXT,
  vessel_type TEXT NOT NULL, -- Container Ship, Bulk Carrier, Tanker, etc.
  classification_society TEXT, -- Lloyd's Register, DNV GL, ABS, etc.
  status TEXT DEFAULT 'Active', -- Active, Inactive, Under Maintenance, Decommissioned
  
  -- Physical Specifications (Optional)
  length_overall NUMERIC(8,2), -- meters
  beam NUMERIC(8,2), -- meters (width)
  draft NUMERIC(8,2), -- meters (depth)
  gross_tonnage NUMERIC(12,2), -- GT
  net_tonnage NUMERIC(12,2), -- NT
  deadweight_tonnage NUMERIC(12,2), -- DWT
  teu_capacity INTEGER, -- Twenty-foot Equivalent Unit capacity
  
  -- Build Information (Optional)
  build_year INTEGER,
  builder TEXT,
  build_country TEXT,
  
  -- Operational Details (Optional)
  owner TEXT,
  operator TEXT,
  manager TEXT,
  engine_type TEXT,
  service_speed NUMERIC(6,2), -- knots
  max_speed NUMERIC(6,2), -- knots
  fuel_type TEXT,
  fuel_capacity NUMERIC(12,2), -- metric tons
  
  -- Additional Information (Optional)
  hull_number TEXT,
  previous_names TEXT, -- Comma-separated list of previous vessel names
  notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_imo_number CHECK (LENGTH(imo_number) = 7 AND imo_number ~ '^[0-9]+$'),
  CONSTRAINT valid_mmsi CHECK (mmsi IS NULL OR (LENGTH(mmsi) = 9 AND mmsi ~ '^[0-9]+$')),
  CONSTRAINT valid_status CHECK (status IN ('Active', 'Inactive', 'Under Maintenance', 'Decommissioned')),
  CONSTRAINT valid_build_year CHECK (build_year IS NULL OR (build_year >= 1800 AND build_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 5)),
  CONSTRAINT positive_dimensions CHECK (
    (length_overall IS NULL OR length_overall > 0) AND
    (beam IS NULL OR beam > 0) AND
    (draft IS NULL OR draft > 0) AND
    (gross_tonnage IS NULL OR gross_tonnage > 0) AND
    (net_tonnage IS NULL OR net_tonnage > 0) AND
    (deadweight_tonnage IS NULL OR deadweight_tonnage > 0) AND
    (teu_capacity IS NULL OR teu_capacity > 0) AND
    (service_speed IS NULL OR service_speed > 0) AND
    (max_speed IS NULL OR max_speed > 0) AND
    (fuel_capacity IS NULL OR fuel_capacity > 0)
  )
);

-- Create indexes for common query patterns
CREATE INDEX idx_vessels_vessel_name ON vessels(vessel_name);
CREATE INDEX idx_vessels_imo_number ON vessels(imo_number);
CREATE INDEX idx_vessels_flag_state ON vessels(flag_state);
CREATE INDEX idx_vessels_vessel_type ON vessels(vessel_type);
CREATE INDEX idx_vessels_status ON vessels(status);
CREATE INDEX idx_vessels_owner ON vessels(owner);
CREATE INDEX idx_vessels_operator ON vessels(operator);
CREATE INDEX idx_vessels_created_at ON vessels(created_at DESC);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_vessels_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on row updates
CREATE TRIGGER trigger_update_vessels_updated_at
  BEFORE UPDATE ON vessels
  FOR EACH ROW
  EXECUTE FUNCTION update_vessels_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE vessels ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
-- Policy: Allow authenticated users to read all vessels
CREATE POLICY "Allow authenticated users to read vessels"
  ON vessels
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow authenticated users to insert vessels
CREATE POLICY "Allow authenticated users to insert vessels"
  ON vessels
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy: Allow authenticated users to update vessels
CREATE POLICY "Allow authenticated users to update vessels"
  ON vessels
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy: Allow authenticated users to delete vessels
CREATE POLICY "Allow authenticated users to delete vessels"
  ON vessels
  FOR DELETE
  TO authenticated
  USING (true);

-- Insert sample vessel data for testing
INSERT INTO vessels (
  vessel_name,
  imo_number,
  mmsi,
  call_sign,
  flag_state,
  port_of_registry,
  vessel_type,
  classification_society,
  status,
  length_overall,
  beam,
  draft,
  gross_tonnage,
  net_tonnage,
  deadweight_tonnage,
  teu_capacity,
  build_year,
  builder,
  build_country,
  owner,
  operator,
  engine_type,
  service_speed,
  max_speed,
  fuel_type,
  fuel_capacity
) VALUES
(
  'MSC GÜLSÜN',
  '9839850',
  '636019825',
  '9HA4489',
  'Panama',
  'Panama City',
  'Container Ship',
  'Lloyd''s Register',
  'Active',
  399.90,
  61.50,
  16.50,
  232618.00,
  139434.00,
  223773.00,
  23756,
  2019,
  'Samsung Heavy Industries',
  'South Korea',
  'Mediterranean Shipping Company',
  'MSC Ship Management',
  'MAN B&W 11S90ME-C10.5',
  22.80,
  24.00,
  'Heavy Fuel Oil',
  18000.00
),
(
  'EVER GIVEN',
  '9811000',
  '353136000',
  'HPJY',
  'Panama',
  'Panama City',
  'Container Ship',
  'Lloyd''s Register',
  'Active',
  399.94,
  58.80,
  16.00,
  220940.00,
  99155.00,
  199629.00,
  20124,
  2018,
  'Imabari Shipbuilding',
  'Japan',
  'Shoei Kisen Kaisha',
  'Evergreen Marine',
  'MAN B&W 11S90ME-C9.5',
  22.50,
  24.00,
  'Heavy Fuel Oil',
  17000.00
),
(
  'MAERSK ESSEX',
  '9632065',
  '219018000',
  'OXQN2',
  'Denmark',
  'Copenhagen',
  'Container Ship',
  'Det Norske Veritas',
  'Active',
  367.28,
  48.20,
  15.50,
  156907.00,
  82377.00,
  165000.00,
  15500,
  2015,
  'Daewoo Shipbuilding',
  'South Korea',
  'A.P. Moller-Maersk',
  'Maersk Line',
  'MAN B&W 9S90ME-C10.2',
  23.00,
  25.00,
  'Heavy Fuel Oil',
  14500.00
);

-- Add comments to the table and key columns for documentation
COMMENT ON TABLE vessels IS 'Master data table for vessel information - stores comprehensive vessel identification, specifications, and operational details';
COMMENT ON COLUMN vessels.imo_number IS 'International Maritime Organization number - unique 7-digit identifier';
COMMENT ON COLUMN vessels.mmsi IS 'Maritime Mobile Service Identity - unique 9-digit identifier for AIS';
COMMENT ON COLUMN vessels.teu_capacity IS 'Twenty-foot Equivalent Unit capacity - standard container capacity measure';
COMMENT ON COLUMN vessels.deadweight_tonnage IS 'Maximum weight a vessel can safely carry including cargo, fuel, crew, and provisions';
