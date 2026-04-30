/// ReservationApproval model matching the 'reservation_approvals' table in Supabase
class ReservationApproval {
  final int approvalId;
  final int reservationId;
  final int officeId;
  final String status; // e.g., 'pending', 'approved', 'rejected'
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool followUpRequested; // NEW: Track follow-up requests
  final DateTime? followUpRequestedAt; // NEW: When follow-up was requested
  final int? followUpRequestedBy; // NEW: Who requested the follow-up

  ReservationApproval({
    required this.approvalId,
    required this.reservationId,
    required this.officeId,
    required this.status,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
    this.followUpRequested = false, // NEW
    this.followUpRequestedAt, // NEW
    this.followUpRequestedBy, // NEW
  });

  factory ReservationApproval.fromJson(Map<String, dynamic> json) {
    return ReservationApproval(
      approvalId: json['approval_id'] ?? 0,
      reservationId: json['reservation_id'] ?? 0,
      officeId: json['office_id'] ?? 0,
      status: json['status'] ?? 'pending',
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      followUpRequested: json['follow_up_requested'] ?? false, // NEW
      followUpRequestedAt: json['follow_up_requested_at'] != null
          ? DateTime.parse(json['follow_up_requested_at'] as String)
          : null, // NEW
      followUpRequestedBy: json['follow_up_requested_by'], // NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approval_id': approvalId,
      'reservation_id': reservationId,
      'office_id': officeId,
      'status': status,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'follow_up_requested': followUpRequested, // NEW
      'follow_up_requested_at': followUpRequestedAt?.toIso8601String(), // NEW
      'follow_up_requested_by': followUpRequestedBy, // NEW
    };
  }

  ReservationApproval copyWith({
    int? approvalId,
    int? reservationId,
    int? officeId,
    String? status,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? followUpRequested, // NEW
    DateTime? followUpRequestedAt, // NEW
    int? followUpRequestedBy, // NEW
  }) {
    return ReservationApproval(
      approvalId: approvalId ?? this.approvalId,
      reservationId: reservationId ?? this.reservationId,
      officeId: officeId ?? this.officeId,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      followUpRequested: followUpRequested ?? this.followUpRequested, // NEW
      followUpRequestedAt: followUpRequestedAt ?? this.followUpRequestedAt, // NEW
      followUpRequestedBy: followUpRequestedBy ?? this.followUpRequestedBy, // NEW
    );
  }
}
