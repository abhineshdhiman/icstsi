# Port Implementation Guide

## Overview
This document describes the Port content type and PortSelector widget implementation for the ICSTSI application.

## Components Created

### 1. Port Model (`lib/models/port.dart`)
Data model representing port information with the following fields:
- `id` (String): Unique identifier (UUID)
- `portCode` (String): UN/LOCODE port code (e.g., "USNYC")
- `portName` (String): Full name of the port
- `location` (String): City or region
- `country` (String): Country name
- `createdAt` (DateTime?): Timestamp of creation

**Key Features:**
- JSON serialization/deserialization for Supabase integration
- `displayName` getter for formatted display in dropdowns
- Follows the same pattern as the existing Vessel model

### 2. Port Service (`lib/services/port_service.dart`)
Service layer for managing port data in Supabase with the following methods:

- `getAllPorts()`: Fetch all ports, ordered by name
- `getPortById(String id)`: Get a specific port by ID
- `searchPorts(String query)`: Search ports by name, code, or country
- `createPort(Port port)`: Create a new port
- `updatePort(Port port)`: Update an existing port
- `deletePort(String id)`: Delete a port

**Key Features:**
- Full CRUD operations
- Search functionality using Supabase's `or` and `ilike` operators
- Error handling with descriptive messages
- Consistent with existing VesselService pattern

### 3. PortSelector Widget (`lib/widgets/port_selector.dart`)
Reusable Flutter widget for port selection with two variants:

#### Dropdown Variant (Default)
- Standard Material dropdown
- Suitable for forms with limited space
- Auto-loads all ports on initialization
- Supports optional label and required indicator

#### Modal Variant (`showModal: true`)
- Opens a bottom sheet modal
- Includes search functionality
- Better UX for large port lists
- Visual feedback for selected port
- Searchable by name, code, or country

**Design System Compliance:**
- Primary color: `#FF6319` (ICSTSI orange)
- Text color: `#1A1919` (dark gray)
- Border color: `#E0E0E0` (light gray)
- Hint text: `#999999` (medium gray)
- Matches Figma design specifications

**Props:**
```dart
PortSelector({
  Port? selectedPort,           // Currently selected port
  required Function(Port?) onPortSelected,  // Callback when port is selected
  String? label,                // Optional label text
  bool isRequired = false,      // Show asterisk if required
  String? hintText,             // Placeholder text
  bool showModal = false,       // Use modal variant instead of dropdown
})
```

### 4. Ports Demo Screen (`lib/screens/ports_screen.dart`)
Demo screen showcasing both variants of the PortSelector widget:
- Dropdown selector example with "Departure Port"
- Modal selector example with "Arrival Port"
- Selected port details display
- Clear selections button

### 5. Database Migration (`supabase_migrations/001_create_ports_table.sql`)
SQL script to create the ports table in Supabase:

**Table Structure:**
```sql
CREATE TABLE ports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    port_code VARCHAR(10) NOT NULL UNIQUE,
    port_name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Features:**
- Indexes on port_code, port_name, and country for fast searches
- Row Level Security (RLS) enabled
- Policies for authenticated and anonymous access
- Sample data with 15 major international ports
- Auto-update trigger for updated_at column

## Setup Instructions

### 1. Database Setup
Run the migration script in your Supabase SQL Editor:
```bash
# Copy the contents of supabase_migrations/001_create_ports_table.sql
# Paste into Supabase SQL Editor and execute
```

Or use Supabase CLI:
```bash
supabase db push
```

### 2. Verify Installation
The ports table should now exist with sample data. You can verify by running:
```sql
SELECT * FROM ports ORDER BY port_name;
```

### 3. Test the Widget
1. Run the Flutter app: `flutter run`
2. Navigate to "Port Selection" from the home screen
3. Test both dropdown and modal variants
4. Try the search functionality in the modal

## Usage Examples

### Basic Dropdown Usage
```dart
Port? selectedPort;

PortSelector(
  label: 'Departure Port',
  isRequired: true,
  selectedPort: selectedPort,
  onPortSelected: (port) {
    setState(() => selectedPort = port);
  },
)
```

### Modal Variant Usage
```dart
Port? selectedPort;

