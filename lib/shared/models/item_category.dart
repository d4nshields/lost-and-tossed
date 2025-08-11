import 'package:json_annotation/json_annotation.dart';

part 'item_category.g.dart';

/// Categories for found objects
@JsonEnum(valueField: 'value')
enum ItemCategory {
  lost('lost'),
  tossed('tossed'),
  posted('posted'),
  marked('marked'),
  curious('curious');

  const ItemCategory(this.value);
  final String value;

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
@JsonEnum(valueField: 'value')
enum LicenseType {
  ccByNc('cc_by_nc'),
  cc0('cc0');

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

/// Moderation status for content
@JsonEnum(valueField: 'value')
enum ModerationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  flagged('flagged');

  const ModerationStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ModerationStatus.pending:
        return 'Pending Review';
      case ModerationStatus.approved:
        return 'Approved';
      case ModerationStatus.rejected:
        return 'Rejected';
      case ModerationStatus.flagged:
        return 'Flagged';
    }
  }

  bool get isVisible {
    return this == ModerationStatus.approved;
  }
}
