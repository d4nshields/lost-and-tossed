import 'package:json_annotation/json_annotation.dart';
import 'item_category.dart';
import 'profile.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  final String id;
  @JsonKey(name: 'contributor_id')
  final String contributorId;
  final String title;
  final String? description;
  final ItemCategory category;
  final LicenseType license;
  final String geohash;
  @JsonKey(name: 'exact_lat')
  final double? exactLat;
  @JsonKey(name: 'exact_lng')
  final double? exactLng;
  @JsonKey(name: 'location_name')
  final String? locationName;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'image_thumbnail_url')
  final String? imageThumbnailUrl;
  @JsonKey(name: 'found_at')
  final DateTime? foundAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final ModerationStatus status;
  @JsonKey(name: 'moderator_notes')
  final String? moderatorNotes;

  // Expanded fields (from joins)
  final Profile? contributor;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'comment_count')
  final int? commentCount;
  @JsonKey(name: 'user_liked')
  final bool? userLiked;

  const Item({
    required this.id,
    required this.contributorId,
    required this.title,
    this.description,
    required this.category,
    required this.license,
    required this.geohash,
    this.exactLat,
    this.exactLng,
    this.locationName,
    this.imageUrl,
    this.imageThumbnailUrl,
    this.foundAt,
    this.createdAt,
    this.updatedAt,
    required this.status,
    this.moderatorNotes,
    this.contributor,
    this.likeCount,
    this.commentCount,
    this.userLiked,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  bool get hasImage => imageUrl?.isNotEmpty == true;
  bool get hasLocation => exactLat != null && exactLng != null;
  bool get isApproved => status == ModerationStatus.approved;
  
  String get effectiveImageUrl => imageThumbnailUrl ?? imageUrl ?? '';
  int get effectiveLikeCount => likeCount ?? 0;
  int get effectiveCommentCount => commentCount ?? 0;
  bool get effectiveUserLiked => userLiked ?? false;

  Item copyWith({
    String? id,
    String? contributorId,
    String? title,
    String? description,
    ItemCategory? category,
    LicenseType? license,
    String? geohash,
    double? exactLat,
    double? exactLng,
    String? locationName,
    String? imageUrl,
    String? imageThumbnailUrl,
    DateTime? foundAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ModerationStatus? status,
    String? moderatorNotes,
    Profile? contributor,
    int? likeCount,
    int? commentCount,
    bool? userLiked,
  }) {
    return Item(
      id: id ?? this.id,
      contributorId: contributorId ?? this.contributorId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      license: license ?? this.license,
      geohash: geohash ?? this.geohash,
      exactLat: exactLat ?? this.exactLat,
      exactLng: exactLng ?? this.exactLng,
      locationName: locationName ?? this.locationName,
      imageUrl: imageUrl ?? this.imageUrl,
      imageThumbnailUrl: imageThumbnailUrl ?? this.imageThumbnailUrl,
      foundAt: foundAt ?? this.foundAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      contributor: contributor ?? this.contributor,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      userLiked: userLiked ?? this.userLiked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Item(id: $id, title: $title, category: $category, status: $status)';
  }
}

/// Data class for creating new items
@JsonSerializable()
class CreateItemRequest {
  final String title;
  final String? description;
  final ItemCategory category;
  final LicenseType license;
  final String geohash;
  final double? exactLat;
  final double? exactLng;
  final String? locationName;
  final DateTime? foundAt;

  const CreateItemRequest({
    required this.title,
    this.description,
    required this.category,
    this.license = LicenseType.ccByNc,
    required this.geohash,
    this.exactLat,
    this.exactLng,
    this.locationName,
    this.foundAt,
  });

  factory CreateItemRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateItemRequestToJson(this);
}
