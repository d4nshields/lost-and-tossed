import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_geohash/dart_geohash.dart';

import '../models/submission_models.dart';
import 'submission_service.dart';
import 'storage_service.dart';
import 'image_service.dart';
import 'offline_queue_service.dart';
import 'location_service.dart';

/// Manages the complete upload flow for submissions
class UploadManager {
  final Logger _logger;
  final SubmissionService _submissionService;
  final StorageService _storageService;
  final ImageService _imageService;
  final OfflineQueueService _offlineQueueService;
  final LocationService _locationService;
  final Connectivity _connectivity;

  UploadManager({
    required Logger logger,
    required SubmissionService submissionService,
    required StorageService storageService,
    required ImageService imageService,
    required OfflineQueueService offlineQueueService,
    required LocationService locationService,
  })  : _logger = logger,
        _submissionService = submissionService,
        _storageService = storageService,
        _imageService = imageService,
        _offlineQueueService = offlineQueueService,
        _locationService = locationService,
        _connectivity = Connectivity();

  /// Complete upload flow for a new submission
  Future<UploadResult> uploadSubmission({
    required SubmissionCategory category,
    required XFile imageFile,
    String? caption,
    List<String>? tags,
    LicenseType license = LicenseType.ccByNc,
    DateTime? foundAt,
    // Trace-specific parameters
    TraceSurface? traceSurface,
    TraceFreshness? traceFreshness,
    double? traceDirectionDeg,
    TracePermanence? tracePermanence,
    String? traceNotes,
  }) async {
    try {
      _logger.i('Starting submission upload process');

      // Step 1: Get location
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        _logger.e('Failed to get location');
        return UploadResult.error('Could not determine location');
      }

      // Calculate geohash
      final geoHasher = GeoHasher();
      final geohash = geoHasher.encode(
        location.longitude,
        location.latitude,
        precision: 5,
      );

      // Step 2: Process image for privacy
      _logger.d('Processing image for privacy');
      final processedImage = await _imageService.processImageForPrivacy(imageFile);
      if (processedImage == null) {
        _logger.e('Failed to process image');
        return UploadResult.error('Failed to process image');
      }

      // Step 3: Create submission request
      final request = CreateSubmissionRequest(
        category: category,
        caption: caption,
        tags: tags,
        geohash5: geohash,
        lat: location.latitude,
        lon: location.longitude,
        license: license,
        foundAt: foundAt ?? DateTime.now(),
        safetyFlags: {
          'has_faces': processedImage.faceCount > 0,
          'has_text': processedImage.sensitiveTextCount > 0,
          'blurred_count': processedImage.totalSensitiveItems,
          'processed_client': true,
        },
        // Trace fields
        traceSurface: traceSurface,
        traceFreshness: traceFreshness,
        traceDirectionDeg: traceDirectionDeg,
        tracePermanence: tracePermanence,
        traceNotes: traceNotes,
      );

      // Step 4: Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _logger.i('No connectivity, adding to offline queue');
        
        // Save image to temporary location
        final tempPath = await _saveImageTemporarily(imageFile);
        
        // Add to offline queue
        final queueId = await _offlineQueueService.addToQueue(
          request: request,
          imagePath: tempPath,
        );
        
        return UploadResult.queued(queueId);
      }

      // Step 5: Upload immediately
      _logger.i('Uploading submission immediately');
      
      // Create submission in database
      final submission = await _submissionService.createSubmission(request);
      if (submission == null) {
        _logger.e('Failed to create submission');
        
        // Fallback to offline queue
        final tempPath = await _saveImageTemporarily(imageFile);
        final queueId = await _offlineQueueService.addToQueue(
          request: request,
          imagePath: tempPath,
        );
        
        return UploadResult.queued(queueId);
      }

      // Upload images to storage
      final imageUrls = await _storageService.uploadSubmissionImages(
        processedImage: processedImage,
        userId: submission.userId,
        submissionId: submission.id,
      );

      if (imageUrls == null) {
        _logger.e('Failed to upload images');
        
        // Delete the submission since image upload failed
        await _submissionService.deleteSubmission(submission.id);
        
        // Fallback to offline queue
        final tempPath = await _saveImageTemporarily(imageFile);
        final queueId = await _offlineQueueService.addToQueue(
          request: request,
          imagePath: tempPath,
        );
        
        return UploadResult.queued(queueId);
      }

