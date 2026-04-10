class Room {
  final int id;
  final String roomNumber;
  final bool maintenanceStatus;
  final bool availabilityStatus;
  final DateTime? dateReserved;

  Room({
    required this.id, 
    required this.roomNumber, 
    required this.maintenanceStatus, 
    required this.availabilityStatus,
    this.dateReserved,
  });

  // This is the "Translator" - it takes the Map from Supabase and makes a Room object
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['room_id'],
      roomNumber: json['room_number'],
      maintenanceStatus: json['maintenance_status'] ?? false,
      availabilityStatus: json['availability_status'] ?? true,
      dateReserved: json['date_reserved'] != null 
          ? DateTime.parse(json['date_reserved']) 
          : null,
    );
  }

  // This is for the "Add/Update" part - it turns a Room object back into a Map for Supabase
  Map<String, dynamic> toJson() {
    return {
      'room_id': id,
      'room_number': roomNumber,
      'maintenance_status': maintenanceStatus,
      'availability_status': availabilityStatus,
      'date_reserved': dateReserved?.toIso8601String(),
    };
  }
}