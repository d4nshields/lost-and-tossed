/// Domain models for submissions matching the Supabase schema

/// Main submission model
class Submission {
  final String id;
  final String userId;
  final SubmissionCategory category;
  final String? caption;
  final List<String> tags;
  final LicenseType license;
  final bool disposed;
  final String geohash5;
  final double? lat;
  final double? lon;
  final DateTime? foundAt;
  final Map<String, dynamic> urls;
  final Map<String, dynamic>? safetyFlags;
  final DateTime? createdAt;

  const Submission({
    required this.id,
    required this.userId,
    required this.category,
    this.caption,
    this.tags = const [],
    this.license = LicenseType.ccByNc,
    this.disposed = false,
    required this.geohash5,
    this.lat,
    this.lon,
    this.foundAt,
    required this.urls,
    this.safetyFlags,
    this.createdAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: SubmissionCategory.fromString(json['category'] as String),
      caption: json['caption'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      license: LicenseType.fromString(json['license'] as String),
      disposed: json['disposed'] as bool? ?? false,
      geohash5: json['geohash5'] as String,
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
      foundAt: json['found_at'] != null 
          ? DateTime.parse(json['found_at'] as String)
          : null,
      urls: json['urls'] as Map<String, dynamic>,
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
      'license': license.value,
      'disposed': disposed,
      'geohash5': geohash5,
      'lat': lat,
      'lon': lon,
      'found_at': foundAt?.toIso8601String(),
      'urls': urls,
      'safety_flags': safetyFlags,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Trace details for trace category submissions
class TraceDetails {
  final String id;
  final String submissionId;
  final TraceSurface surface;
  final TraceFreshness? freshness;
  final double? directionDeg;
  final TracePermanence? permanence;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TraceDetails({
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

  factory TraceDetails.fromJson(Map<String, dynamic> json) {
    return TraceDetails(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String,
      surface: TraceSurface.fromString(json['surface'] as String),
      freshness: json['freshness'] != null 
          ? TraceFreshness.fromString(json['freshness'] as String)
          : null,
      directionDeg: json['direction_deg']?.toDouble(),
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
}

/// Tag model
class Tag {
  final String id;
  final String name;

  const Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Submission categories matching database enum
enum SubmissionCategory {
  lost('lost', 'Lost', '🧤', 'Unintentionally left behind'),
  tossed('tossed', 'Tossed', '🥤', 'Deliberately discarded'),
  posted('posted', 'Posted', '📋', 'Intended for display'),
  marked('marked', 'Marked', '✏️', 'Non-removable markings'),
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
}

/// License types matching database enum
enum LicenseType {
  ccByNc('CC_BY_NC', 'CC BY-NC', 'Others can share with attribution, non-commercial only'),
  cc0('CC0', 'CC0', 'Public domain - no rights reserved');

  final String value;
  final String displayName;
  final String description;

  const LicenseType(this.value, this.displayName, this.description);

  static LicenseType fromString(String value) {
    return LicenseType.values.firstWhere(
      (license) => license.value == value,
      orElse: () => LicenseType.ccByNc,
    );
  }
}

/// Trace surface types matching database enum
enum TraceSurface {
  soil('soil', 'Soil', '🏜️'),
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

/// Trace freshness enum
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

/// Trace permanence enum
enum TracePermanence {
  ephemeral('ephemeral', 'Ephemeral', '💨'),
  seasonal('seasonal', 'Seasonal', '🍂'),
  semiPermanent('semi_permanent', 'Semi-permanent', '🗿');

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

/// Draft submission for local storage
class SubmissionDraft {
  final String? imagePath;
  final SubmissionCategory? category;
  final String? caption;
  final List<String> selectedTags;
  final LicenseType license;
  final bool disposed;
  final TraceDetailsDraft? traceDetails;
  final DateTime lastModified;

  const SubmissionDraft({
    this.imagePath,
    this.category,
    this.caption,
    this.selectedTags = const [],
    this.license = LicenseType.ccByNc,
    this.disposed = false,
    this.traceDetails,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'category': category?.value,
      'caption': caption,
      'selectedTags': selectedTags,
      'license': license.value,
      'disposed': disposed,
      'traceDetails': traceDetails?.toJson(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory SubmissionDraft.fromJson(Map<String, dynamic> json) {
    return SubmissionDraft(
      imagePath: json['imagePath'] as String?,
      category: json['category'] != null 
          ? SubmissionCategory.fromString(json['category'] as String)
          : null,
      caption: json['caption'] as String?,
      selectedTags: (json['selectedTags'] as List<dynamic>?)?.cast<String>() ?? [],
      license: json['license'] != null
          ? LicenseType.fromString(json['license'] as String)
          : LicenseType.ccByNc,
      disposed: json['disposed'] as bool? ?? false,
      traceDetails: json['traceDetails'] != null
          ? TraceDetailsDraft.fromJson(json['traceDetails'] as Map<String, dynamic>)
          : null,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }
}

/// Draft trace details for local storage
class TraceDetailsDraft {
  final TraceSurface? surface;
  final TraceFreshness? freshness;
  final TracePermanence? permanence;
  final double? directionDeg;
  final String? notes;

  const TraceDetailsDraft({
    this.surface,
    this.freshness,
    this.permanence,
    this.directionDeg,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'surface': surface?.value,
      'freshness': freshness?.value,
      'permanence': permanence?.value,
      'directionDeg': directionDeg,
      'notes': notes,
    };
  }

  factory TraceDetailsDraft.fromJson(Map<String, dynamic> json) {
    return TraceDetailsDraft(
      surface: json['surface'] != null
          ? TraceSurface.fromString(json['surface'] as String)
          : null,
      freshness: json['freshness'] != null
          ? TraceFreshness.fromString(json['freshness'] as String)
          : null,
      permanence: json['permanence'] != null
          ? TracePermanence.fromString(json['permanence'] as String)
          : null,
      directionDeg: json['directionDeg']?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
}
