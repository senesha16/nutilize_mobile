import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutilize/core/models/user.dart' as user_model;

/// Service for user authentication and profile management
class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current logged-in user
  /// Returns null if no user is logged in
  user_model.User? getCurrentUser() {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    
    // Note: This returns basic Supabase auth info
    // You may need to fetch additional user data from the users table
    return null;
  }

  /// Get user profile from users table
  Future<user_model.User> getUserProfile(int userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      return user_model.User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Get user by email
  Future<user_model.User?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email);

      if ((response as List).isEmpty) return null;

      return user_model.User.fromJson(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch user by email: $e');
    }
  }

  /// Create a new user in the users table
  Future<user_model.User> createUser({
    required String username,
    required String email,
    required String password,
    String role = 'student', // default role
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .insert({
            'username': username,
            'email': email,
            'password': password, // In production, hash this!
            'role': role,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return user_model.User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update user profile
  Future<user_model.User> updateUserProfile(
    int userId, {
    String? username,
    String? email,
    String? role,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updates['username'] = username;
      if (email != null) updates['email'] = email;
      if (role != null) updates['role'] = role;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      return user_model.User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Verify user credentials (basic auth check)
  Future<user_model.User?> verifyCredentials(String email, String password) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password); // In production, use proper password hashing!

      if ((response as List).isEmpty) return null;

      return user_model.User.fromJson(response[0] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to verify credentials: $e');
    }
  }

  /// Get all users with a specific role
  Future<List<user_model.User>> getUsersByRole(String role) async {
    try {
      final response =
          await _supabase.from('users').select().eq('role', role);

      return (response as List)
          .map((json) => user_model.User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }
}
