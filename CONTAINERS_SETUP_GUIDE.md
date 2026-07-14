# 📦 ICSTSI Containers Setup Guide

## Overview
This guide covers the complete setup of the **Container Management System** for ICSTSI, including database schema, Flutter implementation, and testing.

---

## 🗄️ Database Schema

### Containers Table Structure

```sql
CREATE TABLE public.containers (
    id UUID PRIMARY KEY,
    container_number VARCHAR(11) UNIQUE,  -- ISO 6346 format: ABCD1234567
    type VARCHAR(50),                      -- dry, reefer, open_top, flat_rack, tank
    size VARCHAR(10),                      -- 20ft, 40ft, 40ft_hc, 45ft
    status VARCHAR(20),                    -- available, in_use, maintenance, damaged, reserved
    booking_id UUID REFERENCES bookings(id),
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);
```

### Relationships
- **containers.booking_id** → **bookings.id** (many-to-one, nullable)
  - A container can be linked to one booking
  - When booking is deleted, `booking_id` is set to NULL (ON DELETE SET NULL)

### Constraints
- ✅ Container number must match ISO 6346 format: `^[A-Z]{4}[0-9]{7}$`
- ✅ Type must be one of: `dry`, `reefer`, `open_top`, `flat_rack`, `tank`
- ✅ Size must be one of: `20ft`, `40ft`, `40ft_hc`, `45ft`
- ✅ Status must be one of: `available`, `in_use`, `maintenance`, `damaged`, `reserved`

### Indexes
- `container_number` (unique)
- `status` (for filtering)
- `booking_id` (for joins)
- `type` (for filtering)
- `size` (for filtering)
- `created_at` (for sorting)
- Composite: `(status, type)` (for common queries)

---

## 🚀 Setup Instructions

### Step 1: Run Database Migrations (IN ORDER)

**Important:** Run migrations in this exact order:

```bash
# 1. Vessels table (required for bookings)
supabase_migrations/create_vessels_table.sql

# 2. Ports table (required for bookings)
supabase_migrations/create_ports_table.sql

# 3. Bookings table (required for containers)
supabase_migrations/create_bookings_table.sql

# 4. Containers table (depends on bookings)
supabase_migrations/create_containers_table.sql
```

**How to run:**
1. Open Supabase Dashboard → SQL Editor
2. Copy and paste each migration file
3. Click "Run" for each one
4. Verify no errors in the output

### Step 2: Add Sample Data

After running migrations, add sample data for testing:

```sql
-- Sample Vessels
INSERT INTO public.vessels (vessel_name, imo_number, flag_state, vessel_type) VALUES
    ('MSC GÜLSÜN', '9839450', 'Panama', 'Container Ship'),
    ('EVER GIVEN', '9811000', 'Panama', 'Container Ship'),
    ('CMA CGM ANTOINE DE SAINT EXUPERY', '9454436', 'Malta', 'Container Ship');

-- Sample Ports
INSERT INTO public.ports (port_code, port_name, location, country) VALUES
    ('SGSIN', 'Singapore', 'Singapore', 'Singapore'),
    ('NLRTM', 'Rotterdam', 'Rotterdam', 'Netherlands'),
    ('CNSHA', 'Shanghai', 'Shanghai', 'China');

-- Sample Bookings (get vessel_id and port_id from above inserts)
INSERT INTO public.bookings (booking_reference, status, vessel_id, port_id, booking_date)
SELECT 
    'BKG-2024-001',
    'confirmed',
    v.id,
    p.id,
    NOW()
FROM vessels v, ports p
WHERE v.vessel_name = 'MSC GÜLSÜN' AND p.port_code = 'SGSIN'
LIMIT 1;

-- Sample Containers
INSERT INTO public.containers (container_number, type, size, status, booking_id) VALUES
    ('MSCU1234567', 'dry', '20ft', 'available', NULL),
    ('MSCU2345678', 'dry', '40ft', 'available', NULL),
    ('MSCU3456789', 'reefer', '40ft_hc', 'available', NULL),
    ('MSCU4567890', 'dry', '40ft', 'in_use', (SELECT id FROM bookings WHERE booking_reference = 'BKG-2024-001')),
    ('MSCU5678901', 'open_top', '20ft', 'available', NULL),
    ('MSCU6789012', 'flat_rack', '40ft', 'available', NULL),
    ('MSCU7890123', 'tank', '20ft', 'maintenance', NULL),
    ('MSCU8901234', 'dry', '40ft_hc', 'available', NULL),
    ('MSCU9012345', 'reefer', '40ft', 'reserved', NULL),
    ('MSCU0123456', 'dry', '20ft', 'damaged', NULL);
```

