/// Simple model classes without code generation for initial build

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
