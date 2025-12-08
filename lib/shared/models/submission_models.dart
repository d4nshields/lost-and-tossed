import 'dart:convert';

/// Submission model matching the Supabase submissions table
class Submission {
  final String id;
  final String userId;
  final SubmissionCategory category;
  final String? caption;
  final List<String>? tags;
  final String geohash5;
  final double? lat;
  final double? lon;
  final Map<String, dynamic> urls;
  final LicenseType license;
  final bool? disposed;
  final DateTime? foundAt;
  final Map<String, dynamic>? safetyFlags;
  final DateTime? createdAt;

  const Submission({
    required this.id,
    required this.userId,
    required this.category,
    this.caption,
    this.tags,
    required this.geohash5,
    this.lat,
    this.lon,
    required this.urls,
    required this.license,
    this.disposed,
    this.foundAt,
    this.safetyFlags,
    this.createdAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: SubmissionCategory.fromString(json['category'] as String),
      caption: json['caption'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      geohash5: json['geohash5'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      urls: json['urls'] as Map<String, dynamic>,
      license: LicenseType.fromString(json['license'] as String),
      disposed: json['disposed'] as bool?,
      foundAt: json['found_at'] != null
          ? DateTime.parse(json['found_at'] as String)
          : null,
      safetyFlags: json['safety_flags'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category.value,
      'caption': caption,
      'tags': tags,
      'geohash5': geohash5,
      'lat': lat,
      'lon': lon,
      'urls': urls,
      'license': license.value,
      'disposed': disposed,
      'found_at': foundAt?.toIso8601String(),
      'safety_flags': safetyFlags,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  SubmissionUrls get imageUrls => SubmissionUrls.fromJson(urls);

  Submission copyWith({
    String? id,
    String? userId,
    SubmissionCategory? category,
    String? caption,
    List<String>? tags,
    String? geohash5,
    double? lat,
    double? lon,
    Map<String, dynamic>? urls,
    LicenseType? license,
    bool? disposed,
    DateTime? foundAt,
    Map<String, dynamic>? safetyFlags,
    DateTime? createdAt,
  }) {
    return Submission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      geohash5: geohash5 ?? this.geohash5,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      urls: urls ?? this.urls,
      license: license ?? this.license,
      disposed: disposed ?? this.disposed,
      foundAt: foundAt ?? this.foundAt,
      safetyFlags: safetyFlags ?? this.safetyFlags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// URLs structure for submission images
class SubmissionUrls {
  final String? original;
  final String? blurred;
  final String? thumbnail;

  const SubmissionUrls({
    this.original,
    this.blurred,
    this.thumbnail,
  });

  factory SubmissionUrls.fromJson(Map<String, dynamic> json) {
    return SubmissionUrls(
      original: json['original'] as String?,
      blurred: json['blurred'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (original != null) 'original': original,
      if (blurred != null) 'blurred': blurred,
      if (thumbnail != null) 'thumbnail': thumbnail,
    };
  }

  String get displayUrl => blurred ?? original ?? '';
  bool get hasImages => original != null || blurred != null || thumbnail != null;
}

/// Trace model for the traces table
class Trace {
  final String id;
  final String submissionId;
  final TraceSurface surface;
  final TraceFreshness? freshness;
  final double? directionDeg;
  final TracePermanence? permanence;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Trace({
    required this.id,
    required this.submissionId,
    required this.surface,
    this.freshness,
    this.directionDeg,
    this.permanence,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Trace.fromJson(Map<String, dynamic> json) {
    return Trace(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String,
      surface: TraceSurface.fromString(json['surface'] as String),
      freshness: json['freshness'] != null
          ? TraceFreshness.fromString(json['freshness'] as String)
          : null,
      directionDeg: (json['direction_deg'] as num?)?.toDouble(),
      permanence: json['permanence'] != null
          ? TracePermanence.fromString(json['permanence'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submission_id': submissionId,
      'surface': surface.value,
      'freshness': freshness?.value,
      'direction_deg': directionDeg,
      'permanence': permanence?.value,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Trace copyWith({
    String? id,
    String? submissionId,
    TraceSurface? surface,
    TraceFreshness? freshness,
    double? directionDeg,
    TracePermanence? permanence,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trace(
      id: id ?? this.id,
      submissionId: submissionId ?? this.submissionId,
      surface: surface ?? this.surface,
      freshness: freshness ?? this.freshness,
      directionDeg: directionDeg ?? this.directionDeg,
      permanence: permanence ?? this.permanence,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Categories for submissions
enum SubmissionCategory {
  lost('lost', 'Lost', '🧤', 'Unintentionally left behind'),
  tossed('tossed', 'Tossed', '🗑️', 'Deliberately discarded'),
  posted('posted', 'Posted', '📋', 'Intended for display'),
  marked('marked', 'Marked', '🎨', 'Non-removable markings'),
  curious('curious', 'Curious', '🤔', 'Anything odd or unclassifiable'),
  traces('traces', 'Traces', '👣', 'Ephemeral marks of human presence');

  final String value;
  final String displayName;
  final String emoji;
  final String description;

  const SubmissionCategory(this.value, this.displayName, this.emoji, this.description);

  static SubmissionCategory fromString(String value) {
    return SubmissionCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => SubmissionCategory.curious,
    );
  }

  /// Micro-copy for each category
  String get microCopy {
    switch (this) {
      case SubmissionCategory.lost:
        return "A glove begins its solo adventure.";
      case SubmissionCategory.tossed:
        return "The snack that left only a clue.";
      case SubmissionCategory.posted:
        return "Poster's still here, but the event is long gone.";
      case SubmissionCategory.marked:
        return "Someone was here, and wanted you to know.";
      case SubmissionCategory.curious:
        return "What even is this? Let's document it anyway.";
      case SubmissionCategory.traces:
        return "Footprints in time, soon to fade away.";
    }
  }
}

/// License types
enum LicenseType {
  ccByNc('CC_BY_NC', 'CC BY-NC', 'Creative Commons Attribution-NonCommercial'),
  cc0('CC0', 'CC0', 'Creative Commons Zero (Public Domain)');

  final String value;
  final String displayName;
  final String description;

  const LicenseType(this.value, this.displayName, this.description);

  static LicenseType fromString(String value) {
    return LicenseType.values.firstWhere(
      (lic) => lic.value == value,
      orElse: () => LicenseType.ccByNc,
    );
  }
}

/// Trace surface types
enum TraceSurface {
  soil('soil', 'Soil', '🏞️'),
  snow('snow', 'Snow', '❄️'),
  pavement('pavement', 'Pavement', '🛣️'),
  glass('glass', 'Glass', '🪟'),
  metal('metal', 'Metal', '🔩'),
  wood('wood', 'Wood', '🪵'),
  grass('grass', 'Grass', '🌱'),
  other('other', 'Other', '❓');

  final String value;
  final String displayName;
  final String emoji;

  const TraceSurface(this.value, this.displayName, this.emoji);

  static TraceSurface fromString(String value) {
    return TraceSurface.values.firstWhere(
      (surface) => surface.value == value,
      orElse: () => TraceSurface.other,
    );
  }
}

/// Trace freshness
enum TraceFreshness {
  minutes('minutes', 'Minutes old', '⚡'),
  hours('hours', 'Hours old', '⏰'),
  days('days', 'Days old', '📅');

  final String value;
  final String displayName;
  final String emoji;

  const TraceFreshness(this.value, this.displayName, this.emoji);

  static TraceFreshness fromString(String value) {
    return TraceFreshness.values.firstWhere(
      (fresh) => fresh.value == value,
      orElse: () => TraceFreshness.hours,
    );
  }
}

/// Trace permanence
enum TracePermanence {
  ephemeral('ephemeral', 'Ephemeral', '💨'),
  seasonal('seasonal', 'Seasonal', '🍂'),
  semiPermanent('semi_permanent', 'Semi-permanent', '🏗️');

  final String value;
  final String displayName;
  final String emoji;

  const TracePermanence(this.value, this.displayName, this.emoji);

  static TracePermanence fromString(String value) {
    return TracePermanence.values.firstWhere(
      (perm) => perm.value == value,
      orElse: () => TracePermanence.ephemeral,
    );
  }
}

/// Create submission request
class CreateSubmissionRequest {
  final SubmissionCategory category;
  final String? caption;
  final List<String>? tags;
  final String geohash5;
  final double? lat;
  final double? lon;
  final LicenseType license;
  final DateTime? foundAt;
  final Map<String, dynamic>? urls;
  final Map<String, dynamic>? safetyFlags;

  // Trace-specific fields
  final TraceSurface? traceSurface;
  final TraceFreshness? traceFreshness;
  final double? traceDirectionDeg;
  final TracePermanence? tracePermanence;
  final String? traceNotes;

  const CreateSubmissionRequest({
    required this.category,
    this.caption,
    this.tags,
    required this.geohash5,
    this.lat,
    this.lon,
    required this.license,
    this.foundAt,
    this.urls,
    this.safetyFlags,
    this.traceSurface,
    this.traceFreshness,
    this.traceDirectionDeg,
    this.tracePermanence,
    this.traceNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.value,
      'caption': caption,
      'tags': tags,
      'geohash5': geohash5,
      'lat': lat,
      'lon': lon,
      'license': license.value,
      'found_at': foundAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'urls': urls ?? {},
      'safety_flags': safetyFlags ?? {},
      'disposed': false,
    };
  }

  Map<String, dynamic>? toTraceJson(String submissionId) {
    if (category != SubmissionCategory.traces || traceSurface == null) {
      return null;
    }

    return {
      'submission_id': submissionId,
      'surface': traceSurface!.value,
      'freshness': traceFreshness?.value,
      'direction_deg': traceDirectionDeg,
      'permanence': tracePermanence?.value,
      'notes': traceNotes,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Offline queue item for pending uploads
class OfflineQueueItem {
  final String id;
  final CreateSubmissionRequest request;
  final String? imagePath;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  const OfflineQueueItem({
    required this.id,
    required this.request,
    this.imagePath,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': request.toJson(),
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) {
    final requestJson = json['request'] as Map<String, dynamic>;
    return OfflineQueueItem(
      id: json['id'] as String,
      request: CreateSubmissionRequest(
        category: SubmissionCategory.fromString(requestJson['category'] as String),
        caption: requestJson['caption'] as String?,
        tags: (requestJson['tags'] as List<dynamic>?)?.cast<String>(),
        geohash5: requestJson['geohash5'] as String,
        lat: (requestJson['lat'] as num?)?.toDouble(),
        lon: (requestJson['lon'] as num?)?.toDouble(),
        license: LicenseType.fromString(requestJson['license'] as String),
        foundAt: requestJson['found_at'] != null
            ? DateTime.parse(requestJson['found_at'] as String)
            : null,
        urls: requestJson['urls'] as Map<String, dynamic>?,
        safetyFlags: requestJson['safety_flags'] as Map<String, dynamic>?,
      ),
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  OfflineQueueItem copyWith({
    String? id,
    CreateSubmissionRequest? request,
    String? imagePath,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
  }) {
    return OfflineQueueItem(
      id: id ?? this.id,
      request: request ?? this.request,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
