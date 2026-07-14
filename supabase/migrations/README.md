# Database Migrations

This directory contains SQL migration files for the ICSTSI Supabase database.

## Migration Naming Convention

Migrations follow this naming pattern:
```
YYYYMMDDHHMMSS_description_of_change.sql
```

Example: `20240101000001_create_vessels_table.sql`

## Current Migrations

### 20240101000001_create_vessels_table.sql

**Purpose**: Create the vessels master data table with comprehensive fields for vessel management.

**What it does**:
- Creates `vessels` table with 30+ fields covering:
  - Core identification (vessel name, IMO number, MMSI, call sign)
  - Classification & registration (flag state, vessel type, status)
  - Physical specifications (dimensions, tonnage, capacity)
  - Build information (year, builder, country)
  - Operational details (owner, operator, speeds, fuel)
  - Additional metadata (hull number, previous names, notes)
- Adds validation constraints:
  - IMO number must be 7 digits
  - MMSI must be 9 digits (if provided)
  - Status must be valid enum value
  - Build year must be reasonable range
  - All measurements must be positive
- Creates 8 indexes for query optimization
- Sets up automatic `updated_at` timestamp trigger
- Enables Row Level Security (RLS) with policies for authenticated users
- Inserts 3 sample vessels for testing

**Dependencies**: None (first migration)

**Rollback**: See "Rollback Instructions" section below

## Applying Migrations

### Method 1: Supabase CLI (Recommended)

```bash
# Apply all pending migrations
supabase db push

# Check migration status
supabase migration list

# Create a new migration
supabase migration new your_migration_name
```

### Method 2: Supabase Dashboard

