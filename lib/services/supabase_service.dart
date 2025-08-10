import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class SupabaseService {
  const SupabaseService(this._client);

  final SupabaseClient _client;

  SupabaseClient get client => _client;

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseService(client);
});
