import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/user_profile.dart';

/// Repository for authentication operations
class AuthRepository {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required SupabaseClient supabase,
    GoogleSignIn? googleSignIn,
  })  : _supabase = supabase,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              // Web Client ID from your google-services.json
              clientId: kIsWeb 
                ? '1038604734243-ka6qhvk7atns5e6oie26g05dfudhqjdo.apps.googleusercontent.com'
                : null, // On Android, it uses the Android OAuth client
            );

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Start Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // Sign in with Supabase using Google tokens
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // If sign-in successful, ensure user profile exists
      if (response.user != null) {
        await _ensureUserProfile(response.user!);
      }

      return response;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Ensure user profile exists
  Future<void> _ensureUserProfile(User user) async {
    try {
      // Check if profile exists
      final profile = await getUserProfile(user.id);
      
      if (profile == null) {
        // Profile doesn't exist, try to create it
        // Call the create_user_profile function
        await _supabase.rpc('create_user_profile', params: {
          'user_id': user.id,
          'user_email': user.email,
          'user_avatar': user.userMetadata?['avatar_url'],
        });
      }
    } catch (e) {
      // Don't throw - the profile might be created by the trigger
      // or can be created later
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Get submission count - using Supabase's count API correctly
      // We need to use a separate query for counting
      final countResponse = await _supabase
          .from('submissions')
          .select('id')
          .eq('user_id', userId);
      
      // Count the results manually since Supabase Flutter SDK 
      // doesn't have a direct count method like the JS SDK
      final submissionCount = (countResponse as List).length;

      final profileData = {
        ...response,
        'submission_count': submissionCount,
        'find_count': submissionCount, // Same as submission count for now
      };

      return UserProfile.fromJson(profileData);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? handle,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (handle != null) updates['handle'] = handle;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Check if handle is available
  Future<bool> isHandleAvailable(String handle) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('handle', handle)
          .maybeSingle();

      return response == null;
    } catch (e) {
      debugPrint('Error checking handle availability: $e');
      return false;
    }
  }

  /// Delete account (soft delete - just signs out for now)
  Future<void> deleteAccount() async {
    try {
      // For now, just sign out
      // In production, you might want to add a flag or actually delete data
      await signOut();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }
}