      // Update submission with image URLs
      final updatedSubmission = await _submissionService.updateSubmissionUrls(
        submission.id,
        imageUrls,
      );

      if (updatedSubmission == null) {
        _logger.w('Failed to update submission URLs, but upload succeeded');
      }

      _logger.i('Submission uploaded successfully: ${submission.id}');
      return UploadResult.success(submission);
    } catch (e, stackTrace) {
      _logger.e('Failed to upload submission', error: e, stackTrace: stackTrace);
      
      // Try to add to offline queue as last resort
      try {
        final tempPath = await _saveImageTemporarily(imageFile);
        final request = CreateSubmissionRequest(
          category: category,
          caption: caption,
          tags: tags,
          geohash5: 'temp1', // Temporary geohash
          license: license,
          foundAt: foundAt ?? DateTime.now(),
        );
        
        final queueId = await _offlineQueueService.addToQueue(
          request: request,
          imagePath: tempPath,
        );
        
        return UploadResult.queued(queueId);
      } catch (queueError) {
        _logger.e('Failed to add to offline queue', error: queueError);
        return UploadResult.error(e.toString());
      }
    }
  }

  /// Save image to temporary location for offline queue
  Future<String> _saveImageTemporarily(XFile imageFile) async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/lost_tossed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final bytes = await imageFile.readAsBytes();
      await tempFile.writeAsBytes(bytes);
      
      _logger.d('Image saved temporarily: ${tempFile.path}');
      return tempFile.path;
    } catch (e, stackTrace) {
      _logger.e('Failed to save image temporarily', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Process pending uploads from offline queue
  Future<int> processPendingUploads() async {
    try {
      _logger.i('Processing pending uploads');
      
      // Check connectivity first
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _logger.d('No connectivity, skipping pending uploads');
        return 0;
      }
      
      // Process all queued items
      final processedCount = await _offlineQueueService.processAllQueueItems();
      
      _logger.i('Processed $processedCount pending uploads');
      return processedCount;
    } catch (e, stackTrace) {
      _logger.e('Failed to process pending uploads', error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  /// Get status of offline queue
  Future<QueueStats> getQueueStatus() async {
    return await _offlineQueueService.getQueueStats();
  }

  /// Clear offline queue
  Future<void> clearQueue() async {
    await _offlineQueueService.clearQueue();
  }

  /// Retry a specific queued item
  Future<bool> retryQueuedItem(String queueItemId) async {
    try {
      _logger.i('Retrying queued item: $queueItemId');
      
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _logger.d('No connectivity, cannot retry');
        return false;
      }
      
      // Process the specific item
      final success = await _offlineQueueService.processQueueItem(queueItemId);
      
      _logger.i('Retry result: $success');
      return success;
    } catch (e, stackTrace) {
      _logger.e('Failed to retry queued item', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

/// Result of an upload attempt
class UploadResult {
  final UploadStatus status;
  final Submission? submission;
  final String? queueId;
  final String? errorMessage;

  const UploadResult._({
    required this.status,
    this.submission,
    this.queueId,
    this.errorMessage,
  });

  factory UploadResult.success(Submission submission) {
    return UploadResult._(
      status: UploadStatus.success,
      submission: submission,
    );
  }

  factory UploadResult.queued(String queueId) {
    return UploadResult._(
      status: UploadStatus.queued,
      queueId: queueId,
    );
  }

  factory UploadResult.error(String message) {
    return UploadResult._(
      status: UploadStatus.error,
      errorMessage: message,
    );
  }

  bool get isSuccess => status == UploadStatus.success;
  bool get isQueued => status == UploadStatus.queued;
  bool get isError => status == UploadStatus.error;

  String get displayMessage {
    switch (status) {
      case UploadStatus.success:
        return 'Successfully uploaded!';
      case UploadStatus.queued:
        return 'Added to queue. Will upload when connected.';
      case UploadStatus.error:
        return errorMessage ?? 'Upload failed';
    }
  }

  Color get statusColor {
    switch (status) {
      case UploadStatus.success:
        return Colors.green;
      case UploadStatus.queued:
        return Colors.orange;
      case UploadStatus.error:
        return Colors.red;
    }
  }
}

enum UploadStatus {
  success,
  queued,
  error,
}
