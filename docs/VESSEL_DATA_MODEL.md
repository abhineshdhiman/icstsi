# Vessel Data Model Documentation

## Overview

The Vessel data model serves as the **master data source** for all vessel information in the ICSTSI system. This comprehensive data structure captures vessel identification, specifications, and operational details required for container shipping and terminal operations.

## Database Schema

### Table: `vessels`

The `vessels` table in Supabase stores all vessel master data with the following structure:

#### Core Identification Fields (Required)

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| `id` | UUID | Primary key, auto-generated | NOT NULL, PRIMARY KEY |
| `vessel_name` | TEXT | Official vessel name | NOT NULL |
| `imo_number` | TEXT | International Maritime Organization number | NOT NULL, UNIQUE, 7 digits |
| `flag_state` | TEXT | Country of vessel registration | NOT NULL |
| `vessel_type` | TEXT | Type of vessel (Container Ship, Bulk Carrier, etc.) | NOT NULL |

#### Secondary Identification Fields (Optional)

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| `mmsi` | TEXT | Maritime Mobile Service Identity | 9 digits, UNIQUE |
| `call_sign` | TEXT | Radio call sign | - |
| `official_number` | TEXT | National registration number | - |
| `port_of_registry` | TEXT | Port where vessel is registered | - |
| `classification_society` | TEXT | Classification society (Lloyd's Register, DNV GL, etc.) | - |
| `status` | TEXT | Operational status | Active, Inactive, Under Maintenance, Decommissioned |

#### Physical Specifications (Optional)

| Field | Type | Description | Unit | Constraints |
|-------|------|-------------|------|-------------|
| `length_overall` | NUMERIC(8,2) | Total length of vessel | meters | > 0 |
| `beam` | NUMERIC(8,2) | Width of vessel | meters | > 0 |
| `draft` | NUMERIC(8,2) | Depth of vessel below waterline | meters | > 0 |
| `gross_tonnage` | NUMERIC(12,2) | Total internal volume | GT | > 0 |
| `net_tonnage` | NUMERIC(12,2) | Cargo-carrying volume | NT | > 0 |
| `deadweight_tonnage` | NUMERIC(12,2) | Maximum cargo weight capacity | DWT | > 0 |
| `teu_capacity` | INTEGER | Container capacity | TEU | > 0 |

#### Build Information (Optional)

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| `build_year` | INTEGER | Year vessel was built | 1800 - (current year + 5) |
| `builder` | TEXT | Shipyard that built the vessel | - |
| `build_country` | TEXT | Country where vessel was built | - |

#### Operational Details (Optional)

| Field | Type | Description | Unit | Constraints |
|-------|------|-------------|------|-------------|
| `owner` | TEXT | Legal owner of the vessel | - | - |
| `operator` | TEXT | Company operating the vessel | - | - |
| `manager` | TEXT | Ship management company | - | - |
| `engine_type` | TEXT | Main engine specification | - | - |
| `service_speed` | NUMERIC(6,2) | Normal operating speed | knots | > 0 |
| `max_speed` | NUMERIC(6,2) | Maximum speed | knots | > 0 |
| `fuel_type` | TEXT | Primary fuel type | - | - |
| `fuel_capacity` | NUMERIC(12,2) | Fuel tank capacity | metric tons | > 0 |

#### Additional Information (Optional)

| Field | Type | Description |
|-------|------|-------------|
| `hull_number` | TEXT | Shipyard hull number |
| `previous_names` | TEXT | Comma-separated list of previous vessel names |
| `notes` | TEXT | Additional notes or comments |

#### System Fields (Auto-managed)

| Field | Type | Description |
|-------|------|-------------|
| `created_at` | TIMESTAMPTZ | Record creation timestamp (auto-set) |
| `updated_at` | TIMESTAMPTZ | Last update timestamp (auto-updated) |

## Flutter Model

### Class: `Vessel`

Location: `lib/models/vessel.dart`

The Dart model mirrors the database schema with proper type safety and null handling:

```dart
class Vessel {
  final String id;
  final String vesselName;
  final String imoNumber;
  final String? mmsi;
  // ... (see full implementation in lib/models/vessel.dart)
}
```

### Key Methods

- `Vessel.fromJson(Map<String, dynamic> json)` - Parse from Supabase response
- `toJson()` - Convert to JSON for Supabase operations
- `copyWith({...})` - Create modified copy with updated fields

## Service Layer

### Class: `VesselService`

Location: `lib/services/vessel_service.dart`

Provides CRUD operations for vessel data:

```dart
final vesselService = VesselService();

// Fetch all vessels
List<Vessel> vessels = await vesselService.getVessels();

// Fetch single vessel by ID
Vessel? vessel = await vesselService.getVesselById('uuid-here');

// Create new vessel
Vessel newVessel = await vesselService.createVessel(vessel);

// Update existing vessel
Vessel updated = await vesselService.updateVessel(vessel);

// Delete vessel
await vesselService.deleteVessel('uuid-here');
```

## Data Validation

### Database-Level Constraints

1. **IMO Number**: Must be exactly 7 digits (numeric only)
2. **MMSI**: Must be exactly 9 digits (numeric only) if provided
3. **Status**: Must be one of: Active, Inactive, Under Maintenance, Decommissioned
4. **Build Year**: Must be between 1800 and current year + 5
5. **Positive Values**: All numeric measurements must be positive (> 0)

### Application-Level Validation

Implement additional validation in Flutter forms:
- Required field checks for vessel_name, imo_number, flag_state, vessel_type
- Format validation for IMO and MMSI numbers
- Range validation for numeric fields
- Dropdown/enum validation for status and vessel_type

## Indexes

The following indexes are created for optimal query performance:

- `idx_vessels_vessel_name` - Search by vessel name
- `idx_vessels_imo_number` - Lookup by IMO number (unique identifier)
- `idx_vessels_flag_state` - Filter by flag state
- `idx_vessels_vessel_type` - Filter by vessel type
- `idx_vessels_status` - Filter by operational status
- `idx_vessels_owner` - Filter by owner
- `idx_vessels_operator` - Filter by operator
- `idx_vessels_created_at` - Sort by creation date (descending)

## Row Level Security (RLS)

The vessels table has RLS enabled with the following policies:

- **SELECT**: All authenticated users can read vessel data
- **INSERT**: All authenticated users can create vessels
- **UPDATE**: All authenticated users can update vessels
- **DELETE**: All authenticated users can delete vessels

> **Note**: Adjust these policies based on your specific security requirements. Consider implementing role-based access control (RBAC) for production environments.

## Sample Data

The migration includes three sample vessels for testing:

1. **MSC GÜLSÜN** - One of the world's largest container ships (23,756 TEU)
2. **EVER GIVEN** - Famous for the Suez Canal incident (20,124 TEU)
3. **MAERSK ESSEX** - Large Maersk Line container vessel (15,500 TEU)

## Common Vessel Types

Use these standardized vessel type values for consistency:

- Container Ship
- Bulk Carrier
- Tanker (Oil, Chemical, LNG, LPG)
- General Cargo
- Ro-Ro (Roll-on/Roll-off)
- Passenger Ship
- Cruise Ship
- Ferry
- Offshore Supply Vessel
- Tug
- Dredger
- Fishing Vessel
- Research Vessel
- Naval Vessel

## Common Classification Societies

- Lloyd's Register (LR)
- Det Norske Veritas (DNV GL)
- American Bureau of Shipping (ABS)
- Bureau Veritas (BV)
- China Classification Society (CCS)
- Korean Register (KR)
- Nippon Kaiji Kyokai (ClassNK)
- Registro Italiano Navale (RINA)

## Integration with Other Models

The Vessel model serves as a **master data reference** for:

1. **Bookings** - Links to vessel for container bookings
2. **Schedules** - Vessel schedules and port calls
3. **Cargo Manifests** - Cargo loaded on specific vessels
4. **Port Operations** - Vessel arrivals, departures, and berth assignments

### Example: Booking Reference

```dart
class Booking {
  final String id;
  final String vesselId; // Foreign key to vessels.id
  // ... other fields
}
```

## Migration Instructions

### Apply Migration to Supabase

1. **Using Supabase CLI** (Recommended):
   ```bash
   supabase db push
   ```

2. **Using Supabase Dashboard**:
   - Navigate to SQL Editor
   - Copy contents of `supabase/migrations/20240101000001_create_vessels_table.sql`
   - Execute the SQL

3. **Verify Migration**:
   ```sql
   SELECT * FROM vessels LIMIT 10;
   ```

### Rollback (if needed)

```sql
DROP TABLE IF EXISTS vessels CASCADE;
DROP FUNCTION IF EXISTS update_vessels_updated_at() CASCADE;
```

## Best Practices

1. **Always use IMO number** as the primary business identifier (not UUID)
2. **Validate IMO numbers** using the IMO check digit algorithm
3. **Keep vessel names updated** if vessels are renamed
4. **Store previous names** in the `previous_names` field for historical tracking
5. **Update status** when vessels change operational state
6. **Maintain accurate specifications** for operational planning
7. **Use consistent units** (meters, metric tons, knots) across the system

## API Usage Examples

### Create a New Vessel

```dart
final newVessel = Vessel(
  id: '', // Will be auto-generated
  vesselName: 'MAERSK ATLANTA',
  imoNumber: '9876543',
  mmsi: '219123456',
  callSign: 'OXYZ1',
  flagState: 'Denmark',
  portOfRegistry: 'Copenhagen',
  vesselType: 'Container Ship',
  classificationSociety: 'Det Norske Veritas',
  status: 'Active',
  lengthOverall: 350.0,
  beam: 45.6,
  draft: 14.5,
  grossTonnage: 145000.0,
  netTonnage: 75000.0,
  deadweightTonnage: 155000.0,
  teuCapacity: 14500,
  buildYear: 2020,
  builder: 'Hyundai Heavy Industries',
  buildCountry: 'South Korea',
  owner: 'A.P. Moller-Maersk',
  operator: 'Maersk Line',
  manager: 'Maersk Ship Management',
  engineType: 'MAN B&W 9S90ME-C10.2',
  serviceSpeed: 22.5,
  maxSpeed: 24.5,
  fuelType: 'Heavy Fuel Oil',
  fuelCapacity: 13500.0,
);

final created = await vesselService.createVessel(newVessel);
print('Created vessel: ${created.id}');
```

### Search Vessels by Name

```dart
final vessels = await vesselService.getVessels();
final filtered = vessels.where((v) => 
  v.vesselName.toLowerCase().contains('maersk')
).toList();
```

### Update Vessel Status

```dart
final vessel = await vesselService.getVesselById(vesselId);
if (vessel != null) {
  final updated = vessel.copyWith(
    status: 'Under Maintenance',
    notes: 'Scheduled maintenance at Singapore shipyard',
  );
  await vesselService.updateVessel(updated);
}
```

## Troubleshooting

### Common Issues

1. **IMO Number Validation Error**
   - Ensure IMO number is exactly 7 digits
   - Use only numeric characters (no letters or special characters)

2. **MMSI Validation Error**
   - Ensure MMSI is exactly 9 digits if provided
   - Can be left null if not available

3. **Foreign Key Constraint Errors**
   - Ensure vessel exists before creating bookings that reference it
   - Use proper UUID format for vessel IDs

4. **RLS Policy Errors**
   - Ensure user is authenticated before accessing vessel data
   - Check Supabase authentication status

## Future Enhancements

Consider these enhancements for future iterations:

1. **Vessel Images** - Add support for vessel photos
2. **Document Attachments** - Store certificates, surveys, etc.
3. **Voyage History** - Track historical voyages and port calls
4. **Performance Metrics** - Fuel consumption, emissions, etc.
5. **Maintenance Records** - Link to maintenance schedules and history
6. **Crew Information** - Link to crew assignments
7. **AIS Integration** - Real-time vessel tracking via AIS data
8. **Weather Integration** - Current weather at vessel location

## Support

For questions or issues related to the Vessel data model:
- Review this documentation
- Check the Flutter model implementation in `lib/models/vessel.dart`
- Review the service layer in `lib/services/vessel_service.dart`
- Consult the Supabase dashboard for database schema details

---

**Last Updated**: 2024-01-01  
**Version**: 1.0.0  
**Maintainer**: ICSTSI Development Team
