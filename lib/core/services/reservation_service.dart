import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutilize/core/models/reservation.dart';
import 'package:nutilize/core/models/reservation_approval.dart';

/// Service for managing reservations in Supabase
class ReservationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new reservation
  /// Returns the created reservation with its ID
  Future<Reservation> createReservation({
    required int userId,
    required String activityName,
    String? overallStatus = 'pending',
  }) async {
    try {
      final response = await _supabase
          .from('reservations')
          .insert({
            'user_id': userId,
            'activity_name': activityName,
            'overall_status': overallStatus,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Reservation.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  /// Get reservation by ID
  Future<Reservation> getReservation(int reservationId) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('reservation_id', reservationId)
          .single();

      return Reservation.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch reservation: $e');
    }
  }

  /// Get all reservations for a user
  Future<List<Reservation>> getUserReservations(int userId) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user reservations: $e');
    }
  }

  /// Update reservation overall status
  Future<Reservation> updateReservationStatus(
    int reservationId,
    String newStatus,
  ) async {
    try {
      final response = await _supabase
          .from('reservations')
          .update({
            'overall_status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('reservation_id', reservationId)
          .select()
          .single();

      return Reservation.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update reservation status: $e');
    }
  }

  /// Add rooms to a reservation
  /// This creates entries in reservation_rooms and reservation_details tables
  Future<void> addRoomToReservation({
    required int reservationId,
    required int roomId,
  }) async {
    try {
      // First create the reservation_rooms entry
      final roomRes = await _supabase
          .from('reservation_rooms')
          .insert({'room_id': roomId})
          .select()
          .single();

      final reservationRoomsId = roomRes['reservation_rooms_id'];

      // Then create the reservation_details entry
      await _supabase.from('reservation_details').insert({
        'reservation_id': reservationId,
        'reservation_rooms_id': reservationRoomsId,
        'quantity': 1,
      });
    } catch (e) {
      throw Exception('Failed to add room to reservation: $e');
    }
  }

  /// Add items to a reservation
  /// This creates entries in reservation_items and reservation_details tables
  Future<void> addItemToReservation({
    required int reservationId,
    required int itemId,
    int quantity = 1,
  }) async {
    try {
      // First create the reservation_items entry
      final itemRes = await _supabase
          .from('reservation_items')
          .insert({'item_id': itemId})
          .select()
          .single();

      final reservationItemsId = itemRes['reservation_items_id'];

      // Then create the reservation_details entry
      await _supabase.from('reservation_details').insert({
        'reservation_id': reservationId,
        'reservation_items_id': reservationItemsId,
        'quantity': quantity,
      });
    } catch (e) {
      throw Exception('Failed to add item to reservation: $e');
    }
  }

  /// Get approval details for a reservation
  Future<List<ReservationApproval>> getReservationApprovals(
    int reservationId,
  ) async {
    try {
      final response = await _supabase
          .from('reservation_approvals')
          .select()
          .eq('reservation_id', reservationId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              ReservationApproval.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reservation approvals: $e');
    }
  }

  /// Get pending approvals (all that need action)
  Future<List<ReservationApproval>> getPendingApprovals() async {
    try {
      final response = await _supabase
          .from('reservation_approvals')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              ReservationApproval.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending approvals: $e');
    }
  }

  /// Approve a reservation (called by office staff)
  Future<ReservationApproval> approveReservation(
    int approvalId,
  ) async {
    try {
      final response = await _supabase
          .from('reservation_approvals')
          .update({
            'status': 'approved',
            'approved_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('approval_id', approvalId)
          .select()
          .single();

      return ReservationApproval.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to approve reservation: $e');
    }
  }

  /// Reject a reservation (called by office staff)
  Future<ReservationApproval> rejectReservation(
    int approvalId,
  ) async {
    try {
      final response = await _supabase
          .from('reservation_approvals')
          .update({
            'status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('approval_id', approvalId)
          .select()
          .single();

      return ReservationApproval.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to reject reservation: $e');
    }
  }

  /// Delete a reservation (cascades to details)
  Future<void> deleteReservation(int reservationId) async {
    try {
      await _supabase
          .from('reservations')
          .delete()
          .eq('reservation_id', reservationId);
    } catch (e) {
      throw Exception('Failed to delete reservation: $e');
    }
  }
}
