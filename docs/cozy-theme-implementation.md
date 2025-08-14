# Lost & Tossed Cozy Theme Implementation

## Overview

The Lost & Tossed app has been updated with a new **Cozy Theme** that provides a warm, accessible, and community-focused design aesthetic. This theme is specifically tailored for the playful, observational nature of documenting found objects and building community connections.

## Key Features

### 🎨 Color Palette
- **Warm, paper-like backgrounds**: Linen white (#F9F7F3) and warm sand (#E8E2D9) create a field guide aesthetic
- **Natural interaction colors**: Golden amber (#C9A961), forest mist (#7BA88A), and terracotta (#CC7A5C)
- **High-contrast text**: Rich charcoal (#2B2A26) ensures WCAG AA compliance
- **Category-specific colors**: Each object category has its own cozy color variant

### ♿ Accessibility
- **WCAG AA Compliant**: All color combinations meet 4.5:1 contrast ratio requirements
- **Built-in contrast checker**: Theme includes accessibility verification tools
- **Readable typography**: Optimized text styles with proper spacing and weights

### 🏗️ Architecture
- **Clean theme separation**: Located in `lib/presentation/theme/cozy_theme.dart`
- **Utility methods**: Helper functions for creating themed components
- **Category integration**: Seamless blend with Lost & Tossed's six object categories
- **Backward compatibility**: Maintains existing functionality while enhancing aesthetics

## Category Colors & Micro-copy

Each category has been given a thoughtful color and descriptive text:

| Category | Color | Description |
|----------|--------|-------------|
| **Lost** | Soft Purple (#9B7EBF) | "Unintentionally left behind, awaiting reunion" |
| **Tossed** | Warm Gray (#8B8B8B) | "Deliberately discarded, telling urban stories" |
| **Posted** | Forest Mist (#7BA88A) | "Messages meant to be seen, conversations with strangers" |
| **Marked** | Rose Dust (#D08B94) | "Permanent expressions, voices on walls" |
| **Curious** | Warm Amber (#D4A574) | "The delightfully unexplainable" |
| **Traces** | Sky Blue (#8FABC7) | "Ephemeral marks of human presence" |

## Usage Examples

### Basic Theme Application
```dart
// Apply theme to MaterialApp
MaterialApp(
  theme: LostTossedCozyTheme.lightTheme,
  // ... rest of app
)
```

### Utility Widgets
```dart
// Create themed discovery cards
LostTossedCozyTheme.createDiscoveryCard(
  category: 'lost', // Optional category theming
  child: YourContent(),
)

// Create community buttons
LostTossedCozyTheme.createCommunityButton(
  text: "Document Discovery",
  onPressed: () {},
  icon: Icons.camera_alt,
  isPrimary: true,
)

// Create playful micro-copy
LostTossedCozyTheme.createMicroCopy(
  "Every object has a story waiting to be told.",
)

// Create category chips
LostTossedCozyTheme.createCategoryChip(
  category: 'curious',
  isSelected: true,
  onTap: () {},
)
```

### Custom Styling
```dart
// Use theme colors
Container(
  color: LostTossedCozyTheme.warmSand,
  child: Text(
    'Themed text',
    style: LostTossedCozyTheme.bodyLarge,
  ),
)

// Get category-specific colors
final lostColor = LostTossedCozyTheme.getCategoryColor('lost');
final lostColorWithOpacity = LostTossedCozyTheme.getCategoryColorWithOpacity('lost', 0.3);
```

## Implementation Details

### Files Updated
1. **Theme Creation**: `lib/presentation/theme/cozy_theme.dart`
2. **Main App**: `lib/main.dart` - Updated to use new theme
3. **Screens Updated**:
   - `lib/features/items/presentation/home_screen.dart`
   - `lib/features/capture/presentation/capture_screen.dart`
   - `lib/features/profile/presentation/profile_screen.dart`
   - `lib/features/items/presentation/search_screen.dart`
   - `lib/shared/widgets/main_scaffold.dart`
   - `lib/shared/widgets/loading_screen.dart`

### Test Coverage
- **Theme tests**: `test/presentation/theme/cozy_theme_test.dart`
- **Accessibility verification**: Automated contrast ratio checking
- **Widget functionality**: Utility widget testing
- **Constants validation**: Spacing and radius verification

## Design Philosophy

The Cozy Theme embodies the Lost & Tossed mission:

1. **Curious & Kind**: Warm colors and playful micro-copy encourage exploration without judgment
2. **Community-Focused**: Shared color language creates cohesion across discoveries
3. **Observational**: Field guide aesthetic honors the documentary nature of the app
4. **Accessible**: High contrast ensures everyone can participate in the community

## Micro-copy Examples

The theme includes several examples of the app's playful, observational voice:

- *"A glove begins its solo adventure."* (Lost items)
- *"Poster's still here, but the event is long gone."* (Posted items)  
- *"The snack that left only a clue."* (Tossed items)
- *"Every object has a story waiting to be told."* (General encouragement)
- *"What curious thing caught your eye today?"* (Capture prompt)

## Future Enhancements

The theme architecture supports:
- **Dark mode**: Easy addition of dark variant
- **Seasonal themes**: Color palette variations
- **Personalization**: User-specific category color preferences
- **Accessibility improvements**: Dynamic text scaling, high contrast mode

## Migration Notes

The new theme maintains backward compatibility:
- All existing `AppTheme` references have been updated to `LostTossedCozyTheme`
- Spacing and sizing constants remain the same values
- Material 3 compliance is maintained
- Category color system integrates seamlessly with existing models

---

*The Cozy Theme transforms Lost & Tossed into a warm, welcoming space for community-driven urban exploration and discovery documentation.*
