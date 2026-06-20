import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/supabase_debug.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error, stackTrace) {
      logSupabaseError('auth service login', error, stackTrace);
      rethrow;
    }
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (error, stackTrace) {
      logSupabaseError('auth service signup', error, stackTrace);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
