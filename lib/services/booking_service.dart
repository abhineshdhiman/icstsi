import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

/// Service for managing booking data in Supabase
class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all bookings from Supabase with vessel and port details
  Future<List<Booking>> getBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            vessels(*),
            ports(*)
          ''')
          .order('booking_date', ascending: false);

      return (response as List)
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  /// Fetch a single booking by ID with vessel and port details
  Future<Booking?> getBookingById(String id) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            vessels(*),
            ports(*)
          ''')
          .eq('id', id)
          .single();

      return Booking.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  /// Fetch bookings by vessel ID
  Future<List<Booking>> getBookingsByVessel(String vesselId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            vessels(*),
            ports(*)
          ''')
          .eq('vessel_id', vesselId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings by vessel: $e');
    }
  }

  /// Fetch bookings by port ID
  Future<List<Booking>> getBookingsByPort(String portId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            vessels(*),
            ports(*)
          ''')
          .eq('port_id', portId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings by port: $e');
    }
  }

  /// Create a new booking
  Future<Booking> createBooking(Booking booking) async {
    try {
      final response = await _supabase
          .from('bookings')
          .insert(booking.toJson())
          .select('''
            *,
            vessels(*),
            ports(*)
          ''')
          .single();

      return Booking.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Update an existing booking
  Future<Booking> updateBooking(Booking booking) async {
    try {
      final response = await _supabase
          .from('bookings')
          .update(booking.toJson())
          .eq('id', booking.id)
          .select('''
            *,
            vessels(*),
            ports(*)
          ''')
          .single();

      return Booking.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  /// Delete a booking
  Future<void> deleteBooking(String id) async {
    try {
      await _supabase.from('bookings').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }
}
