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
            'item_id, owner_id, item_name, maintenance_status, availability_status, date_reserved, created_at, updated_at, category_id, item_categories(category_id, category_key, display_name)',
          );

      return (response as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  /// Get item by ID
  Future<Item> getItem(int itemId) async {
    try {
      final response = await _supabase
          .from('items')
          .select(
            'item_id, owner_id, item_name, maintenance_status, availability_status, date_reserved, created_at, updated_at, category_id, item_categories(category_id, category_key, display_name)',
          )
          .eq('item_id', itemId)
          .single();

      return Item.fromJson(response as Map<String, dynamic>);
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
            'item_id, owner_id, item_name, maintenance_status, availability_status, date_reserved, created_at, updated_at, category_id, item_categories!inner(category_id, category_key, display_name)',
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
