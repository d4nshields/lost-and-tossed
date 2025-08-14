import 'package:flutter/material.dart';

/// Lost & Tossed Cozy Theme - Accessible Community Field Guide Design
/// Adapted from CozyPuzzleTheme for playful, observational community mapping
class LostTossedCozyTheme {
  // ===============================
  // Color Palette - ACCESSIBILITY OPTIMIZED
  // ===============================
  
  // Backgrounds & Structure - Warm, inviting field guide aesthetic
  static const Color linenWhite = Color(0xFFF9F7F3);      // Primary background - like aged paper
  static const Color warmSand = Color(0xFFE8E2D9);        // Secondary background/cards - like notebook pages
  static const Color weatheredDriftwood = Color(0xFFB7AFA6); // Tertiary background - like found wood
  
  // Text Colors - ENHANCED FOR ACCESSIBILITY
  static const Color richCharcoal = Color(0xFF2B2A26);     // Primary text - like pencil marks
  static const Color slateGray = Color(0xFF383532);        // Secondary text - like faded ink
  static const Color pewter = Color(0xFF565656);           // Tertiary text - like weathered signs
  
  // Interactive Elements - Nature-inspired, community-focused
  static const Color goldenAmber = Color(0xFFC9A961);      // Primary buttons - like autumn leaves
  static const Color forestMist = Color(0xFF447253);       // Secondary buttons - like park benches (WCAG AA compliant)
  static const Color terracotta = Color(0xFFCC7A5C);       // Alerts - like brick walkways
  
  // Category Colors - Cozy adaptations of Lost & Tossed categories
  static const Map<String, Color> categoryColors = {
    'lost': Color(0xFF9B7EBF),      // Soft purple - "A glove begins its solo adventure"
    'tossed': Color(0xFF8B8B8B),    // Warm gray - "The snack that left only a clue"
    'posted': Color(0xFF447253),    // Forest mist - "Poster's still here, but the event is long gone"
    'marked': Color(0xFFD08B94),    // Rose dust - Like chalk on sidewalks
    'curious': Color(0xFFD4A574),   // Warm amber - For the unexplainable
    'traces': Color(0xFF8FABC7),    // Sky blue - Ephemeral like morning mist
  };
  
  // Legacy color names for backward compatibility with original theme
  @Deprecated('Use richCharcoal instead for better accessibility')
  static const Color deepSlate = richCharcoal;
  @Deprecated('Use slateGray instead for better accessibility')
  static const Color stoneGray = slateGray;
  @Deprecated('Use pewter instead for better accessibility')
  static const Color seaPebble = pewter;
  @Deprecated('Use goldenAmber instead for better accessibility')
  static const Color goldenSandbar = goldenAmber;
  @Deprecated('Use forestMist instead for better accessibility')
  static const Color seafoamMist = forestMist;
  @Deprecated('Use terracotta instead for better accessibility')
  static const Color coralBlush = terracotta;
  
  // ===============================
  // Category-Specific Helpers
  // ===============================
  
