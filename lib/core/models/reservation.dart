/// Reservation model matching the 'reservations' table in Supabase
class Reservation {
  final int reservationId;
  final int userId;
  final String activityName;
  final String? overallStatus; // e.g., 'pending', 'approved', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.reservationId,
    required this.userId,
    required this.activityName,
    this.overallStatus,
    required this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservation_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      activityName: json['activity_name'] ?? '',
      overallStatus: json['overall_status'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_id': reservationId,
      'user_id': userId,
      'activity_name': activityName,
      'overall_status': overallStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Reservation copyWith({
    int? reservationId,
    int? userId,
    String? activityName,
    String? overallStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      reservationId: reservationId ?? this.reservationId,
      userId: userId ?? this.userId,
      activityName: activityName ?? this.activityName,
      overallStatus: overallStatus ?? this.overallStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
