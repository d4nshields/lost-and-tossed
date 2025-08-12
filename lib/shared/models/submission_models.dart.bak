import 'package:json_annotation/json_annotation.dart';

part 'submission_models.g.dart';

/// Categories for found objects (matching database enum)
@JsonEnum(valueField: 'value')
enum SubmissionCategory {
  lost('lost'),
  tossed('tossed'),
  posted('posted'),
  marked('marked'),
  curious('curious');

  const SubmissionCategory(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case SubmissionCategory.lost:
        return 'Lost';
      case SubmissionCategory.tossed:
        return 'Tossed';
      case SubmissionCategory.posted:
        return 'Posted';
      case SubmissionCategory.marked:
        return 'Marked';
      case SubmissionCategory.curious:
        return 'Curious';
    }
  }

  String get description {
    switch (this) {
      case SubmissionCategory.lost:
        return 'Unintentionally left behind';
      case SubmissionCategory.tossed:
        return 'Deliberately discarded';
      case SubmissionCategory.posted:
        return 'Intended for display';
      case SubmissionCategory.marked:
        return 'Non-removable markings';
      case SubmissionCategory.curious:
        return 'Anything else odd or unclassifiable';
    }
  }

  String get emoji {
    switch (this) {
      case SubmissionCategory.lost:
        return '🧤';
      case SubmissionCategory.tossed:
        return '🗑️';
      case SubmissionCategory.posted:
        return '📋';
      case SubmissionCategory.marked:
        return '🎨';
      case SubmissionCategory.curious:
        return '🤔';
    }
  }
}

/// License types for shared content (matching database enum)
@JsonEnum(valueField: 'value')
enum LicenseType {
  ccByNc('CC_BY_NC'),
  cc0('CC0');

  const LicenseType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case LicenseType.ccByNc:
        return 'CC BY-NC';
      case LicenseType.cc0:
        return 'CC0';
    }
  }

  String get description {
    switch (this) {
      case LicenseType.ccByNc:
        return 'Creative Commons Attribution-NonCommercial';
      case LicenseType.cc0:
        return 'Creative Commons Zero (Public Domain)';
    }
  }
}

/// User model (matching database schema)
@JsonSerializable()
class User {
  final String id;
  final String handle;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.handle,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? handle,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      handle: handle ?? this.handle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, handle: $handle)';
}

/// URLs structure for submission images
@JsonSerializable()
class SubmissionUrls {
  final String? original;
  final String? thumbnail;
  final String? processed;

  const SubmissionUrls({
    this.original,
    this.thumbnail,
    this.processed,
  });

  factory SubmissionUrls.fromJson(Map<String, dynamic> json) =>
      _$SubmissionUrlsFromJson(json);
  Map<String, dynamic> toJson() => _$SubmissionUrlsToJson(this);

  String get effectiveUrl => processed ?? original ?? thumbnail ?? '';
  String get effectiveThumbnail => thumbnail ?? processed ?? original ?? '';
  bool get hasImages =>
      original != null || processed != null || thumbnail != null;

  SubmissionUrls copyWith({
    String? original,
    String? thumbnail,
    String? processed,
  }) {
    return SubmissionUrls(
      original: original ?? this.original,
      thumbnail: thumbnail ?? this.thumbnail,
      processed: processed ?? this.processed,
    );
  }
}

/// Safety flags for content moderation
@JsonSerializable()
class SafetyFlags {
  final bool? hidden;
  final bool? reported;
  final bool? reviewed;
  final String? reason;

  const SafetyFlags({
    this.hidden,
    this.reported,
    this.reviewed,
    this.reason,
  });

  factory SafetyFlags.fromJson(Map<String, dynamic> json) =>
      _$SafetyFlagsFromJson(json);
  Map<String, dynamic> toJson() => _$SafetyFlagsToJson(this);

  bool get isHidden => hidden == true;
  bool get isReported => reported == true;
  bool get isReviewed => reviewed == true;
  bool get isVisible => !isHidden;

  SafetyFlags copyWith({
    bool? hidden,
    bool? reported,
    bool? reviewed,
    String? reason,
  }) {
    return SafetyFlags(
      hidden: hidden ?? this.hidden,
      reported: reported ?? this.reported,
      reviewed: reviewed ?? this.reviewed,
      reason: reason ?? this.reason,
    );
  }
}