  /// Get category color with cozy adaptations
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? pewter;
  }
  
  /// Get category color with opacity for subtle backgrounds
  static Color getCategoryColorWithOpacity(String category, double opacity) {
    return getCategoryColor(category).withOpacity(opacity);
  }
  
  /// Get descriptive text for categories with cozy micro-copy
  static String getCategoryDescription(String category) {
    switch (category.toLowerCase()) {
      case 'lost':
        return "Unintentionally left behind, awaiting reunion";
      case 'tossed':
        return "Deliberately discarded, telling urban stories";
      case 'posted':
        return "Messages meant to be seen, conversations with strangers";
      case 'marked':
        return "Permanent expressions, voices on walls";
      case 'curious':
        return "The delightfully unexplainable";
      case 'traces':
        return "Ephemeral marks of human presence";
      default:
        return "Part of our shared landscape";
    }
  }
  
  // Individual category getters for convenience
  static Color get lostColor => categoryColors['lost']!;
  static Color get tossedColor => categoryColors['tossed']!;
  static Color get postedColor => categoryColors['posted']!;
  static Color get markedColor => categoryColors['marked']!;
  static Color get curiousColor => categoryColors['curious']!;
  static Color get tracesColor => categoryColors['traces']!;
  
  // ===============================
  // Text Styles - COMMUNITY FIELD GUIDE AESTHETIC
  // ===============================
  
  /// Large heading style - for discovery titles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: richCharcoal,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Medium heading style - for section titles  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: richCharcoal,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  /// Small heading style - for category labels
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: richCharcoal,
    letterSpacing: 0,
    height: 1.4,
  );
  
  /// Primary body text - for descriptions and observations
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: richCharcoal,
    height: 1.5,
    letterSpacing: 0.1,
  );
  
  /// Secondary body text - for metadata and details
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: slateGray,
    height: 1.5,
    letterSpacing: 0.1,
  );
  
  /// Small text - for timestamps and fine print
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: pewter,
    height: 1.4,
    letterSpacing: 0.2,
  );
  
  /// Label text - for form fields and captions
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: slateGray,
    letterSpacing: 0.1,
  );
  
  /// Small label text - for category tags
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: pewter,
    letterSpacing: 0.5,
  );
  
  /// Button text style
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  
  /// Playful micro-copy style for discoveries
  static const TextStyle microCopy = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: slateGray,
    height: 1.4,
    fontStyle: FontStyle.italic,
  );
  
  // ===============================
  // Button Styles - COMMUNITY-FRIENDLY
  // ===============================
  
  /// Primary button style - for main actions like "Document Discovery"
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: goldenAmber,
    foregroundColor: richCharcoal,
    elevation: 2,
    shadowColor: richCharcoal.withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: buttonText,
  );
  
  /// Secondary button style - for exploration actions
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: forestMist,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: richCharcoal.withOpacity(0.15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    textStyle: buttonText,
  );
  
  /// Alert/highlight button style - for important community actions
  static ButtonStyle get alertButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: terracotta,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: richCharcoal.withOpacity(0.15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    textStyle: buttonText,
  );
  
  /// Text button style - for subtle actions
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: slateGray,
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: slateGray,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  /// Outlined button style - for category selection
  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: richCharcoal,
    side: BorderSide(color: forestMist, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    textStyle: buttonText,
  );
  
  /// Category button style - for object category selection
  static ButtonStyle getCategoryButtonStyle(String category, {bool isSelected = false}) {
    final categoryColor = getCategoryColor(category);
    return ElevatedButton.styleFrom(
      backgroundColor: isSelected ? categoryColor : categoryColor.withOpacity(0.1),
      foregroundColor: isSelected ? Colors.white : categoryColor,
      elevation: isSelected ? 3 : 1,
      shadowColor: categoryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: buttonText.copyWith(fontSize: 14),
    );
  }
  
  // ===============================
  // Decorations & Shadows - FIELD GUIDE AESTHETIC
  // ===============================
  
  /// Primary card decoration - for discovery cards
  static BoxDecoration get primaryCardDecoration => BoxDecoration(
    color: warmSand,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: richCharcoal.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 1,
      ),
    ],
  );
  
  /// Secondary card decoration - for information panels
  static BoxDecoration get secondaryCardDecoration => BoxDecoration(
    color: weatheredDriftwood,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: richCharcoal.withOpacity(0.06),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ],
  );
  
  /// Category card decoration - themed for specific object types
  static BoxDecoration getCategoryCardDecoration(String category) => BoxDecoration(
    color: getCategoryColorWithOpacity(category, 0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: getCategoryColor(category).withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: getCategoryColor(category).withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  /// Modal/dialog decoration - for community interactions
  static BoxDecoration get modalDecoration => BoxDecoration(
    color: linenWhite,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: richCharcoal.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 2,
      ),
    ],
  );
  
  /// Image decoration - for discovery photos
  static BoxDecoration get imageDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: richCharcoal.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // ===============================
  // Material Theme Generation - LOST & TOSSED OPTIMIZED
  // ===============================
  
  /// Generate Material 3 ColorScheme for Lost & Tossed
  static ColorScheme get lightColorScheme => ColorScheme.light(
    // Core colors
    primary: goldenAmber,
    onPrimary: richCharcoal,
    primaryContainer: goldenAmber.withOpacity(0.2),
    onPrimaryContainer: richCharcoal,
    
    secondary: forestMist,
    onSecondary: Colors.white,
    secondaryContainer: forestMist.withOpacity(0.2),
    onSecondaryContainer: richCharcoal,
    
    tertiary: terracotta,
    onTertiary: Colors.white,
    tertiaryContainer: terracotta.withOpacity(0.2),
    onTertiaryContainer: richCharcoal,
    
    // Surface colors
    surface: linenWhite,
    onSurface: richCharcoal,
    surfaceVariant: warmSand,
    onSurfaceVariant: slateGray,
    
    // Background colors
    background: linenWhite,
    onBackground: richCharcoal,
    
    // Error colors
    error: terracotta,
    onError: Colors.white,
    
    // Other colors
    outline: weatheredDriftwood,
    outlineVariant: weatheredDriftwood.withOpacity(0.5),
    shadow: richCharcoal.withOpacity(0.15),
    scrim: richCharcoal.withOpacity(0.3),
    inverseSurface: richCharcoal,
    onInverseSurface: linenWhite,
    inversePrimary: goldenAmber.withOpacity(0.8),
  );
  
  /// Generate complete ThemeData for Lost & Tossed
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    fontFamily: 'Inter', // Keeping your existing font choice
    
    // Text theme
    textTheme: TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      headlineSmall: headingSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelSmall: labelSmall,
    ),
    
    // App bar theme - field guide aesthetic
    appBarTheme: AppBarTheme(
      backgroundColor: linenWhite,
      foregroundColor: richCharcoal,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headingMedium,
      iconTheme: IconThemeData(color: slateGray),
      surfaceTintColor: Colors.transparent,
    ),
    
    // Card theme - discovery cards
    cardTheme: CardThemeData(
      color: warmSand,
      shadowColor: richCharcoal.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    textButtonTheme: TextButtonThemeData(style: textButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
    
    // Input decoration theme - community forms
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: warmSand,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: weatheredDriftwood),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: weatheredDriftwood),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: forestMist, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: terracotta, width: 1),
      ),
      labelStyle: labelLarge,
      hintStyle: bodyMedium.copyWith(color: pewter),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    // Chip theme - for category tags
    chipTheme: ChipThemeData(
      backgroundColor: warmSand,
      selectedColor: goldenAmber.withOpacity(0.2),
      labelStyle: labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      side: BorderSide(color: weatheredDriftwood.withOpacity(0.5)),
    ),
    
    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: linenWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: headingMedium,
      contentTextStyle: bodyLarge,
    ),
    
    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: linenWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Scaffold background
    scaffoldBackgroundColor: linenWhite,
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: weatheredDriftwood.withOpacity(0.5),
      thickness: 1,
    ),
    
    // Icon theme
    iconTheme: IconThemeData(
      color: slateGray,
      size: 24,
    ),
    
    // Progress indicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: goldenAmber,
      linearTrackColor: weatheredDriftwood.withOpacity(0.3),
    ),
    
    // Floating action button theme - camera button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: terracotta,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      backgroundColor: linenWhite,
      selectedItemColor: goldenAmber,
      unselectedItemColor: pewter,
      selectedLabelStyle: labelSmall.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: labelSmall,
    ),
    
    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
  
  // ===============================
  // Utility Methods - COMMUNITY HELPERS
  // ===============================
  
  /// Get appropriate text color for any background
  static Color getTextColorForBackground(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.light ? richCharcoal : linenWhite;
  }
  
  /// Create a themed discovery card
  static Widget createDiscoveryCard({
    required Widget child,
    String? category,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: category != null 
          ? getCategoryCardDecoration(category)
          : primaryCardDecoration,
      child: child,
    );
  }
  
  /// Create a themed community button
  static Widget createCommunityButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isPrimary = true,
    bool isAlert = false,
    String? category,
  }) {
    ButtonStyle style;
    
    if (category != null) {
      style = getCategoryButtonStyle(category);
    } else if (isAlert) {
      style = alertButtonStyle;
    } else if (isPrimary) {
      style = primaryButtonStyle;
    } else {
      style = secondaryButtonStyle;
    }
    
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: style,
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Text(text),
      );
    }
  }
  
  /// Create a playful micro-copy text widget
  static Widget createMicroCopy(String text) {
    return Text(
      text,
      style: microCopy,
      textAlign: TextAlign.center,
    );
  }
  
  /// Create a category chip
  static Widget createCategoryChip({
    required String category,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final categoryColor = getCategoryColor(category);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? categoryColor 
              : categoryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          category.toUpperCase(),
          style: labelSmall.copyWith(
            color: isSelected ? Colors.white : categoryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  // ===============================
  // Spacing Constants
  // ===============================
  
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 48.0;
  
  // Border radius constants
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 24.0;
  
  // ===============================
  // ACCESSIBILITY VERIFICATION
  // ===============================
  
  /// Calculate WCAG contrast ratio between two colors
  static double _contrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Verify accessibility compliance for Lost & Tossed
  static Map<String, Map<String, dynamic>> get accessibilityReport {
    final primaryOnLinen = _contrastRatio(richCharcoal, linenWhite);
    final secondaryOnSand = _contrastRatio(slateGray, warmSand);
    final buttonTextOnAmber = _contrastRatio(richCharcoal, goldenAmber);
    final whiteOnForest = _contrastRatio(Colors.white, forestMist);
    
    return {
      'Primary Text on Linen White': {
        'contrast_ratio': '${primaryOnLinen.toStringAsFixed(1)}:1',
        'wcag_aa': primaryOnLinen >= 4.5,
        'wcag_aaa': primaryOnLinen >= 7.0,
      },
      'Secondary Text on Warm Sand': {
        'contrast_ratio': '${secondaryOnSand.toStringAsFixed(1)}:1',
        'wcag_aa': secondaryOnSand >= 4.5,
        'wcag_aaa': secondaryOnSand >= 7.0,
      },
      'Button Text on Golden Amber': {
        'contrast_ratio': '${buttonTextOnAmber.toStringAsFixed(1)}:1',
        'wcag_aa': buttonTextOnAmber >= 4.5,
        'wcag_aaa': buttonTextOnAmber >= 7.0,
      },
      'White Text on Forest Mist': {
        'contrast_ratio': '${whiteOnForest.toStringAsFixed(1)}:1',
        'wcag_aa': whiteOnForest >= 4.5,
        'wcag_aaa': whiteOnForest >= 7.0,
      },
    };
  }
}
