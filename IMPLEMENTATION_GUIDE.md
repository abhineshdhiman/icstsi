# ICSTSI Implementation Guide

## Overview
This guide documents the implementation of Vessel, Port, and Booking features in the ICSTSI Flutter application with Supabase backend.

## Database Schema

### 1. Vessels Table
**File:** `supabase_migrations/create_vessels_table.sql`

**Fields:**
- `id` (UUID, Primary Key) - Auto-generated unique identifier
- `vessel_name` (TEXT, NOT NULL) - Name of the vessel
- `imo_number` (TEXT, NOT NULL, UNIQUE) - International Maritime Organization number
- `flag_state` (TEXT, NOT NULL) - Country of vessel registration
- `vessel_type` (TEXT, NOT NULL) - Type of vessel (e.g., Container Ship, Bulk Carrier)
- `created_at` (TIMESTAMPTZ) - Timestamp of record creation

**Indexes:**
- `idx_vessels_imo_number` - For fast IMO number lookups
- `idx_vessels_vessel_name` - For vessel name searches
- `idx_vessels_vessel_type` - For filtering by vessel type

**Security:**
- Row Level Security (RLS) enabled
- Policies for authenticated users: SELECT, INSERT, UPDATE, DELETE

### 2. Ports Table
**File:** `supabase_migrations/create_ports_table.sql`

**Fields:**
- `id` (UUID, Primary Key) - Auto-generated unique identifier
- `port_code` (TEXT, NOT NULL, UNIQUE) - Unique port code (e.g., USNYC)
- `port_name` (TEXT, NOT NULL) - Name of the port
- `location` (TEXT, NOT NULL) - City or location
- `country` (TEXT, NOT NULL) - Country where port is located
- `created_at` (TIMESTAMPTZ) - Timestamp of record creation

**Indexes:**
- `idx_ports_port_code` - For fast port code lookups
- `idx_ports_port_name` - For port name searches
- `idx_ports_country` - For filtering by country

**Security:**
- Row Level Security (RLS) enabled
- Policies for authenticated users: SELECT, INSERT, UPDATE, DELETE

### 3. Bookings Table
**File:** `supabase_migrations/create_bookings_table.sql`

**Fields:**
- `id` (UUID, Primary Key) - Auto-generated unique identifier
- `booking_reference` (TEXT, NOT NULL, UNIQUE) - Unique booking reference number
- `status` (TEXT, NOT NULL) - Booking status (pending, confirmed, cancelled, completed)
- `booking_date` (TIMESTAMPTZ, NOT NULL) - Date and time of booking
- `discharge_date` (TIMESTAMPTZ) - Date and time of cargo discharge
- `gate_out_date` (TIMESTAMPTZ) - Date and time of container gate out
- `vessel_id` (UUID, NOT NULL, FK) - Foreign key to vessels table
- `port_id` (UUID, NOT NULL, FK) - Foreign key to ports table
- `created_at` (TIMESTAMPTZ) - Timestamp of record creation

**Relationships:**
- `vessel_id` → `vessels(id)` ON DELETE CASCADE
- `port_id` → `ports(id)` ON DELETE CASCADE

**Indexes:**
- `idx_bookings_vessel_id` - For vessel-based queries
- `idx_bookings_port_id` - For port-based queries
- `idx_bookings_status` - For filtering by status
- `idx_bookings_booking_date` - For date-based queries
- `idx_bookings_booking_reference` - For reference lookups

**Security:**
- Row Level Security (RLS) enabled
- Policies for authenticated users: SELECT, INSERT, UPDATE, DELETE

## Flutter Implementation

### Models

#### 1. Vessel Model
**File:** `lib/models/vessel.dart`

```dart
class Vessel {
  final String id;
  final String vesselName;
  final String imoNumber;
  final String flagState;
  final String vesselType;
  final DateTime? createdAt;
}
```

**Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from Supabase response
- `toJson()` - Convert to JSON for Supabase operations

#### 2. Port Model
**File:** `lib/models/port.dart`

```dart
class Port {
  final String id;
  final String portCode;
  final String portName;
  final String location;
  final String country;
  final DateTime? createdAt;
}
```

**Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from Supabase response
- `toJson()` - Convert to JSON for Supabase operations
- `displayName` - Formatted string for UI display

#### 3. Booking Model
**File:** `lib/models/booking.dart`

```dart
class Booking {
  final String id;
  final String bookingReference;
  final String status;
  final DateTime bookingDate;
  final DateTime? dischargeDate;
  final DateTime? gateOutDate;
  final String vesselId;
  final String portId;
  final DateTime? createdAt;
  
  // Optional populated fields
  final Vessel? vessel;
  final Port? port;
}
```

