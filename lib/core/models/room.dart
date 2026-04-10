/// Room model matching the 'rooms' table in Supabase
class Room {
  final int roomId;
  final String roomNumber;
  final String roomType; // 'Classroom' or 'Laboratory'
  final int roomCapacity;
  final bool maintenanceStatus;
  final bool availabilityStatus;
  final DateTime? dateReserved;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? roomChairQuantity;
  final String? roomTableType;
  final int? roomTableCount;

  Room({
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.roomCapacity,
    required this.maintenanceStatus,
    required this.availabilityStatus,
    this.dateReserved,
    required this.createdAt,
    this.updatedAt,
    this.roomChairQuantity,
    this.roomTableType,
    this.roomTableCount,
  });

  /// Get display-friendly room type (converts "Lab" to "Laboratory")
  String get displayRoomType {
    if (roomType.toLowerCase() == 'lab') {
      return 'Laboratory';
    }
    return roomType;
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse dates
    DateTime parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty || value.toString() == 'null') {
        return DateTime.now();
      }
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return Room(
      roomId: (json['room_id'] as int?) ?? 0,
      roomNumber: (json['room_number'] as String?) ?? '',
      roomType: (json['room_type'] as String?) ?? 'Classroom',
      roomCapacity: (json['room_capacity'] as int?) ?? 0,
      maintenanceStatus: (json['maintenance_status'] as bool?) ?? false,
      availabilityStatus: (json['availability_status'] as bool?) ?? true,
      dateReserved: json['date_reserved'] != null && json['date_reserved'].toString() != 'null'
          ? parseDate(json['date_reserved'])
          : null,
      createdAt: parseDate(json['created_at']),
      updatedAt: json['updated_at'] != null && json['updated_at'].toString() != 'null'
          ? parseDate(json['updated_at'])
          : null,
      roomChairQuantity: json['room_chair_quantity'] as int?,
      roomTableType: json['room_table_type'] as String?,
      roomTableCount: json['room_table_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'room_number': roomNumber,
      'room_type': roomType,
      'room_capacity': roomCapacity,
      'maintenance_status': maintenanceStatus,
      'availability_status': availabilityStatus,
      'date_reserved': dateReserved?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'room_chair_quantity': roomChairQuantity,
      'room_table_type': roomTableType,
      'room_table_count': roomTableCount,
    };
  }

  Room copyWith({
    int? roomId,
    String? roomNumber,
    String? roomType,
    int? roomCapacity,
    bool? maintenanceStatus,
    bool? availabilityStatus,
    DateTime? dateReserved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      roomType: roomType ?? this.roomType,
      roomCapacity: roomCapacity ?? this.roomCapacity,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      dateReserved: dateReserved ?? this.dateReserved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
