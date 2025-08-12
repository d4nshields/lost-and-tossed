import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

/// Minimal Supabase service for basic operations
/// This will be expanded once we get the build working
class SupabaseService {
  final SupabaseClient _supabase;
  final Logger _logger;

  SupabaseService({
    required SupabaseClient supabase,
    required Logger logger,
  })  : _supabase = supabase,
        _logger = logger;

  /// Get a user profile by ID (returns raw JSON for now)
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      return response;
    } catch (e, stackTrace) {
      _logger.e('Failed to get profile', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get submissions with basic filtering (returns raw JSON for now)
  Future<List<Map<String, dynamic>>> getSubmissions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('submissions')
          .select('''
            *,
            user:users!user_id(id, handle)
          ''')
          .not('safety_flags->hidden', 'is', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to get submissions', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a new submission (accepts raw JSON for now)
  Future<Map<String, dynamic>> createSubmission(
    Map<String, dynamic> submissionData,
    String userId,
  ) async {
    try {
      submissionData['user_id'] = userId;

      final response =
          await _supabase.from('submissions').insert(submissionData).select('''
            *,
            user:users!user_id(id, handle)
          ''').single();

      return response;
    } catch (e, stackTrace) {
      _logger.e('Failed to create submission',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a submission
  Future<void> deleteSubmission(String submissionId) async {
    try {
      await _supabase.from('submissions').delete().eq('id', submissionId);
    } catch (e, stackTrace) {
      _logger.e('Failed to delete submission',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get submissions near a location (basic geohash matching)
  Future<List<Map<String, dynamic>>> getSubmissionsNearLocation(
    String geohash, {
    int precision = 5,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final geohashPrefix = geohash.substring(0, precision);

      final response = await _supabase
          .from('submissions')
          .select('''
            *,
            user:users!user_id(id, handle)
          ''')
          .not('safety_flags->hidden', 'is', true)
          .like('geohash5', '$geohashPrefix%')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to get submissions near location',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
