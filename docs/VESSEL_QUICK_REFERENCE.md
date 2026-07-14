# Vessel Model - Quick Reference Guide

## TL;DR

```dart
// Import
import 'package:icstsi/models/vessel.dart';
import 'package:icstsi/services/vessel_service.dart';

// Initialize service
final vesselService = VesselService();

// Fetch all vessels
final vessels = await vesselService.getVessels();

// Get single vessel
final vessel = await vesselService.getVesselById('uuid-here');

// Create vessel
final newVessel = Vessel(
  id: '',
  vesselName: 'MAERSK ATLANTA',
  imoNumber: '9876543',
  flagState: 'Denmark',
  vesselType: 'Container Ship',
);
await vesselService.createVessel(newVessel);

// Update vessel
final updated = vessel.copyWith(status: 'Under Maintenance');
await vesselService.updateVessel(updated);

// Delete vessel
await vesselService.deleteVessel('uuid-here');
```

## Required Fields

Only 4 fields are required to create a vessel:

| Field | Type | Example |
|-------|------|---------|
| `vesselName` | String | `"MAERSK ATLANTA"` |
| `imoNumber` | String | `"9876543"` (7 digits) |
| `flagState` | String | `"Denmark"` |
| `vesselType` | String | `"Container Ship"` |

## Common Vessel Types

```dart
// Use these standardized values
'Container Ship'
'Bulk Carrier'
'Tanker'
'General Cargo'
'Ro-Ro'
'Passenger Ship'
'Cruise Ship'
'Ferry'
```

## Status Values

```dart
// Valid status values
'Active'
'Inactive'
'Under Maintenance'
'Decommissioned'
```

## Validation Rules

### IMO Number
- **Must be**: Exactly 7 digits
- **Format**: Numeric only (no letters)
- **Example**: `"9839850"` ✅
- **Invalid**: `"IMO9839850"` ❌, `"983985"` ❌

### MMSI
- **Must be**: Exactly 9 digits (if provided)
- **Format**: Numeric only
- **Example**: `"636019825"` ✅
- **Can be**: `null` (optional)

### Build Year
- **Range**: 1800 to (current year + 5)
- **Example**: `2020` ✅
- **Invalid**: `1799` ❌, `2050` ❌

### Measurements
- All numeric values must be **positive** (> 0)
- Includes: length, beam, draft, tonnage, speed, capacity

## Code Examples

### Create a Complete Vessel

```dart
final vessel = Vessel(
  id: '', // Auto-generated
  vesselName: 'MAERSK ATLANTA',
  imoNumber: '9876543',
  mmsi: '219123456',
  callSign: 'OXYZ1',
  officialNumber: 'DK-12345',
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
  hullNumber: 'H-2020-001',
  previousNames: 'ATLANTIC STAR, OCEAN VOYAGER',
  notes: 'Flagship vessel of the fleet',
);

final created = await vesselService.createVessel(vessel);
print('Created: ${created.id}');
```

### Create a Minimal Vessel

```dart
final vessel = Vessel(
  id: '',
  vesselName: 'QUICK SHIP',
  imoNumber: '1234567',
  flagState: 'USA',
  vesselType: 'Container Ship',
);

await vesselService.createVessel(vessel);
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

### Search Vessels by Name

```dart
final vessels = await vesselService.getVessels();
final maerskVessels = vessels.where((v) => 
  v.vesselName.toLowerCase().contains('maersk')
).toList();
```

### Filter by Vessel Type

```dart
final vessels = await vesselService.getVessels();
final containerShips = vessels.where((v) => 
  v.vesselType == 'Container Ship'
).toList();
```

### Sort by TEU Capacity

```dart
final vessels = await vesselService.getVessels();
vessels.sort((a, b) {
  final aTeu = a.teuCapacity ?? 0;
  final bTeu = b.teuCapacity ?? 0;
  return bTeu.compareTo(aTeu); // Descending
});
```

### Display Vessel Info

```dart
Widget buildVesselCard(Vessel vessel) {
  return Card(
    child: ListTile(
      title: Text(vessel.vesselName),
      subtitle: Text('IMO: ${vessel.imoNumber} | ${vessel.vesselType}'),
      trailing: Chip(
        label: Text(vessel.status ?? 'Unknown'),
        backgroundColor: _getStatusColor(vessel.status),
      ),
      onTap: () => _showVesselDetails(vessel),
    ),
  );
}

Color _getStatusColor(String? status) {
  switch (status) {
    case 'Active':
      return Colors.green;
    case 'Inactive':
      return Colors.grey;
    case 'Under Maintenance':
      return Colors.orange;
    case 'Decommissioned':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
```

## Error Handling

```dart
try {
  final vessel = await vesselService.getVesselById(vesselId);
  if (vessel == null) {
    print('Vessel not found');
    return;
  }
  // Use vessel...
} catch (e) {
  print('Error fetching vessel: $e');
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to load vessel: $e')),
  );
}
```

## Form Validation

```dart
String? validateImoNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'IMO number is required';
  }
  if (value.length != 7) {
    return 'IMO number must be exactly 7 digits';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'IMO number must contain only digits';
  }
  return null;
}

String? validateMmsi(String? value) {
  if (value == null || value.isEmpty) {
    return null; // MMSI is optional
  }
  if (value.length != 9) {
    return 'MMSI must be exactly 9 digits';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'MMSI must contain only digits';
  }
  return null;
}

