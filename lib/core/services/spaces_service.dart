import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutilize/core/models/space.dart';

/// Service for managing bigger spaces within NU
class SpacesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Predefined spaces
  static const List<Map<String, String>> predefinedSpaces = [
    {'spaceType': 'AVR', 'spaceName': 'Audio Visual Room (AVR)', 'description': 'Audio Visual Room for presentations and events'},
    {'spaceType': 'Lobby', 'spaceName': 'Main Lobby', 'description': 'Main lobby for gatherings and meetings'},
    {'spaceType': 'Student Lounge', 'spaceName': 'Student Lounge', 'description': 'Student lounge for casual events'},
    {'spaceType': 'Gym', 'spaceName': 'Gymnasium', 'description': 'Main gymnasium for sports events'},
  ];

  /// Get all available spaces that are not currently reserved by active requests
  Future<List<Space>> getAvailableSpaces() async {
    try {
      final reservedSpaceTypes = await _getReservedSpaceTypes();

      return predefinedSpaces
          .asMap()
          .entries
          .map((entry) {
            final spaceData = entry.value;
            return Space(
              spaceId: entry.key + 1,
              spaceName: spaceData['spaceName']!,
              spaceType: spaceData['spaceType']!,
              description: spaceData['description']!,
              createdAt: DateTime.now(),
            );
          })
          .where((space) => !reservedSpaceTypes.contains(space.spaceType))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available spaces: $e');
    }
  }

  /// Get reserved space types from active reservations
  Future<Set<String>> _getReservedSpaceTypes() async {
    try {
      final response = await _supabase
          .from('reservation_spaces')
          .select('space_type, reservations!inner(overall_status)')
          .not('space_type', 'is', null);

      final reservedSpaceTypes = <String>{};
      for (final raw in response as List) {
        final detail = raw as Map<String, dynamic>;
        final reservation = detail['reservations'] as Map<String, dynamic>?;
        final status = reservation?['overall_status']?.toString().toLowerCase();

        // Skip cancelled, rejected, and completed reservations
        if (status == null || status == 'rejected' || status == 'completed' || status == 'cancelled') {
          continue;
        }

        final spaceType = detail['space_type'] as String?;
        if (spaceType != null) {
          reservedSpaceTypes.add(spaceType);
        }
      }

      return reservedSpaceTypes;
    } catch (e) {
      // If table doesn't exist yet, return empty set
      return <String>{};
    }
  }

  /// Get space by type
  Future<Space?> getSpaceByType(String spaceType) async {
    try {
      final space = predefinedSpaces.firstWhere(
        (s) => s['spaceType'] == spaceType,
        orElse: () => {},
      );

      if (space.isEmpty) return null;

      return Space(
        spaceId: predefinedSpaces.indexOf(space) + 1,
        spaceName: space['spaceName']!,
        spaceType: space['spaceType']!,
        description: space['description']!,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to fetch space: $e');
    }
  }
}
