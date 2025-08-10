import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

@freezed
class AppError with _$AppError {
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

extension AppErrorExtension on AppError {
  String get userFriendlyMessage => when(
    network: (message, code) => 'Network error: Please check your connection and try again.',
    authentication: (message, code) => 'Authentication failed. Please sign in again.',
    validation: (message, field) => 'Invalid $field: $message',
    permission: (message, permission) => 'Permission denied: $message',
    storage: (message, code) => 'Storage error: $message',
    location: (message, code) => 'Location error: $message',
    imageProcessing: (message, code) => 'Image processing error: $message',
    unknown: (message, originalError) => 'Something went wrong: $message',
  );

  bool get isRetryable => when(
    network: (_, __) => true,
    authentication: (_, __) => false,
    validation: (_, __) => false,
    permission: (_, __) => false,
    storage: (_, __) => true,
    location: (_, __) => true,
    imageProcessing: (_, __) => false,
    unknown: (_, __) => true,
  );
}
