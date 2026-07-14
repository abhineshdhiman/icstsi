import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';

class AnnouncementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Announcement>> getAnnouncements({String? terminal}) async {
    try {
      var query = _supabase.from('announcements').select();
      if (terminal != null && terminal.isNotEmpty && terminal != 'ALL') {
        query = query.or('terminal.eq.$terminal,terminal.eq.ALL');
      }
      final response = await query.order('published_at', ascending: false);
      return (response as List)
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  Future<Announcement> getAnnouncementById(String id) async {
    try {
      final response =
          await _supabase.from('announcements').select().eq('id', id).single();
      return Announcement.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch announcement: $e');
    }
  }
}
