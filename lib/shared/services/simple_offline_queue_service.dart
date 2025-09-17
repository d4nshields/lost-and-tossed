import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../models/submission_models.dart';
import 'submission_service.dart';
import 'storage_service.dart';
import 'image_service.dart';

/// Simple offline queue service without background processing
/// Processes queue when app is in foreground
class SimpleOfflineQueueService {
  static const String _queueKey = 'offline_submission_queue';
  static const int _maxRetries = 3;

  final Logger _logger;
  final SharedPreferences _prefs;
  final Connectivity _connectivity;
  final Uuid _uuid;
  final SubmissionService _submissionService;
  final StorageService _storageService;
  final ImageService _imageService;

  SimpleOfflineQueueService({
    required Logger logger,
    required SharedPreferences prefs,
    required SubmissionService submissionService,
    required StorageService storageService,
    required ImageService imageService,
  })  : _logger = logger,
        _prefs = prefs,
        _connectivity = Connectivity(),
        _uuid = const Uuid(),
        _submissionService = submissionService,
        _storageService = storageService,
        _imageService = imageService;

  /// Add submission to offline queue
  Future<String> addToQueue({
    required CreateSubmissionRequest request,
    String? imagePath,
  }) async {
    try {
      _logger.i('Adding submission to offline queue');

      final queueItem = OfflineQueueItem(
        id: _uuid.v4(),
        request: request,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );

      // Get existing queue
      final queue = await _getQueue();
      queue.add(queueItem);

      // Save updated queue
      await _saveQueue(queue);

      _logger.i('Submission added to queue: ${queueItem.id}');
      return queueItem.id;
    } catch (e, stackTrace) {
      _logger.e('Failed to add to queue', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Process single queue item
  Future<bool> processQueueItem(String queueItemId) async {
    try {
      _logger.i('Processing queue item: $queueItemId');

      // Get queue item
      final queue = await _getQueue();
      final queueItem = queue.firstWhere(
        (item) => item.id == queueItemId,
        orElse: () => throw Exception('Queue item not found'),
      );

      // Check retry count
      if (queueItem.retryCount >= _maxRetries) {
        _logger.w('Max retries exceeded for: $queueItemId');
        await _markAsFailed(queueItem);
        return false;
      }

      // Process image if present
      SubmissionUrls? imageUrls;
      if (queueItem.imagePath != null) {
        final imageFile = XFile(queueItem.imagePath!);
        
        // Check if file still exists
        if (!await File(imageFile.path).exists()) {
          _logger.e('Image file not found: ${imageFile.path}');
          await _updateQueueItem(queueItem.copyWith(
            retryCount: queueItem.retryCount + 1,
            lastError: 'Image file not found',
          ));
          return false;
        }

        // Process image for privacy
        final processedImage = await _imageService.processImageForPrivacy(imageFile);
        if (processedImage == null) {
          _logger.e('Failed to process image');
          await _updateQueueItem(queueItem.copyWith(
            retryCount: queueItem.retryCount + 1,
            lastError: 'Failed to process image',
          ));
          return false;
        }

        // Create submission first to get ID
        final submission = await _submissionService.createSubmission(queueItem.request);
        if (submission == null) {
          _logger.e('Failed to create submission');
          await _updateQueueItem(queueItem.copyWith(
            retryCount: queueItem.retryCount + 1,
            lastError: 'Failed to create submission',
          ));
          return false;
        }

        // Upload images
        imageUrls = await _storageService.uploadSubmissionImages(
          processedImage: processedImage,
          userId: submission.userId,
          submissionId: submission.id,
        );

        if (imageUrls == null) {
          _logger.e('Failed to upload images');
          // Delete the submission since image upload failed
          await _submissionService.deleteSubmission(submission.id);
          await _updateQueueItem(queueItem.copyWith(
            retryCount: queueItem.retryCount + 1,
            lastError: 'Failed to upload images',
          ));
          return false;
        }

        // Update submission with image URLs
        await _submissionService.updateSubmissionUrls(
          submission.id,
          imageUrls,
        );

        // Update safety flags if needed
        if (processedImage.hasBlurredContent) {
          await _submissionService.updateSafetyFlags(
            submission.id,
            {
              'faces_blurred': processedImage.faceCount,
              'text_blurred': processedImage.sensitiveTextCount,
              'processed_at': DateTime.now().toIso8601String(),
            },
          );
        }
      } else {
        // No image, just create submission
        final submission = await _submissionService.createSubmission(queueItem.request);
        if (submission == null) {
          _logger.e('Failed to create submission');
          await _updateQueueItem(queueItem.copyWith(
            retryCount: queueItem.retryCount + 1,
            lastError: 'Failed to create submission',
          ));
          return false;
        }
      }

      // Remove from queue on success
      await _removeFromQueue(queueItemId);
      _logger.i('Successfully processed queue item: $queueItemId');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Failed to process queue item: $queueItemId',
          error: e, stackTrace: stackTrace);
      
      // Update retry count and error
      final queue = await _getQueue();
      final itemIndex = queue.indexWhere((item) => item.id == queueItemId);
      if (itemIndex != -1) {
        queue[itemIndex] = queue[itemIndex].copyWith(
          retryCount: queue[itemIndex].retryCount + 1,
          lastError: e.toString(),
        );
        await _saveQueue(queue);
      }
      
      return false;
    }
  }

  /// Process all items in queue
  Future<int> processAllQueueItems() async {
    try {
      _logger.i('Processing all queue items');

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _logger.d('No connectivity, skipping queue processing');
        return 0;
      }

      final queue = await _getQueue();
      if (queue.isEmpty) {
        _logger.d('Queue is empty');
        return 0;
      }

      int processedCount = 0;
      for (final item in queue.toList()) { // Convert to list to avoid modification during iteration
        // Skip items that have exceeded max retries
        if (item.retryCount >= _maxRetries) {
          continue;
        }

        // Process item
        final success = await processQueueItem(item.id);
        if (success) {
          processedCount++;
        }

        // Add delay between uploads to avoid rate limiting
        await Future.delayed(const Duration(seconds: 2));
      }

      _logger.i('Processed $processedCount queue items');
      return processedCount;
    } catch (e, stackTrace) {
      _logger.e('Failed to process queue', error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  /// Get all items in queue
  Future<List<OfflineQueueItem>> getQueue() async {
    return _getQueue();
  }

  /// Get queue from storage
  Future<List<OfflineQueueItem>> _getQueue() async {
    try {
      final queueJson = _prefs.getString(_queueKey);
      if (queueJson == null) return [];

      final queueList = jsonDecode(queueJson) as List<dynamic>;
      return queueList
          .map((json) => OfflineQueueItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get queue', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue(List<OfflineQueueItem> queue) async {
    try {
      final queueJson = jsonEncode(queue.map((item) => item.toJson()).toList());
      await _prefs.setString(_queueKey, queueJson);
    } catch (e, stackTrace) {
      _logger.e('Failed to save queue', error: e, stackTrace: stackTrace);
    }
  }

  /// Remove item from queue
  Future<void> _removeFromQueue(String queueItemId) async {
    try {
      final queue = await _getQueue();
      queue.removeWhere((item) => item.id == queueItemId);
      await _saveQueue(queue);
      _logger.d('Removed from queue: $queueItemId');
    } catch (e, stackTrace) {
      _logger.e('Failed to remove from queue', error: e, stackTrace: stackTrace);
    }
  }

  /// Update queue item
  Future<void> _updateQueueItem(OfflineQueueItem updatedItem) async {
    try {
      final queue = await _getQueue();
      final index = queue.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        queue[index] = updatedItem;
        await _saveQueue(queue);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to update queue item', error: e, stackTrace: stackTrace);
    }
  }

  /// Mark item as failed (exceeded retries)
  Future<void> _markAsFailed(OfflineQueueItem item) async {
    try {
      _logger.w('Marking as failed: ${item.id}');
      
      // Remove from queue
      await _removeFromQueue(item.id);
      
      // Clean up image file if exists
      if (item.imagePath != null) {
        final file = File(item.imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to mark as failed', error: e, stackTrace: stackTrace);
    }
  }

  /// Clear entire queue
  Future<void> clearQueue() async {
    try {
      // Clean up any associated image files
      final queue = await _getQueue();
      for (final item in queue) {
        if (item.imagePath != null) {
          final file = File(item.imagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // Clear queue
      await _prefs.remove(_queueKey);
      _logger.i('Queue cleared');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear queue', error: e, stackTrace: stackTrace);
    }
  }

  /// Get queue statistics
  Future<QueueStats> getQueueStats() async {
    try {
      final queue = await _getQueue();
      
      final pending = queue.where((item) => item.retryCount < _maxRetries).length;
      final failed = queue.where((item) => item.retryCount >= _maxRetries).length;
      
      return QueueStats(
        totalItems: queue.length,
        pendingItems: pending,
        failedItems: failed,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to get queue stats', error: e, stackTrace: stackTrace);
      return QueueStats(totalItems: 0, pendingItems: 0, failedItems: 0);
    }
  }
}

/// Queue statistics
class QueueStats {
  final int totalItems;
  final int pendingItems;
  final int failedItems;

  const QueueStats({
    required this.totalItems,
    required this.pendingItems,
    required this.failedItems,
  });
}
