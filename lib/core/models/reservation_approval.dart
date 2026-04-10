/// ReservationApproval model matching the 'reservation_approvals' table in Supabase
class ReservationApproval {
  final int approvalId;
  final int reservationId;
  final int officeId;
  final String status; // e.g., 'pending', 'approved', 'rejected'
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReservationApproval({
    required this.approvalId,
    required this.reservationId,
    required this.officeId,
    required this.status,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
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
  }) {
    return ReservationApproval(
      approvalId: approvalId ?? this.approvalId,
      reservationId: reservationId ?? this.reservationId,
      officeId: officeId ?? this.officeId,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
