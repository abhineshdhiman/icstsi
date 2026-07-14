# 📚 Booking Flow Implementation Guide

## Overview
Complete booking management system for ICSTSI Flutter app with list view, creation form, and full CRUD operations.

---

## 🎯 Features Implemented

### 1. **Bookings List Screen** (`lib/screens/bookings_screen.dart`)
- ✅ Display all bookings with BookingCard widget
- ✅ Pull-to-refresh functionality
- ✅ Tap to view detailed booking information
- ✅ Empty state with "Create Booking" CTA
- ✅ Floating Action Button for quick booking creation
- ✅ Error handling with retry option
- ✅ Loading states with spinner

### 2. **Create Booking Screen** (`lib/screens/create_booking_screen.dart`)
- ✅ Form validation for all required fields
- ✅ Vessel selection dropdown (populated from database)
- ✅ Port selection dropdown (populated from database)
- ✅ Status selection (pending, confirmed, completed, cancelled)
- ✅ Date pickers for:
  - Booking date (required)
  - Discharge date (optional)
  - Gate out date (optional)
- ✅ Auto-generated booking reference
- ✅ Submit with loading state
- ✅ Success/error feedback with SnackBars
- ✅ Returns to list screen after successful creation

### 3. **Home Screen Integration** (`lib/main.dart`)
- ✅ "View Bookings" button added to home screen
- ✅ Positioned between "Port Selection" and "View Voyages"
- ✅ Consistent styling with other navigation buttons

---

## 📱 User Flow

### Viewing Bookings
1. User taps **"View Bookings"** on home screen
2. App loads all bookings from Supabase
3. Bookings displayed as cards with:
   - Booking reference
   - Status badge (color-coded)
   - Vessel details (name, IMO, flag, type)
   - Port details (name, code, location, country)
   - Important dates (booking, discharge, gate out)
4. User can:
   - Pull down to refresh
   - Tap card to view full details in dialog
   - Tap FAB to create new booking

### Creating a Booking
1. User taps **"New Booking"** FAB or empty state button
2. Form loads with:
   - Auto-generated booking reference (editable)
   - Status dropdown (defaults to "pending")
   - Vessel dropdown (loads from database)
   - Port dropdown (loads from database)
   - Booking date (defaults to today)
   - Optional discharge date
   - Optional gate out date
3. User fills required fields (marked with *)
4. User taps **"Create Booking"**
5. App validates and submits to Supabase
6. Success: Returns to list with new booking visible
7. Error: Shows error message, form remains open

---

## 🎨 Design System

### Colors
- **Primary Orange:** `#FF6319` - Buttons, headers, accents
- **Dark Gray:** `#1A1919` - Text, borders
- **Status Colors:**
  - Confirmed: `#4CAF50` (Green)
  - Pending: `#FFA726` (Orange)
  - Cancelled: `#EF5350` (Red)
  - Completed: `#42A5F5` (Blue)

### Typography
- **Headers:** 18px, FontWeight.w600
- **Body:** 14px, FontWeight.normal
- **Labels:** 13px, FontWeight.w500
- **Status Badge:** 11px, FontWeight.w600, uppercase

### Components
- **Card Elevation:** 2
- **Border Radius:** 8px
- **Padding:** 16px (cards), 12px (sections)
- **Icon Size:** 16px (info rows), 64px (empty states)

---

## 🗄️ Database Schema

