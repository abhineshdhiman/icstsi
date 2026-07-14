# Voyage Tracking Feature

## Overview
This feature implements comprehensive voyage tracking for vessel movements in the ICSTSI application. It includes a Voyage data model, service layer for Supabase integration, and a beautiful timeline visualization widget.

## Components

### 1. Voyage Model (`lib/models/voyage.dart`)
The Voyage model represents vessel voyage information with the following fields:

**Core Fields:**
- `id`: Unique identifier (UUID)
- `voyageNumber`: Unique voyage reference number
- `vesselId`: Reference to the vessel (foreign key)

**Voyage Details:**
- `departureDate`: Scheduled/actual departure date and time
- `arrivalDate`: Scheduled/actual arrival date and time
- `departurePort`: Name of departure port
- `arrivalPort`: Name of arrival port

**Status:**
- `status`: Current voyage status
  - Scheduled
  - In Progress
  - Completed
  - Delayed
  - Cancelled

**Computed Properties:**
- `durationInDays`: Calculates voyage duration
- `isActive`: Checks if voyage is currently active
- `progressPercentage`: Calculates progress (0-100%)

### 2. Voyage Service (`lib/services/voyage_service.dart`)
Service layer for managing voyage data in Supabase:

**Methods:**
- `getVoyages()`: Fetch all voyages
- `getVoyagesByVessel(vesselId)`: Fetch voyages for a specific vessel
- `getVoyageById(id)`: Fetch a single voyage
- `createVoyage(voyage)`: Create a new voyage
- `updateVoyage(voyage)`: Update an existing voyage
- `deleteVoyage(id)`: Delete a voyage
- `getActiveVoyages()`: Get currently active voyages
- `getUpcomingVoyages()`: Get scheduled upcoming voyages

### 3. VoyageTimeline Widget (`lib/widgets/voyage_timeline.dart`)
Beautiful timeline visualization component based on Figma design specifications.

**Features:**
- Calendar icons for departure/arrival dates
- Clock icons for time display
- Status badges with color coding
- Progress bar showing voyage completion
- Port information display
- Duration calculation
- Notes section
- Responsive layout

**Design Elements:**
- Primary color: `#FF6319` (Orange)
- Text color: `#1A1919` (Dark gray)
- Secondary text: `#666666` (Medium gray)
- Status-based color coding
- Smooth gradients and shadows

**Props:**
- `voyage`: Voyage object to display
- `showProgress`: Boolean to show/hide progress bar
- `onTap`: Callback for tap events

### 4. Voyages Screen (`lib/screens/voyages_screen.dart`)
Full-featured screen for viewing and managing voyages.

**Features:**
- List view of all voyages
- Filter by status (All, Active, Upcoming)
- Pull-to-refresh functionality
- Tap to view detailed voyage information
- Modal bottom sheet for voyage details
- Empty state handling
- Error handling with retry
- Loading states

## Database Schema

### Voyages Table
Run the SQL migration in `supabase_voyages_migration.sql` to create the table:

```sql
CREATE TABLE voyages (
    id UUID PRIMARY KEY,
    voyage_number TEXT NOT NULL UNIQUE,
    vessel_id UUID NOT NULL REFERENCES vessels(id),
    departure_date TIMESTAMPTZ,
    arrival_date TIMESTAMPTZ,
    departure_port TEXT,
    arrival_port TEXT,
    status TEXT NOT NULL DEFAULT 'Scheduled',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Indexes:**
- `idx_voyages_vessel_id`: Fast lookups by vessel
- `idx_voyages_departure_date`: Efficient sorting by date
- `idx_voyages_status`: Quick filtering by status

**Security:**
- Row Level Security (RLS) enabled
- Policies for authenticated users
- Automatic timestamp updates

## Installation & Setup

### 1. Database Setup
1. Open your Supabase project dashboard
2. Navigate to SQL Editor
3. Run the migration script from `supabase_voyages_migration.sql`
4. Verify the table was created successfully

### 2. Test the Feature
1. The app is already configured with the new screens
2. Run the Flutter app: `flutter run`
3. Navigate to "View Voyages" from the home screen
4. The screen will load (empty initially)

### 3. Add Sample Data (Optional)
You can add sample voyages through the Supabase dashboard or use the SQL insert statements in the migration file (uncomment and update vessel IDs).

## Usage Examples

### Using VoyageTimeline Widget

```dart
import 'package:icstsi/widgets/voyage_timeline.dart';
import 'package:icstsi/models/voyage.dart';

