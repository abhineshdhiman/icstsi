-- Create voyages table
-- This table tracks vessel voyage information with references to vessels

CREATE TABLE IF NOT EXISTS public.voyages (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Core Identification
    voyage_number TEXT NOT NULL UNIQUE,
    vessel_id UUID NOT NULL REFERENCES public.vessels(id) ON DELETE CASCADE,
    
    -- Voyage Details
    departure_date TIMESTAMPTZ,
    arrival_date TIMESTAMPTZ,
    departure_port TEXT,
    arrival_port TEXT,
    
    -- Status
    status TEXT NOT NULL DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Delayed', 'Cancelled')),
    
    -- Additional Information
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_voyages_vessel_id ON public.voyages(vessel_id);
CREATE INDEX IF NOT EXISTS idx_voyages_status ON public.voyages(status);
CREATE INDEX IF NOT EXISTS idx_voyages_departure_date ON public.voyages(departure_date);
CREATE INDEX IF NOT EXISTS idx_voyages_voyage_number ON public.voyages(voyage_number);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_voyages_updated_at
    BEFORE UPDATE ON public.voyages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.voyages ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Enable read access for all authenticated users" ON public.voyages
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Enable insert access for all authenticated users" ON public.voyages
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Enable update access for all authenticated users" ON public.voyages
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable delete access for all authenticated users" ON public.voyages
    FOR DELETE
    TO authenticated
    USING (true);

-- Insert sample data for testing
INSERT INTO public.voyages (voyage_number, vessel_id, departure_date, arrival_date, departure_port, arrival_port, status, notes)
SELECT 
    'VOY-2024-001',
    v.id,
    NOW() - INTERVAL '5 days',
    NOW() + INTERVAL '10 days',
    'Singapore',
    'Rotterdam',
    'In Progress',
    'Regular scheduled voyage with full cargo load'
FROM public.vessels v
LIMIT 1
ON CONFLICT (voyage_number) DO NOTHING;

INSERT INTO public.voyages (voyage_number, vessel_id, departure_date, arrival_date, departure_port, arrival_port, status, notes)
SELECT 
    'VOY-2024-002',
    v.id,
    NOW() + INTERVAL '3 days',
    NOW() + INTERVAL '18 days',
    'Shanghai',
    'Los Angeles',
    'Scheduled',
    'Trans-Pacific route with container cargo'
FROM public.vessels v
LIMIT 1
ON CONFLICT (voyage_number) DO NOTHING;

INSERT INTO public.voyages (voyage_number, vessel_id, departure_date, arrival_date, departure_port, arrival_port, status, notes)
SELECT 
    'VOY-2024-003',
    v.id,
    NOW() - INTERVAL '20 days',
    NOW() - INTERVAL '5 days',
    'Hamburg',
    'New York',
    'Completed',
    'Successfully completed voyage with no delays'
FROM public.vessels v
LIMIT 1
ON CONFLICT (voyage_number) DO NOTHING;

-- Add comment to table
COMMENT ON TABLE public.voyages IS 'Stores voyage information for vessel movements and tracking';