1. Open [Supabase Dashboard](https://app.supabase.com)
2. Navigate to **SQL Editor**
3. Copy the migration SQL file content
4. Paste and execute

### Method 3: Direct PostgreSQL Connection

```bash
psql -h db.your-project-ref.supabase.co \
     -U postgres \
     -d postgres \
     -f supabase/migrations/20240101000001_create_vessels_table.sql
```

## Migration Best Practices

### 1. Always Test Locally First

```bash
# Start local Supabase
supabase start

# Apply migration locally
supabase db push

# Test your changes
# ...

# Stop local Supabase
supabase stop
```

### 2. Make Migrations Idempotent

Use `IF NOT EXISTS` and `IF EXISTS` to make migrations safe to run multiple times:

```sql
CREATE TABLE IF NOT EXISTS my_table (...);
DROP TABLE IF EXISTS old_table;
ALTER TABLE my_table ADD COLUMN IF NOT EXISTS new_column TEXT;
```

### 3. Include Rollback Instructions

Always document how to undo a migration:

```sql
-- Rollback:
-- DROP TABLE IF EXISTS vessels CASCADE;
-- DROP FUNCTION IF EXISTS update_vessels_updated_at() CASCADE;
```

### 4. Add Comments

Document your schema with SQL comments:

```sql
COMMENT ON TABLE vessels IS 'Master data table for vessel information';
COMMENT ON COLUMN vessels.imo_number IS 'International Maritime Organization number';
```

### 5. Version Control

- Never modify existing migration files after they've been applied
- Create a new migration to make changes
- Keep migrations in chronological order

## Creating New Migrations

### Step 1: Generate Migration File

```bash
# Using Supabase CLI
supabase migration new add_vessel_images

# Or manually create file
touch supabase/migrations/$(date +%Y%m%d%H%M%S)_add_vessel_images.sql
```

### Step 2: Write Migration SQL

```sql
-- Add vessel_images table
CREATE TABLE IF NOT EXISTS vessel_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vessel_id UUID NOT NULL REFERENCES vessels(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption TEXT,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add index
CREATE INDEX idx_vessel_images_vessel_id ON vessel_images(vessel_id);

-- Enable RLS
ALTER TABLE vessel_images ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Allow authenticated users to read vessel images"
  ON vessel_images FOR SELECT TO authenticated USING (true);
```

### Step 3: Test Migration

```bash
# Apply locally
supabase db push

# Verify
supabase db inspect
```

### Step 4: Apply to Production

```bash
# Link to production project
supabase link --project-ref your-prod-ref

# Push migration
supabase db push
```

## Rollback Instructions

### Rollback: 20240101000001_create_vessels_table.sql

```sql
-- Drop the vessels table and all related objects
DROP TABLE IF EXISTS vessels CASCADE;

-- Drop the trigger function
DROP FUNCTION IF EXISTS update_vessels_updated_at() CASCADE;

-- Note: This will also drop any foreign key constraints
-- referencing the vessels table in other tables
```

To apply rollback:

```bash
# Using Supabase CLI
supabase db reset

# Or manually in SQL Editor
# Copy and execute the rollback SQL above
```

## Migration Checklist

Before applying a migration to production:

- [ ] Migration tested locally
- [ ] Migration is idempotent (safe to run multiple times)
- [ ] Rollback instructions documented
- [ ] Schema changes documented in code comments
- [ ] Indexes added for new columns that will be queried
- [ ] RLS policies configured appropriately
- [ ] Sample data added (if applicable)
- [ ] Related application code updated
- [ ] Team notified of schema changes
- [ ] Database backup created

## Common Migration Patterns

### Adding a Column

```sql
ALTER TABLE vessels 
ADD COLUMN IF NOT EXISTS new_column TEXT;

-- Add index if column will be queried
CREATE INDEX IF NOT EXISTS idx_vessels_new_column 
ON vessels(new_column);

-- Add comment
COMMENT ON COLUMN vessels.new_column IS 'Description of new column';
```

### Modifying a Column

```sql
-- Change column type
ALTER TABLE vessels 
ALTER COLUMN existing_column TYPE TEXT;

-- Add constraint
ALTER TABLE vessels 
ADD CONSTRAINT check_existing_column 
CHECK (existing_column IN ('value1', 'value2'));

-- Set default
ALTER TABLE vessels 
ALTER COLUMN existing_column SET DEFAULT 'default_value';
```

### Removing a Column

```sql
-- Remove column (be careful!)
ALTER TABLE vessels 
DROP COLUMN IF EXISTS old_column;

-- Note: Always check for dependencies first
-- SELECT * FROM information_schema.columns 
-- WHERE table_name = 'vessels' AND column_name = 'old_column';
```

### Adding a Foreign Key

```sql
-- Add foreign key constraint
ALTER TABLE bookings 
ADD CONSTRAINT fk_bookings_vessel 
FOREIGN KEY (vessel_id) 
REFERENCES vessels(id) 
ON DELETE CASCADE;

-- Add index for foreign key
CREATE INDEX IF NOT EXISTS idx_bookings_vessel_id 
ON bookings(vessel_id);
```

### Creating an Enum Type

```sql
-- Create enum type
CREATE TYPE vessel_status AS ENUM (
  'Active', 
  'Inactive', 
  'Under Maintenance', 
  'Decommissioned'
);

-- Use in table
ALTER TABLE vessels 
ALTER COLUMN status TYPE vessel_status 
USING status::vessel_status;
```

## Troubleshooting

### Issue: Migration fails with "relation already exists"

**Solution**: Use `IF NOT EXISTS` in CREATE statements:
```sql
CREATE TABLE IF NOT EXISTS vessels (...);
```

### Issue: Migration fails with "column already exists"

**Solution**: Use `IF NOT EXISTS` in ALTER TABLE:
```sql
ALTER TABLE vessels ADD COLUMN IF NOT EXISTS new_column TEXT;
```

### Issue: Migration fails with "constraint already exists"

**Solution**: Drop and recreate, or use `IF NOT EXISTS`:
```sql
ALTER TABLE vessels DROP CONSTRAINT IF EXISTS constraint_name;
ALTER TABLE vessels ADD CONSTRAINT constraint_name CHECK (...);
```

### Issue: Need to undo a migration

**Solution**: Create a new migration that reverses the changes:
```bash
supabase migration new rollback_previous_change
```

### Issue: Migration order is wrong

**Solution**: Rename migration files to correct the timestamp order:
```bash
mv 20240102000001_wrong_order.sql 20240101000002_correct_order.sql
```

## Database Schema Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                          VESSELS                            │
├─────────────────────────────────────────────────────────────┤
│ id (PK)                    UUID                             │
│ vessel_name                TEXT                             │
│ imo_number (UNIQUE)        TEXT                             │
│ mmsi                       TEXT                             │
│ call_sign                  TEXT                             │
│ flag_state                 TEXT                             │
│ vessel_type                TEXT                             │
│ status                     TEXT                             │
│ ... (30+ more fields)                                       │
│ created_at                 TIMESTAMPTZ                      │
│ updated_at                 TIMESTAMPTZ                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Referenced by:
                              ├─ bookings.vessel_id (FK)
                              ├─ schedules.vessel_id (FK)
                              └─ cargo_manifests.vessel_id (FK)
```

## Future Migrations

Planned migrations for upcoming features:

1. **Vessel Images** - Add support for vessel photos and documents
2. **Voyage History** - Track historical voyages and port calls
3. **Maintenance Records** - Link maintenance schedules and history
4. **Crew Assignments** - Link crew members to vessels
5. **Performance Metrics** - Store fuel consumption, emissions data
6. **AIS Integration** - Real-time vessel tracking data

## Resources

- [Supabase Migrations Guide](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [PostgreSQL ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)
- [PostgreSQL CREATE TABLE](https://www.postgresql.org/docs/current/sql-createtable.html)
- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

**Last Updated**: 2024-01-01  
**Maintainer**: ICSTSI Development Team