// In your widget
VoyageTimeline(
  voyage: myVoyage,
  showProgress: true,
  onTap: () {
    // Handle tap
    print('Voyage tapped: ${myVoyage.voyageNumber}');
  },
)
```

### Fetching Voyages

```dart
import 'package:icstsi/services/voyage_service.dart';

final voyageService = VoyageService();

// Get all voyages
final voyages = await voyageService.getVoyages();

// Get voyages for a specific vessel
final vesselVoyages = await voyageService.getVoyagesByVessel(vesselId);

// Get active voyages
final activeVoyages = await voyageService.getActiveVoyages();
```

### Creating a Voyage

```dart
final newVoyage = Voyage(
  id: 'generated-uuid',
  voyageNumber: 'VOY-2024-001',
  vesselId: 'vessel-uuid',
  departureDate: DateTime(2024, 3, 1, 8, 0),
  arrivalDate: DateTime(2024, 3, 15, 14, 0),
  departurePort: 'Singapore',
  arrivalPort: 'Los Angeles',
  status: 'Scheduled',
  notes: 'Regular scheduled voyage',
);

final createdVoyage = await voyageService.createVoyage(newVoyage);
```

## Design Specifications

The VoyageTimeline widget follows the Figma design specifications:

### Colors
- Primary: `#FF6319` (Orange)
- Text Primary: `#1A1919`
- Text Secondary: `#666666`
- Background: `#FFFFFF`
- Border: `#E0E0E0`
- Success: `#4CAF50`
- Info: `#2196F3`
- Warning: `#FF9800`
- Error: `#F44336`

### Typography
- Header: 16px, Semi-bold (600)
- Body: 14px, Regular (400)
- Caption: 12px, Regular (400)
- Small: 11px, Medium (500)

### Spacing
- Container padding: 16px
- Element spacing: 8px, 12px, 16px
- Icon size: 20px (timeline), 14px (inline)

### Icons
- Calendar: `Icons.calendar_today`
- Clock: `Icons.access_time`
- Info: `Icons.info_outline`
- Sailing: `Icons.sailing`

## Status Color Coding

| Status | Background | Text Color |
|--------|-----------|------------|
| In Progress | `#4CAF50` (10% opacity) | `#4CAF50` |
| Completed | `#2196F3` (10% opacity) | `#2196F3` |
| Delayed | `#FF9800` (10% opacity) | `#FF9800` |
| Cancelled | `#F44336` (10% opacity) | `#F44336` |
| Scheduled | `#9E9E9E` (10% opacity) | `#9E9E9E` |

## Future Enhancements

Potential improvements for future iterations:

1. **Real-time Tracking**
   - Live vessel position updates
   - Map integration
   - ETA calculations

2. **Notifications**
   - Departure/arrival alerts
   - Delay notifications
   - Status change updates

3. **Analytics**
   - Voyage statistics
   - Performance metrics
   - Historical data analysis

4. **Advanced Filtering**
   - Date range filters
   - Port-based filtering
   - Multi-status selection

5. **Export Functionality**
   - PDF reports
   - CSV exports
   - Share voyage details

6. **Integration**
   - Weather data
   - Port congestion info
   - Fuel consumption tracking

## Troubleshooting

### Common Issues

**Issue: "Failed to fetch voyages"**
- Check Supabase connection in `.env` file
- Verify the voyages table exists
- Check RLS policies are configured correctly

**Issue: "No voyages found"**
- Add sample data to the database
- Check filter settings (try "All" filter)
- Verify vessel_id references are valid

**Issue: Progress bar not showing**
- Ensure both departureDate and arrivalDate are set
- Check that dates are valid DateTime objects
- Verify showProgress prop is set to true

## Support

For issues or questions:
1. Check the Supabase logs for database errors
2. Review Flutter console for runtime errors
3. Verify all dependencies are installed (`flutter pub get`)
4. Ensure Supabase credentials are correct in `.env`

## License

Part of the ICSTSI project - International Container Shipping & Terminal Services