PortSelector(
  showModal: true,
  hintText: 'Select arrival port',
  selectedPort: selectedPort,
  onPortSelected: (port) {
    setState(() => selectedPort = port);
  },
)
```

### In a Form
```dart
Form(
  child: Column(
    children: [
      PortSelector(
        label: 'Origin Port',
        isRequired: true,
        selectedPort: _originPort,
        onPortSelected: (port) {
          setState(() => _originPort = port);
        },
      ),
      SizedBox(height: 16),
      PortSelector(
        label: 'Destination Port',
        isRequired: true,
        selectedPort: _destinationPort,
        onPortSelected: (port) {
          setState(() => _destinationPort = port);
        },
      ),
    ],
  ),
)
```

## Integration with Other Features

### Using with Vessel Routes
```dart
class VesselRoute {
  final Vessel vessel;
  final Port originPort;
  final Port destinationPort;
  final DateTime departureDate;
  final DateTime arrivalDate;
  
  // ... implementation
}
```

### Using with Container Tracking
```dart
class ContainerShipment {
  final String containerId;
  final Port currentPort;
  final Port destinationPort;
  final String status;
  
  // ... implementation
}
```

## API Reference

### PortService Methods

#### getAllPorts()
```dart
Future<List<Port>> getAllPorts()
```
Returns all ports ordered by name.

#### searchPorts(String query)
```dart
Future<List<Port>> searchPorts(String query)
```
Searches ports by name, code, or country. Case-insensitive.

#### getPortById(String id)
```dart
Future<Port?> getPortById(String id)
```
Returns a specific port by ID, or null if not found.

#### createPort(Port port)
```dart
Future<Port> createPort(Port port)
```
Creates a new port in the database.

#### updatePort(Port port)
```dart
Future<Port> updatePort(Port port)
```
Updates an existing port.

#### deletePort(String id)
```dart
Future<void> deletePort(String id)
```
Deletes a port by ID.

## Design Decisions

### Why Two Variants?
- **Dropdown**: Best for forms with limited space, quick selection from known ports
- **Modal**: Better UX for large lists, provides search, more mobile-friendly

### Why Supabase Instead of CMS?
The story mentioned "None CMS" but the project uses Supabase as the backend. Ports are operational data that:
- Need to be queried frequently
- Require fast search capabilities
- Are referenced by other entities (vessels, shipments)
- Benefit from relational database features

### Search Implementation
Uses Supabase's `or` and `ilike` operators for flexible, case-insensitive search across multiple fields:
```dart
.or('port_name.ilike.%$query%,port_code.ilike.%$query%,country.ilike.%$query%')
```

## Testing Checklist

- [ ] Ports table created in Supabase
- [ ] Sample data loaded successfully
- [ ] Dropdown variant displays all ports
- [ ] Modal variant opens and closes correctly
- [ ] Search functionality works in modal
- [ ] Selected port displays correctly
- [ ] Required indicator shows when isRequired=true
- [ ] Callback fires when port is selected
- [ ] Loading state shows while fetching data
- [ ] Error handling works for network failures
- [ ] Design matches ICSTSI color scheme (#FF6319, #1A1919)

## Future Enhancements

1. **Port Details Screen**: Full port information with map, facilities, etc.
2. **Favorites**: Allow users to mark frequently used ports
3. **Recent Selections**: Show recently selected ports at the top
4. **Offline Support**: Cache ports locally for offline access
5. **Port Images**: Add port photos/logos
6. **Distance Calculator**: Calculate distance between two ports
7. **Port Facilities**: Add information about port facilities and services
8. **Multi-select**: Allow selecting multiple ports for route planning

## Troubleshooting

### Ports not loading
- Check Supabase connection in `.env` file
- Verify the ports table exists: `SELECT * FROM ports;`
- Check RLS policies are correctly set up

### Search not working
- Ensure indexes are created on port_code, port_name, and country
- Verify the search query syntax in PortService

### Dropdown empty
- Check if `getAllPorts()` is being called in `initState()`
- Verify data is being returned from Supabase
- Check for errors in the console

## Related Files
- `lib/models/port.dart` - Port data model
- `lib/services/port_service.dart` - Port service layer
- `lib/widgets/port_selector.dart` - PortSelector widget
- `lib/screens/ports_screen.dart` - Demo screen
- `supabase_migrations/001_create_ports_table.sql` - Database migration
- `lib/main.dart` - Updated with navigation to ports screen

## Support
For questions or issues, refer to:
- Flutter documentation: https://flutter.dev/docs
- Supabase documentation: https://supabase.com/docs
- ICSTSI project documentation
