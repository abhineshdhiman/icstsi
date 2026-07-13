import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/port.dart';

/// Service for managing Port data in Supabase
class PortService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all ports from Supabase
  Future<List<Port>> getAllPorts() async {
    try {
      final response = await _supabase
          .from('ports')
          .select()
          .order('port_name', ascending: true);

      return (response as List)
          .map((json) => Port.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load ports: $e');
    }
  }

  /// Get a specific port by ID
  Future<Port?> getPortById(String id) async {
    try {
      final response = await _supabase
          .from('ports')
          .select()
          .eq('id', id)
          .single();

      return Port.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Search ports by name, code, or country
  Future<List<Port>> searchPorts(String query) async {
    try {
      final response = await _supabase
          .from('ports')
          .select()
          .or('port_name.ilike.%$query%,port_code.ilike.%$query%,country.ilike.%$query%')
          .order('port_name', ascending: true);

      return (response as List)
          .map((json) => Port.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search ports: $e');
    }
  }

  /// Create a new port
  Future<Port> createPort(Port port) async {
    try {
      final response = await _supabase
          .from('ports')
          .insert(port.toJson())
          .select()
          .single();

      return Port.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create port: $e');
    }
  }

  /// Update an existing port
  Future<Port> updatePort(Port port) async {
    try {
      final response = await _supabase
          .from('ports')
          .update(port.toJson())
          .eq('id', port.id)
          .select()
          .single();

      return Port.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update port: $e');
    }
  }

  /// Delete a port
  Future<void> deletePort(String id) async {
    try {
      await _supabase.from('ports').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete port: $e');
    }
  }
}
