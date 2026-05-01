import 'package:flutter/material.dart';
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
    DateTime? dateOfActivity,
    TimeOfDay? startOfActivity,
    TimeOfDay? endOfActivity,
  }) async {
    try {
      // Combine date and times into full DateTime objects
      DateTime? startDateTime;
      DateTime? endDateTime;

      if (dateOfActivity != null) {
        if (startOfActivity != null) {
          startDateTime = DateTime(
            dateOfActivity.year,
            dateOfActivity.month,
            dateOfActivity.day,
            startOfActivity.hour,
            startOfActivity.minute,
          );
        }
        if (endOfActivity != null) {
          endDateTime = DateTime(
            dateOfActivity.year,
            dateOfActivity.month,
            dateOfActivity.day,
            endOfActivity.hour,
            endOfActivity.minute,
          );
        }
      }

      final response = await _supabase
          .from('reservations')
          .insert({
            'user_id': userId,
            'activity_name': activityName,
            'overall_status': overallStatus,
            'Date_of_Activity': dateOfActivity?.toIso8601String(),
            'Start_of_activity': startDateTime?.toIso8601String(),
            'End_of_Activity': endDateTime?.toIso8601String(),
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

  /// Check if user has any overdue returning reservations
  Future<bool> hasOverdueReturningReservations(int userId) async {
    try {
      final reservations = await getUserReservations(userId);
      final now = DateTime.now();

      return reservations.any((reservation) {
        final status = (reservation.overallStatus ?? '').toLowerCase();
        if (status == 'returned' || status == 'cancelled' || status == 'rejected') {
          return false;
        }

        final endOfActivity = reservation.endOfActivity;
        if (endOfActivity == null) return false;

        // Overdue if past end of activity + 24 hours
        final returnDeadline = endOfActivity.add(const Duration(hours: 24));
        return now.isAfter(returnDeadline);
      });
    } catch (e) {
      throw Exception('Failed to check overdue reservations: $e');
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

  /// Cancel a reservation by setting its status to cancelled
  Future<Reservation> cancelReservation(int reservationId) async {
    return await updateReservationStatus(reservationId, 'cancelled');
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

  /// Add items to a reservations
  /// This creates entries in reservation_items and reservation_details tables
  Future<void> addItemToReservation({
    required int reservationId,
    required int itemId,
    int quantity = 1,
  }) async {
    try {
      // First create the reservation_items entryy
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

  /// Request follow-up for a pending approval
  Future<ReservationApproval> requestFollowUp(
    int approvalId,
    int requestedByUserId,
  ) async {
    try {
      final response = await _supabase
          .from('reservation_approvals')
          .update({
            'follow_up_requested': true,
            'follow_up_requested_at': DateTime.now().toIso8601String(),
            'follow_up_requested_by': requestedByUserId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('approval_id', approvalId)
          .select()
          .single();

      return ReservationApproval.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to request follow-up: $e');
    }
  }

  /// Get follow-up requests (for web system to fetch)
  Future<List<ReservationApproval>> getFollowUpRequests() async {
    try {
      final response = await _supabase
          .from('reservation_approvals')
          .select()
          .eq('follow_up_requested', true)
          .eq('status', 'pending') // Only pending approvals
          .order('follow_up_requested_at', ascending: false);

      return (response as List)
          .map((json) =>
              ReservationApproval.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch follow-up requests: $e');
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

  /// Get rooms borrowed in a reservation
  Future<List<BorrowedRoom>> getReservationRooms(int reservationId) async {
    try {
      final response = await _supabase
          .from('reservation_details')
          .select(
              'reservation_rooms_id, reservation_rooms!inner(room_id, rooms!inner(room_id, room_number, room_type))')
          .eq('reservation_id', reservationId)
          .not('reservation_rooms_id', 'is', null);

      return (response as List)
          .map((json) => BorrowedRoom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get items borrowed in a reservation
  Future<List<BorrowedItem>> getReservationItems(int reservationId) async {
    try {
      final response = await _supabase
          .from('reservation_details')
          .select(
              'quantity, reservation_items_id, reservation_items!inner(item_id, items!inner(item_id, item_name, category_id, item_owners!inner(owner_name), item_categories(category_id, category_key, display_name)))')
          .eq('reservation_id', reservationId)
          .not('reservation_items_id', 'is', null);

      return (response as List)
          .map((json) => BorrowedItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

class BorrowedRoom {
  final int roomId;
  final String roomNumber;
  final String roomType;

  BorrowedRoom({required this.roomId, required this.roomNumber, required this.roomType});

  factory BorrowedRoom.fromJson(Map<String, dynamic> json) {
    final rooms = json['reservation_rooms'] as Map<String, dynamic>?;
    final room = rooms?['rooms'] as Map<String, dynamic>?;
    return BorrowedRoom(
      roomId: room?['room_id'] as int? ?? 0,
      roomNumber: room?['room_number']?.toString() ?? 'Unknown',
      roomType: room?['room_type']?.toString() ?? 'Unknown',
    );
  }
}

class BorrowedItem {
  final int itemId;
  final String itemName;
  final String category;
  final int quantity;
  final String ownerName; // New field for item owner

  BorrowedItem({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.ownerName,
  });

  factory BorrowedItem.fromJson(Map<String, dynamic> json) {
    final items = json['reservation_items'] as Map<String, dynamic>?;
    final item = items?['items'] as Map<String, dynamic>?;
    final categoryData = item?['item_categories'] as Map<String, dynamic>?;
    final ownerData = item?['item_owners'] as Map<String, dynamic>?;
    
    return BorrowedItem(
      itemId: item?['item_id'] as int? ?? 0,
      itemName: item?['item_name']?.toString() ?? 'Unknown',
      category: categoryData?['display_name']?.toString() ??
          categoryData?['category_key']?.toString() ??
          'Uncategorized',
      quantity: json['quantity'] as int? ?? 1,
      ownerName: ownerData?['owner_name']?.toString() ?? 'Unknown',
    );
  }
}
