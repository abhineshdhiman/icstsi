-- Create bookings table in Supabase
-- This table stores booking information with references to vessels and ports

CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_reference TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
  booking_date TIMESTAMPTZ NOT NULL,
  discharge_date TIMESTAMPTZ,
  gate_out_date TIMESTAMPTZ,
  vessel_id UUID NOT NULL REFERENCES vessels(id) ON DELETE CASCADE,
  port_id UUID NOT NULL REFERENCES ports(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_bookings_vessel_id ON bookings(vessel_id);
CREATE INDEX IF NOT EXISTS idx_bookings_port_id ON bookings(port_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX IF NOT EXISTS idx_bookings_booking_reference ON bookings(booking_reference);

-- Enable Row Level Security (RLS)
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Create policies (adjust based on your authentication requirements)
-- Example: Allow authenticated users to read all bookings
CREATE POLICY "Allow authenticated users to read bookings"
  ON bookings
  FOR SELECT
  TO authenticated
  USING (true);

-- Example: Allow authenticated users to insert bookings
CREATE POLICY "Allow authenticated users to insert bookings"
  ON bookings
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Example: Allow authenticated users to update bookings
CREATE POLICY "Allow authenticated users to update bookings"
  ON bookings
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Example: Allow authenticated users to delete bookings
CREATE POLICY "Allow authenticated users to delete bookings"
  ON bookings
  FOR DELETE
  TO authenticated
  USING (true);

-- Add comments for documentation
COMMENT ON TABLE bookings IS 'Stores booking information with references to vessels and ports';
COMMENT ON COLUMN bookings.booking_reference IS 'Unique booking reference number';
COMMENT ON COLUMN bookings.status IS 'Booking status: pending, confirmed, cancelled, or completed';
COMMENT ON COLUMN bookings.booking_date IS 'Date and time when the booking was made';
COMMENT ON COLUMN bookings.discharge_date IS 'Date and time when cargo is discharged';
COMMENT ON COLUMN bookings.gate_out_date IS 'Date and time when container exits the port gate';
COMMENT ON COLUMN bookings.vessel_id IS 'Foreign key reference to vessels table';
COMMENT ON COLUMN bookings.port_id IS 'Foreign key reference to ports table';
