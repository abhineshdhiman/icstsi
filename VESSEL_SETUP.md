# Vessel Feature Setup Guide

This guide explains how to set up and use the Vessel feature in the ICSTSI Flutter application.

## Overview

The Vessel feature includes:
- **Vessel Model** (`lib/models/vessel.dart`) - Data model for vessel information
- **VesselCard Widget** (`lib/widgets/vessel_card.dart`) - Reusable card component to display vessel details
- **VesselService** (`lib/services/vessel_service.dart`) - Service layer for Supabase operations
- **VesselsScreen** (`lib/screens/vessels_screen.dart`) - Screen to display list of vessels

## Database Setup

### 1. Create the Vessels Table in Supabase

Run the migration SQL in your Supabase project:

```sql
-- See supabase/migrations/001_create_vessels_table.sql
```

Or manually create the table in Supabase SQL Editor:

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of `supabase/migrations/001_create_vessels_table.sql`
4. Click "Run" to execute the migration

### 2. Table Schema

The `vessels` table includes:
- `id` (UUID, Primary Key) - Auto-generated unique identifier
- `vessel_name` (TEXT, NOT NULL) - Name of the vessel
- `imo_number` (TEXT, NOT NULL, UNIQUE) - International Maritime Organization number
- `flag_state` (TEXT, NOT NULL) - Country of vessel registration
- `vessel_type` (TEXT, NOT NULL) - Type of vessel (e.g., Container Ship, Tanker)
- `created_at` (TIMESTAMP) - Auto-generated creation timestamp
- `updated_at` (TIMESTAMP) - Auto-updated modification timestamp

### 3. Row Level Security (RLS)

The table has RLS enabled with the following policies:
- Authenticated users can perform all operations (SELECT, INSERT, UPDATE, DELETE)
- Anonymous users can only read (SELECT) vessel data

## Component Usage

### VesselCard Widget

The `VesselCard` widget displays vessel information in a card layout:

```dart
import 'package:icstsi/models/vessel.dart';
import 'package:icstsi/widgets/vessel_card.dart';

// Example usage
VesselCard(
  vessel: Vessel(
    id: '123',
    vesselName: 'MSC GÜLSÜN',
    imoNumber: 'IMO9811000',
    flagState: 'Panama',
    vesselType: 'Container Ship',
  ),
  onTap: () {
    // Handle tap event
    print('Vessel tapped');
  },
)
```

### Design Features

The VesselCard follows the Figma design specifications:
- **Primary Color**: #FF6319 (Orange) - Used for vessel icon background and accents
- **Text Color**: #1A1919 (Dark) - Used for all text content
- **Card Layout**: 
  - Vessel icon (56x56) with orange background
  - Vessel name (16px, semi-bold)
  - Three info rows: IMO, Flag State, and Vessel Type (12px)
  - Chevron right indicator
- **Spacing**: 16px padding, 8px vertical margins
- **Interactive**: Tap to view full vessel details

### VesselService

The service provides methods to interact with Supabase:

```dart
import 'package:icstsi/services/vessel_service.dart';

final vesselService = VesselService();

// Fetch all vessels
final vessels = await vesselService.getVessels();

// Fetch single vessel by ID
final vessel = await vesselService.getVesselById('vessel-id');

// Create new vessel
final newVessel = await vesselService.createVessel(vessel);

// Update vessel
final updatedVessel = await vesselService.updateVessel(vessel);

// Delete vessel
await vesselService.deleteVessel('vessel-id');
```

## Testing

### Sample Data

The migration includes 5 sample vessels:
1. MSC GÜLSÜN (IMO9811000) - Panama
2. EVER GIVEN (IMO9811891) - Panama
3. CMA CGM ANTOINE DE SAINT EXUPERY (IMO9454436) - Malta
4. OOCL HONG KONG (IMO9714335) - Hong Kong
5. COSCO SHIPPING UNIVERSE (IMO9795320) - China

### Running the App

1. Ensure your `.env` file has valid Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

2. Run the migration in Supabase SQL Editor

3. Launch the app:
   ```bash
   flutter run
   ```

4. Tap "View Vessels" button on the home screen

5. You should see the list of vessels displayed using VesselCard components

## Troubleshooting

### No vessels displayed
- Verify the migration was run successfully in Supabase
- Check that RLS policies are correctly configured
- Ensure your `.env` file has correct Supabase credentials

### Error loading vessels
- Check your internet connection
- Verify Supabase project is active
- Check the error message in the app for specific details

### Images not loading
- The vessel icon uses Flutter's built-in `Icons.directions_boat`
- No external images are required

## Next Steps

Potential enhancements:
- Add vessel search and filtering
- Implement vessel details page with more information
- Add vessel creation/editing forms
- Include vessel images from Supabase Storage
- Add vessel tracking and location features
- Implement vessel voyage history