### Services

#### 1. VesselService
**File:** `lib/services/vessel_service.dart`

**Methods:**
- `getVessels()` - Fetch all vessels
- `getVesselById(String id)` - Fetch single vessel
- `createVessel(Vessel)` - Create new vessel
- `updateVessel(Vessel)` - Update existing vessel
- `deleteVessel(String id)` - Delete vessel

#### 2. PortService
**File:** `lib/services/port_service.dart`

**Methods:**
- `getAllPorts()` - Fetch all ports
- `getPortById(String id)` - Fetch single port
- `searchPorts(String query)` - Search ports by name, code, or country
- `createPort(Port)` - Create new port
- `updatePort(Port)` - Update existing port
- `deletePort(String id)` - Delete port

#### 3. BookingService
**File:** `lib/services/booking_service.dart`

**Methods:**
- `getBookings()` - Fetch all bookings with vessel and port data
- `getBookingById(String id)` - Fetch single booking with relationships
- `createBooking(Booking)` - Create new booking
- `updateBooking(Booking)` - Update existing booking
- `deleteBooking(String id)` - Delete booking

### Widgets

#### 1. VesselCard
**File:** `lib/widgets/vessel_card.dart`

**Purpose:** Display vessel information in a card layout

**Features:**
- Vessel icon with brand color (#FF6319)
- Vessel name as title
- IMO number, flag state, and vessel type
- Tap handler for navigation/details
- Chevron indicator for interactivity

**Design:**
- Card elevation: 2
- Border radius: 8px
- Padding: 16px
- Icon size: 32px in 56x56 container
- Primary color: #FF6319
- Text color: #1A1919

#### 2. PortSelector
**File:** `lib/widgets/port_selector.dart`

**Purpose:** Enable port selection via dropdown or modal

**Features:**
- Two modes: dropdown and modal
- Search functionality in modal mode
- Real-time port filtering
- Selected port highlighting
- Loading states
- Error handling

**Props:**
- `selectedPort` - Currently selected port
- `onPortSelected` - Callback when port is selected
- `label` - Optional label text
- `isRequired` - Show asterisk for required fields
- `hintText` - Placeholder text
- `showModal` - Use modal instead of dropdown

**Design:**
- Primary color: #FF6319
- Text color: #1A1919
- Border color: #E0E0E0
- Border radius: 8px
- Modal height: 75% of screen

#### 3. BookingCard
**File:** `lib/widgets/booking_card.dart`

**Purpose:** Display booking information with vessel and port details

**Features:**
- Booking reference and status badge
- Vessel information section
- Port information section
- Date information (booking, discharge, gate out)
- Status-based color coding
- Tap handler for details

**Design:**
- Card elevation: 2
- Border radius: 12px
- Padding: 16px
- Status badge colors:
  - Pending: #FFA500
  - Confirmed: #4CAF50
  - Cancelled: #F44336
  - Completed: #2196F3

### Screens

#### 1. VesselsScreen
**File:** `lib/screens/vessels_screen.dart`

**Purpose:** Display list of all vessels

**Features:**
- Pull-to-refresh
- Loading states
- Error handling with retry
- Empty state
- Vessel details dialog
- Floating refresh button

#### 2. PortsScreen
**File:** `lib/screens/ports_screen.dart`

**Purpose:** Demo screen for PortSelector widget

**Features:**
- Dropdown selector example
- Modal selector example
- Selected port details display
- Clear selections button

## Setup Instructions

### 1. Database Setup

Run the migration files in order:

```bash
# 1. Create vessels table
psql -h <supabase-host> -U postgres -d postgres -f supabase_migrations/create_vessels_table.sql

# 2. Create ports table
psql -h <supabase-host> -U postgres -d postgres -f supabase_migrations/create_ports_table.sql

# 3. Create bookings table
psql -h <supabase-host> -U postgres -d postgres -f supabase_migrations/create_bookings_table.sql
```

Or use Supabase Dashboard:
1. Go to SQL Editor
2. Copy and paste each migration file
3. Run in order (vessels → ports → bookings)

### 2. Sample Data

Insert sample vessels:
```sql
INSERT INTO vessels (vessel_name, imo_number, flag_state, vessel_type) VALUES
  ('MSC Gülsün', 'IMO9811000', 'Panama', 'Container Ship'),
  ('Ever Given', 'IMO9811891', 'Panama', 'Container Ship'),
  ('CMA CGM Antoine De Saint Exupery', 'IMO9454436', 'Malta', 'Container Ship');
```

Insert sample ports:
```sql
INSERT INTO ports (port_code, port_name, location, country) VALUES
  ('USNYC', 'Port of New York', 'New York', 'United States'),
  ('CNSHA', 'Port of Shanghai', 'Shanghai', 'China'),
  ('SGSIN', 'Port of Singapore', 'Singapore', 'Singapore'),
  ('NLRTM', 'Port of Rotterdam', 'Rotterdam', 'Netherlands');
```

Insert sample bookings:
```sql
INSERT INTO bookings (
  booking_reference, 
  status, 
  booking_date, 
  discharge_date, 
  gate_out_date,
  vessel_id, 
  port_id
) VALUES (
  'BKG-2024-001',
  'confirmed',
  '2024-01-15 10:00:00+00',
  '2024-02-01 08:00:00+00',
  '2024-02-02 14:00:00+00',
  (SELECT id FROM vessels WHERE imo_number = 'IMO9811000'),
  (SELECT id FROM ports WHERE port_code = 'USNYC')
);
```

### 3. Flutter Dependencies

Ensure these dependencies are in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  intl: ^0.18.0  # For date formatting
```

### 4. Supabase Initialization

In `lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

## Usage Examples

### Display Vessels List

```dart
import 'package:flutter/material.dart';
import 'screens/vessels_screen.dart';

// Navigate to vessels screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const VesselsScreen()),
);
```

### Use PortSelector in a Form

```dart
Port? selectedPort;

PortSelector(
  label: 'Departure Port',
  isRequired: true,
  selectedPort: selectedPort,
  onPortSelected: (port) {
    setState(() => selectedPort = port);
  },
);
```

### Display Booking with VesselCard

```dart
import 'package:flutter/material.dart';
import 'widgets/booking_card.dart';
import 'services/booking_service.dart';

class BookingsScreen extends StatefulWidget {
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookings = await _bookingService.getBookings();
    setState(() => _bookings = bookings);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(
          booking: _bookings[index],
          onTap: () {
            // Navigate to booking details
          },
        );
      },
    );
  }
}
```

## Design System

### Colors
- **Primary Orange:** `#FF6319` - Used for CTAs, highlights, icons
- **Text Primary:** `#1A1919` - Main text color
- **Text Secondary:** `#666666` - Secondary text, labels
- **Text Hint:** `#999999` - Placeholder text
- **Border:** `#E0E0E0` - Input borders, dividers
- **Background:** `#F5F5F5` - Card backgrounds, sections

### Typography
- **Title:** 18-24px, FontWeight.w600
- **Body:** 14-16px, FontWeight.normal
- **Caption:** 12px, FontWeight.normal
- **Label:** 14px, FontWeight.normal

### Spacing
- **Card padding:** 16px
- **Section spacing:** 16-24px
- **Element spacing:** 8-12px
- **Border radius:** 8-12px
- **Card elevation:** 2

## Testing

### Test Vessel Display
1. Navigate to VesselsScreen
2. Verify vessels load from Supabase
3. Tap a vessel card to see details dialog
4. Pull down to refresh list

### Test Port Selection
1. Navigate to PortsScreen
2. Test dropdown selector
3. Test modal selector with search
4. Verify selected port details display

### Test Booking Display
1. Create a booking with vessel and port references
2. Display BookingCard
3. Verify vessel and port details are populated
4. Check status badge color matches booking status

## Troubleshooting

### Vessels/Ports not loading
- Check Supabase connection in main.dart
- Verify tables exist in Supabase dashboard
- Check RLS policies allow authenticated access
- Review error messages in debug console

### Foreign key errors in bookings
- Ensure vessels and ports tables are created first
- Verify vessel_id and port_id reference valid records
- Check cascade delete behavior

### UI not matching design
- Verify color codes match design system
- Check font weights and sizes
- Review spacing and padding values
- Ensure border radius is consistent

## Next Steps

1. **Authentication:** Implement user authentication with Supabase Auth
2. **Booking Creation:** Add forms to create new bookings
3. **Vessel Management:** Add CRUD operations for vessels
4. **Port Management:** Add CRUD operations for ports
5. **Search & Filter:** Add advanced search and filtering
6. **Notifications:** Add booking status change notifications
7. **Analytics:** Add booking analytics and reporting

## Support

For issues or questions:
- Check Supabase logs in dashboard
- Review Flutter debug console
- Verify database schema matches models
- Test API calls in Supabase API docs
