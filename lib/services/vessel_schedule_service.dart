import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vessel_schedule.dart';

class VesselScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<VesselSchedule>> getVesselSchedules({
    String? terminal,
    String? status,
    String? vesselName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabase.from('vessel_schedules').select();

      if (terminal != null && terminal.isNotEmpty) {
        query = query.eq('terminal', terminal);
      }
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (vesselName != null && vesselName.isNotEmpty) {
        query = query.ilike('vessel_name', '%$vesselName%');
      }
      if (fromDate != null) {
        query = query.gte('eta_etb', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('eta_etb', toDate.toIso8601String());
      }

      final response = await query.order('eta_etb', ascending: true);
      return (response as List)
          .map((json) => VesselSchedule.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vessel schedules: $e');
    }
  }
}
