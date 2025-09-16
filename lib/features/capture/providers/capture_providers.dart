import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../data/capture_repository.dart';
import '../domain/models/submission_models.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/storage_service.dart';
import '../../../services/enhanced_privacy_ml_service.dart';

/// Provider for logger
final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

/// Provider for SharedPreferences
/// This will be overridden during app initialization
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden during app initialization');
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

/// Provider for enhanced privacy ML service
final enhancedPrivacyMLServiceProvider = Provider<EnhancedPrivacyMLService>((ref) {
  final logger = ref.watch(loggerProvider);
  return EnhancedPrivacyMLService(logger: logger);
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

/// State notifier for capture screen with ML processing
class CaptureNotifier extends StateNotifier<CaptureState> {
  final CaptureRepository _repository;
  final EnhancedPrivacyMLService _mlService;
  final Ref _ref;

  CaptureNotifier(this._repository, this._mlService, this._ref) 
      : super(const CaptureState()) {
    _loadDraft();
    _initializeML();
  }

  /// Initialize ML service
  Future<void> _initializeML() async {
    try {
      await _mlService.initialize();
    } catch (e) {
      _ref.read(loggerProvider).e('Failed to initialize ML service: $e');
    }
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

  /// Set the captured image and process it for privacy
  Future<void> setImage(File? image) async {
    if (image == null) {
      state = state.copyWith(
        imagePath: null,
        clearImage: true,
        processedImagePath: null,
        clearProcessedImage: true,
        extractedListText: null,
        clearExtractedText: true,
      );
      _saveDraft();
      return;
    }

    state = state.copyWith(
      imagePath: image.path,
      isProcessingImage: true,
      processingStatus: 'Analyzing image...',
    );

    try {
      // Process the image for privacy
      final result = await _mlService.processImage(
        imagePath: image.path,
        category: state.category ?? SubmissionCategory.curious,
        subtype: state.subtype,
      );

      // Save the processed image
      final processedPath = image.path.replaceAll('.jpg', '_processed.jpg');
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(result.blurredImageBytes);

      state = state.copyWith(
        processedImagePath: processedPath,
        privacyAreas: result.privacyAreas,
        extractedListText: result.extractedListText,
        processingMode: result.processingMode,
        isProcessingImage: false,
        processingStatus: null,
      );

      _saveDraft();
    } catch (e) {
      _ref.read(loggerProvider).e('Failed to process image: $e');
      state = state.copyWith(
        isProcessingImage: false,
        processingStatus: null,
        error: 'Failed to process image for privacy',
      );
    }
  }

  /// Reprocess image with different settings
  Future<void> reprocessImage() async {
    if (state.imagePath == null) return;
    
    final imageFile = File(state.imagePath!);
    await setImage(imageFile);
  }

  /// Set the category
  void setCategory(SubmissionCategory category) {
    state = state.copyWith(category: category);
    
    // If switching to Lost category and we have an image, reprocess for OCR
    if (category == SubmissionCategory.lost && state.imagePath != null) {
      reprocessImage();
    }
    
    _saveDraft();
  }

  /// Set the subtype (e.g., 'list' for Lost category)
  void setSubtype(String? subtype) {
    state = state.copyWith(subtype: subtype);
    
    // Reprocess if it's a list to extract text
    if (subtype == 'list' && state.imagePath != null) {
      reprocessImage();
    }
    
    _saveDraft();
  }

  /// Update extracted list text (after user edits)
  void updateExtractedListText(String text) {
    state = state.copyWith(extractedListText: text);
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
      imagePath: state.processedImagePath ?? state.imagePath,
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
      // Use processed image if available, otherwise original
      final imagePath = state.processedImagePath ?? state.imagePath!;
      final imageFile = File(imagePath);
      
      // Include extracted text in caption if it's a lost list
      String? finalCaption = state.caption;
      if (state.category == SubmissionCategory.lost && 
          state.subtype == 'list' && 
          state.extractedListText != null) {
        finalCaption = '${state.caption ?? ''}\n\n--- Extracted List ---\n${state.extractedListText}';
      }
      
      await _repository.submitCapture(
        imageFile: imageFile,
        category: state.category!,
        caption: finalCaption,
        tags: state.selectedTags,
        license: state.license,
        disposed: state.disposed,
        traceDetails: state.traceDetails,
      );

      // Clear state after successful submission
      state = const CaptureState();
      await _repository.clearDraft();
      
      // Clean up processed image file
      if (state.processedImagePath != null) {
        try {
          await File(state.processedImagePath!).delete();
        } catch (_) {}
      }
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
    // Clean up processed image file
    if (state.processedImagePath != null) {
      try {
        File(state.processedImagePath!).delete();
      } catch (_) {}
    }
    
    state = const CaptureState();
    _repository.clearDraft();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}

/// Enhanced state for capture screen with ML processing
class CaptureState {
  final String? imagePath;
  final String? processedImagePath;
  final SubmissionCategory? category;
  final String? subtype;
  final String? caption;
  final List<String> selectedTags;
  final LicenseType license;
  final bool disposed;
  final TraceDetailsDraft? traceDetails;
  final bool isSubmitting;
  final String? error;
  
  // ML processing fields
  final bool isProcessingImage;
  final String? processingStatus;
  final List<PrivacyBlurArea>? privacyAreas;
  final String? extractedListText;
  final ProcessingMode? processingMode;

  const CaptureState({
    this.imagePath,
    this.processedImagePath,
    this.category,
    this.subtype,
    this.caption,
    this.selectedTags = const [],
    this.license = LicenseType.ccByNc,
    this.disposed = false,
    this.traceDetails,
    this.isSubmitting = false,
    this.error,
    this.isProcessingImage = false,
    this.processingStatus,
    this.privacyAreas,
    this.extractedListText,
    this.processingMode,
  });

  CaptureState copyWith({
    String? imagePath,
    bool clearImage = false,
    String? processedImagePath,
    bool clearProcessedImage = false,
    SubmissionCategory? category,
    String? subtype,
    String? caption,
    List<String>? selectedTags,
    LicenseType? license,
    bool? disposed,
    TraceDetailsDraft? traceDetails,
    bool? isSubmitting,
    String? error,
    bool? isProcessingImage,
    String? processingStatus,
    List<PrivacyBlurArea>? privacyAreas,
    String? extractedListText,
    bool clearExtractedText = false,
    ProcessingMode? processingMode,
  }) {
    return CaptureState(
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      processedImagePath: clearProcessedImage ? null : (processedImagePath ?? this.processedImagePath),
      category: category ?? this.category,
      subtype: subtype ?? this.subtype,
      caption: caption ?? this.caption,
      selectedTags: selectedTags ?? this.selectedTags,
      license: license ?? this.license,
      disposed: disposed ?? this.disposed,
      traceDetails: traceDetails ?? this.traceDetails,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isProcessingImage: isProcessingImage ?? this.isProcessingImage,
      processingStatus: processingStatus,
      privacyAreas: privacyAreas ?? this.privacyAreas,
      extractedListText: clearExtractedText ? null : (extractedListText ?? this.extractedListText),
      processingMode: processingMode ?? this.processingMode,
    );
  }
}

/// Provider for capture notifier
final captureNotifierProvider = StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  final repository = ref.watch(captureRepositoryProvider);
  final mlService = ref.watch(enhancedPrivacyMLServiceProvider);
  return CaptureNotifier(repository, mlService, ref);
});
