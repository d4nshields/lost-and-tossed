import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../domain/models/user_profile.dart';
import '../../../core/di/providers.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthRepository(supabase: supabase);
});

/// Current auth user provider
final authUserProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.map((state) => state.session?.user);
});

/// Current user profile provider
final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.getUserProfile(userId);
});

/// Current user's own profile provider
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = await ref.watch(authUserProvider.future);
  if (user == null) return null;
  
  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.getUserProfile(user.id);
});

/// Auth state notifier for managing auth operations
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(const AsyncValue.data(null));

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final response = await _authRepository.signInWithGoogle();
      
      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Check if this is a new user (profile doesn't exist yet)
      final profile = await _authRepository.getUserProfile(response.user!.id);
      
      state = const AsyncValue.data(null);
      
      // The profile should be auto-created by the database trigger
      // but we check here just in case
      if (profile == null) {
        // This shouldn't happen with our trigger, but handle it gracefully
        throw Exception('User profile was not created');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? handle,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = _ref.read(authUserProvider).value;
    if (user == null) {
      state = AsyncValue.error(Exception('Not authenticated'), StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _authRepository.updateUserProfile(
        userId: user.id,
        handle: handle,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      
      // Invalidate the profile cache
      _ref.invalidate(currentUserProfileProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Check if handle is available
  Future<bool> isHandleAvailable(String handle) async {
    try {
      return await _authRepository.isHandleAvailable(handle);
    } catch (e) {
      return false;
    }
  }
}

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepo, ref);
});

/// Helper extension for auth state
extension AuthStateX on WidgetRef {
  /// Check if user is authenticated
  bool get isAuthenticated {
    final user = watch(authUserProvider).value;
    return user != null;
  }

  /// Get current user ID
  String? get currentUserId {
    final user = watch(authUserProvider).value;
    return user?.id;
  }

  /// Get current user
  User? get currentUser {
    return watch(authUserProvider).value;
  }
}
