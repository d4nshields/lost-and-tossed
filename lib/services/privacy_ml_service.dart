import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

import '../core/errors/app_error.dart';
import '../core/constants/app_constants.dart';

class PrivacyMLService {
  const PrivacyMLService();

  late final FaceDetector _faceDetector;
  late final TextRecognizer _textRecognizer;

  /// Initialize ML Kit detectors
  Future<void> initialize() async {
    try {
      // Configure face detector for privacy protection
      final faceDetectorOptions = FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
        minFaceSize: 0.1, // Detect smaller faces
        performanceMode: FaceDetectorMode.accurate,
      );

      _faceDetector = FaceDetector(options: faceDetectorOptions);
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    } catch (e) {
      throw AppError.imageProcessing(
        message: 'Failed to initialize ML Kit services',
        code: e.toString(),
      );
    }
  }

  /// Detect faces in image and return bounding boxes for blurring
  Future<List<FaceBlurArea>> detectFaces(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);

      return faces.map((face) {
        final boundingBox = face.boundingBox;
        return FaceBlurArea(
          left: boundingBox.left.toInt(),
          top: boundingBox.top.toInt(),
          width: boundingBox.width.toInt(),
          height: boundingBox.height.toInt(),
          confidence: face.headEulerAngleY ?? 0.0, // Use as confidence proxy
        );
      }).where((area) {
        // Only blur faces with reasonable confidence
        return area.confidence.abs() < 45; // Face is relatively frontal
      }).toList();
    } catch (e) {
      throw AppError.imageProcessing(
        message: 'Face detection failed',
        code: e.toString(),
      );
    }
  }

  /// Detect text that might contain personal information
  Future<List<TextBlurArea>> detectSensitiveText(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final sensitiveAreas = <TextBlurArea>[];

      for (final textBlock in recognizedText.blocks) {
        for (final line in textBlock.lines) {
          final text = line.text;

          // Check for patterns that might be personal info
          if (_containsSensitiveInfo(text)) {
            final boundingBox = line.boundingBox;
            sensitiveAreas.add(TextBlurArea(
              left: boundingBox.left.toInt(),
              top: boundingBox.top.toInt(),
              width: boundingBox.width.toInt(),
              height: boundingBox.height.toInt(),
              text: text,
              sensitivityType: _classifySensitiveText(text),
            ));
          }
        }
      }

      return sensitiveAreas;
    } catch (e) {
      throw AppError.imageProcessing(
        message: 'Text recognition failed',
        code: e.toString(),
      );
    }
  }

  /// Apply privacy blurring to image
  Future<Uint8List> applyPrivacyBlur(
    Uint8List imageBytes,
    List<FaceBlurArea> faceAreas,
    List<TextBlurArea> textAreas,
  ) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const AppError.imageProcessing(
          message: 'Failed to decode image',
        );
      }

      // Apply face blurring
      for (final area in faceAreas) {
        _blurArea(image, area.left, area.top, area.width, area.height);
      }

      // Apply text blurring
      for (final area in textAreas) {
        _blurArea(image, area.left, area.top, area.width, area.height);
      }

      // Encode back to bytes
      final blurredBytes = img.encodeJpg(
        image,
        quality: (AppConstants.imageQuality * 100).toInt(),
      );

      return Uint8List.fromList(blurredBytes);
    } catch (e) {
      throw AppError.imageProcessing(
        message: 'Failed to apply privacy blur',
        code: e.toString(),
      );
    }
  }

  /// Check if text contains sensitive information
  bool _containsSensitiveInfo(String text) {
    final lowerText = text.toLowerCase();

    // License plate patterns (simple examples)
    final licensePatterns = [
      RegExp(r'[a-z]{3}\s?\d{3,4}', caseSensitive: false), // ABC 123
      RegExp(r'\d{3}\s?[a-z]{3}', caseSensitive: false), // 123 ABC
    ];

    // Phone number patterns
    final phonePatterns = [
      RegExp(r'\(\d{3}\)\s?\d{3}-?\d{4}'), // (123) 456-7890
      RegExp(r'\d{3}-?\d{3}-?\d{4}'), // 123-456-7890
    ];

    // Email patterns
    final emailPattern =
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');

    // Address patterns (house numbers)
    final addressPattern = RegExp(
        r'\b\d{1,5}\s+\w+\s+(st|street|ave|avenue|rd|road|dr|drive|blvd|boulevard)',
        caseSensitive: false);

    return licensePatterns.any((pattern) => pattern.hasMatch(text)) ||
        phonePatterns.any((pattern) => pattern.hasMatch(text)) ||
        emailPattern.hasMatch(text) ||
        addressPattern.hasMatch(text);
  }

  /// Classify the type of sensitive text
  SensitiveTextType _classifySensitiveText(String text) {
    if (RegExp(r'[a-z]{3}\s?\d{3,4}', caseSensitive: false).hasMatch(text)) {
      return SensitiveTextType.licensePlate;
    }
    if (RegExp(r'\d{3}-?\d{3}-?\d{4}').hasMatch(text)) {
      return SensitiveTextType.phoneNumber;
    }
    if (RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(text)) {
      return SensitiveTextType.email;
    }
    if (RegExp(r'\b\d{1,5}\s+\w+\s+(st|street|ave|avenue)',
            caseSensitive: false)
        .hasMatch(text)) {
      return SensitiveTextType.address;
    }
    return SensitiveTextType.other;
  }

  /// Apply blur effect to a specific area of the image
  void _blurArea(img.Image image, int left, int top, int width, int height) {
    // Extract the area to blur
    final area = img.copyCrop(
      image,
      x: left.clamp(0, image.width),
      y: top.clamp(0, image.height),
      width: width.clamp(0, image.width - left),
      height: height.clamp(0, image.height - top),
    );

    // Apply Gaussian blur
    final blurred = img.gaussianBlur(area, radius: 15);

    // Composite the blurred area back onto the original image
    img.compositeImage(
      image,
      blurred,
      dstX: left,
      dstY: top,
    );
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _faceDetector.close();
    await _textRecognizer.close();
  }
}

// Data classes for blur areas
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

enum SensitiveTextType {
  licensePlate,
  phoneNumber,
  email,
  address,
  other,
}

// Riverpod provider
final privacyMLServiceProvider = Provider<PrivacyMLService>((ref) {
  return const PrivacyMLService();
});
