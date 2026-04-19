import 'package:flutter/material.dart';

/// Reservation model matching the 'reservations' table in Supabase
class Reservation {
  final int reservationId;
  final int userId;
  final String activityName;
  final String? overallStatus; // e.g., 'pending', 'approved', 'rejected', 'completed'
  final DateTime? dateOfActivity; // Full timestamp of when activity is scheduled
  final DateTime? startOfActivity; // Full timestamp when activity starts
  final DateTime? endOfActivity; // Full timestamp when activity ends
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.reservationId,
    required this.userId,
    required this.activityName,
    this.overallStatus,
    this.dateOfActivity,
    this.startOfActivity,
    this.endOfActivity,
    required this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservation_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      activityName: json['activity_name'] ?? '',
      overallStatus: json['overall_status'],
      dateOfActivity: json['Date_of_Activity'] != null
          ? DateTime.tryParse(json['Date_of_Activity'] as String)
          : null,
      startOfActivity: json['Start_of_activity'] != null
          ? DateTime.tryParse(json['Start_of_activity'] as String)
          : null,
      endOfActivity: json['End_of_Activity'] != null
          ? DateTime.tryParse(json['End_of_Activity'] as String)
          : null,
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
      'Date_of_Activity': dateOfActivity?.toIso8601String(),
      'Start_of_activity': startOfActivity?.toIso8601String(),
      'End_of_Activity': endOfActivity?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Reservation copyWith({
    int? reservationId,
    int? userId,
    String? activityName,
    String? overallStatus,
    DateTime? dateOfActivity,
    DateTime? startOfActivity,
    DateTime? endOfActivity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      reservationId: reservationId ?? this.reservationId,
      userId: userId ?? this.userId,
      activityName: activityName ?? this.activityName,
      overallStatus: overallStatus ?? this.overallStatus,
      dateOfActivity: dateOfActivity ?? this.dateOfActivity,
      startOfActivity: startOfActivity ?? this.startOfActivity,
      endOfActivity: endOfActivity ?? this.endOfActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
