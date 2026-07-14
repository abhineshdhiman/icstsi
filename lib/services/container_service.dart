import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/container.dart';

/// Service for managing container data in Supabase
class ContainerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all containers with optional booking reference
  Future<List<Container>> getContainers() async {
    try {
      final response = await _supabase
          .from('containers')
          .select('*, bookings(*)')
          .order('container_number', ascending: true);

      return (response as List)
          .map((json) => Container.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load containers: $e');
    }
  }

  /// Fetch a single container by ID
  Future<Container?> getContainerById(String id) async {
    try {
      final response = await _supabase
          .from('containers')
          .select('*, bookings(*)')
          .eq('id', id)
          .single();

      return Container.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load container: $e');
    }
  }

  /// Create a new container
  Future<Container> createContainer(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('containers')
          .insert(data)
          .select('*, bookings(*)')
          .single();

      return Container.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create container: $e');
    }
  }

  /// Update an existing container
  Future<Container> updateContainer(String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('containers')
          .update(data)
          .eq('id', id)
          .select('*, bookings(*)')
          .single();

      return Container.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update container: $e');
    }
  }

  /// Delete a container
  Future<void> deleteContainer(String id) async {
    try {
      await _supabase
          .from('containers')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete container: $e');
    }
  }

  /// Filter containers by status
  Future<List<Container>> getContainersByStatus(String status) async {
    try {
      final response = await _supabase
          .from('containers')
          .select('*, bookings(*)')
          .eq('status', status)
          .order('container_number', ascending: true);

      return (response as List)
          .map((json) => Container.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load containers by status: $e');
    }
  }

  /// Filter containers by booking ID
  Future<List<Container>> getContainersByBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('containers')
          .select('*, bookings(*)')
          .eq('booking_id', bookingId)
          .order('container_number', ascending: true);

      return (response as List)
          .map((json) => Container.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load containers by booking: $e');
    }
  }
}
