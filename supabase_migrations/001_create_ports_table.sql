-- Create ports table in Supabase
-- This table stores port information for the ICSTSI application

CREATE TABLE IF NOT EXISTS ports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    port_code VARCHAR(10) NOT NULL UNIQUE,
    port_name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster searches
CREATE INDEX IF NOT EXISTS idx_ports_port_code ON ports(port_code);
CREATE INDEX IF NOT EXISTS idx_ports_port_name ON ports(port_name);
CREATE INDEX IF NOT EXISTS idx_ports_country ON ports(country);

-- Enable Row Level Security
ALTER TABLE ports ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for authenticated users
CREATE POLICY "Allow all operations for authenticated users" ON ports
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Create policy to allow read access for anonymous users
CREATE POLICY "Allow read access for anonymous users" ON ports
    FOR SELECT
    TO anon
    USING (true);

-- Insert sample port data
INSERT INTO ports (port_code, port_name, location, country) VALUES
    ('USNYC', 'Port of New York and New Jersey', 'New York', 'United States'),
    ('USLAX', 'Port of Los Angeles', 'Los Angeles', 'United States'),
    ('CNSHA', 'Port of Shanghai', 'Shanghai', 'China'),
    ('SGSIN', 'Port of Singapore', 'Singapore', 'Singapore'),
    ('NLRTM', 'Port of Rotterdam', 'Rotterdam', 'Netherlands'),
    ('DEHAM', 'Port of Hamburg', 'Hamburg', 'Germany'),
    ('HKHKG', 'Port of Hong Kong', 'Hong Kong', 'Hong Kong'),
    ('KRPUS', 'Port of Busan', 'Busan', 'South Korea'),
    ('AEDXB', 'Port of Dubai', 'Dubai', 'United Arab Emirates'),
    ('GBLON', 'Port of London', 'London', 'United Kingdom'),
    ('INMUN', 'Jawaharlal Nehru Port', 'Mumbai', 'India'),
    ('JPTYO', 'Port of Tokyo', 'Tokyo', 'Japan'),
    ('AUBNE', 'Port of Brisbane', 'Brisbane', 'Australia'),
    ('BRSAO', 'Port of Santos', 'Santos', 'Brazil'),
    ('MXVER', 'Port of Veracruz', 'Veracruz', 'Mexico')
ON CONFLICT (port_code) DO NOTHING;

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_ports_updated_at
    BEFORE UPDATE ON ports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE ports IS 'Stores port information for container shipping operations';
COMMENT ON COLUMN ports.port_code IS 'UN/LOCODE port code (e.g., USNYC for New York)';
COMMENT ON COLUMN ports.port_name IS 'Full name of the port';
COMMENT ON COLUMN ports.location IS 'City or region where the port is located';
COMMENT ON COLUMN ports.country IS 'Country where the port is located';
