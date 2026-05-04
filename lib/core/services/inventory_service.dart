import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutilize/core/models/room.dart';
import 'package:nutilize/core/models/item.dart';

/// Service for fetching rooms and items from Supabase
class InventoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all available rooms that are not currently reserved by active requests.
  Future<List<Room>> getAvailableRooms({DateTime? startDateTime, DateTime? endDateTime}) async {
    try {
      final reservedRoomIds = await _getReservedRoomIds(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
      );

      final response = await _supabase
          .from('rooms')
          .select()
          .eq('availability_status', true)
          .eq('maintenance_status', false);

      return (response as List)
          .map((json) => Room.fromJson(json as Map<String, dynamic>))
          .where((room) => !reservedRoomIds.contains(room.roomId))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  Future<Set<int>> _getReservedRoomIds({DateTime? startDateTime, DateTime? endDateTime}) async {
    try {
      final response = await _supabase
          .from('reservation_details')
          .select('reservation_rooms!inner(room_id), reservations!inner(overall_status, Date_of_Activity, Start_of_activity, End_of_Activity)')
          .not('reservation_rooms_id', 'is', null);

      final reservedRoomIds = <int>{};
      for (final raw in response as List) {
        final detail = raw as Map<String, dynamic>;
        final reservationData = detail['reservations'];
        if (reservationData is! Map<String, dynamic>) {
          continue;
        }

        final status = reservationData['overall_status']?.toString().toLowerCase();

        if (status == null || status == 'rejected' || status == 'completed' || status == 'cancelled') {
          continue;
        }

        if (startDateTime != null && endDateTime != null) {
          final overlaps = _reservationOverlapsWindow(
            reservationData,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
          );
          if (!overlaps) {
            continue; // No overlap, skip this reservation
          }
          // If we reach here, there IS an overlap, so add the room to blocked set
          final roomInfo = detail['reservation_rooms'] as Map<String, dynamic>?;
          final roomId = roomInfo?['room_id'] as int?;
          if (roomId != null) {
            reservedRoomIds.add(roomId);
          }
        }
        // If startDateTime/endDateTime are null, don't block any rooms
      }

      return reservedRoomIds;
    } catch (e) {
      throw Exception('Failed to fetch reserved room ids: $e');
    }
  }

  /// Get room by ID
  Future<Room> getRoom(int roomId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('room_id', roomId)
          .single();

      return Room.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch room: $e');
    }
  }

  /// Get all available items
  Future<List<Item>> getAvailableItems({DateTime? startDateTime, DateTime? endDateTime}) async {
    try {
      final response = await _supabase
          .from('items')
          .select(
            'item_id, owner_id, item_name, maintenance_status, availability_status, quantity_total, date_reserved, created_at, updated_at, category_id, item_categories(category_id, category_key, display_name)',
          );

      final reservedQuantities = await _getReservedQuantities(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
      );
      return (response as List)
          .map((json) {
            final item = Item.fromJson(json as Map<String, dynamic>);
            return item.copyWith(quantityReserved: reservedQuantities[item.itemId] ?? 0);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<Map<int, int>> _getReservedQuantities({DateTime? startDateTime, DateTime? endDateTime}) async {
    try {
      final response = await _supabase
          .from('reservation_details')
          .select('quantity, reservation_items!inner(item_id), reservations!inner(overall_status, Date_of_Activity, Start_of_activity, End_of_Activity)');

      final reservedQuantities = <int, int>{};
      for (final raw in response as List) {
        final detail = raw as Map<String, dynamic>;
        final reservationData = detail['reservations'];
        if (reservationData is! Map<String, dynamic>) {
          continue;
        }

        final status = reservationData['overall_status']?.toString().toLowerCase();
        if (status == null || status == 'rejected' || status == 'completed' || status == 'cancelled') {
          continue;
        }

        if (startDateTime != null && endDateTime != null) {
          final overlaps = _reservationOverlapsWindow(
            reservationData,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
          );
          if (!overlaps) {
            continue; // No overlap, skip this reservation
          }
          // If we reach here, there IS an overlap, so add the item quantity
          _addQuantityForDetail(detail, reservedQuantities);
        }
        // If startDateTime/endDateTime are null, don't block any item quantities
      }

      return reservedQuantities;
    } catch (e) {
      throw Exception('Failed to fetch reserved item quantities: $e');
    }
  }

  void _addQuantityForDetail(Map<String, dynamic> detail, Map<int, int> reservedQuantities) {
    final itemInfo = detail['reservation_items'] as Map<String, dynamic>?;
    final itemId = itemInfo?['item_id'] as int?;
    final quantityRaw = detail['quantity'];
    final quantity = quantityRaw is int
        ? quantityRaw
        : int.tryParse(quantityRaw?.toString() ?? '') ?? 0;

    if (itemId == null || quantity <= 0) {
      return;
    }

    reservedQuantities[itemId] = (reservedQuantities[itemId] ?? 0) + quantity;
  }

  bool _reservationOverlapsWindow(
    Map<String, dynamic> reservationData, {
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    final reservationStart = _parseDateTimeValue(reservationData['Start_of_activity']);
    final reservationEnd = _parseDateTimeValue(reservationData['End_of_Activity']);

    if (reservationStart != null && reservationEnd != null) {
      return startDateTime.isBefore(reservationEnd) && reservationStart.isBefore(endDateTime);
    }

    final reservationDate = _parseDateTimeValue(reservationData['Date_of_Activity']);
    if (reservationDate != null) {
      return _sameCalendarDate(reservationDate, startDateTime) || _sameCalendarDate(reservationDate, endDateTime);
    }

    return false;
  }

  DateTime? _parseDateTimeValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  bool _sameCalendarDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get item by ID
  Future<Item> getItem(int itemId) async {
    try {
      final response = await _supabase
          .from('items')
          .select(
            'item_id, owner_id, item_name, maintenance_status, availability_status, quantity_total, date_reserved, created_at, updated_at, category_id, item_categories(category_id, category_key, display_name)',
          )
          .eq('item_id', itemId)
          .single();

      final reservedQuantities = await _getReservedQuantities();
      final item = Item.fromJson(response as Map<String, dynamic>);
      return item.copyWith(quantityReserved: reservedQuantities[item.itemId] ?? 0);
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }

  /// Get items by category
  Future<List<Item>> getItemsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('items')
          .select(
            'item_id, owner_id, item_name, maintenance_status, availability_status, quantity_total, date_reserved, created_at, updated_at, category_id, item_categories!inner(category_id, category_key, display_name)',
          )
          .or('category_key.eq.$category,display_name.eq.$category',
              referencedTable: 'item_categories');

      return (response as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items by category: $e');
    }
  }
}
