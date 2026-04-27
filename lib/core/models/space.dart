/// Space model for bigger spaces within NU (AVR, Lobby, Student Lounge, Gym)
class Space {
  final int spaceId;
  final String spaceName;
  final String spaceType; // 'AVR', 'Lobby', 'Student Lounge', 'Gym'
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Space({
    required this.spaceId,
    required this.spaceName,
    required this.spaceType,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
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

    return Space(
      spaceId: (json['space_id'] as int?) ?? 0,
      spaceName: (json['space_name'] as String?) ?? '',
      spaceType: (json['space_type'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      createdAt: parseDate(json['created_at']),
      updatedAt: json['updated_at'] != null && json['updated_at'].toString() != 'null'
          ? parseDate(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'space_id': spaceId,
      'space_name': spaceName,
      'space_type': spaceType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Space copyWith({
    int? spaceId,
    String? spaceName,
    String? spaceType,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Space(
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      spaceType: spaceType ?? this.spaceType,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
