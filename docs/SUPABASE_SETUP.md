# Supabase Database Setup Guide

## Overview

This guide walks you through setting up the Supabase database for the ICSTSI application, including applying migrations and configuring the vessels table.

## Prerequisites

- Supabase account (free tier is sufficient for development)
- Supabase CLI installed (optional, but recommended)
- Flutter development environment set up

## Option 1: Using Supabase CLI (Recommended)

### Step 1: Install Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Windows (via Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Linux
brew install supabase/tap/supabase
```

### Step 2: Initialize Supabase Project

```bash
# Navigate to your project directory
cd icstsi

# Initialize Supabase (if not already done)
supabase init

# Link to your Supabase project
supabase link --project-ref your-project-ref
```

### Step 3: Apply Migrations

```bash
# Apply all pending migrations
supabase db push

# Verify migration was applied
supabase db diff
```

### Step 4: Verify Tables

```bash
# Open Supabase Studio locally
supabase start

# Or check via CLI
supabase db inspect
```

## Option 2: Using Supabase Dashboard (Manual)

### Step 1: Access SQL Editor

1. Log in to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Execute Migration SQL

1. Open the migration file: `supabase/migrations/20240101000001_create_vessels_table.sql`
2. Copy the entire SQL content
3. Paste into the SQL Editor
4. Click **Run** or press `Ctrl+Enter` (Windows/Linux) / `Cmd+Enter` (macOS)

### Step 3: Verify Table Creation

1. Navigate to **Table Editor** in the left sidebar
2. You should see the `vessels` table listed
3. Click on the table to view its structure
4. Verify that sample data (3 vessels) has been inserted

### Step 4: Check Indexes and Policies

1. Navigate to **Database** → **Indexes**
2. Verify that all vessel indexes are created:
   - `idx_vessels_vessel_name`
   - `idx_vessels_imo_number`
   - `idx_vessels_flag_state`
   - `idx_vessels_vessel_type`
   - `idx_vessels_status`
   - `idx_vessels_owner`
   - `idx_vessels_operator`
   - `idx_vessels_created_at`

3. Navigate to **Authentication** → **Policies**
4. Verify RLS policies for the `vessels` table:
   - Allow authenticated users to read vessels
   - Allow authenticated users to insert vessels
   - Allow authenticated users to update vessels
   - Allow authenticated users to delete vessels

## Configure Flutter App

### Step 1: Get Supabase Credentials

1. In Supabase Dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key (starts with `eyJ...`)

### Step 2: Create Environment File

Create a `.env` file in the project root (if not exists):

```bash
# .env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 3: Update Flutter Configuration

Ensure `lib/main.dart` initializes Supabase correctly:

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const MyApp());
}
```

### Step 4: Test Connection

Run a simple test to verify the connection:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testConnection() async {
  try {
    final response = await Supabase.instance.client
        .from('vessels')
        .select()
        .limit(1);
    
    print('✅ Connection successful! Found ${response.length} vessel(s)');
  } catch (e) {
    print('❌ Connection failed: $e');
  }
}
```

## Verify Installation

### Test Queries

Run these SQL queries in the Supabase SQL Editor to verify everything is working:

#### 1. Count Vessels

```sql
SELECT COUNT(*) as total_vessels FROM vessels;
-- Expected: 3 (sample data)
```

#### 2. List All Vessels

```sql
SELECT 
  vessel_name, 
  imo_number, 
  vessel_type, 
  flag_state, 
  teu_capacity 
FROM vessels 
ORDER BY vessel_name;
```

#### 3. Check Constraints

```sql
-- This should FAIL (IMO number too short)
INSERT INTO vessels (vessel_name, imo_number, flag_state, vessel_type)
VALUES ('Test Vessel', '12345', 'USA', 'Container Ship');

-- This should SUCCEED
INSERT INTO vessels (vessel_name, imo_number, flag_state, vessel_type)
VALUES ('Test Vessel', '1234567', 'USA', 'Container Ship');
```

#### 4. Test Trigger (updated_at)

```sql
-- Update a vessel
UPDATE vessels 
SET vessel_name = 'MSC GÜLSÜN (Updated)' 
WHERE imo_number = '9839850';

-- Check that updated_at changed
SELECT vessel_name, created_at, updated_at 
FROM vessels 
WHERE imo_number = '9839850';
-- updated_at should be more recent than created_at
```

### Test from Flutter App

Create a test screen or run this in your app:

