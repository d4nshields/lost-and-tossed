import 'package:freezed_annotation/freezed_annotation.dart';

part 'lost_item.freezed.dart';
part 'lost_item.g.dart';

@freezed
class LostItem with _$LostItem {
  const factory LostItem({
    required String id,
    required String title,
    required String description,
    required LostItemCategory category,
    required String imageUrl,
    required String geohash,
    required DateTime createdAt,
    required String createdBy,
    @Default(LicenseType.ccByNc) LicenseType license,
    String? exactLocation, // Private field for contributor only
    Map<String, dynamic>? metadata,
  }) = _LostItem;

  factory LostItem.fromJson(Map<String, dynamic> json) => _$LostItemFromJson(json);
}

@freezed
class LostItemCategory with _$LostItemCategory {
  const factory LostItemCategory.lost() = _Lost;
  const factory LostItemCategory.tossed() = _Tossed;
  const factory LostItemCategory.posted() = _Posted;
  const factory LostItemCategory.marked() = _Marked;
  const factory LostItemCategory.curious() = _Curious;

  factory LostItemCategory.fromJson(Map<String, dynamic> json) => 
      _$LostItemCategoryFromJson(json);
}

enum LicenseType {
  @JsonValue('cc_by_nc')
  ccByNc,
  @JsonValue('cc0')
  cc0,
}

extension LostItemCategoryExtension on LostItemCategory {
  String get name => when(
    lost: () => 'Lost',
    tossed: () => 'Tossed',
    posted: () => 'Posted',
    marked: () => 'Marked',
    curious: () => 'Curious',
  );

  String get description => when(
    lost: () => 'Unintentionally left behind',
    tossed: () => 'Deliberately discarded',
    posted: () => 'Intended for display',
    marked: () => 'Non-removable markings',
    curious: () => 'Odd or unclassifiable',
  );

  String get playfulDescription => when(
    lost: () => 'A glove begins its solo adventure.',
    tossed: () => 'The snack that left only a clue.',
    posted: () => 'Poster\'s still here, but the event is long gone.',
    marked: () => 'Someone\'s creative mark on the world.',
    curious: () => 'What story does this tell?',
  );
}
