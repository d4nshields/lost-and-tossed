import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/submission_models.dart';

/// Service for managing submissions in Supabase
class SubmissionService {
  final SupabaseClient _supabase;
  final Logger _logger;
  final Uuid _uuid;

  SubmissionService({
    required SupabaseClient supabase,
    required Logger logger,
  })  : _supabase = supabase,
        _logger = logger,
        _uuid = const Uuid();

  /// Create a new submission
  Future<Submission?> createSubmission(CreateSubmissionRequest request) async {
    try {
      _logger.i('Creating submission: ${request.category.value}');

      // Get current user
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _logger.e('No authenticated user');
        return null;
      }

      // Create submission
      final submissionData = request.toJson();
      submissionData['user_id'] = userId;
      submissionData['id'] = _uuid.v4();

      final response = await _supabase
          .from('submissions')
          .insert(submissionData)
          .select()
          .single();

      final submission = Submission.fromJson(response);

      // If it's a trace, create the trace record
      if (request.category == SubmissionCategory.traces) {
        final traceData = request.toTraceJson(submission.id);
        if (traceData != null) {
          await _createTrace(traceData);
        }
      }

      _logger.i('Submission created: ${submission.id}');
      return submission;
    } catch (e, stackTrace) {
      _logger.e('Failed to create submission', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Create trace metadata for a submission
  Future<Trace?> _createTrace(Map<String, dynamic> traceData) async {
    try {
      _logger.d('Creating trace metadata');

      final response = await _supabase
          .from('traces')
          .insert(traceData)
          .select()
          .single();

      final trace = Trace.fromJson(response);
      _logger.d('Trace created: ${trace.id}');
      return trace;
    } catch (e, stackTrace) {
      _logger.e('Failed to create trace', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Update submission URLs after image upload
  Future<Submission?> updateSubmissionUrls(
    String submissionId,
    SubmissionUrls urls,
  ) async {
    try {
      _logger.i('Updating submission URLs: $submissionId');

      final response = await _supabase
          .from('submissions')
          .update({'urls': urls.toJson()})
          .eq('id', submissionId)
          .select()
          .single();

      final submission = Submission.fromJson(response);
      _logger.i('Submission URLs updated');
      return submission;
    } catch (e, stackTrace) {
      _logger.e('Failed to update submission URLs', 
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Update safety flags after server-side check
  Future<Submission?> updateSafetyFlags(
    String submissionId,
    Map<String, dynamic> safetyFlags,
  ) async {
    try {
      _logger.i('Updating safety flags: $submissionId');

      final response = await _supabase
          .from('submissions')
          .update({'safety_flags': safetyFlags})
          .eq('id', submissionId)
          .select()
          .single();

      final submission = Submission.fromJson(response);
      _logger.i('Safety flags updated');
      return submission;
    } catch (e, stackTrace) {
      _logger.e('Failed to update safety flags', 
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get submissions with filters
  Future<List<Submission>> getSubmissions({
    int limit = 20,
    int offset = 0,
    SubmissionCategory? category,
    String? geohashPrefix,
    String? userId,
    bool? disposed,
  }) async {
    try {
      var query = _supabase.from('submissions').select();

      if (category != null) {
        query = query.eq('category', category.value);
      }

      if (geohashPrefix != null && geohashPrefix.isNotEmpty) {
        query = query.ilike('geohash5', '$geohashPrefix%');
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (disposed != null) {
        query = query.eq('disposed', disposed);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<Submission>((json) => Submission.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get submissions', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get a single submission by ID
  Future<Submission?> getSubmission(String submissionId) async {
    try {
      final response = await _supabase
          .from('submissions')
          .select()
          .eq('id', submissionId)
          .maybeSingle();

      if (response == null) return null;
      return Submission.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to get submission', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get trace metadata for a submission
  Future<Trace?> getTrace(String submissionId) async {
    try {
      final response = await _supabase
          .from('traces')
          .select()
          .eq('submission_id', submissionId)
          .maybeSingle();

      if (response == null) return null;
      return Trace.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Failed to get trace', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Mark submission as disposed
  Future<bool> markAsDisposed(String submissionId) async {
    try {
      _logger.i('Marking submission as disposed: $submissionId');

      await _supabase
          .from('submissions')
          .update({'disposed': true})
          .eq('id', submissionId);

      _logger.i('Submission marked as disposed');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Failed to mark as disposed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete a submission (if user owns it)
  Future<bool> deleteSubmission(String submissionId) async {
    try {
      _logger.i('Deleting submission: $submissionId');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _logger.e('No authenticated user');
        return false;
      }

      // Delete will cascade to traces table due to foreign key
      await _supabase
          .from('submissions')
          .delete()
          .eq('id', submissionId)
          .eq('user_id', userId);

      _logger.i('Submission deleted');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete submission', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Search submissions by tags
  Future<List<Submission>> searchByTags(List<String> tags) async {
    try {
      final response = await _supabase
          .from('submissions')
          .select()
          .contains('tags', tags)
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map<Submission>((json) => Submission.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to search by tags', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get submissions near a location
  Future<List<Submission>> getNearbySubmissions({
    required String geohash,
    int precision = 5,
    int limit = 50,
  }) async {
    try {
      final prefix = geohash.substring(0, precision.clamp(1, geohash.length));

      final response = await _supabase
          .from('submissions')
          .select()
          .ilike('geohash5', '$prefix%')
          .eq('disposed', false)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<Submission>((json) => Submission.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get nearby submissions', 
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get user's submission statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get total count by category
      final countResponse = await _supabase
          .from('submissions')
          .select('category')
          .eq('user_id', userId);

      final categoryCounts = <String, int>{};
      for (final row in countResponse) {
        final category = row['category'] as String;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      // Get recent submissions
      final recentResponse = await _supabase
          .from('submissions')
          .select('id, category, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      return {
        'total': countResponse.length,
        'by_category': categoryCounts,
        'recent': recentResponse,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to get user stats', error: e, stackTrace: stackTrace);
      return {
        'total': 0,
        'by_category': {},
        'recent': [],
      };
    }
  }
}
