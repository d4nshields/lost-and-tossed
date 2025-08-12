/// Simple model classes without code generation for initial build

/// Simple Profile class
class Profile {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
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
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Simple Item class
class Item {
  final String id;
  final String title;
  final String? description;
  final ItemCategory category;
  final double? latitude;
  final double? longitude;
  final String? geohash;
  final String? imageUrl;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Item({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.latitude,
    this.longitude,
    this.geohash,
    this.imageUrl,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: ItemCategory.values.firstWhere(
        (c) => c.value == json['category'],
        orElse: () => ItemCategory.curious,
      ),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      geohash: json['geohash'] as String?,
      imageUrl: json['image_url'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.value,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'image_url': imageUrl,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Simple Comment class
class Comment {
  final String id;
  final String content;
  final String itemId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Comment({
    required this.id,
    required this.content,
    required this.itemId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      content: json['content'] as String,
      itemId: json['item_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'item_id': itemId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Simple create item request class
class CreateItemRequest {
  final String title;
  final String? description;
  final ItemCategory category;
  final double? latitude;
  final double? longitude;
  final String? geohash;
  final String? imageUrl;

  const CreateItemRequest({
    required this.title,
    this.description,
    required this.category,
    this.latitude,
    this.longitude,
    this.geohash,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.value,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'image_url': imageUrl,
    };
  }
}

/// Simple create comment request class
class CreateCommentRequest {
  final String content;
  final String itemId;

  const CreateCommentRequest({
    required this.content,
    required this.itemId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'item_id': itemId,
    };
  }
}

/// Categories for found objects
enum ItemCategory {
  lost,
  tossed,
  posted,
  marked,
  curious;

  String get value {
    switch (this) {
      case ItemCategory.lost:
        return 'lost';
      case ItemCategory.tossed:
        return 'tossed';
      case ItemCategory.posted:
        return 'posted';
      case ItemCategory.marked:
        return 'marked';
      case ItemCategory.curious:
        return 'curious';
    }
  }

  String get displayName {
    switch (this) {
      case ItemCategory.lost:
        return 'Lost';
      case ItemCategory.tossed:
        return 'Tossed';
      case ItemCategory.posted:
        return 'Posted';
      case ItemCategory.marked:
        return 'Marked';
      case ItemCategory.curious:
        return 'Curious';
    }
  }

  String get description {
    switch (this) {
      case ItemCategory.lost:
        return 'Unintentionally left behind';
      case ItemCategory.tossed:
        return 'Deliberately discarded';
      case ItemCategory.posted:
        return 'Intended for display';
      case ItemCategory.marked:
        return 'Non-removable markings';
      case ItemCategory.curious:
        return 'Anything else odd or unclassifiable';
    }
  }

  String get emoji {
    switch (this) {
      case ItemCategory.lost:
        return '🧤';
      case ItemCategory.tossed:
        return '🗑️';
      case ItemCategory.posted:
        return '📋';
      case ItemCategory.marked:
        return '🎨';
      case ItemCategory.curious:
        return '🤔';
    }
  }
}

/// License types for shared content
enum LicenseType {
  ccByNc,
  cc0;

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