/// Main submission model (matching database schema)
@JsonSerializable()
class Submission {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final SubmissionCategory category;
  final String? caption;
  final List<String>? tags;
  final LicenseType license;
  final bool? disposed;
  final String geohash5;
  final double? lat;
  final double? lon;
  @JsonKey(name: 'found_at')
  final DateTime? foundAt;
  final SubmissionUrls urls;
  @JsonKey(name: 'safety_flags')
  final SafetyFlags? safetyFlags;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  // Expanded fields (from joins)
  final User? user;

  const Submission({
    required this.id,
    required this.userId,
    required this.category,
    this.caption,
    this.tags,
    required this.license,
    this.disposed,
    required this.geohash5,
    this.lat,
    this.lon,
    this.foundAt,
    required this.urls,
    this.safetyFlags,
    this.createdAt,
    this.user,
  });

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);
  Map<String, dynamic> toJson() => _$SubmissionToJson(this);

  bool get hasLocation => lat != null && lon != null;
  bool get isVisible => safetyFlags?.isVisible ?? true;
  bool get isDisposed => disposed == true;
  bool get hasImages => urls.hasImages;

  String get effectiveImageUrl => urls.effectiveUrl;
  String get effectiveThumbnailUrl => urls.effectiveThumbnail;

  Submission copyWith({
    String? id,
    String? userId,
    SubmissionCategory? category,
    String? caption,
    List<String>? tags,
    LicenseType? license,
    bool? disposed,
    String? geohash5,
    double? lat,
    double? lon,
    DateTime? foundAt,
    SubmissionUrls? urls,
    SafetyFlags? safetyFlags,
    DateTime? createdAt,
    User? user,
  }) {
    return Submission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      license: license ?? this.license,
      disposed: disposed ?? this.disposed,
      geohash5: geohash5 ?? this.geohash5,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      foundAt: foundAt ?? this.foundAt,
      urls: urls ?? this.urls,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Submission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Submission(id: $id, category: $category, caption: $caption)';
  }
}

/// Data class for creating new submissions
@JsonSerializable()
class CreateSubmissionRequest {
  final SubmissionCategory category;
  final String? caption;
  final List<String>? tags;
  final LicenseType license;
  final String geohash5;
  final double? lat;
  final double? lon;
  final DateTime? foundAt;
  final SubmissionUrls urls;

  const CreateSubmissionRequest({
    required this.category,
    this.caption,
    this.tags,
    this.license = LicenseType.ccByNc,
    required this.geohash5,
    this.lat,
    this.lon,
    this.foundAt,
    required this.urls,
  });

  factory CreateSubmissionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubmissionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSubmissionRequestToJson(this);
}

/// Tag model
@JsonSerializable()
class Tag {
  final String id;
  final String name;

  const Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tag(id: $id, name: $name)';
}

/// List/OCR model for found text content
@JsonSerializable()
class SubmissionList {
  final String id;
  @JsonKey(name: 'submission_id')
  final String submissionId;
  @JsonKey(name: 'ocr_text')
  final String? ocrText;
  @JsonKey(name: 'corrected_text')
  final String? correctedText;
  @JsonKey(name: 'word_count')
  final int? wordCount;

  const SubmissionList({
    required this.id,
    required this.submissionId,
    this.ocrText,
    this.correctedText,
    this.wordCount,
  });

  factory SubmissionList.fromJson(Map<String, dynamic> json) =>
      _$SubmissionListFromJson(json);
  Map<String, dynamic> toJson() => _$SubmissionListToJson(this);

  String get effectiveText => correctedText ?? ocrText ?? '';
  bool get hasText => ocrText != null || correctedText != null;
  int get effectiveWordCount => wordCount ?? 0;

  SubmissionList copyWith({
    String? id,
    String? submissionId,
    String? ocrText,
    String? correctedText,
    int? wordCount,
  }) {
    return SubmissionList(
      id: id ?? this.id,
      submissionId: submissionId ?? this.submissionId,
      ocrText: ocrText ?? this.ocrText,
      correctedText: correctedText ?? this.correctedText,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubmissionList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SubmissionList(id: $id, submissionId: $submissionId, wordCount: $wordCount)';
  }
}
