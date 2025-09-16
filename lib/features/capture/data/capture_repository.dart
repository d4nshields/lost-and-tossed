import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/submission_models.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/storage_service.dart';

class CaptureRepository {
  final SupabaseClient _supabase;
  final LocationService _locationService;
  final SharedPreferences _prefs;
  static const _draftKey = 'capture_draft';
  static const _uuid = Uuid();

  CaptureRepository({
    required SupabaseClient supabase,
    required LocationService locationService,
    required StorageService storageService,
    required SharedPreferences prefs,
  })  : _supabase = supabase,
        _locationService = locationService,
        _prefs = prefs;

  /// Get all available tags from the database
  Future<List<Tag>> getTags() async {
    try {
      final response = await _supabase
          .from('tags')
          .select()
          .order('name', ascending: true);
      
      return (response as List)
          .map((json) => Tag.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load tags: $e');
    }
  }

  /// Create a new tag if it doesn't exist
  Future<Tag> createTag(String name) async {
    try {
      // Clean the tag name (lowercase, alphanumeric with dashes/underscores)
      final cleanName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '');
      
      // Try to insert, on conflict do nothing
      final response = await _supabase
          .from('tags')
          .upsert({'name': cleanName})
          .select()
          .single();
      
      return Tag.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create tag: $e');
    }
  }

  /// Submit a new capture
  Future<Submission> submitCapture({
    required File imageFile,
    required SubmissionCategory category,
    String? caption,
    List<String> tags = const [],
    LicenseType license = LicenseType.ccByNc,
    bool disposed = false,
    TraceDetailsDraft? traceDetails,
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get location
      final locationData = await _locationService.getCurrentLocationData();
      if (locationData == null) {
        throw Exception('Could not get location');
      }
      final geohash = locationData.geohash;

      // Upload image to storage
      final imageUrl = await _uploadImage(imageFile, user.id);

      // Create submission
      final submissionId = _uuid.v4();
      final submissionData = {
        'id': submissionId,
        'user_id': user.id,
        'category': category.value,
        'caption': caption,
        'tags': tags,
        'license': license.value,
        'disposed': disposed,
        'geohash5': geohash,
        'lat': locationData.latitude,
        'lon': locationData.longitude,
        'urls': {
          'original': imageUrl,
        },
        'found_at': DateTime.now().toIso8601String(),
      };

      final submissionResponse = await _supabase
          .from('submissions')
          .insert(submissionData)
          .select()
          .single();

      // If it's a trace category, insert trace details
      if (category == SubmissionCategory.traces && traceDetails != null) {
        await _supabase.from('traces').insert({
          'submission_id': submissionId,
          'surface': traceDetails.surface?.value,
          'freshness': traceDetails.freshness?.value,
          'permanence': traceDetails.permanence?.value,
          'direction_deg': traceDetails.directionDeg,
          'notes': traceDetails.notes,
        });
      }

      // Clear draft after successful submission
      await clearDraft();

      return Submission.fromJson(submissionResponse);
    } catch (e) {
      throw Exception('Failed to submit capture: $e');
    }
  }

  /// Upload image to Supabase storage
  Future<String> _uploadImage(File imageFile, String userId) async {
    try {
      final fileName = '${userId}/${_uuid.v4()}.jpg';
      final bytes = await imageFile.readAsBytes();
      
      await _supabase.storage
          .from('submissions')
          .uploadBinary(fileName, bytes);
      
      final url = _supabase.storage
          .from('submissions')
          .getPublicUrl(fileName);
      
      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Save draft to local storage
  Future<void> saveDraft(SubmissionDraft draft) async {
    try {
      final json = jsonEncode(draft.toJson());
      await _prefs.setString(_draftKey, json);
    } catch (e) {
      throw Exception('Failed to save draft: $e');
    }
  }

  /// Load draft from local storage
  Future<SubmissionDraft?> loadDraft() async {
    try {
      final json = _prefs.getString(_draftKey);
      if (json == null) return null;
      
      final map = jsonDecode(json) as Map<String, dynamic>;
      return SubmissionDraft.fromJson(map);
    } catch (e) {
      // If there's an error loading the draft, return null
      return null;
    }
  }

  /// Clear draft from local storage
  Future<void> clearDraft() async {
    await _prefs.remove(_draftKey);
  }
}