### Step 3: Verify Data

```sql
-- Check containers with booking details
SELECT 
    c.container_number,
    c.type,
    c.size,
    c.status,
    b.booking_reference,
    v.vessel_name,
    p.port_name
FROM containers c
LEFT JOIN bookings b ON c.booking_id = b.id
LEFT JOIN vessels v ON b.vessel_id = v.id
LEFT JOIN ports p ON b.port_id = p.id
ORDER BY c.created_at DESC;
```

---

## 📱 Flutter Implementation

### Files Structure

```
lib/
├── models/
│   └── container.dart              ✅ Container model with Booking reference
├── services/
│   └── container_service.dart      ✅ CRUD operations + filtering
├── widgets/
│   ├── container_card.dart         ✅ Display container info
│   └── container_list.dart         ✅ List with pull-to-refresh
└── screens/
    └── containers_screen.dart      ✅ Main screen with status filters
```

### Key Features

#### 1. **Container Model** (`lib/models/container.dart`)
- Properties: id, containerNumber, type, size, status, bookingId
- Nested Booking object (populated via join)
- Status color mapping
- JSON serialization

#### 2. **Container Service** (`lib/services/container_service.dart`)
- `getContainers()` - Fetch all containers with bookings
- `getContainerById(id)` - Fetch single container
- `createContainer(data)` - Create new container
- `updateContainer(id, data)` - Update container
- `deleteContainer(id)` - Delete container
- `getContainersByStatus(status)` - Filter by status
- `getContainersByBooking(bookingId)` - Filter by booking

#### 3. **Container Card** (`lib/widgets/container_card.dart`)
- Displays container number, type, size
- Color-coded status badge
- Shows linked booking reference (if any)
- Tap to view details

#### 4. **Container List** (`lib/widgets/container_list.dart`)
- Pull-to-refresh functionality
- Status filtering
- Loading states
- Error handling with retry
- Empty state

#### 5. **Containers Screen** (`lib/screens/containers_screen.dart`)
- Filter chips for status selection
- Horizontal scrollable filters
- Real-time filtering
- ICSTSI design system

---

## 🎨 Design System

### Colors
- **Primary:** `#FF6319` (ICSTSI Orange)
- **Text:** `#1A1919` (Dark Gray)
- **Background:** `#F5F5F5` (Light Gray)

### Status Colors
| Status | Color | Hex |
|--------|-------|-----|
| Available | Green | `#4CAF50` |
| In Use | Blue | `#2196F3` |
| Maintenance | Orange | `#FFA726` |
| Damaged | Red | `#EF5350` |
| Reserved | Purple | `#9C27B0` |

### Typography
- **Title:** 16px, FontWeight.w600
- **Subtitle:** 14px, FontWeight.normal
- **Caption:** 12px, FontWeight.w500

### Spacing
- Card padding: 16px
- Card margin: 8px horizontal, 4px vertical
- Border radius: 8px
- Card elevation: 2

---

## 🧪 Testing Checklist

### Database Tests
- [ ] Containers table created successfully
- [ ] Foreign key to bookings works
- [ ] Constraints validate data correctly
- [ ] Indexes improve query performance
- [ ] RLS policies allow authenticated access
- [ ] Sample data inserted without errors

### Flutter Tests
- [ ] App launches without errors
- [ ] "View Containers" button navigates correctly
- [ ] Containers list displays all containers
- [ ] Status filter chips work correctly
- [ ] Pull-to-refresh updates the list
- [ ] Container cards show correct information
- [ ] Status badges display correct colors
- [ ] Booking reference shows when linked
- [ ] Empty state displays when no containers
- [ ] Error state shows with retry button

### Integration Tests
- [ ] Container linked to booking displays booking info
- [ ] Deleting a booking sets container.booking_id to NULL
- [ ] Creating a container with invalid data shows error
- [ ] Filtering by status returns correct results
- [ ] Search by container number works

---

## 🔧 Troubleshooting

### Error: "Could not find a relationship between 'containers' and 'bookings'"

**Cause:** Containers table doesn't exist or foreign key is missing.