String? validateBuildYear(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Build year is optional
  }
  final year = int.tryParse(value);
  if (year == null) {
    return 'Build year must be a number';
  }
  final currentYear = DateTime.now().year;
  if (year < 1800 || year > currentYear + 5) {
    return 'Build year must be between 1800 and ${currentYear + 5}';
  }
  return null;
}
```

## Common Queries

### Get Active Vessels Only

```dart
final vessels = await vesselService.getVessels();
final activeVessels = vessels.where((v) => v.status == 'Active').toList();
```

### Get Vessels by Owner

```dart
final vessels = await vesselService.getVessels();
final maerskVessels = vessels.where((v) => 
  v.owner?.toLowerCase().contains('maersk') ?? false
).toList();
```

### Get Large Container Ships (> 10,000 TEU)

```dart
final vessels = await vesselService.getVessels();
final largeShips = vessels.where((v) => 
  v.vesselType == 'Container Ship' && (v.teuCapacity ?? 0) > 10000
).toList();
```

### Get Recently Built Vessels (last 5 years)

```dart
final vessels = await vesselService.getVessels();
final currentYear = DateTime.now().year;
final recentVessels = vessels.where((v) => 
  v.buildYear != null && v.buildYear! >= currentYear - 5
).toList();
```

## Performance Tips

### 1. Cache Vessel List

```dart
class VesselCache {
  static List<Vessel>? _cachedVessels;
  static DateTime? _lastFetch;
  
  static Future<List<Vessel>> getVessels() async {
    final now = DateTime.now();
    if (_cachedVessels != null && 
        _lastFetch != null && 
        now.difference(_lastFetch!).inMinutes < 5) {
      return _cachedVessels!;
    }
    
    final vesselService = VesselService();
    _cachedVessels = await vesselService.getVessels();
    _lastFetch = now;
    return _cachedVessels!;
  }
  
  static void invalidate() {
    _cachedVessels = null;
    _lastFetch = null;
  }
}
```

### 2. Use FutureBuilder

```dart
FutureBuilder<List<Vessel>>(
  future: vesselService.getVessels(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Text('No vessels found');
    }
    
    final vessels = snapshot.data!;
    return ListView.builder(
      itemCount: vessels.length,
      itemBuilder: (context, index) => buildVesselCard(vessels[index]),
    );
  },
)
```

### 3. Implement Search Debouncing

```dart
import 'dart:async';

class VesselSearchDelegate extends SearchDelegate<Vessel?> {
  final VesselService _vesselService = VesselService();
  Timer? _debounce;
  
  @override
  Widget buildResults(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    return FutureBuilder<List<Vessel>>(
      future: _searchVessels(query),
      builder: (context, snapshot) {
        // ... build search results
      },
    );
  }
  
  Future<List<Vessel>> _searchVessels(String query) async {
    final vessels = await _vesselService.getVessels();
    return vessels.where((v) =>
      v.vesselName.toLowerCase().contains(query.toLowerCase()) ||
      v.imoNumber.contains(query)
    ).toList();
  }
}
```

## Testing

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:icstsi/models/vessel.dart';

void main() {
  group('Vessel Model', () {
    test('fromJson creates valid Vessel', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'vessel_name': 'TEST SHIP',
        'imo_number': '1234567',
        'flag_state': 'USA',
        'vessel_type': 'Container Ship',
        'status': 'Active',
        'teu_capacity': 5000,
      };
      
      final vessel = Vessel.fromJson(json);
      
      expect(vessel.vesselName, 'TEST SHIP');
      expect(vessel.imoNumber, '1234567');
      expect(vessel.teuCapacity, 5000);
    });
    
    test('toJson creates valid JSON', () {
      final vessel = Vessel(
        id: '123e4567-e89b-12d3-a456-426614174000',
        vesselName: 'TEST SHIP',
        imoNumber: '1234567',
        flagState: 'USA',
        vesselType: 'Container Ship',
      );
      
      final json = vessel.toJson();
      
      expect(json['vessel_name'], 'TEST SHIP');
      expect(json['imo_number'], '1234567');
    });
    
    test('copyWith creates modified copy', () {
      final vessel = Vessel(
        id: '123',
        vesselName: 'ORIGINAL',
        imoNumber: '1234567',
        flagState: 'USA',
        vesselType: 'Container Ship',
        status: 'Active',
      );
      
      final updated = vessel.copyWith(status: 'Inactive');
      
      expect(updated.vesselName, 'ORIGINAL');
      expect(updated.status, 'Inactive');
    });
  });
}
```

## Troubleshooting

### Issue: "Failed to fetch vessels"

**Check**:
1. Supabase connection initialized?
2. User authenticated?
3. RLS policies configured?
4. Network connectivity?

### Issue: "Failed to create vessel"

**Check**:
1. All required fields provided?
2. IMO number exactly 7 digits?
3. IMO number unique (not already exists)?
4. Valid status value?

### Issue: Vessel not appearing in list

**Check**:
1. Vessel created successfully?
2. RLS policies allow reading?
3. Cache needs invalidation?
4. Filter/search excluding vessel?

## Quick Links

- [Full Documentation](./VESSEL_DATA_MODEL.md)
- [Supabase Setup Guide](./SUPABASE_SETUP.md)
- [Migration Files](../supabase/migrations/)
- [Vessel Model Source](../lib/models/vessel.dart)
- [Vessel Service Source](../lib/services/vessel_service.dart)

---

**Last Updated**: 2024-01-01  
**Version**: 1.0.0
