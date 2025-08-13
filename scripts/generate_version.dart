import 'dart:io';

/// Generate version numbers for Lost & Tossed releases
/// 
/// Version pattern: 0.1.0+YYMMDDHHMM 
/// Where YY = years since 2025, capped to stay under Android's 2.1B limit
void main(List<String> args) {
  final now = DateTime.now();
  
  // Years since 2025 (this gives us a reasonable starting point)
  final yearsSince2025 = now.year - 2025;
  if (yearsSince2025 < 0) {
    print('Error: Cannot generate version for year before 2025');
    exit(1);
  }
  
  // Format: YYMMDDHHMM (10 digits max)
  // This keeps us well under the 2.1B Android limit
  final versionCodeString = 
    '${yearsSince2025.toString().padLeft(2, '0')}'
    '${now.month.toString().padLeft(2, '0')}'
    '${now.day.toString().padLeft(2, '0')}'
    '${now.hour.toString().padLeft(2, '0')}'
    '${now.minute.toString().padLeft(2, '0')}';
  
  // Convert to integer (removes any leading zeros if present)
  final versionCode = int.parse(versionCodeString);
  
  // Sanity check - ensure we don't exceed Android's limit
  if (versionCode > 2100000000) {
    print('Error: Version code $versionCode exceeds Android limit of 2,100,000,000');
    exit(1);
  }
  
  final versionName = args.isNotEmpty ? args[0] : '0.1.0';
  
  // Output for use in scripts
  if (args.contains('--version-name-only')) {
    print(versionName);
  } else if (args.contains('--version-code-only')) {
    print(versionCode);
  } else if (args.contains('--full')) {
    print('$versionName+$versionCode');
  } else {
    // Default: output both separately for GitHub Actions
    print('VERSION_NAME=$versionName');
    print('VERSION_CODE=$versionCode');
  }
  
  // Debug info
  if (args.contains('--debug')) {
    print('Timestamp: ${now.toIso8601String()}');
    print('Years since 2025: $yearsSince2025');
    print('Version code breakdown: ${yearsSince2025.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    print('Version code as integer: $versionCode');
    print('Safe for Android: ${versionCode <= 2100000000}');
    print('Remaining headroom: ${2100000000 - versionCode} version codes');
  }
}
