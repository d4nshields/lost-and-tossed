// Temporary simplified model without code generation for initial build
// This will be replaced with proper Freezed models after code generation works

enum LostItemCategory {
  lost,
  tossed,
  posted,
  marked,
  curious,
  traces,
}

enum LicenseType {
  ccByNc,
  cc0,
}

class LostItem {
  const LostItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.geohash,
    required this.createdAt,
    required this.createdBy,
    this.license = LicenseType.ccByNc,
    this.exactLocation,
    this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final LostItemCategory category;
  final String imageUrl;
  final String geohash;
  final DateTime createdAt;
  final String createdBy;
  final LicenseType license;
  final String? exactLocation;
  final Map<String, dynamic>? metadata;

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: LostItemCategory.values.byName(json['category']),
      imageUrl: json['imageUrl'],
      geohash: json['geohash'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      license: LicenseType.values.byName(json['license'] ?? 'ccByNc'),
      exactLocation: json['exactLocation'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name, // This returns lowercase name
      'imageUrl': imageUrl,
      'geohash': geohash,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'license': license.name,
      'exactLocation': exactLocation,
      'metadata': metadata,
    };
  }
}

extension LostItemCategoryExtension on LostItemCategory {
  String get displayName {
    switch (this) {
      case LostItemCategory.lost:
        return 'Lost';
      case LostItemCategory.tossed:
        return 'Tossed';
      case LostItemCategory.posted:
        return 'Posted';
      case LostItemCategory.marked:
        return 'Marked';
      case LostItemCategory.curious:
        return 'Curious';
      case LostItemCategory.traces:
        return 'Traces';
    }
  }

  String get description {
    switch (this) {
      case LostItemCategory.lost:
        return 'Unintentionally left behind';
      case LostItemCategory.tossed:
        return 'Deliberately discarded';
      case LostItemCategory.posted:
        return 'Intended for display';
      case LostItemCategory.marked:
        return 'Non-removable markings';
      case LostItemCategory.curious:
        return 'Odd or unclassifiable';
      case LostItemCategory.traces:
        return 'Ephemeral marks of human presence';
    }
  }

  String get playfulDescription {
    switch (this) {
      case LostItemCategory.lost:
        return 'A glove begins its solo adventure.';
      case LostItemCategory.tossed:
        return 'The snack that left only a clue.';
      case LostItemCategory.posted:
        return 'Poster\'s still here, but the event is long gone.';
      case LostItemCategory.marked:
        return 'Someone\'s creative mark on the world.';
      case LostItemCategory.curious:
        return 'What story does this tell?';
      case LostItemCategory.traces:
        return 'Footprints tell tales of who passed by.';
    }
  }
}
