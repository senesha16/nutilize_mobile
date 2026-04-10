import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutilize/core/models/office.dart';

/// Service for fetching office information
class OfficeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all offices
  Future<List<Office>> getAllOffices() async {
    try {
      final response = await _supabase
          .from('offices')
          .select()
          .order('order_sequence', ascending: true);

      return (response as List)
          .map((json) => Office.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch offices: $e');
    }
  }

  /// Get office by ID
  Future<Office> getOffice(int officeId) async {
    try {
      final response = await _supabase
          .from('offices')
          .select()
          .eq('office_id', officeId)
          .single();

      return Office.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch office: $e');
    }
  }

  /// Get offices that need to approve a specific room
  Future<List<Office>> getRoomApprovalOffices(int roomId) async {
    try {
      final response = await _supabase
          .from('room_approver_offices')
          .select('office_id')
          .eq('room_id', roomId);

      final officeIds = (response as List)
          .map((json) => json['office_id'] as int)
          .toList();

      if (officeIds.isEmpty) return [];

      // Get the full office details
      final officeResponse = await _supabase
          .from('offices')
          .select()
          .inFilter('office_id', officeIds);

      return (officeResponse as List)
          .map((json) => Office.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch room approval offices: $e');
    }
  }

  /// Get offices by department
  Future<Office?> getOfficeByDepartment(String departmentName) async {
    try {
      final response = await _supabase
          .from('offices')
          .select()
          .eq('department_name', departmentName);

      if ((response as List).isEmpty) return null;

      return Office.fromJson(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch office by department: $e');
    }
  }
}
