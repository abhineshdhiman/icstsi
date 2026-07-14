import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/access_request.dart';

class AccessRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AccessRequest> submitRequest(
    AccessRequest request,
    List<File> documents,
  ) async {
    try {
      final response = await _supabase
          .from('access_requests')
          .insert(request.toJson())
          .select()
          .single();

      final requestId = response['id'] as String;

      for (final file in documents) {
        final fileName = file.path.split('/').last;
        final storagePath = '$requestId/$fileName';
        await _supabase.storage
            .from('access-documents')
            .upload(storagePath, file);

        final fileUrl =
            _supabase.storage.from('access-documents').getPublicUrl(storagePath);

        await _supabase.from('access_request_documents').insert({
          'request_id': requestId,
          'doc_type': 'document',
          'file_url': fileUrl,
          'file_name': fileName,
        });
      }

      return AccessRequest(
        id: requestId,
        companyName: request.companyName,
        city: request.city,
        stateProvince: request.stateProvince,
        country: request.country,
        zipCode: request.zipCode,
        businessAddress: request.businessAddress,
        taxIdNumber: request.taxIdNumber,
        email: request.email,
        terminal: request.terminal,
        userType: request.userType,
        copyFrom: request.copyFrom,
        repName: request.repName,
        repEmail: request.repEmail,
        repPosition: request.repPosition,
        remarks: request.remarks,
        status: 'pending',
      );
    } catch (e) {
      throw Exception('Failed to submit access request: $e');
    }
  }
}