```dart
import 'package:flutter/material.dart';
import '../services/vessel_service.dart';

class VesselTestScreen extends StatefulWidget {
  const VesselTestScreen({Key? key}) : super(key: key);

  @override
  State<VesselTestScreen> createState() => _VesselTestScreenState();
}

class _VesselTestScreenState extends State<VesselTestScreen> {
  final _vesselService = VesselService();
  String _status = 'Not tested';

  Future<void> _testVesselService() async {
    try {
      setState(() => _status = 'Testing...');
      
      // Test: Fetch all vessels
      final vessels = await _vesselService.getVessels();
      
      if (vessels.isEmpty) {
        setState(() => _status = '❌ No vessels found');
        return;
      }
      
      setState(() => _status = '✅ Success! Found ${vessels.length} vessel(s):\n' +
          vessels.map((v) => '- ${v.vesselName} (${v.imoNumber})').join('\n'));
      
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vessel Service Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _testVesselService,
              child: const Text('Test Vessel Service'),
            ),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
```

## Troubleshooting

### Issue: "relation 'vessels' does not exist"

**Solution**: The migration hasn't been applied yet.
- Re-run the migration SQL in Supabase Dashboard
- Or use `supabase db push` if using CLI

### Issue: "permission denied for table vessels"

**Solution**: RLS policies are blocking access.
- Check that you're authenticated (logged in)
- Verify RLS policies in Supabase Dashboard
- Temporarily disable RLS for testing: `ALTER TABLE vessels DISABLE ROW LEVEL SECURITY;`

### Issue: "duplicate key value violates unique constraint"

**Solution**: Trying to insert a vessel with an existing IMO number.
- IMO numbers must be unique
- Check existing vessels before inserting
- Use `UPDATE` instead of `INSERT` if vessel already exists

### Issue: "check constraint 'valid_imo_number' is violated"

**Solution**: IMO number format is incorrect.
- Ensure IMO number is exactly 7 digits
- Use only numeric characters (0-9)
- Example: `9839850` ✅, `IMO9839850` ❌, `983985` ❌

### Issue: Flutter app can't connect to Supabase

**Solution**: Check environment variables and initialization.
1. Verify `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
2. Ensure `Supabase.initialize()` is called in `main()` before `runApp()`
3. Check network connectivity
4. Verify Supabase project is active (not paused)

## Security Considerations

### Production Checklist

Before deploying to production:

- [ ] Review and tighten RLS policies based on user roles
- [ ] Implement role-based access control (RBAC)
- [ ] Enable audit logging for vessel data changes
- [ ] Set up database backups
- [ ] Configure SSL/TLS for database connections
- [ ] Rotate API keys regularly
- [ ] Implement rate limiting
- [ ] Add data validation at application level
- [ ] Set up monitoring and alerts

### Recommended RLS Policies for Production

```sql
-- Example: Only allow vessel managers to modify vessels
CREATE POLICY "Only vessel managers can update vessels"
  ON vessels
  FOR UPDATE
  TO authenticated
  USING (
    auth.jwt() ->> 'role' = 'vessel_manager'
  );

-- Example: Allow all authenticated users to read, but restrict writes
CREATE POLICY "All authenticated users can read vessels"
  ON vessels
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can insert vessels"
  ON vessels
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.jwt() ->> 'role' IN ('admin', 'vessel_manager')
  );
```

## Backup and Recovery

### Manual Backup

```bash
# Using Supabase CLI
supabase db dump -f backup.sql

# Or using pg_dump directly
pg_dump -h db.your-project-ref.supabase.co \
        -U postgres \
        -d postgres \
        -t vessels \
        > vessels_backup.sql
```

### Restore from Backup

```bash
# Using Supabase CLI
supabase db reset

# Or using psql
psql -h db.your-project-ref.supabase.co \
     -U postgres \
     -d postgres \
     < vessels_backup.sql
```

## Next Steps

After setting up the vessels table:

1. ✅ Test CRUD operations from Flutter app
2. ✅ Verify RLS policies work as expected
3. ✅ Add more sample data if needed
4. ✅ Set up related tables (bookings, schedules, etc.)
5. ✅ Implement vessel search and filtering UI
6. ✅ Add vessel form validation
7. ✅ Set up automated backups
8. ✅ Configure monitoring and alerts

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

## Support

For issues or questions:
- Check the [Supabase Discord](https://discord.supabase.com)
- Review [Supabase GitHub Issues](https://github.com/supabase/supabase/issues)
- Consult the project documentation in `docs/VESSEL_DATA_MODEL.md`

---

**Last Updated**: 2024-01-01  
**Version**: 1.0.0  
**Maintainer**: ICSTSI Development Team
