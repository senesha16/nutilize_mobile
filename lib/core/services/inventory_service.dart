import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
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

      final rooms = (response as List)
          .map((json) => Room.fromJson(json as Map<String, dynamic>))
          .toList();

      return rooms
          .where((room) => !reservedRoomIds.contains(room.roomId))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  Future<Set<int>> _getReservedRoomIds({DateTime? startDateTime, DateTime? endDateTime}) async {
    try {
      final response = await _supabase
          .from('v_reservation_rooms_details')
          .select();

      final reservedRoomIds = <int>{};
      for (final raw in response as List) {
        final detail = raw as Map<String, dynamic>;
        final status = detail['overall_status']?.toString().toLowerCase();

        if (_isTerminalReservationStatus(status)) {
          continue;
        }

        final reservationStart = _parseDateTimeValue(
          _readAny(detail, ['Start_of_activity', 'start_of_activity']),
        );
        final reservationEnd = _parseDateTimeValue(
          _readAny(detail, ['End_of_Activity', 'end_of_activity']),
        );
        
        if (startDateTime != null && endDateTime != null) {
          if (reservationStart != null && reservationEnd != null &&
              startDateTime.isBefore(reservationEnd) && reservationStart.isBefore(endDateTime)) {
            // Overlap detected, add room to blocked set
            final roomId = _toInt(detail['room_id']);
            if (roomId != null) {
              reservedRoomIds.add(roomId);
            }
          }
        } else {
          // No time window specified, count all active reservations
          final roomId = _toInt(detail['room_id']);
          if (roomId != null) {
            reservedRoomIds.add(roomId);
          }
        }
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

      // Compute reserved quantities for the requested window and for all active
      // reservations (global). We merge them using the larger value so Phase 4
      // reflects cross-account reserved counts (fallback to global when needed).
      final windowFuture = _getReservedQuantities(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
      );
      final globalFuture = _getReservedQuantities();

      final results = await Future.wait([windowFuture, globalFuture]);
      final Map<int, int> windowReserved = results[0] as Map<int, int>;
      final Map<int, int> globalReserved = results[1] as Map<int, int>;

      if (kDebugMode) {
        debugPrint('[InventoryService] getAvailableItems start=$startDateTime end=$endDateTime windowReserved=${windowReserved} globalReserved=${globalReserved}');
      }

      return (response as List)
          .map((json) {
            final item = Item.fromJson(json as Map<String, dynamic>);
            final w = windowReserved[item.itemId] ?? 0;
            final g = globalReserved[item.itemId] ?? 0;
            final merged = w >= g ? w : g;
            return item.copyWith(quantityReserved: merged);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<Map<int, int>> _getReservedQuantities({DateTime? startDateTime, DateTime? endDateTime}) async {
    try {
      final response = await _supabase
          .from('v_reservation_items_details')
          .select();

      final reservedQuantities = <int, int>{};
      for (final raw in response as List) {
        final detail = raw as Map<String, dynamic>;
        final status = detail['overall_status']?.toString().toLowerCase();
        if (_isTerminalReservationStatus(status)) {
          continue;
        }

        final reservationStart = _parseDateTimeValue(
          _readAny(detail, ['Start_of_activity', 'start_of_activity']),
        );
        final reservationEnd = _parseDateTimeValue(
          _readAny(detail, ['End_of_Activity', 'end_of_activity']),
        );
        
        if (startDateTime != null && endDateTime != null) {
          if (reservationStart != null && reservationEnd != null &&
              startDateTime.isBefore(reservationEnd) && reservationStart.isBefore(endDateTime)) {
            // Overlap detected, add quantity
            _addQuantityForDetail(detail, reservedQuantities);
          }
        } else {
          // No time window specified, count all active reservations
          _addQuantityForDetail(detail, reservedQuantities);
        }
      }

      if (kDebugMode) {
        debugPrint('[InventoryService] _getReservedQuantities computed=${reservedQuantities} for start=$startDateTime end=$endDateTime');
      }
      return reservedQuantities;
    } catch (e) {
      throw Exception('Failed to fetch reserved item quantities: $e');
    }
  }

  void _addQuantityForDetail(Map<String, dynamic> detail, Map<int, int> reservedQuantities) {
    final itemId = _toInt(detail['item_id']);
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

  dynamic _readAny(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key)) {
        return data[key];
      }
    }
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  bool _isTerminalReservationStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      // Null/empty status means request is still active in workflow; keep blocking.
      return false;
    }

    return status == 'rejected' ||
        status == 'completed' ||
        status == 'cancelled' ||
        status == 'returned';
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
