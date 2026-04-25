import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutilize/core/models/room.dart';
import 'package:nutilize/core/models/item.dart';

/// Service for fetching rooms and items from Supabase
class InventoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all available rooms
  Future<List<Room>> getAvailableRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('availability_status', true)
          .eq('maintenance_status', false);

      return (response as List)
          .map((json) => Room.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
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
  Future<List<Item>> getAvailableItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select(
            'item_id, owner_id, item_name, maintenance_status, availability_status, quantity_total, date_reserved, created_at, updated_at, category_id, item_categories(category_id, category_key, display_name)',
          );

      final reservedQuantities = await _getReservedQuantities();
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

  Future<Map<int, int>> _getReservedQuantities() async {
    try {
      final response = await _supabase
          .from('reservation_details')
          .select('quantity, reservation_items!inner(item_id), reservations!inner(overall_status)');

      final reservedQuantities = <int, int>{};
      for (final raw in response as List) {
        final detail = raw as Map<String, dynamic>;
        final reservation = detail['reservations'] as Map<String, dynamic>?;
        final status = reservation?['overall_status']?.toString().toLowerCase();
        if (status == null || status == 'rejected' || status == 'completed') {
          continue;
        }

        final itemInfo = detail['reservation_items'] as Map<String, dynamic>?;
        final itemId = itemInfo?['item_id'] as int?;
        final quantityRaw = detail['quantity'];
        final quantity = quantityRaw is int
            ? quantityRaw
            : int.tryParse(quantityRaw?.toString() ?? '') ?? 0;

        if (itemId == null || quantity <= 0) {
          continue;
        }

        reservedQuantities[itemId] = (reservedQuantities[itemId] ?? 0) + quantity;
      }

      return reservedQuantities;
    } catch (e) {
      throw Exception('Failed to fetch reserved item quantities: $e');
    }
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