### Bookings Table
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_reference TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  booking_date TIMESTAMPTZ NOT NULL,
  discharge_date TIMESTAMPTZ,
  gate_out_date TIMESTAMPTZ,
  vessel_id UUID NOT NULL REFERENCES vessels(id) ON DELETE CASCADE,
  port_id UUID NOT NULL REFERENCES ports(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Relationships
- **Booking → Vessel:** Many-to-One (vessel_id)
- **Booking → Port:** Many-to-One (port_id)
- **Cascade Delete:** Deleting vessel/port removes associated bookings

---

## 📦 Dependencies

### Added to `pubspec.yaml`
```yaml
dependencies:
  uuid: ^4.5.1        # For generating unique booking IDs
  intl: ^0.19.0       # For date formatting (already present)
  supabase_flutter: ^2.5.0  # Database integration (already present)
```

### Installation
```bash
flutter pub get
```

---

## 🚀 Setup Instructions

### 1. Run Database Migration
Execute the booking table migration in Supabase SQL Editor:
```bash
# File: supabase_migrations/create_bookings_table.sql
```

### 2. Ensure Vessels & Ports Exist
Run these migrations first (if not already done):
```bash
# supabase_migrations/create_vessels_table.sql
# supabase_migrations/create_ports_table.sql
```

### 3. Add Sample Data (Optional)
```sql
-- Insert sample vessels
INSERT INTO vessels (id, vessel_name, imo_number, flag_state, vessel_type) VALUES
  ('11111111-1111-1111-1111-111111111111', 'MSC Oscar', 'IMO9744465', 'Panama', 'Container Ship'),
  ('22222222-2222-2222-2222-222222222222', 'OOCL Hong Kong', 'IMO9714335', 'Hong Kong', 'Container Ship');

-- Insert sample ports
INSERT INTO ports (id, port_code, port_name, location, country) VALUES
  ('33333333-3333-3333-3333-333333333333', 'SGSIN', 'Port of Singapore', 'Singapore', 'Singapore'),
  ('44444444-4444-4444-4444-444444444444', 'USNYC', 'Port of New York', 'New York', 'United States');

-- Insert sample bookings
INSERT INTO bookings (id, booking_reference, status, booking_date, discharge_date, vessel_id, port_id) VALUES
  ('55555555-5555-5555-5555-555555555555', 'BKG-2024-001', 'confirmed', '2024-01-15 10:00:00+00', '2024-01-20 14:00:00+00', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333'),
  ('66666666-6666-6666-6666-666666666666', 'BKG-2024-002', 'pending', '2024-01-18 09:30:00+00', NULL, '22222222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444');
```

### 4. Install Dependencies
```bash
cd icstsi_app
flutter pub get
```

### 5. Run the App
```bash
flutter run
# or
flutter run -d chrome  # For web
```

---

## 🧪 Testing Checklist

### Bookings List Screen
- [ ] List loads successfully with bookings
- [ ] Empty state shows when no bookings exist
- [ ] Pull-to-refresh updates the list
- [ ] Tapping a card shows detail dialog
- [ ] FAB navigates to create screen
- [ ] Error state shows with retry button
- [ ] Loading spinner displays during fetch

### Create Booking Screen
- [ ] Form loads with vessels and ports
- [ ] Booking reference auto-generates
- [ ] All dropdowns populate correctly
- [ ] Date pickers open and update fields
- [ ] Validation prevents empty required fields
- [ ] Submit button shows loading state
- [ ] Success creates booking and returns to list
- [ ] Error shows SnackBar with message
- [ ] Back button cancels creation

### Integration
- [ ] Home screen button navigates to bookings
- [ ] Created bookings appear in list immediately
- [ ] Booking details match input data
- [ ] Status colors display correctly
- [ ] Vessel and port details populate in cards

---

## 🔧 Troubleshooting

### "Failed to fetch bookings"
**Cause:** Database tables not created or RLS policies blocking access  
**Fix:**
1. Run all migrations in order (vessels → ports → bookings)
2. Check Supabase RLS policies allow SELECT for authenticated users
3. Verify `.env` has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`

### "No vessels/ports available"
**Cause:** Empty vessels or ports tables  
**Fix:**
1. Insert sample data (see Setup Instructions #3)
2. Or create vessels/ports through their respective screens first

### "Package uuid not found"
**Cause:** Dependencies not installed  
**Fix:**
```bash
flutter pub get
flutter clean
flutter pub get
```

### Date picker not showing
**Cause:** Theme conflict  
**Fix:** Already handled in code with custom theme builder

---

## 📊 API Methods Used

### BookingService
```dart
getBookings()                    // Fetch all bookings with vessel & port
getBookingById(String id)        // Fetch single booking
getBookingsByVessel(String id)   // Filter by vessel
getBookingsByPort(String id)     // Filter by port
createBooking(Booking booking)   // Create new booking
updateBooking(Booking booking)   // Update existing booking
deleteBooking(String id)         // Delete booking
```

### VesselService
```dart
getVessels()  // Used in create form dropdown
```

### PortService
```dart
getAllPorts()  // Used in create form dropdown
```

---

## 🎯 Future Enhancements

### Potential Features
- [ ] Edit existing bookings
- [ ] Delete bookings with confirmation
- [ ] Filter bookings by status
- [ ] Search bookings by reference
- [ ] Sort by date/status/vessel
- [ ] Export bookings to PDF/CSV
- [ ] Push notifications for status changes
- [ ] Booking timeline view
- [ ] Bulk booking creation
- [ ] QR code generation for bookings

### Performance Optimizations
- [ ] Pagination for large booking lists
- [ ] Caching with local storage
- [ ] Optimistic UI updates
- [ ] Background sync

---

## 📝 Code Structure

```
lib/
├── models/
│   ├── booking.dart          # Booking model with status colors
│   ├── vessel.dart           # Vessel model (existing)
│   └── port.dart             # Port model (existing)
├── services/
│   ├── booking_service.dart  # Booking CRUD operations
│   ├── vessel_service.dart   # Vessel data access (existing)
│   └── port_service.dart     # Port data access (existing)
├── widgets/
│   └── booking_card.dart     # Booking display card (existing)
├── screens/
│   ├── bookings_screen.dart       # NEW: List all bookings
│   ├── create_booking_screen.dart # NEW: Create booking form
│   └── main.dart                  # UPDATED: Added bookings button
└── main.dart                 # App entry point
```

---

## 🎉 Summary

The complete booking flow is now implemented with:
- ✅ **List View** - Display all bookings with details
- ✅ **Create Form** - Add new bookings with validation
- ✅ **Navigation** - Integrated into home screen
- ✅ **Error Handling** - Graceful failures with retry
- ✅ **Loading States** - User feedback during operations
- ✅ **Design System** - Consistent ICSTSI branding

**Next Steps:**
1. Review the implementation at http://localhost:3000
2. Test the booking flow end-to-end
3. Add sample data to Supabase
4. Reply **"approve"** or **"push"** to commit to GitHub

---

**Questions or Issues?** Let me know! 🚀
