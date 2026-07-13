import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vessel.dart';

/// Service for managing vessel data in Supabase
class VesselService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all vessels from Supabase
  Future<List<Vessel>> getVessels() async {
    try {
      final response = await _supabase
          .from('vessels')
          .select()
          .order('vessel_name', ascending: true);

      return (response as List)
          .map((json) => Vessel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vessels: $e');
    }
  }

  /// Fetch a single vessel by ID
  Future<Vessel?> getVesselById(String id) async {
    try {
      final response = await _supabase
          .from('vessels')
          .select()
          .eq('id', id)
          .single();

      return Vessel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch vessel: $e');
    }
  }

  /// Create a new vessel
  Future<Vessel> createVessel(Vessel vessel) async {
    try {
      final response = await _supabase
          .from('vessels')
          .insert(vessel.toJson())
          .select()
          .single();

      return Vessel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create vessel: $e');
    }
  }

  /// Update an existing vessel
  Future<Vessel> updateVessel(Vessel vessel) async {
    try {
      final response = await _supabase
          .from('vessels')
          .update(vessel.toJson())
          .eq('id', vessel.id)
          .select()
          .single();

      return Vessel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update vessel: $e');
    }
  }

  /// Delete a vessel
  Future<void> deleteVessel(String id) async {
    try {
      await _supabase.from('vessels').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vessel: $e');
    }
  }
}
