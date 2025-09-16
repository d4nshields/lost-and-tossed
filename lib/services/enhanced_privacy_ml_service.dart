import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

import '../core/constants/app_constants.dart';
import '../features/capture/domain/models/submission_models.dart';

/// Enhanced privacy ML service with improved detection and OCR capabilities
class EnhancedPrivacyMLService {
  EnhancedPrivacyMLService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;
  
  FaceDetector? _faceDetector;
  TextRecognizer? _textRecognizer;
  ObjectDetector? _objectDetector;
  
  // Performance mode flags
  bool _useGpu = true;
  bool _isInitialized = false;

  /// Initialize ML Kit detectors with CPU/GPU fallback
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Try GPU-accelerated initialization first
      await _initializeWithGpu();
      _logger.i('ML Kit initialized with GPU acceleration');
    } catch (e) {
      _logger.w('GPU initialization failed, falling back to CPU: $e');
      _useGpu = false;
      await _initializeWithCpu();
      _logger.i('ML Kit initialized with CPU');
    }
    
    _isInitialized = true;
  }

  Future<void> _initializeWithGpu() async {
    // Configure face detector for privacy protection with GPU
    final faceDetectorOptions = FaceDetectorOptions(
      enableContours: true, // Better face boundary detection
      enableLandmarks: true, // Better face feature detection
      enableClassification: false,
      minFaceSize: 0.05, // Detect very small faces
      performanceMode: FaceDetectorMode.accurate,
      enableTracking: false, // We don't need tracking for static images
    );

    _faceDetector = FaceDetector(options: faceDetectorOptions);
    
    // Initialize text recognizer for OCR and sensitive text detection
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    // Initialize object detector for additional privacy items
    final objectDetectorOptions = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    
    _objectDetector = ObjectDetector(options: objectDetectorOptions);
  }

  Future<void> _initializeWithCpu() async {
    // Configure with CPU-optimized settings
    final faceDetectorOptions = FaceDetectorOptions(
      enableContours: false, // Reduce computation
      enableLandmarks: false, // Reduce computation
      enableClassification: false,
      minFaceSize: 0.1, // Slightly larger minimum to reduce false positives
      performanceMode: FaceDetectorMode.fast,
      enableTracking: false,
    );

    _faceDetector = FaceDetector(options: faceDetectorOptions);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    // Skip object detector in CPU mode for performance
    _objectDetector = null;
  }

  /// Process image for privacy and OCR
  Future<PrivacyProcessingResult> processImage({
    required String imagePath,
    required SubmissionCategory category,
    String? subtype,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    
    // Detect privacy-sensitive areas
    final faceAreas = await _detectFaces(inputImage);
    final textAreas = await _detectSensitiveText(inputImage);
    final objectAreas = _objectDetector != null 
        ? await _detectSensitiveObjects(inputImage)
        : <PrivacyBlurArea>[];
    
    // Combine all privacy areas
    final allPrivacyAreas = [
      ...faceAreas.map((f) => PrivacyBlurArea(
        left: f.left,
        top: f.top,
        width: f.width,
        height: f.height,
        type: PrivacyAreaType.face,
        confidence: f.confidence,
      )),
      ...textAreas.map((t) => PrivacyBlurArea(
        left: t.left,
        top: t.top,
        width: t.width,
        height: t.height,
        type: PrivacyAreaType.sensitiveText,
        metadata: {'text': t.text, 'type': t.sensitivityType.toString()},
      )),
      ...objectAreas,
    ];
    
    // Apply privacy blur
    final imageBytes = await File(imagePath).readAsBytes();
    final blurredBytes = await applyPrivacyBlur(imageBytes, allPrivacyAreas);
    
    // Perform OCR if it's a Lost category list
    String? extractedText;
    if (category == SubmissionCategory.lost && subtype == 'list') {
      extractedText = await _extractListText(inputImage);
    }
    
    return PrivacyProcessingResult(
      blurredImageBytes: blurredBytes,
      privacyAreas: allPrivacyAreas,
      extractedListText: extractedText,
      processingMode: _useGpu ? ProcessingMode.gpu : ProcessingMode.cpu,
    );
  }

  /// Enhanced face detection
  Future<List<FaceBlurArea>> _detectFaces(InputImage inputImage) async {
    try {
      final faces = await _faceDetector?.processImage(inputImage) ?? [];
      
      return faces.map((face) {
        final boundingBox = face.boundingBox;
        
        // Expand face bounding box by 20% for better privacy
        final expansion = 0.2;
        final expandedWidth = boundingBox.width * (1 + expansion);
        final expandedHeight = boundingBox.height * (1 + expansion);
        final expandedLeft = boundingBox.left - (expandedWidth - boundingBox.width) / 2;
        final expandedTop = boundingBox.top - (expandedHeight - boundingBox.height) / 2;
        
        return FaceBlurArea(
          left: expandedLeft.toInt().clamp(0, 999999),
          top: expandedTop.toInt().clamp(0, 999999),
          width: expandedWidth.toInt(),
          height: expandedHeight.toInt(),
          confidence: _calculateFaceConfidence(face),
        );
      }).where((area) => area.confidence > 0.3).toList(); // Filter low confidence
    } catch (e) {
      _logger.e('Face detection failed: $e');
      return [];
    }
  }

  double _calculateFaceConfidence(Face face) {
    // Use multiple factors to calculate confidence
    double confidence = 0.5; // Base confidence
    
    // If we have landmarks, increase confidence
    if (face.landmarks.isNotEmpty) {
      confidence += 0.2;
    }
    
    // If we have contours, increase confidence
    if (face.contours.isNotEmpty) {
      confidence += 0.2;
    }
    
    // Size-based confidence (larger faces are more likely to be real)
    final area = face.boundingBox.width * face.boundingBox.height;
    if (area > 10000) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Enhanced text detection for sensitive information
  Future<List<TextBlurArea>> _detectSensitiveText(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer?.processImage(inputImage) 
          ?? RecognizedText(text: '', blocks: []);
      
      final sensitiveAreas = <TextBlurArea>[];
      
      for (final textBlock in recognizedText.blocks) {
        for (final line in textBlock.lines) {
          final text = line.text;
          
          // Enhanced pattern matching
          final sensitivityInfo = _analyzeSensitivity(text);
          
          if (sensitivityInfo != null) {
            final boundingBox = line.boundingBox;
            
            // Expand text bounding box slightly for better coverage
            final expansion = 0.1;
            final expandedWidth = boundingBox.width * (1 + expansion);
            final expandedHeight = boundingBox.height * (1 + expansion);
            
            sensitiveAreas.add(TextBlurArea(
              left: (boundingBox.left - expandedWidth * expansion / 2).toInt(),
              top: (boundingBox.top - expandedHeight * expansion / 2).toInt(),
              width: expandedWidth.toInt(),
              height: expandedHeight.toInt(),
              text: text,
              sensitivityType: sensitivityInfo.type,
            ));
          }
        }
      }
      
      return sensitiveAreas;
    } catch (e) {
      _logger.e('Text detection failed: $e');
      return [];
    }
  }

  /// Detect sensitive objects like house numbers using object detection
  Future<List<PrivacyBlurArea>> _detectSensitiveObjects(InputImage inputImage) async {
    if (_objectDetector == null) return [];
    
    try {
      final objects = await _objectDetector!.processImage(inputImage);
      final sensitiveAreas = <PrivacyBlurArea>[];
      
      for (final obj in objects) {
        // Check if object might be sensitive
        if (_isSensitiveObject(obj)) {
          final boundingBox = obj.boundingBox;
          
          sensitiveAreas.add(PrivacyBlurArea(
            left: boundingBox.left.toInt(),
            top: boundingBox.top.toInt(),
            width: boundingBox.width.toInt(),
            height: boundingBox.height.toInt(),
            type: PrivacyAreaType.object,
            metadata: {
              'labels': obj.labels.map((l) => l.text).toList(),
            },
          ));
        }
      }
      
      return sensitiveAreas;
    } catch (e) {
      _logger.e('Object detection failed: $e');
      return [];
    }
  }

  bool _isSensitiveObject(DetectedObject obj) {
    // Check labels for potentially sensitive objects
    for (final label in obj.labels) {
      final text = label.text.toLowerCase();
      if (text.contains('person') ||
          text.contains('face') ||
          text.contains('car') ||
          text.contains('license') ||
          text.contains('sign')) {
        return true;
      }
    }
    return false;
  }

  /// Extract text from a lost list
  Future<String?> _extractListText(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer?.processImage(inputImage);
      
      if (recognizedText == null || recognizedText.text.isEmpty) {
        return null;
      }
      
      // Process the text to clean it up for a list
      final lines = <String>[];
      
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final cleanedLine = _cleanListLine(line.text);
          if (cleanedLine.isNotEmpty) {
            lines.add(cleanedLine);
          }
        }
      }
      
      // Join lines and format as a readable list
      return _formatAsList(lines);
    } catch (e) {
      _logger.e('List text extraction failed: $e');
      return null;
    }
  }

  String _cleanListLine(String text) {
    // Remove common list markers and clean up
    String cleaned = text.trim();
    
    // Remove bullet points, numbers, etc.
    cleaned = cleaned.replaceAll(RegExp(r'^[\-\*\•\·\→\▪\▸]\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\d+[\.\)\-]\s*'), '');
    
    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    return cleaned;
  }

  String _formatAsList(List<String> lines) {
    if (lines.isEmpty) return '';
    
    // Join with line breaks and add bullet points
    return lines.map((line) => '• $line').join('\n');
  }

  /// Enhanced sensitivity analysis
  SensitivityInfo? _analyzeSensitivity(String text) {
    // House numbers and addresses (check first as they're most specific)
    final houseNumberPatterns = [
      RegExp(r'\b\d{1,5}[A-Za-z]?\s+\w+\s+(street|st|avenue|ave|road|rd|drive|dr|boulevard|blvd|lane|ln|court|ct|place|pl|circle|cir|way|terrace|ter|park|pkwy|highway|hwy)\b', caseSensitive: false),
      RegExp(r'\b(apt|apartment|suite|unit|#)\s*\d+[A-Za-z]?\b', caseSensitive: false),
      RegExp(r'\b\d{1,5}[\s\-]\d{1,2}(st|nd|rd|th)\s+(street|avenue|floor)\b', caseSensitive: false),
    ];
    
    // Check address patterns first
    for (final pattern in houseNumberPatterns) {
      if (pattern.hasMatch(text)) {
        return SensitivityInfo(SensitiveTextType.address, pattern.stringMatch(text) ?? text);
      }
    }
    
    // Enhanced patterns for better detection
    
    // License plates (various formats)
    final licensePlatePatterns = [
      RegExp(r'\b[A-Z]{2,3}[\s\-]?\d{3,4}[\s\-]?[A-Z]{0,3}\b', caseSensitive: false),
      RegExp(r'\b\d{1,4}[\s\-]?[A-Z]{2,3}[\s\-]?\d{0,4}\b', caseSensitive: false),
      RegExp(r'\b[A-Z]\d{3}[\s\-]?[A-Z]{3}\b', caseSensitive: false), // Canadian format
    ];
    
    // Phone numbers (various formats)
    final phonePatterns = [
      RegExp(r'\(?\d{3}\)?[\s\-\.]?\d{3}[\s\-\.]?\d{4}'),
      RegExp(r'\+?1?[\s\-\.]?\(?\d{3}\)?[\s\-\.]?\d{3}[\s\-\.]?\d{4}'),
      RegExp(r'\d{3}[\s\-\.]?\d{4}'), // Short format
    ];
    
    // Email addresses
    final emailPattern = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
      caseSensitive: false,
    );
    
    // Check patterns
    for (final pattern in licensePlatePatterns) {
      if (pattern.hasMatch(text)) {
        return SensitivityInfo(SensitiveTextType.licensePlate, pattern.stringMatch(text) ?? text);
      }
    }
    
    for (final pattern in phonePatterns) {
      if (pattern.hasMatch(text)) {
        return SensitivityInfo(SensitiveTextType.phoneNumber, pattern.stringMatch(text) ?? text);
      }
    }
    
    if (emailPattern.hasMatch(text)) {
      return SensitivityInfo(SensitiveTextType.email, emailPattern.stringMatch(text) ?? text);
    }
    
    // Check for names (simple heuristic)
    if (_mightBeName(text)) {
      return SensitivityInfo(SensitiveTextType.possibleName, text);
    }
    
    return null;
  }

  bool _mightBeName(String text) {
    // Simple heuristic for detecting possible names
    final words = text.split(' ');
    
    // Check if it looks like a name (2-3 capitalized words)
    if (words.length >= 2 && words.length <= 3) {
      final allCapitalized = words.every((word) => 
        word.isNotEmpty && word[0] == word[0].toUpperCase()
      );
      
      if (allCapitalized) {
        // Exclude common non-name phrases
        final lowerText = text.toLowerCase();
        final excludedPhrases = [
          'for sale', 'no parking', 'private property', 
          'keep out', 'do not', 'please do',
        ];
        
        return !excludedPhrases.any((phrase) => lowerText.contains(phrase));
      }
    }
    
    return false;
  }

  /// Apply privacy blur with enhanced algorithm
  Future<Uint8List> applyPrivacyBlur(
    Uint8List imageBytes,
    List<PrivacyBlurArea> privacyAreas,
  ) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Sort areas by size (blur larger areas first for better effect)
      final sortedAreas = List<PrivacyBlurArea>.from(privacyAreas)
        ..sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));
      
      // Apply blur to each area
      for (final area in sortedAreas) {
        _applyAreaBlur(image, area);
      }
      
      // Encode back to bytes with good quality
      final blurredBytes = img.encodeJpg(
        image,
        quality: (AppConstants.imageQuality * 100).toInt(),
      );
      
      return Uint8List.fromList(blurredBytes);
    } catch (e) {
      _logger.e('Failed to apply privacy blur: $e');
      rethrow;
    }
  }

  void _applyAreaBlur(img.Image image, PrivacyBlurArea area) {
    // Calculate blur intensity based on area type
    final blurRadius = _getBlurRadius(area.type);
    
    // Ensure area is within image bounds
    final left = area.left.clamp(0, image.width - 1);
    final top = area.top.clamp(0, image.height - 1);
    final right = (area.left + area.width).clamp(left, image.width);
    final bottom = (area.top + area.height).clamp(top, image.height);
    
    final width = right - left;
    final height = bottom - top;
    
    // Skip if the area is too small or completely outside bounds
    if (width <= 2 || height <= 2) {
      return;
    }
    
    // Extract the area to blur
    final areaImage = img.copyCrop(
      image,
      x: left,
      y: top,
      width: width,
      height: height,
    );
    
    // Apply multiple blur passes for stronger effect
    img.Image blurred = areaImage;
    // Only apply blur if the area is large enough for gaussian blur
    if (width > blurRadius * 2 && height > blurRadius * 2) {
      for (int i = 0; i < 2; i++) {
        blurred = img.gaussianBlur(blurred, radius: blurRadius);
      }
    } else {
      // For very small areas, just apply a simple average
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          blurred.setPixelRgba(x, y, 128, 128, 128, 255);
        }
      }
    }
    
    // For faces, also apply pixelation for extra privacy
    if (area.type == PrivacyAreaType.face) {
      final pixelSize = (width / 15).round().clamp(4, 20);
      blurred = _pixelate(blurred, pixelSize);
    }
    
    // Composite the blurred area back
    img.compositeImage(
      image,
      blurred,
      dstX: left,
      dstY: top,
    );
  }

  img.Image _pixelate(img.Image image, int pixelSize) {
    final width = image.width;
    final height = image.height;
    
    for (int y = 0; y < height; y += pixelSize) {
      for (int x = 0; x < width; x += pixelSize) {
        // Calculate average color for the pixel block
        int r = 0, g = 0, b = 0, count = 0;
        
        for (int py = y; py < y + pixelSize && py < height; py++) {
          for (int px = x; px < x + pixelSize && px < width; px++) {
            final pixel = image.getPixel(px, py);
            r += pixel.r.toInt();
            g += pixel.g.toInt();
            b += pixel.b.toInt();
            count++;
          }
        }
        
        if (count > 0) {
          r ~/= count;
          g ~/= count;
          b ~/= count;
          
          // Set all pixels in the block to the average color
          for (int py = y; py < y + pixelSize && py < height; py++) {
            for (int px = x; px < x + pixelSize && px < width; px++) {
              image.setPixelRgba(px, py, r, g, b, 255);
            }
          }
        }
      }
    }
    
    return image;
  }

  int _getBlurRadius(PrivacyAreaType type) {
    switch (type) {
      case PrivacyAreaType.face:
        return 25; // Strong blur for faces
      case PrivacyAreaType.licensePlate:
        return 20; // Strong blur for license plates
      case PrivacyAreaType.sensitiveText:
        return 15; // Medium blur for text
      case PrivacyAreaType.object:
        return 12; // Light blur for objects
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _faceDetector?.close();
    await _textRecognizer?.close();
    await _objectDetector?.close();
    _isInitialized = false;
  }
}

