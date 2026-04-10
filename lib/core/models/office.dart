/// Office model matching the 'offices' table in Supabase
class Office {
  final int officeId;
  final String departmentName;
  final String officerName;
  final String? statusCheckType;
  final String? shortCode;
  final int? orderSequence;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Office({
    required this.officeId,
    required this.departmentName,
    required this.officerName,
    this.statusCheckType,
    this.shortCode,
    this.orderSequence,
    required this.createdAt,
    this.updatedAt,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      officeId: json['office_id'] ?? 0,
      departmentName: json['department_name'] ?? '',
      officerName: json['officer_name'] ?? '',
      statusCheckType: json['status_check_type'],
      shortCode: json['short_code'],
      orderSequence: json['order_sequence'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'office_id': officeId,
      'department_name': departmentName,
      'officer_name': officerName,
      'status_check_type': statusCheckType,
      'short_code': shortCode,
      'order_sequence': orderSequence,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Office copyWith({
    int? officeId,
    String? departmentName,
    String? officerName,
    String? statusCheckType,
    String? shortCode,
    int? orderSequence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Office(
      officeId: officeId ?? this.officeId,
      departmentName: departmentName ?? this.departmentName,
      officerName: officerName ?? this.officerName,
      statusCheckType: statusCheckType ?? this.statusCheckType,
      shortCode: shortCode ?? this.shortCode,
      orderSequence: orderSequence ?? this.orderSequence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
