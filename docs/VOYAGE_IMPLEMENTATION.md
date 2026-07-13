# Voyage Implementation Guide

This document describes the complete implementation of the Voyage tracking system in the ICSTSI application.

## Overview

The Voyage system tracks vessel movements with departure/arrival dates, ports, and status tracking. It includes:

1. **Database Schema** - Supabase table with foreign key to vessels
2. **Flutter Model** - Dart class with JSON serialization
3. **Service Layer** - API calls to Supabase
4. **UI Component** - VoyageTimeline widget with visual progress tracking

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  VoyageTimeline Widget (lib/widgets/voyage_timeline.dart)│
│           ↓                                             │
│  VoyageService (lib/services/voyage_service.dart)       │
│           ↓                                             │
│  Voyage Model (lib/models/voyage.dart)                  │
│           ↓                                             │
│  Supabase Client                                        │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│              Supabase PostgreSQL                        │
├─────────────────────────────────────────────────────────┤
│  voyages table                                          │
│    - id (UUID, PK)                                      │
│    - voyage_number (TEXT, UNIQUE)                       │
│    - vessel_id (UUID, FK → vessels.id)                  │
│    - departure_date, arrival_date (TIMESTAMPTZ)         │
│    - departure_port, arrival_port (TEXT)                │
│    - status (TEXT, CHECK constraint)                    │
│    - notes (TEXT)                                       │
│    - created_at, updated_at (TIMESTAMPTZ)               │
└─────────────────────────────────────────────────────────┘
```

## Database Setup

### 1. Run the Migration

The `voyages` table must be created in Supabase before the app can function.

**Option A: Using Supabase Dashboard (Easiest)**

1. Go to your Supabase project: https://app.supabase.com
2. Navigate to **SQL Editor**
3. Copy the contents of `supabase/migrations/20240101000002_create_voyages_table.sql`
4. Paste into the SQL Editor
5. Click **Run** to execute

**Option B: Using the Setup Script**

```bash
chmod +x scripts/setup_voyages_table.sh
./scripts/setup_voyages_table.sh
```

**Option C: Using Supabase CLI**

```bash
supabase link --project-ref your-project-ref
supabase db push
```

### 2. Verify the Table

Run this query in the SQL Editor to verify:

```sql
SELECT * FROM public.voyages;
```

You should see 3 sample voyages if the migration ran successfully.

## Flutter Implementation

### Model (lib/models/voyage.dart)

The `Voyage` class represents a vessel voyage with:

- **Core fields**: id, voyageNumber, vesselId
- **Dates**: departureDate, arrivalDate
- **Ports**: departurePort, arrivalPort
- **Status**: Scheduled, In Progress, Completed, Delayed, Cancelled
- **Computed properties**:
  - `durationInDays` - calculates voyage duration
  - `isActive` - checks if voyage is currently in progress
  - `progressPercentage` - calculates 0-100% progress

### Service (lib/services/voyage_service.dart)

The `VoyageService` provides methods to:

- `getVoyages()` - fetch all voyages
- `getVoyagesByVessel(vesselId)` - fetch voyages for a specific vessel
- `getVoyageById(id)` - fetch a single voyage
- `createVoyage(voyage)` - create a new voyage
- `updateVoyage(voyage)` - update an existing voyage
- `deleteVoyage(id)` - delete a voyage
- `getActiveVoyages()` - fetch voyages with status "In Progress"
- `getUpcomingVoyages()` - fetch scheduled future voyages

### Widget (lib/widgets/voyage_timeline.dart)

The `VoyageTimeline` widget displays:

1. **Header** - Voyage number and status badge
2. **Timeline** - Visual representation with:
   - Departure point (calendar icon, date, time, port)
   - Connection line with duration
   - Arrival point (calendar icon, date, time, port)
3. **Progress Bar** - Shows voyage completion percentage
4. **Notes** - Additional voyage information

**Design Features:**
- Calendar icons for dates
- Clock icons for times
- Color-coded status badges:
  - 🟢 Green - In Progress
  - 🔵 Blue - Completed
  - 🟠 Orange - Delayed
  - 🔴 Red - Cancelled
  - ⚪ Gray - Scheduled
- Gradient progress bar
- Responsive layout

## Usage Examples

### Display a Voyage Timeline

```dart
import 'package:flutter/material.dart';
import '../models/voyage.dart';
import '../widgets/voyage_timeline.dart';

