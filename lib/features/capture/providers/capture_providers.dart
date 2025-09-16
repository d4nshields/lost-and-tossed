import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../data/capture_repository.dart';
import '../domain/models/submission_models.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/storage_service.dart';

/// Provider for logger
final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for location service
final locationServiceProvider = Provider<LocationService>((ref) {
  final logger = ref.watch(loggerProvider);
  return LocationService(logger: logger);
});

/// Provider for storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = Supabase.instance.client;
  final logger = ref.watch(loggerProvider);
  return StorageService(supabase: supabase, logger: logger);
});

/// Provider for capture repository
final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  final supabase = Supabase.instance.client;
  final locationService = ref.watch(locationServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  
  return CaptureRepository(
    supabase: supabase,
    locationService: locationService,
    storageService: storageService,
    prefs: prefs,
  );
});

/// Provider for available tags
final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final repository = ref.watch(captureRepositoryProvider);
  return repository.getTags();
});

/// State notifier for capture screen
class CaptureNotifier extends StateNotifier<CaptureState> {
  final CaptureRepository _repository;

  CaptureNotifier(this._repository) : super(const CaptureState()) {
    _loadDraft();
  }

  /// Load draft on initialization
  Future<void> _loadDraft() async {
    final draft = await _repository.loadDraft();
    if (draft != null) {
      state = CaptureState(
        imagePath: draft.imagePath,
        category: draft.category,
        caption: draft.caption,
        selectedTags: draft.selectedTags,
        license: draft.license,
        disposed: draft.disposed,
        traceDetails: draft.traceDetails,
      );
    }
  }

  /// Set the captured image
  void setImage(File? image) {
    state = state.copyWith(
      imagePath: image?.path,
      clearImage: image == null,
    );
    _saveDraft();
  }

  /// Set the category
  void setCategory(SubmissionCategory category) {
    state = state.copyWith(category: category);
    _saveDraft();
  }

  /// Set the caption
  void setCaption(String caption) {
    state = state.copyWith(caption: caption);
    _saveDraft();
  }

  /// Toggle a tag
  void toggleTag(String tag) {
    final tags = List<String>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(selectedTags: tags);
    _saveDraft();
  }

  /// Set the license
  void setLicense(LicenseType license) {
    state = state.copyWith(license: license);
    _saveDraft();
  }

  /// Set disposed status
  void setDisposed(bool disposed) {
    state = state.copyWith(disposed: disposed);
    _saveDraft();
  }

  /// Update trace details
  void updateTraceDetails(TraceDetailsDraft details) {
    state = state.copyWith(traceDetails: details);
    _saveDraft();
  }

  /// Save current state as draft
  Future<void> _saveDraft() async {
    final draft = SubmissionDraft(
      imagePath: state.imagePath,
      category: state.category,
      caption: state.caption,
      selectedTags: state.selectedTags,
      license: state.license,
      disposed: state.disposed,
      traceDetails: state.traceDetails,
      lastModified: DateTime.now(),
    );
    await _repository.saveDraft(draft);
  }

  /// Submit the capture
  Future<void> submit() async {
    if (state.imagePath == null || state.category == null) {
      throw Exception('Image and category are required');
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final imageFile = File(state.imagePath!);
      
      await _repository.submitCapture(
        imageFile: imageFile,
        category: state.category!,
        caption: state.caption,
        tags: state.selectedTags,
        license: state.license,
        disposed: state.disposed,
        traceDetails: state.traceDetails,
      );

      // Clear state after successful submission
      state = const CaptureState();
      await _repository.clearDraft();
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear all data
  void clear() {
    state = const CaptureState();
    _repository.clearDraft();
  }
}

/// State for capture screen
class CaptureState {
  final String? imagePath;
  final SubmissionCategory? category;
  final String? caption;
  final List<String> selectedTags;
  final LicenseType license;
  final bool disposed;
  final TraceDetailsDraft? traceDetails;
  final bool isSubmitting;
  final String? error;

  const CaptureState({
    this.imagePath,
    this.category,
    this.caption,
    this.selectedTags = const [],
    this.license = LicenseType.ccByNc,
    this.disposed = false,
    this.traceDetails,
    this.isSubmitting = false,
    this.error,
  });

  CaptureState copyWith({
    String? imagePath,
    bool clearImage = false,
    SubmissionCategory? category,
    String? caption,
    List<String>? selectedTags,
    LicenseType? license,
    bool? disposed,
    TraceDetailsDraft? traceDetails,
    bool? isSubmitting,
    String? error,
  }) {
    return CaptureState(
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      category: category ?? this.category,
      caption: caption ?? this.caption,
      selectedTags: selectedTags ?? this.selectedTags,
      license: license ?? this.license,
      disposed: disposed ?? this.disposed,
      traceDetails: traceDetails ?? this.traceDetails,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

/// Provider for capture notifier
final captureNotifierProvider = StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  final repository = ref.watch(captureRepositoryProvider);
  return CaptureNotifier(repository);
});