**Solution:**
1. Run `create_containers_table.sql` migration
2. Verify foreign key exists:
   ```sql
   SELECT
       tc.constraint_name,
       tc.table_name,
       kcu.column_name,
       ccu.table_name AS foreign_table_name,
       ccu.column_name AS foreign_column_name
   FROM information_schema.table_constraints AS tc
   JOIN information_schema.key_column_usage AS kcu
       ON tc.constraint_name = kcu.constraint_name
   JOIN information_schema.constraint_column_usage AS ccu
       ON ccu.constraint_name = tc.constraint_name
   WHERE tc.table_name = 'containers' AND tc.constraint_type = 'FOREIGN KEY';
   ```

### Error: "Failed to load containers"

**Cause:** RLS policies blocking access or table doesn't exist.

**Solution:**
1. Check if user is authenticated
2. Verify RLS policies:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'containers';
   ```
3. Test query manually in Supabase SQL Editor

### Error: "Container number format invalid"

**Cause:** Container number doesn't match ISO 6346 format.

**Solution:**
- Use format: 4 uppercase letters + 7 digits (e.g., `MSCU1234567`)
- Check constraint: `^[A-Z]{4}[0-9]{7}$`

### Empty List in Flutter

**Cause:** No data in database or query failing.

**Solution:**
1. Check Supabase logs for errors
2. Verify sample data exists:
   ```sql
   SELECT COUNT(*) FROM containers;
   ```
3. Check Flutter console for error messages

---

## 📊 Sample Queries

### Get all available containers
```sql
SELECT * FROM containers WHERE status = 'available' ORDER BY container_number;
```

### Get containers by type and size
```sql
SELECT * FROM containers 
WHERE type = 'dry' AND size = '40ft' 
ORDER BY status, container_number;
```

### Get containers with booking details
```sql
SELECT 
    c.*,
    b.booking_reference,
    v.vessel_name,
    p.port_name
FROM containers c
LEFT JOIN bookings b ON c.booking_id = b.id
LEFT JOIN vessels v ON b.vessel_id = v.id
LEFT JOIN ports p ON b.port_id = p.id
WHERE c.status = 'in_use';
```

### Count containers by status
```sql
SELECT status, COUNT(*) as count
FROM containers
GROUP BY status
ORDER BY count DESC;
```

### Find containers without bookings
```sql
SELECT * FROM containers WHERE booking_id IS NULL;
```

---

## 🚀 Next Steps

### Recommended Enhancements
1. **Container Creation Form** - Add screen to create new containers
2. **Container Details Screen** - Full details with edit/delete options
3. **Link Container to Booking** - UI to assign containers to bookings
4. **Container History** - Track status changes over time
5. **Bulk Operations** - Select multiple containers for batch updates
6. **QR Code Scanning** - Scan container numbers
7. **Export to CSV** - Download container inventory
8. **Advanced Filters** - Filter by multiple criteria
9. **Container Tracking** - Real-time location updates
10. **Maintenance Scheduling** - Schedule and track maintenance

---

## 📚 API Reference

### ContainerService Methods

```dart
// Fetch all containers
Future<List<Container>> getContainers()

// Fetch single container
Future<Container?> getContainerById(String id)

// Create container
Future<Container> createContainer(Map<String, dynamic> data)

// Update container
Future<Container> updateContainer(String id, Map<String, dynamic> data)

// Delete container
Future<void> deleteContainer(String id)

// Filter by status
Future<List<Container>> getContainersByStatus(String status)

// Filter by booking
Future<List<Container>> getContainersByBooking(String bookingId)
```

### Example Usage

```dart
// Get all available containers
final containers = await ContainerService().getContainersByStatus('available');

// Create new container
final newContainer = await ContainerService().createContainer({
  'container_number': 'MSCU9999999',
  'type': 'dry',
  'size': '40ft',
  'status': 'available',
});

// Link container to booking
await ContainerService().updateContainer(containerId, {
  'booking_id': bookingId,
  'status': 'in_use',
});
```

---

## ✅ Summary

This guide covers:
- ✅ Complete database schema with constraints and indexes
- ✅ Foreign key relationship to bookings table
- ✅ Row Level Security policies
- ✅ Sample data for testing
- ✅ Flutter implementation details
- ✅ Design system specifications
- ✅ Testing checklist
- ✅ Troubleshooting guide
- ✅ Sample queries and API reference

**Your container management system is now ready to use!** 📦✨
