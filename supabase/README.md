# Supabase Database Migrations

This directory contains SQL migration files for the ICSTSI project database schema.

## Running Migrations

### Option 1: Using Supabase CLI (Recommended)

If you have the Supabase CLI installed:

```bash
# Link to your Supabase project
supabase link --project-ref your-project-ref

# Run all pending migrations
supabase db push
```

### Option 2: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of the migration file
4. Paste and execute the SQL

### Option 3: Direct SQL Execution

You can also run the SQL directly using any PostgreSQL client connected to your Supabase database.

## Migration Files

### 20240101000002_create_voyages_table.sql

Creates the `voyages` table with the following features:

- **Core Fields:**
  - `id` (UUID, primary key)
  - `voyage_number` (unique identifier)
  - `vessel_id` (foreign key to vessels table)
  
- **Voyage Details:**
  - `departure_date` and `arrival_date` (timestamps with timezone)
  - `departure_port` and `arrival_port` (text)
  
- **Status Tracking:**
  - `status` (enum: Scheduled, In Progress, Completed, Delayed, Cancelled)
  
- **Additional:**
  - `notes` (text)
  - `created_at` and `updated_at` (auto-managed timestamps)

- **Features:**
  - Foreign key constraint to vessels table with CASCADE delete
  - Indexes on vessel_id, status, departure_date, and voyage_number
  - Automatic updated_at timestamp trigger
  - Row Level Security (RLS) enabled
  - Sample data for testing

## Prerequisites

Before running the voyages migration, ensure that:

1. The `vessels` table exists (referenced by foreign key)
2. You have proper authentication set up in Supabase
3. RLS policies are configured according to your security requirements

## Verifying the Migration

After running the migration, verify it worked:

```sql
-- Check if table exists
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'voyages';

-- Check sample data
SELECT * FROM public.voyages;

-- Verify foreign key relationship
SELECT 
    v.voyage_number,
    ve.vessel_name,
    v.departure_port,
    v.arrival_port,
    v.status
FROM public.voyages v
JOIN public.vessels ve ON v.vessel_id = ve.id;
```

## Troubleshooting

### Error: relation "public.vessels" does not exist

The voyages table requires the vessels table to exist first. Create the vessels table before running this migration.

### Error: permission denied

Ensure you have the proper database permissions. You may need to run migrations as a superuser or with elevated privileges.

### RLS Policies

If you encounter permission issues when querying data, check that:
1. You are authenticated
2. RLS policies are correctly configured
3. Your user role has the necessary permissions