class VoyageDetailScreen extends StatelessWidget {
  final Voyage voyage;

  const VoyageDetailScreen({required this.voyage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voyage Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: VoyageTimeline(
          voyage: voyage,
          showProgress: true,
          onTap: () {
            // Handle tap
          },
        ),
      ),
    );
  }
}
```

### Fetch and Display Voyages

```dart
import 'package:flutter/material.dart';
import '../services/voyage_service.dart';
import '../widgets/voyage_timeline.dart';

class VoyagesListScreen extends StatefulWidget {
  @override
  _VoyagesListScreenState createState() => _VoyagesListScreenState();
}

class _VoyagesListScreenState extends State<VoyagesListScreen> {
  final VoyageService _voyageService = VoyageService();
  List<Voyage> _voyages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVoyages();
  }

  Future<void> _loadVoyages() async {
    try {
      final voyages = await _voyageService.getVoyages();
      setState(() {
        _voyages = voyages;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading voyages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _voyages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VoyageTimeline(
            voyage: _voyages[index],
            showProgress: true,
          ),
        );
      },
    );
  }
}
```

### Create a New Voyage

```dart
import '../models/voyage.dart';
import '../services/voyage_service.dart';

Future<void> createNewVoyage() async {
  final voyageService = VoyageService();
  
  final newVoyage = Voyage(
    id: '', // Will be generated by Supabase
    voyageNumber: 'VOY-2024-004',
    vesselId: 'vessel-uuid-here',
    departureDate: DateTime.now().add(Duration(days: 7)),
    arrivalDate: DateTime.now().add(Duration(days: 22)),
    departurePort: 'Hong Kong',
    arrivalPort: 'Vancouver',
    status: 'Scheduled',
    notes: 'Trans-Pacific route with container cargo',
  );
  
  try {
    final created = await voyageService.createVoyage(newVoyage);
    print('Voyage created: ${created.voyageNumber}');
  } catch (e) {
    print('Error creating voyage: $e');
  }
}
```

## Status Values

The voyage status field accepts these values:

| Status | Description | Use Case |
|--------|-------------|----------|
| `Scheduled` | Voyage is planned but not started | Future voyages |
| `In Progress` | Vessel is currently on voyage | Active voyages |
| `Completed` | Voyage finished successfully | Past voyages |
| `Delayed` | Voyage is behind schedule | Tracking delays |
| `Cancelled` | Voyage was cancelled | Cancelled trips |

## Troubleshooting

### Error: "Could not find the table 'public.voyages'"

**Solution:** Run the database migration (see Database Setup above)

### Error: "Foreign key constraint violation"

**Solution:** Ensure the `vessels` table exists and the `vessel_id` references a valid vessel

### No voyages showing in the app

**Checklist:**
1. ✅ Migration ran successfully
2. ✅ Sample data inserted (check SQL Editor)
3. ✅ Supabase credentials correct in `.env`
4. ✅ RLS policies enabled (check Supabase Dashboard → Authentication → Policies)

### Progress bar not showing

The progress bar only shows when:
- `showProgress` prop is `true` (default)
- Both `departureDate` and `arrivalDate` are set
- The voyage has valid dates

## API Reference

### VoyageTimeline Widget

```dart
VoyageTimeline({
  required Voyage voyage,      // The voyage to display
  bool showProgress = true,    // Show progress bar
  VoidCallback? onTap,         // Tap handler
})
```

### Voyage Model Properties

```dart
class Voyage {
  final String id;
  final String voyageNumber;
  final String vesselId;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final String? departurePort;
  final String? arrivalPort;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Computed properties
  int? get durationInDays;
  bool get isActive;
  double? get progressPercentage;
}
```

## Next Steps

1. **Run the migration** to create the voyages table
2. **Test the app** - navigate to the Voyages screen
3. **Verify data** - check that sample voyages display correctly
4. **Customize** - adjust colors, layout, or add features as needed

## Support

For issues or questions:
1. Check the error message in the Flutter console
2. Verify database setup in Supabase Dashboard
3. Review the migration SQL file
4. Check RLS policies in Supabase

---

**Implementation Status:** ✅ Complete

- ✅ Database schema (voyages table)
- ✅ Flutter model (Voyage class)
- ✅ Service layer (VoyageService)
- ✅ UI component (VoyageTimeline widget)
- ✅ Sample data
- ✅ Documentation
