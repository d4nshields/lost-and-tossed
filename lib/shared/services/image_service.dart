import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';

/// Service for image processing, privacy protection, and optimization
/// 
/// This service handles image capture, face/text detection for privacy,
/// automatic blurring of sensitive information, and image optimization
/// for upload and storage.
class ImageService {
  final Logger _logger;
  final ImagePicker _imagePicker;
  final FaceDetector _faceDetector;
  final TextRecognizer _textRecognizer;

  ImageService({required Logger logger})
      : _logger = logger,
        _imagePicker = ImagePicker(),
        _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: false,
            enableLandmarks: false,
            enableContours: false,
            enableTracking: false,
            minFaceSize: 0.1,
            performanceMode: FaceDetectorMode.fast,
          ),
        ),
        _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Initialize the image service
  Future<void> initialize() async {
    try {
      _logger.i('Image service initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize image service', error: e, stackTrace: stackTrace);
    }
  }

  /// Dispose of resources
  void dispose() {
    _faceDetector.close();
    _textRecognizer.close();
  }

  /// Capture image from camera
  Future<XFile?> captureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        _logger.i('Image captured from camera: ${image.path}');
      }

      return image;
    } catch (e, stackTrace) {
      _logger.e('Failed to capture image from camera', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        _logger.i('Image picked from gallery: ${image.path}');
      }

      return image;
    } catch (e, stackTrace) {
      _logger.e('Failed to pick image from gallery', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Process image for privacy protection
  Future<ProcessedImage?> processImageForPrivacy(XFile imageFile) async {
    try {
      _logger.i('Processing image for privacy: ${imageFile.path}');

      // Read image file
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        _logger.e('Failed to decode image');
        return null;
      }

      // Create ML Kit input image
      final inputImage = InputImage.fromFilePath(imageFile.path);

      // Detect faces and text
      final faces = await _detectFaces(inputImage);
      final textBlocks = await _detectText(inputImage);

      // Create blurred version if sensitive content detected
      img.Image processedImage = img.copyResize(originalImage,
          width: originalImage.width, height: originalImage.height);

      bool hasBlurredContent = false;

      // Blur faces
      for (final face in faces) {
        _blurRegion(processedImage, face.boundingBox);
        hasBlurredContent = true;
        _logger.d('Blurred face at ${face.boundingBox}');
      }

      // Blur potential sensitive text (license plates, house numbers, etc.)
      for (final textBlock in textBlocks) {
        if (_isSensitiveText(textBlock.text)) {
          _blurRegion(processedImage, textBlock.boundingBox);
          hasBlurredContent = true;
          _logger.d('Blurred sensitive text: ${textBlock.text}');
        }
      }

      // Create thumbnail
      final thumbnail = img.copyResize(
        processedImage,
        width: AppConstants.thumbnailWidth,
        height: AppConstants.thumbnailHeight,
        interpolation: img.Interpolation.cubic,
      );

      // Encode images
      final processedBytes = Uint8List.fromList(img.encodeJpg(processedImage, quality: 85));
      final thumbnailBytes = Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));

      // Check file size
      if (processedBytes.length > AppConstants.maxImageSizeBytes) {
        _logger.w('Processed image exceeds max size, compressing further');
        final compressedImage = await _compressImage(processedImage);
        return ProcessedImage(
          originalBytes: bytes,
          processedBytes: Uint8List.fromList(img.encodeJpg(compressedImage, quality: 70)),
          thumbnailBytes: thumbnailBytes,
          hasBlurredContent: hasBlurredContent,
          faceCount: faces.length,
          sensitiveTextCount: textBlocks.where((t) => _isSensitiveText(t.text)).length,
        );
      }

      return ProcessedImage(
        originalBytes: bytes,
        processedBytes: processedBytes,
        thumbnailBytes: thumbnailBytes,
        hasBlurredContent: hasBlurredContent,
        faceCount: faces.length,
        sensitiveTextCount: textBlocks.where((t) => _isSensitiveText(t.text)).length,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to process image for privacy', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Detect faces in image
  Future<List<Face>> _detectFaces(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      _logger.d('Detected ${faces.length} faces');
      return faces;
    } catch (e, stackTrace) {
      _logger.e('Failed to detect faces', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Detect text in image
  Future<List<TextBlock>> _detectText(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      _logger.d('Detected ${recognizedText.blocks.length} text blocks');
      return recognizedText.blocks;
    } catch (e, stackTrace) {
      _logger.e('Failed to detect text', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Check if text is potentially sensitive
  bool _isSensitiveText(String text) {
    final cleanText = text.trim().toUpperCase();
    
    // License plate patterns (various formats)
    final licensePatterns = [
      RegExp(r'^[A-Z]{1,3}\s*\d{1,4}$'), // ABC 123
      RegExp(r'^\d{1,3}\s*[A-Z]{1,3}$'), // 123 ABC
      RegExp(r'^[A-Z0-9]{5,8}$'), // Mixed alphanumeric
    ];
    
    for (final pattern in licensePatterns) {
      if (pattern.hasMatch(cleanText)) {
        return true;
      }
    }
    
    // House numbers (simple numeric patterns)
    if (RegExp(r'^\d{1,5}[A-Z]?$').hasMatch(cleanText)) {
      final number = int.tryParse(cleanText.replaceAll(RegExp(r'[A-Z]'), ''));
      if (number != null && number > 0 && number < 99999) {
        return true;
      }
    }
    
    // Phone numbers (basic patterns)
    if (RegExp(r'(\d{3}[-.\s]?\d{3}[-.\s]?\d{4})').hasMatch(cleanText)) {
      return true;
    }
    
    // Email addresses
    if (RegExp(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b').hasMatch(cleanText)) {
      return true;
    }
    
    return false;
  }

  /// Blur a specific region of the image
  void _blurRegion(img.Image image, Rect boundingBox) {
    try {
      // Convert Flutter Rect to image coordinates
      final left = boundingBox.left.toInt().clamp(0, image.width - 1);
      final top = boundingBox.top.toInt().clamp(0, image.height - 1);
      final right = boundingBox.right.toInt().clamp(0, image.width);
      final bottom = boundingBox.bottom.toInt().clamp(0, image.height);
      
      final width = (right - left).clamp(1, image.width - left);
      final height = (bottom - top).clamp(1, image.height - top);
      
      // Extract the region
      final region = img.copyCrop(image, x: left, y: top, width: width, height: height);
      
      // Apply blur
      final blurred = img.gaussianBlur(region, radius: 15);
      
      // Composite back onto the original image
      img.compositeImage(image, blurred, dstX: left, dstY: top);
    } catch (e, stackTrace) {
      _logger.e('Failed to blur region', error: e, stackTrace: stackTrace);
    }
  }

  /// Compress image to reduce file size
  Future<img.Image> _compressImage(img.Image image) async {
    try {
      // Calculate new dimensions (maintain aspect ratio)
      final aspectRatio = image.width / image.height;
      int newWidth, newHeight;
      
      if (aspectRatio > 1) {
        // Landscape
        newWidth = (AppConstants.maxImageWidth * 0.8).toInt();
        newHeight = (newWidth / aspectRatio).toInt();
      } else {
        // Portrait or square
        newHeight = (AppConstants.maxImageHeight * 0.8).toInt();
        newWidth = (newHeight * aspectRatio).toInt();
      }
      
      return img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to compress image', error: e, stackTrace: stackTrace);
      return image; // Return original if compression fails
    }
  }

  /// Create a preview image for display
  Future<Uint8List> createPreviewImage(ProcessedImage processedImage) async {
    try {
      // Decode the processed image
      final image = img.decodeImage(processedImage.processedBytes);
      if (image == null) throw Exception('Failed to decode processed image');
      
      // Create a smaller preview (max 800px on longest side)
      final maxDimension = 800;
      final aspectRatio = image.width / image.height;
      
      int previewWidth, previewHeight;
      if (image.width > image.height) {
        previewWidth = maxDimension;
        previewHeight = (maxDimension / aspectRatio).toInt();
      } else {
        previewHeight = maxDimension;
        previewWidth = (maxDimension * aspectRatio).toInt();
      }
      
      final preview = img.copyResize(
        image,
        width: previewWidth,
        height: previewHeight,
        interpolation: img.Interpolation.cubic,
      );
      
      return Uint8List.fromList(img.encodeJpg(preview, quality: 85));
    } catch (e, stackTrace) {
      _logger.e('Failed to create preview image', error: e, stackTrace: stackTrace);
      return processedImage.thumbnailBytes; // Fallback to thumbnail
    }
  }

  /// Get image dimensions
  Future<ImageDimensions?> getImageDimensions(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      return ImageDimensions(
        width: image.width,
        height: image.height,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to get image dimensions', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Check if file size is within limits
  bool isFileSizeValid(Uint8List bytes) {
    return bytes.length <= AppConstants.maxImageSizeBytes;
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Data class for processed image results
class ProcessedImage {
  final Uint8List originalBytes;
  final Uint8List processedBytes;
  final Uint8List thumbnailBytes;
  final bool hasBlurredContent;
  final int faceCount;
  final int sensitiveTextCount;

  const ProcessedImage({
    required this.originalBytes,
    required this.processedBytes,
    required this.thumbnailBytes,
    required this.hasBlurredContent,
    required this.faceCount,
    required this.sensitiveTextCount,
  });

  bool get hasPrivacyProtection => hasBlurredContent;
  int get totalSensitiveItems => faceCount + sensitiveTextCount;

  String get privacySummary {
    if (!hasBlurredContent) return 'No sensitive content detected';
    
    final items = <String>[];
    if (faceCount > 0) items.add('$faceCount face${faceCount == 1 ? '' : 's'}');
    if (sensitiveTextCount > 0) items.add('$sensitiveTextCount sensitive text${sensitiveTextCount == 1 ? '' : 's'}');
    
    return 'Blurred: ${items.join(', ')}';
  }

  @override
  String toString() {
    return 'ProcessedImage(original: ${originalBytes.length}B, processed: ${processedBytes.length}B, thumbnail: ${thumbnailBytes.length}B, privacy: $privacySummary)';
  }
}

/// Data class for image dimensions
class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({
    required this.width,
    required this.height,
  });

  double get aspectRatio => width / height;
  bool get isLandscape => width > height;
  bool get isPortrait => height > width;
  bool get isSquare => width == height;

  @override
  String toString() {
    return 'ImageDimensions(${width}x$height)';
  }
}