// Enhanced data classes

class PrivacyProcessingResult {
  final Uint8List blurredImageBytes;
  final List<PrivacyBlurArea> privacyAreas;
  final String? extractedListText;
  final ProcessingMode processingMode;
  
  const PrivacyProcessingResult({
    required this.blurredImageBytes,
    required this.privacyAreas,
    this.extractedListText,
    required this.processingMode,
  });
}

class PrivacyBlurArea {
  final int left;
  final int top;
  final int width;
  final int height;
  final PrivacyAreaType type;
  final double? confidence;
  final Map<String, dynamic>? metadata;
  
  const PrivacyBlurArea({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.type,
    this.confidence,
    this.metadata,
  });
}

enum PrivacyAreaType {
  face,
  licensePlate,
  sensitiveText,
  object,
}

enum ProcessingMode {
  gpu,
  cpu,
}

class FaceBlurArea {
  const FaceBlurArea({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.confidence,
  });

  final int left;
  final int top;
  final int width;
  final int height;
  final double confidence;
}

class TextBlurArea {
  const TextBlurArea({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.text,
    required this.sensitivityType,
  });

  final int left;
  final int top;
  final int width;
  final int height;
  final String text;
  final SensitiveTextType sensitivityType;
}

class SensitivityInfo {
  final SensitiveTextType type;
  final String matchedText;
  
  const SensitivityInfo(this.type, this.matchedText);
}

enum SensitiveTextType {
  licensePlate,
  phoneNumber,
  email,
  address,
  possibleName,
  other,
}

// Riverpod providers
final enhancedPrivacyMLServiceProvider = Provider<EnhancedPrivacyMLService>((ref) {
  final logger = ref.watch(loggerProvider);
  return EnhancedPrivacyMLService(logger: logger);
});

final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
});
