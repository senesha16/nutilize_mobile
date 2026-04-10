import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:nutilize/core/models/user.dart' as user_model;

/// Service for handling authentication (login, register, logout)
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _userSessionKey = 'logged_in_user';

  /// Register a new user
  /// Returns the created User if successful
  /// Throws exception if registration fails
  Future<user_model.User> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (fullName.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (password.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      // Check if email already exists
      final existingEmail = await _supabase
          .from('users')
          .select()
          .eq('email', email);

      if (existingEmail.isNotEmpty) {
        throw Exception('Email already registered');
      }

      // Check if username already exists
      final existingUsername = await _supabase
          .from('users')
          .select()
          .eq('username', username);

      if (existingUsername.isNotEmpty) {
        throw Exception('Username already taken');
      }

      // Hash password using bcrypt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Create user in database
      final response = await _supabase
          .from('users')
          .insert({
            'username': username,
            'email': email,
            'password': hashedPassword,
            'role': 'student', // Default role
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final user = user_model.User.fromJson(response as Map<String, dynamic>);

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Login with email and password
  /// Returns the User if login is successful
  /// Throws exception if login fails
  Future<user_model.User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Fetch user from database by email
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email);

      if (response.isEmpty) {
        throw Exception('User not found');
      }

      final userData = response[0] as Map<String, dynamic>;
      final user = user_model.User.fromJson(userData);

      // Verify password using bcrypt
      final storedHashedPassword = userData['password'] as String;
      final isPasswordValid = BCrypt.checkpw(password, storedHashedPassword);

      if (!isPasswordValid) {
        throw Exception('Invalid password');
      }

      // Save user session
      await _saveUserSession(user);

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _userSessionKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Get the currently logged-in user from session storage
  Future<user_model.User?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userSessionKey);
      if (userJson == null) return null;

      // Parse the stored JSON
      // Note: You might want to use a proper JSON decoder here
      return _parseUserFromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Save user session to secure storage
  Future<void> _saveUserSession(user_model.User user) async {
    try {
      final userJson = '''
{
  "user_id": ${user.userId},
  "username": "${user.username}",
  "email": "${user.email}",
  "role": "${user.role}",
  "created_at": "${user.createdAt.toIso8601String()}",
  "updated_at": "${user.updatedAt?.toIso8601String()}"
}
''';
      await _secureStorage.write(key: _userSessionKey, value: userJson);
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  /// Parse User from simple JSON string
  user_model.User? _parseUserFromJson(String jsonString) {
    try {
      final map = <String, dynamic>{};
      
      // Simple parsing using regex patterns
      if (jsonString.contains('user_id')) {
        final userIdMatch = RegExp(r'"user_id"\s*:\s*(\d+)').firstMatch(jsonString);
        if (userIdMatch != null) {
          map['user_id'] = int.parse(userIdMatch.group(1)!);
        }
      }
      
      if (jsonString.contains('username')) {
        final usernameMatch = RegExp(r'"username"\s*:\s*"([^"]+)"').firstMatch(jsonString);
        if (usernameMatch != null) {
          map['username'] = usernameMatch.group(1);
        }
      }
      
      if (jsonString.contains('email')) {
        final emailMatch = RegExp(r'"email"\s*:\s*"([^"]+)"').firstMatch(jsonString);
        if (emailMatch != null) {
          map['email'] = emailMatch.group(1);
        }
      }
      
      if (jsonString.contains('role')) {
        final roleMatch = RegExp(r'"role"\s*:\s*"([^"]+)"').firstMatch(jsonString);
        if (roleMatch != null) {
          map['role'] = roleMatch.group(1);
        }
      }
      
      if (jsonString.contains('created_at')) {
        final createdMatch = RegExp(r'"created_at"\s*:\s*"([^"]+)"').firstMatch(jsonString);
        if (createdMatch != null) {
          map['created_at'] = createdMatch.group(1);
        }
      }
      
      if (map.containsKey('user_id') && map.containsKey('username') && map.containsKey('email')) {
        return user_model.User.fromJson(map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
