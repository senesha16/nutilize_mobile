/// User model matching the 'users' table in Supabase
class User {
  final int userId;
  final String username;
  final String email;
  final String role; // e.g., 'student', 'staff', 'admin'
  final String firstName;
  final String middleInitial;
  final String lastName;
  final String fullName;
  final String affiliation;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.firstName,
    required this.middleInitial,
    required this.lastName,
    required this.fullName,
    required this.affiliation,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert JSON from Supabase to User object
  factory User.fromJson(Map<String, dynamic> json) {
    final firstName = (json['first_name'] ?? '').toString();
    final middleInitial = (json['middle_initial'] ?? '').toString();
    final lastName = (json['last_name'] ?? '').toString();
    final fullName = (json['full_name'] ?? '').toString();

    return User(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      firstName: firstName,
      middleInitial: middleInitial,
      lastName: lastName,
      fullName: fullName.isNotEmpty
          ? fullName
          : [firstName, middleInitial, lastName]
              .where((value) => value.isNotEmpty)
              .join(' '),
      affiliation: (json['affiliation'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert User object to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'role': role,
      'first_name': firstName,
      'middle_initial': middleInitial,
      'last_name': lastName,
      'full_name': fullName,
      'affiliation': affiliation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? userId,
    String? username,
    String? email,
    String? role,
    String? firstName,
    String? middleInitial,
    String? lastName,
    String? fullName,
    String? affiliation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      middleInitial: middleInitial ?? this.middleInitial,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      affiliation: affiliation ?? this.affiliation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
