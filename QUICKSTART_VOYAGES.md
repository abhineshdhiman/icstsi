# 🚢 Quick Start: Voyages Table Setup

**Problem:** Getting error `Could not find the table 'public.voyages'`

**Solution:** Run the database migration to create the table.

## ⚡ Fastest Method (2 minutes)

### Step 1: Copy the SQL

Open this file and copy its contents:
```
supabase/migrations/20240101000002_create_voyages_table.sql
```

### Step 2: Run in Supabase

1. Go to https://app.supabase.com
2. Open your ICSTSI project
3. Click **SQL Editor** in the left sidebar
4. Click **New query**
5. Paste the SQL you copied
6. Click **Run** (or press Cmd+Enter / Ctrl+Enter)

### Step 3: Verify

You should see: `Success. No rows returned`

Run this to check:
```sql
SELECT * FROM public.voyages;
```

You should see 3 sample voyages! 🎉

### Step 4: Restart the Flutter App

```bash
# Stop the app (Ctrl+C in terminal)
# Then restart:
flutter run
```

Navigate to the Voyages screen - you should now see the sample voyages displayed with the VoyageTimeline widget!

---

## 🔧 Alternative: Using the Setup Script

```bash
chmod +x scripts/setup_voyages_table.sh
./scripts/setup_voyages_table.sh
```

Choose option 1 to copy SQL to clipboard, then paste in Supabase Dashboard.

---

## 📚 Full Documentation

For detailed information, see:
- `docs/VOYAGE_IMPLEMENTATION.md` - Complete implementation guide
- `supabase/README.md` - Database migration details

---

## ✅ What Gets Created

The migration creates:

- ✅ `voyages` table with all fields
- ✅ Foreign key to `vessels` table
- ✅ Indexes for performance
- ✅ Row Level Security (RLS) policies
- ✅ Auto-updating `updated_at` trigger
- ✅ 3 sample voyages for testing

---

## 🐛 Still Having Issues?

### Error: "relation 'public.vessels' does not exist"

You need to create the vessels table first. The voyages table references vessels.

### Error: "permission denied"

Check that you're logged in to Supabase and have the correct project selected.

### No data showing in app

1. Verify migration ran: Check SQL Editor for the voyages table
2. Check Supabase credentials in `.env` file
3. Restart the Flutter app

---

**Need Help?** Check the full documentation in `docs/VOYAGE_IMPLEMENTATION.md`
