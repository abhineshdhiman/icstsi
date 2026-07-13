import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voyage.dart';

/// Service for managing voyage data in Supabase
class VoyageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all voyages from Supabase
  Future<List<Voyage>> getVoyages() async {
    try {
      final response = await _supabase
          .from('voyages')
          .select()
          .order('departure_date', ascending: false);

      return (response as List)
          .map((json) => Voyage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch voyages: $e');
    }
  }

  /// Fetch voyages for a specific vessel
  Future<List<Voyage>> getVoyagesByVessel(String vesselId) async {
    try {
      final response = await _supabase
          .from('voyages')
          .select()
          .eq('vessel_id', vesselId)
          .order('departure_date', ascending: false);

      return (response as List)
          .map((json) => Voyage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch voyages for vessel: $e');
    }
  }

  /// Fetch a single voyage by ID
  Future<Voyage?> getVoyageById(String id) async {
    try {
      final response = await _supabase
          .from('voyages')
          .select()
          .eq('id', id)
          .single();

      return Voyage.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch voyage: $e');
    }
  }

  /// Create a new voyage
  Future<Voyage> createVoyage(Voyage voyage) async {
    try {
      final response = await _supabase
          .from('voyages')
          .insert(voyage.toJson())
          .select()
          .single();

      return Voyage.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create voyage: $e');
    }
  }

  /// Update an existing voyage
  Future<Voyage> updateVoyage(Voyage voyage) async {
    try {
      final response = await _supabase
          .from('voyages')
          .update(voyage.toJson())
          .eq('id', voyage.id)
          .select()
          .single();

      return Voyage.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update voyage: $e');
    }
  }

  /// Delete a voyage
  Future<void> deleteVoyage(String id) async {
    try {
      await _supabase.from('voyages').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete voyage: $e');
    }
  }

  /// Get active voyages (currently in progress)
  Future<List<Voyage>> getActiveVoyages() async {
    try {
      final response = await _supabase
          .from('voyages')
          .select()
          .eq('status', 'In Progress')
          .order('departure_date', ascending: false);

      return (response as List)
          .map((json) => Voyage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active voyages: $e');
    }
  }

  /// Get upcoming voyages (scheduled but not started)
  Future<List<Voyage>> getUpcomingVoyages() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('voyages')
          .select()
          .eq('status', 'Scheduled')
          .gte('departure_date', now)
          .order('departure_date', ascending: true);

      return (response as List)
          .map((json) => Voyage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming voyages: $e');
    }
  }
}
