import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email, password, and role - creates both auth user and profile
  Future<AuthResponse> signUpWithRole({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      // 1. Create auth user (no metadata needed now)
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // 2. Create profile in database
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName,
        'role': role.name,
      });

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get user role (convenience method)
  Future<UserRole?> getCurrentUserRole() async {
    final profile = await getCurrentUserProfile();
    return profile?.role;
  }
}
