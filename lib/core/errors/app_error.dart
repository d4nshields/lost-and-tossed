// Temporary simplified model without code generation for initial build

abstract class AppError {
  const AppError();

  const factory AppError.network({
    required String message,
    String? code,
  }) = NetworkError;

  const factory AppError.authentication({
    required String message,
    String? code,
  }) = AuthenticationError;

  const factory AppError.validation({
    required String message,
    required String field,
  }) = ValidationError;

  const factory AppError.permission({
    required String message,
    required String permission,
  }) = PermissionError;

  const factory AppError.storage({
    required String message,
    String? code,
  }) = StorageError;

  const factory AppError.location({
    required String message,
    String? code,
  }) = LocationError;

  const factory AppError.imageProcessing({
    required String message,
    String? code,
  }) = ImageProcessingError;

  const factory AppError.unknown({
    required String message,
    Object? originalError,
  }) = UnknownError;
}

class NetworkError extends AppError {
  const NetworkError({required this.message, this.code});
  final String message;
  final String? code;
}

class AuthenticationError extends AppError {
  const AuthenticationError({required this.message, this.code});
  final String message;
  final String? code;
}

class ValidationError extends AppError {
  const ValidationError({required this.message, required this.field});
  final String message;
  final String field;
}

class PermissionError extends AppError {
  const PermissionError({required this.message, required this.permission});
  final String message;
  final String permission;
}

class StorageError extends AppError {
  const StorageError({required this.message, this.code});
  final String message;
  final String? code;
}

class LocationError extends AppError {
  const LocationError({required this.message, this.code});
  final String message;
  final String? code;
}

class ImageProcessingError extends AppError {
  const ImageProcessingError({required this.message, this.code});
  final String message;
  final String? code;
}

class UnknownError extends AppError {
  const UnknownError({required this.message, this.originalError});
  final String message;
  final Object? originalError;
}

extension AppErrorExtension on AppError {
  String get userFriendlyMessage {
    if (this is NetworkError) {
      return 'Network error: Please check your connection and try again.';
    } else if (this is AuthenticationError) {
      return 'Authentication failed. Please sign in again.';
    } else if (this is ValidationError) {
      final error = this as ValidationError;
      return 'Invalid ${error.field}: ${error.message}';
    } else if (this is PermissionError) {
      final error = this as PermissionError;
      return 'Permission denied: ${error.message}';
    } else if (this is StorageError) {
      final error = this as StorageError;
      return 'Storage error: ${error.message}';
    } else if (this is LocationError) {
      final error = this as LocationError;
      return 'Location error: ${error.message}';
    } else if (this is ImageProcessingError) {
      final error = this as ImageProcessingError;
      return 'Image processing error: ${error.message}';
    } else if (this is UnknownError) {
      final error = this as UnknownError;
      return 'Something went wrong: ${error.message}';
    }
    return 'An error occurred';
  }

  bool get isRetryable {
    return this is NetworkError || 
           this is StorageError || 
           this is LocationError || 
           this is UnknownError;
  }
}
