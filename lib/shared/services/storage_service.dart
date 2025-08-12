import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import 'image_service.dart';

/// Service for Supabase Storage operations
///
/// This service handles file uploads to Supabase Storage buckets,
/// including image optimization, thumbnail generation, and URL management.
class StorageService {
  final SupabaseClient _supabase;
  final Logger _logger;
  final Uuid _uuid;

  StorageService({
    required SupabaseClient supabase,
    required Logger logger,
  })  : _supabase = supabase,
        _logger = logger,
        _uuid = const Uuid();

  /// Upload processed image and thumbnail for an item
  Future<ItemImageUrls?> uploadItemImage(
    ProcessedImage processedImage,
    String userId,
  ) async {
    try {
      _logger.i('Uploading item image for user: $userId');

      // Generate unique file names
      final imageId = _uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = 'items/$userId/$timestamp-$imageId.jpg';
      final thumbnailPath = 'items/$userId/$timestamp-$imageId-thumb.jpg';

      // Upload main image
      final imageUrl = await _uploadFile(
        bucketName: AppConstants.itemImagesBucket,
        filePath: imagePath,
        fileBytes: processedImage.processedBytes,
        contentType: 'image/jpeg',
      );

      if (imageUrl == null) {
        _logger.e('Failed to upload main image');
        return null;
      }

      // Upload thumbnail
      final thumbnailUrl = await _uploadFile(
        bucketName: AppConstants.itemImagesBucket,
        filePath: thumbnailPath,
        fileBytes: processedImage.thumbnailBytes,
        contentType: 'image/jpeg',
      );

      if (thumbnailUrl == null) {
        _logger.e('Failed to upload thumbnail');
        // Try to clean up the main image
        await _deleteFile(AppConstants.itemImagesBucket, imagePath);
        return null;
      }

      _logger
          .i('Successfully uploaded item images: $imagePath, $thumbnailPath');

      return ItemImageUrls(
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to upload item image',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Upload profile avatar
  Future<String?> uploadProfileAvatar(
    Uint8List imageBytes,
    String userId,
  ) async {
    try {
      _logger.i('Uploading profile avatar for user: $userId');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'avatars/$userId-$timestamp.jpg';

      final avatarUrl = await _uploadFile(
        bucketName: AppConstants.profileAvatarsBucket,
        filePath: filePath,
        fileBytes: imageBytes,
        contentType: 'image/jpeg',
      );

      if (avatarUrl != null) {
        _logger.i('Successfully uploaded profile avatar: $filePath');
      }

      return avatarUrl;
    } catch (e, stackTrace) {
      _logger.e('Failed to upload profile avatar',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Generic file upload method
  Future<String?> _uploadFile({
    required String bucketName,
    required String filePath,
    required Uint8List fileBytes,
    required String contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      // Ensure bucket exists
      await _ensureBucketExists(bucketName);

      // Upload file
      await _supabase.storage.from(bucketName).uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl =
          _supabase.storage.from(bucketName).getPublicUrl(filePath);

      _logger.d('File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      _logger.e('Failed to upload file to $bucketName/$filePath',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Delete a file from storage
  Future<bool> _deleteFile(String bucketName, String filePath) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
      _logger.d('File deleted successfully: $bucketName/$filePath');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete file $bucketName/$filePath',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete item images
  Future<bool> deleteItemImages(ItemImageUrls imageUrls) async {
    try {
      final results = await Future.wait([
        _deleteFile(AppConstants.itemImagesBucket, imageUrls.imagePath),
        _deleteFile(AppConstants.itemImagesBucket, imageUrls.thumbnailPath),
      ]);

      final success = results.every((result) => result);
      if (success) {
        _logger.i('Successfully deleted item images');
      } else {
        _logger.w('Some item images could not be deleted');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete item images',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete profile avatar
  Future<bool> deleteProfileAvatar(String avatarUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket and file path
      final bucketIndex = pathSegments.indexOf('object');
      if (bucketIndex == -1 || bucketIndex + 2 >= pathSegments.length) {
        _logger.e('Invalid avatar URL format: $avatarUrl');
        return false;
      }

      final bucketName = pathSegments[bucketIndex + 1];
      final filePath = pathSegments.sublist(bucketIndex + 2).join('/');

      return await _deleteFile(bucketName, filePath);
    } catch (e, stackTrace) {
      _logger.e('Failed to delete profile avatar',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Ensure bucket exists and is properly configured
  Future<void> _ensureBucketExists(String bucketName) async {
    try {
      // Check if bucket exists
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == bucketName);

      if (!bucketExists) {
        _logger.i('Creating storage bucket: $bucketName');

        // Create bucket with public access
        await _supabase.storage.createBucket(
          bucketName,
          const BucketOptions(
            public: true,
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
            fileSizeLimit: '5MB',
          ),
        );

        _logger.i('Storage bucket created successfully: $bucketName');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to ensure bucket exists: $bucketName',
          error: e, stackTrace: stackTrace);
      // Don't rethrow - continue with upload attempt
    }
  }

  /// Get signed URL for private access (if needed in future)
  Future<String?> getSignedUrl(
    String bucketName,
    String filePath, {
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    try {
      final signedUrl = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresIn.inSeconds);

      return signedUrl;
    } catch (e, stackTrace) {
      _logger.e('Failed to create signed URL',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get storage usage statistics
  Future<StorageStats?> getStorageStats(String userId) async {
    try {
      // List all files for the user
      final itemFiles = await _supabase.storage
          .from(AppConstants.itemImagesBucket)
          .list(path: 'items/$userId');

      final avatarFiles = await _supabase.storage
          .from(AppConstants.profileAvatarsBucket)
          .list(path: 'avatars');

      // Filter avatar files for this user
      final userAvatars =
          avatarFiles.where((file) => file.name.startsWith(userId)).toList();

      // Calculate total size
      int totalSize = 0;
      int totalFiles = 0;

      for (final file in itemFiles) {
        if (file.metadata?['size'] != null) {
          totalSize += file.metadata!['size'] as int;
        }
        totalFiles++;
      }

      for (final file in userAvatars) {
        if (file.metadata?['size'] != null) {
          totalSize += file.metadata!['size'] as int;
        }
        totalFiles++;
      }

      return StorageStats(
        totalFiles: totalFiles,
        totalSizeBytes: totalSize,
        itemImageCount: itemFiles.length,
        avatarCount: userAvatars.length,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to get storage stats',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Clean up old temporary files (could be called periodically)
  Future<void> cleanupOldFiles({
    Duration maxAge = const Duration(days: 30),
  }) async {
    try {
      _logger
          .i('Starting cleanup of old files older than ${maxAge.inDays} days');

      final cutoffTime = DateTime.now().subtract(maxAge);

      // This would require more sophisticated logic to parse file timestamps
      // and determine which files are safe to delete. For now, we'll just log.
      _logger.i('Cleanup would remove files older than $cutoffTime');

      // Implementation would involve:
      // 1. List all files in buckets
      // 2. Parse timestamps from filenames or metadata
      // 3. Delete files older than cutoff
      // 4. Clean up orphaned database references
    } catch (e, stackTrace) {
      _logger.e('Failed to cleanup old files',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Extract file path from public URL
  String? extractFilePathFromUrl(String publicUrl) {
    try {
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;

      // Find the object path in the URL
      final objectIndex = pathSegments.indexOf('object');
      if (objectIndex == -1 || objectIndex + 2 >= pathSegments.length) {
        return null;
      }

      // Skip bucket name and return file path
      return pathSegments.sublist(objectIndex + 2).join('/');
    } catch (e) {
      _logger.e('Failed to extract file path from URL: $publicUrl', error: e);
      return null;
    }
  }
}

/// Data class for item image URLs
class ItemImageUrls {
  final String imageUrl;
  final String thumbnailUrl;
  final String imagePath;
  final String thumbnailPath;

  const ItemImageUrls({
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.imagePath,
    required this.thumbnailPath,
  });

  @override
  String toString() {
    return 'ItemImageUrls(imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl)';
  }
}

/// Data class for storage statistics
class StorageStats {
  final int totalFiles;
  final int totalSizeBytes;
  final int itemImageCount;
  final int avatarCount;

  const StorageStats({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.itemImageCount,
    required this.avatarCount,
  });

  double get totalSizeMB => totalSizeBytes / (1024 * 1024);

  String get formattedSize {
    if (totalSizeBytes < 1024) {
      return '$totalSizeBytes B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${totalSizeMB.toStringAsFixed(1)} MB';
    }
  }

  @override
  String toString() {
    return 'StorageStats(files: $totalFiles, size: $formattedSize, items: $itemImageCount, avatars: $avatarCount)';
  }
}
